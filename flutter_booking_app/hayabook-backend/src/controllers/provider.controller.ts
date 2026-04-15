import { Request, Response } from 'express';
import { prisma } from '../lib/prisma';
import jwt from 'jsonwebtoken';

interface AuthRequest extends Request {
  user?: { id: string; role: string };
}

// ─────────────────────────────────────────────────────────────────────
// BECOME PROVIDER
// ─────────────────────────────────────────────────────────────────────
export const becomeProvider = async (req: AuthRequest, res: Response) => {
  const { businessName, category, description, address, latitude, longitude } = req.body;
  try {
    if (!req.user) return res.status(401).json({ message: 'Unauthorized' });

    // ✅ ENFORCE STRICT ROLES: User must already be a PROVIDER from registration
    if (req.user.role !== 'PROVIDER') {
      return res.status(403).json({ 
        message: 'Strict Role Policy: Only authorized providers can initialize a profile. Please register as a provider instead.' 
      });
    }

    const existingProfile = await prisma.providerProfile.findUnique({
      where: { userId: req.user.id },
    });
    if (existingProfile) return res.status(400).json({ message: 'User already has a provider profile' });

    const profile = await prisma.providerProfile.create({
      data: { userId: req.user.id, businessName, category, description, address, latitude, longitude, verificationStatus: 'APPROVED' },
    });

    res.status(201).json({ profile });
  } catch (error) {
    console.error('Become Provider Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};

// ─────────────────────────────────────────────────────────────────────
// GET OWN PROVIDER PROFILE
// ─────────────────────────────────────────────────────────────────────
export const getProviderProfile = async (req: AuthRequest, res: Response) => {
  try {
    if (!req.user) return res.status(401).json({ message: 'Unauthorized' });

    const profile = await prisma.providerProfile.findUnique({
      where: { userId: req.user.id },
      include: {
        services:  true,
        portfolio: true,
        user: { select: { id: true, firstName: true, lastName: true, bio: true, profileImage: true, phone: true, email: true } },
        reviewsReceived: { include: { client: { select: { firstName: true, lastName: true, profileImage: true } } } },
        _count: { select: { reviewsReceived: true } },
      },
    });
    if (!profile) return res.status(404).json({ message: 'Provider profile not found' });
    
    // Alias availability string to workingHours object
    const workingHours = profile.availability ? JSON.parse(profile.availability) : [];
    res.json({ ...profile, workingHours });
  } catch (error) {
    console.error('Get Provider Profile Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};

// ─────────────────────────────────────────────────────────────────────
// GET SINGLE PROVIDER BY ID  (public — for client provider detail screen)
// ─────────────────────────────────────────────────────────────────────
export const getProviderById = async (req: Request, res: Response) => {
  const { id } = req.params;
  try {
    // Try to find by providerProfile.id first, then by userId
    let profile = await prisma.providerProfile.findUnique({
      where: { id: String(id) },
      include: {
        services:  true,
        portfolio: true,
        user: { select: { id: true, firstName: true, lastName: true, bio: true, profileImage: true, phone: true, email: true } },
        reviewsReceived: { include: { client: { select: { firstName: true, lastName: true, profileImage: true } } } },
        _count: { select: { reviewsReceived: true } },
      },
    });

    if (!profile) {
      // Fallback: find by userId (if the Flutter app stored the userId as the provider reference)
      profile = await prisma.providerProfile.findUnique({
        where: { userId: String(id) },
        include: {
          services:  true,
          portfolio: true,
          user: { select: { id: true, firstName: true, lastName: true, bio: true, profileImage: true, phone: true, email: true } },
          reviewsReceived: { include: { client: { select: { firstName: true, lastName: true, profileImage: true } } } },
          _count: { select: { reviewsReceived: true } },
        },
      });
    }

    if (!profile) return res.status(404).json({ message: 'Provider not found' });
    
    // Alias availability string to workingHours object
    const workingHours = profile.availability ? JSON.parse(profile.availability) : [];
    res.json({ ...profile, workingHours });
  } catch (error) {
    console.error('Get Provider By ID Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};

// ─────────────────────────────────────────────────────────────────────
// UPDATE OWN PROVIDER PROFILE
// ─────────────────────────────────────────────────────────────────────
export const updateProviderProfile = async (req: AuthRequest, res: Response) => {
  if (!req.body) {
    return res.status(400).json({ message: 'Request body is missing' });
  }

  const {
    businessName, category, description, address,
    latitude, longitude, bio, firstName, lastName
  } = req.body;

  try {
    if (!req.user) return res.status(401).json({ message: 'Unauthorized' });

    // Handle profile image upload or removal
    let profileImageUrl: string | undefined;
    if (req.file) {
      profileImageUrl = `/uploads/${req.file.filename}`;
    } else if (req.body.removePhoto === 'true') {
      profileImageUrl = 'default';
    }

    const result = await prisma.$transaction(async (tx) => {
      // 1. Update Provider Profile (Robust Upsert)
      const profileData = {
        businessName,
        category,
        description: description || bio,
        address,
        latitude:  latitude  ? parseFloat(String(latitude))  : undefined,
        longitude: longitude ? parseFloat(String(longitude)) : undefined,
      };

      const profile = await tx.providerProfile.upsert({
        where: { userId: req.user!.id },
        update: profileData,
        create: {
          ...profileData,
          userId: req.user!.id,
          verificationStatus: 'APPROVED',
        },
        include: {
          services:  true,
          portfolio: true,
          user: { select: { id: true, firstName: true, lastName: true, bio: true, profileImage: true, phone: true, email: true } }
        },
      });

      // 2. Update User Profile — only include profileImage when a file was actually uploaded
      // ✅ FIX B3: Never overwrite firstName with businessName — use personal name fields only
      const userUpdateData: Record<string, any> = {
        bio: bio || description,
        ...(firstName !== undefined && firstName !== null && firstName !== '' && { firstName }),
        ...(lastName  !== undefined && lastName  !== null                    && { lastName }),
      };
      if (profileImageUrl) {
        userUpdateData.profileImage = profileImageUrl;
      }
      await tx.user.update({
        where: { id: req.user!.id },
        data: userUpdateData,
      });

      return profile;
    });

    res.json(result);
  } catch (error) {
    console.error('Update Provider Profile Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};

// ─────────────────────────────────────────────────────────────────────
// HAVERSINE DISTANCE (km) between two lat/lng points
// ─────────────────────────────────────────────────────────────────────
function haversineKm(lat1: number, lng1: number, lat2: number, lng2: number): number {
  const R = 6371;
  const dLat = ((lat2 - lat1) * Math.PI) / 180;
  const dLng = ((lng2 - lng1) * Math.PI) / 180;
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos((lat1 * Math.PI) / 180) *
      Math.cos((lat2 * Math.PI) / 180) *
      Math.sin(dLng / 2) ** 2;
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

// ─────────────────────────────────────────────────────────────────────
// GET ALL PROVIDERS (public listing for client browse)
// Supports: category, minRating, maxPrice, sortBy, lat, lng, maxDistanceKm
// NOTE: city/address filtering removed — use GPS lat/lng for distance filtering
// ─────────────────────────────────────────────────────────────────────
export const getAllProviders = async (req: Request, res: Response) => {
  const { category, minRating, maxPrice, sortBy, lat, lng, maxDistanceKm } = req.query;
  try {
    const where: any = { verificationStatus: 'APPROVED' };

    // Case-insensitive category filter
    if (category && category !== 'All') {
      where.category = { equals: String(category), mode: 'insensitive' };
    }

    // Minimum rating filter
    if (minRating) {
      where.rating = { gte: parseFloat(String(minRating)) };
    }

    // Determine DB-level ordering (distance is post-fetch)
    let orderBy: any = { createdAt: 'desc' };
    if (sortBy === 'rating')     orderBy = { rating: 'desc' };
    if (sortBy === 'most_booked') orderBy = { _count: { bookings: 'desc' } };
    // price_asc / distance handled in-memory below after fetch

    const providers = await prisma.providerProfile.findMany({
      where,
      orderBy,
      include: {
        user:      { select: { id: true, firstName: true, lastName: true, profileImage: true, bio: true } },
        services:  true,
        portfolio: true,
        reviewsReceived: { include: { client: { select: { firstName: true, lastName: true, profileImage: true } } } },
        _count:    { select: { reviewsReceived: true, bookings: true } },
      },
    });

    // Build formatted list with computed fields
    let formatted = providers.map(p => {
      // Compute the minimum service price for this provider (0 if no services)
      const minServicePrice =
        p.services.length > 0
          ? Math.min(...p.services.map(s => s.price))
          : 0;

      // Compute distance from client's GPS position (if provided)
      let distanceKm: number | null = null;
      if (lat && lng && p.latitude != null && p.longitude != null) {
        distanceKm = haversineKm(
          parseFloat(String(lat)),
          parseFloat(String(lng)),
          p.latitude,
          p.longitude
        );
      }

      return {
        ...p,
        workingHours:    p.availability ? JSON.parse(p.availability) : [],
        minServicePrice,
        distanceKm,
      };
    });

    // Filter by maxPrice (applies to minServicePrice)
    if (maxPrice) {
      const maxP = parseFloat(String(maxPrice));
      formatted = formatted.filter(p => p.minServicePrice <= maxP || p.minServicePrice === 0);
    }

    // Filter by maxDistanceKm (only when GPS coords provided)
    if (maxDistanceKm && lat && lng) {
      const maxD = parseFloat(String(maxDistanceKm));
      formatted = formatted.filter(p => p.distanceKm == null || p.distanceKm <= maxD);
    }

    // Sort by price ascending (in-memory)
    if (sortBy === 'price_asc') {
      formatted.sort((a, b) => a.minServicePrice - b.minServicePrice);
    }

    // Sort by distance ascending (in-memory, only when GPS provided)
    if (sortBy === 'distance' && lat && lng) {
      formatted.sort((a, b) => {
        if (a.distanceKm == null) return 1;
        if (b.distanceKm == null) return -1;
        return a.distanceKm - b.distanceKm;
      });
    }

    res.json(formatted);
  } catch (error) {
    console.error('Get All Providers Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};

// ─────────────────────────────────────────────────────────────────────
// GET PROVIDER STATS  (for provider home dashboard)
// ─────────────────────────────────────────────────────────────────────
export const getProviderStats = async (req: AuthRequest, res: Response) => {
  try {
    if (!req.user) return res.status(401).json({ message: 'Unauthorized' });

    const profile = await prisma.providerProfile.findUnique({
      where: { userId: req.user.id },
    });
    
    if (!profile) {
      return res.json({
        todayBookings: 0,
        totalEarnings: 0,
        rating:        0.0,
        totalReviews:  0,
        earningsChangePercent: 0,
        todayChange:   0,
        totalBookings: 0,
      });
    }

    const now = new Date();
    const startOfDay = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 0, 0, 0, 0);
    const endOfDay   = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 23, 59, 59, 999);
    
    // Yesterday
    const startOfYesterday = new Date(startOfDay);
    startOfYesterday.setDate(startOfYesterday.getDate() - 1);
    const endOfYesterday = new Date(endOfDay);
    endOfYesterday.setDate(endOfYesterday.getDate() - 1);

    // This month vs last month for earnings
    const startOfThisMonth = new Date(now.getFullYear(), now.getMonth(), 1);
    const startOfLastMonth = new Date(now.getFullYear(), now.getMonth() - 1, 1);
    const endOfLastMonth = new Date(now.getFullYear(), now.getMonth(), 0, 23, 59, 59, 999);

    const [todayBookings, yesterdayBookings, completedBookings, thisMonthEarningsBooks, lastMonthEarningsBooks] = await Promise.all([
      prisma.booking.count({
        where: { providerProfileId: profile.id, date: { gte: startOfDay, lte: endOfDay }, status: { in: ['CONFIRMED', 'COMPLETED'] } },
      }),
      prisma.booking.count({
        where: { providerProfileId: profile.id, date: { gte: startOfYesterday, lte: endOfYesterday }, status: { in: ['CONFIRMED', 'COMPLETED'] } },
      }),
      prisma.booking.findMany({
        where: { providerProfileId: profile.id, status: 'COMPLETED' },
        select: { price: true },
      }),
      prisma.booking.findMany({
        where: { providerProfileId: profile.id, status: 'COMPLETED', createdAt: { gte: startOfThisMonth } },
        select: { price: true },
      }),
      prisma.booking.findMany({
        where: { providerProfileId: profile.id, status: 'COMPLETED', createdAt: { gte: startOfLastMonth, lte: endOfLastMonth } },
        select: { price: true },
      })
    ]);

    const totalEarnings = completedBookings.reduce((sum, b) => sum + (b.price || 0), 0);
    const thisMonthEarnings = thisMonthEarningsBooks.reduce((sum, b) => sum + (b.price || 0), 0);
    const lastMonthEarnings = lastMonthEarningsBooks.reduce((sum, b) => sum + (b.price || 0), 0);

    let earningsChangePercent = 0;
    if (lastMonthEarnings > 0) {
      earningsChangePercent = Math.round(((thisMonthEarnings - lastMonthEarnings) / lastMonthEarnings) * 100);
    } else if (thisMonthEarnings > 0) {
      earningsChangePercent = 100;
    }

    const todayChange = todayBookings - yesterdayBookings;

    res.json({
      todayBookings,
      totalEarnings,
      rating: profile.rating || 0,
      totalReviews: profile.reviewCount || 0,
      earningsChangePercent,
      todayChange,
      totalBookings: completedBookings.length,
    });
  } catch (error) {
    console.error('Get Provider Stats Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};

// ─────────────────────────────────────────────────────────────────────
// GET AVAILABILITY
// ─────────────────────────────────────────────────────────────────────
export const getAvailability = async (req: AuthRequest, res: Response) => {
  try {
    if (!req.user) return res.status(401).json({ message: 'Unauthorized' });

    const profile = await prisma.providerProfile.findUnique({
      where: { userId: req.user.id },
      select: { availability: true },
    });
    if (!profile) return res.status(404).json({ message: 'Provider profile not found' });

    const schedule = profile.availability ? JSON.parse(profile.availability) : null;
    res.json({ schedule });
  } catch (error) {
    console.error('Get Availability Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};

// ─────────────────────────────────────────────────────────────────────
// SAVE AVAILABILITY
// ─────────────────────────────────────────────────────────────────────
export const saveAvailability = async (req: AuthRequest, res: Response) => {
  const { schedule } = req.body;
  try {
    if (!req.user) return res.status(401).json({ message: 'Unauthorized' });
    if (!Array.isArray(schedule)) return res.status(400).json({ message: 'schedule must be an array' });

    await prisma.providerProfile.update({
      where: { userId: req.user.id },
      data: { availability: JSON.stringify(schedule) },
    });
    res.json({ message: 'Availability saved successfully' });
  } catch (error) {
    console.error('Save Availability Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};

// ─────────────────────────────────────────────────────────────────────
// UPLOAD PORTFOLIO IMAGES
// ─────────────────────────────────────────────────────────────────────
export const uploadPortfolioImages = async (req: AuthRequest, res: Response) => {
  try {
    if (!req.user) return res.status(401).json({ message: 'Unauthorized' });

    const profile = await prisma.providerProfile.findUnique({
      where: { userId: req.user.id },
    });
    if (!profile) return res.status(404).json({ message: 'Provider profile not found' });

    const files = (req.files as Express.Multer.File[]) ?? [];
    if (!files.length) return res.status(400).json({ message: 'No files uploaded' });

    const protocol = req.protocol;
    const host = req.get('host');

    const created = await prisma.$transaction(
      files.map((file) =>
        prisma.portfolioImage.create({
          data: {
            providerProfileId: profile.id,
            url: `/uploads/${file.filename}`,
          },
        })
      )
    );

    res.status(201).json(created);
  } catch (error) {
    console.error('Upload Portfolio Images Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};

// ─────────────────────────────────────────────────────────────────────
// DELETE PORTFOLIO IMAGE
// ─────────────────────────────────────────────────────────────────────
export const deletePortfolioImage = async (req: AuthRequest, res: Response) => {
  const { imageId } = req.params;
  try {
    if (!req.user) return res.status(401).json({ message: 'Unauthorized' });

    const profile = await prisma.providerProfile.findUnique({
      where: { userId: req.user.id },
    });
    if (!profile) return res.status(404).json({ message: 'Provider profile not found' });

    await prisma.portfolioImage.deleteMany({
      where: { id: String(imageId), providerProfileId: profile.id },
    });

    res.json({ message: 'Portfolio image deleted' });
  } catch (error) {
    console.error('Delete Portfolio Image Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};
