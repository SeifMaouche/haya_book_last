import { Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import { prisma } from '../lib/prisma';
import { createNotification } from './notification.controller';

// ─────────────────────────────────────────────────────────────────────
// PLATFORM STATS
// ─────────────────────────────────────────────────────────────────────
export const getPlatformStats = async (req: Request, res: Response) => {
  try {
    const [userCount, providerCount, bookingCount, completedBookings] = await Promise.all([
      prisma.user.count(),
      prisma.providerProfile.count(),
      prisma.booking.count(),
      prisma.booking.findMany({ where: { status: 'COMPLETED' }, select: { price: true } }),
    ]);

    const totalRevenue = completedBookings.reduce((sum, b) => sum + b.price, 0);

    const providersByCategory = await (prisma.providerProfile as any).groupBy({
      by: ['category'],
      _count: { id: true },
    });

    const startOfDay = new Date(); startOfDay.setHours(0, 0, 0, 0);
    const endOfDay   = new Date(); endOfDay.setHours(23, 59, 59, 999);
    const todayBookings = await prisma.booking.count({
      where: { date: { gte: startOfDay, lte: endOfDay } },
    });

    res.json({
      totalUsers: userCount,
      totalProviders: providerCount,
      totalBookings: bookingCount,
      todayBookings,
      totalRevenue,
      categoryDistribution: providersByCategory.map((c: any) => ({
        category: c.category,
        count: c._count.id,
      })),
    });
  } catch (error) {
    console.error('Get Stats Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};

// ─────────────────────────────────────────────────────────────────────
// MONTHLY REVENUE STATS  (for admin revenue chart)
// ─────────────────────────────────────────────────────────────────────
export const getMonthlyRevenue = async (req: Request, res: Response) => {
  try {
    const bookings = await prisma.booking.findMany({
      where: { status: 'COMPLETED' },
      select: { price: true, date: true },
      orderBy: { date: 'asc' },
    });

    // Group by year-month
    const monthMap = new Map<string, number>();
    const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    for (const b of bookings) {
      const d = new Date(b.date);
      const key = `${monthNames[d.getMonth()]} ${d.getFullYear()}`;
      monthMap.set(key, (monthMap.get(key) ?? 0) + b.price);
    }

    const result = Array.from(monthMap.entries()).map(([month, revenue]) => ({ month, revenue }));
    res.json(result);
  } catch (error) {
    console.error('Monthly Revenue Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};

// ─────────────────────────────────────────────────────────────────────
// ALL USERS  (supports ?role=ADMIN filter for Admins page)
// ─────────────────────────────────────────────────────────────────────
export const getAllUsers = async (req: Request, res: Response) => {
  try {
    const { role } = req.query;
    const where: any = {};
    if (role) where.role = String(role).toUpperCase();

    const users = await prisma.user.findMany({
      where,
      orderBy: { createdAt: 'desc' },
      select: {
        id: true, email: true, phone: true,
        firstName: true, lastName: true,
        role: true, isActive: true, isVerified: true, createdAt: true,
        profileImage: true,
        _count: { select: { clientBookings: true } },
      },
    });
    res.json(users);
  } catch (error) {
    console.error('Get All Users Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};

// ─────────────────────────────────────────────────────────────────────
// TOGGLE USER STATUS
// ─────────────────────────────────────────────────────────────────────
export const toggleUserStatus = async (req: Request, res: Response) => {
  const { id } = req.params;
  const { isActive } = req.body;
  try {
    const user = await prisma.user.update({
      where: { id: id as string },
      data: { isActive },
    });
    res.json({ message: `User ${isActive ? 'activated' : 'deactivated'} successfully`, user });
  } catch (error) {
    console.error('Toggle User Status Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};


// ─────────────────────────────────────────────────────────────────────
// CREATE ADMIN USER  (only existing admins can call this)
// ✅ FIX B6
// ─────────────────────────────────────────────────────────────────────
export const createAdminUser = async (req: Request, res: Response) => {
  const { email, password, firstName, lastName } = req.body;
  try {
    if (!email || !password) {
      return res.status(400).json({ message: 'Email and password are required' });
    }

    const existing = await prisma.user.findUnique({ where: { email } });
    if (existing) {
      return res.status(400).json({ message: 'A user with this email already exists' });
    }

    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(password, salt);

    const admin = await prisma.user.create({
      data: {
        email,
        passwordHash,
        firstName: firstName || null,
        lastName:  lastName  || null,
        role: 'ADMIN',
        isVerified: true,
        isActive: true,
      },
    });

    const { passwordHash: _, ...adminWithoutPassword } = admin;
    res.status(201).json({ message: 'Admin created successfully', user: adminWithoutPassword });
  } catch (error) {
    console.error('Create Admin Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};

// ─────────────────────────────────────────────────────────────────────
// ALL BOOKINGS
// ─────────────────────────────────────────────────────────────────────
export const getGlobalBookings = async (req: Request, res: Response) => {
  try {
    const bookings = await prisma.booking.findMany({
      include: {
        client:          { select: { firstName: true, lastName: true, email: true, profileImage: true } },
        providerProfile: { select: { businessName: true } },
        service:         { select: { name: true } },
      },
      orderBy: { date: 'desc' },
    });
    res.json(bookings);
  } catch (error) {
    console.error('Global Bookings Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};

// ─────────────────────────────────────────────────────────────────────
// ADMIN CANCEL BOOKING
// ─────────────────────────────────────────────────────────────────────
export const adminUpdateBookingStatus = async (req: Request, res: Response) => {
  const { id } = req.params;
  const { status } = req.body;
  try {
    const booking = await prisma.booking.update({
      where: { id: String(id) },
      data: { status },
    });
    res.json(booking);
  } catch (error) {
    console.error('Admin Update Booking Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};

// ─────────────────────────────────────────────────────────────────────
// ALL PROVIDERS  (admin view — includes all statuses)
// ─────────────────────────────────────────────────────────────────────
export const getAdminProviders = async (req: Request, res: Response) => {
  try {
    const providers = await prisma.providerProfile.findMany({
      include: {
        user: { select: { firstName: true, lastName: true, email: true, phone: true, profileImage: true } },
        _count: { select: { bookings: true, services: true } },
      },
      orderBy: { createdAt: 'desc' },
    });
    res.json(providers);
  } catch (error) {
    console.error('Get Admin Providers Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};

// ─────────────────────────────────────────────────────────────────────
// ALL REVIEWS  (admin view)
// ─────────────────────────────────────────────────────────────────────
export const getAdminReviews = async (req: Request, res: Response) => {
  try {
    const reviews = await prisma.review.findMany({
      include: {
        client:          { select: { firstName: true, lastName: true } },
        providerProfile: { select: { businessName: true } },
      },
      orderBy: { createdAt: 'desc' },
    });
    res.json(reviews);
  } catch (error) {
    console.error('Get Admin Reviews Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};

// ─────────────────────────────────────────────────────────────────────
// DELETE REVIEW
// ─────────────────────────────────────────────────────────────────────
export const deleteReview = async (req: Request, res: Response) => {
  const { id } = req.params;
  try {
    const review = await prisma.review.findUnique({ where: { id: String(id) } });
    if (!review) return res.status(404).json({ message: 'Review not found' });

    await prisma.review.delete({ where: { id: String(id) } });

    // Recalculate provider rating
    const remaining = await prisma.review.findMany({
      where: { providerProfileId: review.providerProfileId },
      select: { rating: true },
    });
    const count = remaining.length;
    const avg = count > 0 ? remaining.reduce((s, r) => s + r.rating, 0) / count : 0;
    await prisma.providerProfile.update({
      where: { id: review.providerProfileId },
      data: { rating: avg, reviewCount: count },
    });

    res.json({ message: 'Review deleted' });
  } catch (error) {
    console.error('Delete Review Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};

// ─────────────────────────────────────────────────────────────────────
// RECENT CONVERSATIONS  (admin overview)
// ─────────────────────────────────────────────────────────────────────
export const getAdminMessages = async (req: Request, res: Response) => {
  try {
    const messages = await prisma.message.findMany({
      orderBy: { createdAt: 'desc' },
      include: {
        sender:   { select: { firstName: true, lastName: true, profileImage: true, providerProfile: { select: { businessName: true } } } },
        receiver: { select: { firstName: true, lastName: true, profileImage: true, providerProfile: { select: { businessName: true } } } },
      },
      take: 100,
    });

    const seen = new Map<string, typeof messages[number]>();
    for (const msg of messages) {
      if (!seen.has(msg.conversationId)) seen.set(msg.conversationId, msg);
    }

    res.json(Array.from(seen.values()));
  } catch (error) {
    console.error('Get Admin Messages Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};

// ─────────────────────────────────────────────────────────────────────
// GET USER DETAILS (for admin deep dive)
// ─────────────────────────────────────────────────────────────────────
export const getUserDetails = async (req: Request, res: Response) => {
  const { id } = req.params;
  try {
    const user = await prisma.user.findUnique({
      where: { id: String(id) },
      include: {
        providerProfile: {
          include: {
            _count: { select: { services: true, bookings: true, reviewsReceived: true } },
          }
        },
        _count: { select: { clientBookings: true, reviewsGiven: true, notifications: true } },
      },
    });

    if (!user) return res.status(404).json({ message: 'User not found' });

    // Calculate basic revenue stats
    const [spent, earned] = await Promise.all([
      prisma.booking.aggregate({ where: { clientId: id, status: 'COMPLETED' }, _sum: { price: true } }),
      user.providerProfile 
        ? prisma.booking.aggregate({ where: { providerProfileId: user.providerProfile.id, status: 'COMPLETED' }, _sum: { price: true } })
        : Promise.resolve({ _sum: { price: 0 } }),
    ]);

    const { passwordHash: _, ...safeUser } = user;
    res.json({
      ...safeUser,
      stats: {
        totalSpent: spent._sum.price || 0,
        totalEarned: earned._sum.price || 0,
      }
    });
  } catch (error) {
    console.error('Get User Details Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};

// ─────────────────────────────────────────────────────────────────────
// SUSPEND USER
// ─────────────────────────────────────────────────────────────────────
export const suspendUser = async (req: Request, res: Response) => {
  const { id } = req.params;
  const { isSuspended, suspensionReason } = req.body;
  try {
    const user = await prisma.user.update({
      where: { id: String(id) },
      data: { 
        isSuspended, 
        suspensionReason: isSuspended ? suspensionReason : null,
        isActive: !isSuspended 
      },
    });
    res.json({ message: `User ${isSuspended ? 'suspended' : 'activated'} successfully`, user });
  } catch (error) {
    console.error('Suspend User Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};

// ─────────────────────────────────────────────────────────────────────
// SOFT DELETE USER
// ─────────────────────────────────────────────────────────────────────
export const softDeleteUser = async (req: Request, res: Response) => {
  const { id } = req.params;
  try {
    const user = await prisma.user.findUnique({ where: { id: String(id) } });
    if (!user) return res.status(404).json({ message: 'User not found' });

    // Anonymize sensitive fields
    await prisma.user.update({
      where: { id: String(id) },
      data: {
        firstName: 'Deleted',
        lastName: 'User',
        email: `deleted_${user.id}@hayabook.com`,
        phone: null,
        isActive: false,
        deletedAt: new Date(),
      },
    });

    res.json({ message: 'User deleted and anonymized successfully.' });
  } catch (error) {
    console.error('Soft Delete User Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};

// ─────────────────────────────────────────────────────────────────────
// FULL CONVERSATION DETAIL (for admin thread oversight)
// ─────────────────────────────────────────────────────────────────────
export const getAdminConversationMessages = async (req: Request, res: Response) => {
  const { id } = req.params; // conversationId
  try {
    const messages = await prisma.message.findMany({
      where: { conversationId: String(id) },
      orderBy: { createdAt: 'asc' },
      include: {
        sender: { select: { firstName: true, lastName: true, profileImage: true, role: true } },
      },
    });

    res.json(messages);
  } catch (error) {
    console.error('Get Admin Conversation Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};

// ─────────────────────────────────────────────────────────────────────
// SUPPORT MESSAGES (Contact Us)
// ─────────────────────────────────────────────────────────────────────
export const getSupportMessages = async (req: Request, res: Response) => {
  try {
    const messages = await prisma.supportMessage.findMany({
      include: {
        user: { select: { firstName: true, lastName: true, email: true, phone: true, profileImage: true, role: true } },
      },
      orderBy: { createdAt: 'desc' },
    });
    res.json(messages);
  } catch (error) {
    console.error('Get Support Messages Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};

export const replyToSupportMessage = async (req: Request, res: Response) => {
  const { id } = req.params;
  const { reply } = req.body;
  try {
    const supportMsg = await prisma.supportMessage.update({
      where: { id: String(id) },
      data: { 
        reply,
        status: 'RESOLVED' 
      },
      include: { user: true }
    });

    // Send notification to user
    if (supportMsg.userId) {
      await createNotification(
        supportMsg.userId,
        'SUPPORT_REPLY',
        'Support Reply',
        `Re: ${supportMsg.subject} - ${reply.substring(0, 60)}${reply.length > 60 ? '...' : ''}`,
        JSON.stringify({ supportId: supportMsg.id })
      );
    }

    res.json({ message: 'Reply sent successfully', supportMsg });
  } catch (error) {
    console.error('Reply Support Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};
// ─────────────────────────────────────────────────────────────────────
// SOFT DELETE PROVIDER
// ─────────────────────────────────────────────────────────────────────
export const softDeleteProvider = async (req: Request, res: Response) => {
  const { id } = req.params; // providerProfileId
  try {
    const profile = await prisma.providerProfile.findUnique({
      where: { id: String(id) },
      select: { userId: true }
    });

    if (!profile) return res.status(404).json({ message: 'Provider profile not found' });

    const user = await prisma.user.findUnique({ where: { id: profile.userId } });
    if (!user) return res.status(404).json({ message: 'User not found' });

    // Anonymize sensitive fields + Mark Inactive
    await prisma.user.update({
      where: { id: user.id },
      data: {
        firstName: 'Deleted',
        lastName: 'Provider',
        email: `deleted_provider_${user.id}@hayabook.com`,
        phone: null,
        isActive: false,
        deletedAt: new Date(),
      },
    });

    res.json({ message: 'Provider profile deleted and associated user anonymized successfully.' });
  } catch (error) {
    console.error('Soft Delete Provider Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};
