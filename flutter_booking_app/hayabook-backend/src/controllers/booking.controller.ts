import { Request, Response } from 'express';
import { prisma } from '../lib/prisma';
import { createNotification } from './notification.controller';
import { io } from '../server';

interface AuthRequest extends Request {
  user?: { id: string; role: string };
}

// Helper: strip AM/PM and convert to minutes — handles both "09:00" and "09:00 AM"
const timeToMinutes = (time: string): number => {
  if (!time) return 0;
  const cleaned = time.replace(/\s*(AM|PM)\s*/i, '').trim();
  const parts = cleaned.split(':').map(Number);
  let hours = parts[0] || 0;
  const minutes = parts[1] || 0;
  // Handle 12h format if AM/PM was present in original string
  const upper = time.toUpperCase();
  if (upper.includes('PM') && hours !== 12) hours += 12;
  if (upper.includes('AM') && hours === 12) hours = 0;
  return hours * 60 + minutes;
};

const minutesToTime = (totalMinutes: number): string => {
  const hours = Math.floor(totalMinutes / 60);
  const minutes = totalMinutes % 60;
  return `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}`;
};

// ─────────────────────────────────────────────────────────────────────
// CREATE BOOKING  (auto-confirm with overlap check)
// ─────────────────────────────────────────────────────────────────────
export const createBooking = async (req: AuthRequest, res: Response) => {
  const { providerProfileId, serviceId, serviceOptionId, date, startTime, notes } = req.body;
  try {
    if (!req.user) return res.status(401).json({ message: 'Unauthorized' });

    let duration = 0;
    let price = 0;

    if (serviceOptionId) {
      const option = await (prisma as any).serviceOption.findUnique({ where: { id: serviceOptionId } });
      if (!option) return res.status(404).json({ message: 'Service option not found' });
      duration = option.durationMinutes || 60;
      price = option.price || 0;
    } else {
      const service = await prisma.service.findUnique({ where: { id: serviceId } });
      if (!service) return res.status(404).json({ message: 'Service not found' });
      
      duration = service.durationMinutes || 60;
      price = service.price || 0;
    }

    const startMins = timeToMinutes(startTime);
    const endMins = startMins + duration;
    const endTime = minutesToTime(endMins);
    // Always store times in 24h format
    const normalizedStartTime = minutesToTime(startMins);

    const bookingDate = new Date(`${date}T00:00:00.000Z`);

    const isOverlap = await prisma.$transaction(async (tx) => {
      const existing = await tx.booking.findMany({
        where: { providerProfileId, date: { equals: bookingDate }, status: 'CONFIRMED' },
      });
      return existing.some((b) => {
        const extStart = timeToMinutes(b.startTime);
        const extEnd = timeToMinutes(b.endTime);
        return startMins < extEnd && endMins > extStart;
      });
    });

    if (isOverlap)
      return res.status(409).json({ message: 'Time slot is already booked. Please choose another time.' });

    const booking = await (prisma.booking as any).create({
      data: {
        clientId: req.user.id,
        providerProfileId,
        serviceId,
        serviceOptionId,
        date: bookingDate,
        startTime: normalizedStartTime,
        endTime,
        durationMinutes: duration,
        price,
        notes,
      },
      include: {
        providerProfile: {
          include: {
            user: { select: { firstName: true, lastName: true, profileImage: true } }
          }
        },
        service: true,
        serviceOption: true,
      },
    });

    // 🔔 Notify the provider of new booking
    const providerUserId = booking.providerProfile?.user
      ? undefined
      : (await prisma.providerProfile.findUnique({ where: { id: providerProfileId }, select: { userId: true } }))?.userId;
    const actualProviderUserId = booking.providerProfile?.userId || providerUserId;
    if (actualProviderUserId) {
      const clientName = await prisma.user.findUnique({
        where: { id: req.user!.id },
        select: { firstName: true, lastName: true },
      });
      const name = clientName ? `${clientName.firstName ?? ''} ${clientName.lastName ?? ''}`.trim() : 'A client';
      await createNotification(
        actualProviderUserId,
        'BOOKING_CONFIRMED',
        'New Booking Request',
        `${name} booked "${booking.service?.name ?? 'a service'}" on ${booking.startTime}.`,
        { bookingId: booking.id },
      );
    }
    // 🔔 Notify the client that their booking is confirmed
    await createNotification(
      req.user!.id,
      'BOOKING_CONFIRMED',
      'Booking Confirmed',
      `Your booking for "${booking.service?.name ?? 'a service'}" at ${booking.startTime} is confirmed.`,
      { bookingId: booking.id },
    );
    
    // 🔔 Notify the provider of new booking via Socket.io
    if (actualProviderUserId) {
      io.to(actualProviderUserId).emit('booking_update', { type: 'NEW_BOOKING', bookingId: booking.id });
    }
    // And notify the client
    io.to(req.user!.id).emit('booking_update', { type: 'BOOKING_CREATED', bookingId: booking.id });

    res.status(201).json(booking);
  } catch (error) {
    console.error('Create Booking Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};

// ─────────────────────────────────────────────────────────────────────
// GET AVAILABLE SLOTS
// ─────────────────────────────────────────────────────────────────────
export const getAvailableSlots = async (req: Request, res: Response) => {
  const { providerId, date } = req.query;
  try {
    if (!providerId || !date)
      return res.status(400).json({ message: 'providerId and date are required' });

    // Force UTC midnight for consistent lookup across timezones
    const bookingDate = new Date(`${String(date)}T00:00:00.000Z`);

    // Robust range lookup to catch "shifted" bookings from previous timezone bugs
    const startRange = new Date(bookingDate.getTime() - 12 * 60 * 60 * 1000);
    const endRange   = new Date(bookingDate.getTime() + 12 * 60 * 60 * 1000);
    
    const bookedSlots = await prisma.booking.findMany({
      where: {
        providerProfileId: String(providerId),
        date: { gte: startRange, lte: endRange },
        status: { in: ['CONFIRMED', 'PENDING', 'IN_PROGRESS', 'COMPLETED'] }, // Hide completed if they are the same day (rare but safe)
      },
      select: { startTime: true, endTime: true },
    });

    // We return the raw objects [{startTime, endTime}]; the mobile app's 
    // BookingProvider will handle the expansion into 30m chunks.
    res.json(bookedSlots);
  } catch (error) {
    console.error('Get Available Slots Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};

// ─────────────────────────────────────────────────────────────────────
// GET CLIENT BOOKINGS
// ─────────────────────────────────────────────────────────────────────
export const getClientBookings = async (req: AuthRequest, res: Response) => {
  try {
    if (!req.user) return res.status(401).json({ message: 'Unauthorized' });

    const bookings = await (prisma.booking as any).findMany({
      where: { clientId: req.user.id },
      include: {
        providerProfile: {
          include: { user: { select: { firstName: true, lastName: true, profileImage: true } } }
        },
        service: true,
        serviceOption: true,
      },
      orderBy: { date: 'desc' },
    });
    res.json(bookings);
  } catch (error) {
    console.error('Get Client Bookings Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};

// ─────────────────────────────────────────────────────────────────────
// GET PROVIDER BOOKINGS  (✅ now includes full client info for messaging)
// ─────────────────────────────────────────────────────────────────────
export const getProviderBookings = async (req: AuthRequest, res: Response) => {
  try {
    if (!req.user) return res.status(401).json({ message: 'Unauthorized' });

    const provider = await prisma.providerProfile.findUnique({ where: { userId: req.user.id } });
    if (!provider) return res.status(404).json({ message: 'Provider profile not found' });

    const bookings = await (prisma.booking as any).findMany({
      where: { providerProfileId: provider.id },
      include: {
        client: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            phone: true,
            email: true,
            profileImage: true,  // ✅ needed for provider → client avatar in messages
            bio: true,
          }
        },
        service: true,
        serviceOption: true,
      },
      orderBy: { date: 'desc' },
    });
    res.json(bookings);
  } catch (error) {
    console.error('Get Provider Bookings Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};

// ─────────────────────────────────────────────────────────────────────
// UPDATE BOOKING STATUS  (✅ with role-based guards)
// ─────────────────────────────────────────────────────────────────────
export const updateBookingStatus = async (req: AuthRequest, res: Response) => {
  const { id } = req.params;
  const { status } = req.body;
  try {
    if (!req.user) return res.status(401).json({ message: 'Unauthorized' });

    const bookingId = id as string;
    const booking = await prisma.booking.findUnique({
      where: { id: bookingId },
      include: { providerProfile: true },
    });

    if (!booking) return res.status(404).json({ message: 'Booking not found' });

    const isProvider = booking.providerProfile?.userId === req.user.id;
    const isClient = booking.clientId === req.user.id;
    if (!isProvider && !isClient) return res.status(403).json({ message: 'Access denied' });

    // ✅ Role-based status transition guards
    const clientOnlyStatuses = ['CANCELLED_BY_CLIENT'];
    const providerOnlyStatuses = ['CANCELLED_BY_PROVIDER', 'COMPLETED', 'NO_SHOW'];

    if (clientOnlyStatuses.includes(status) && !isClient) {
      return res.status(403).json({ message: 'Only the client can set this status' });
    }
    if (providerOnlyStatuses.includes(status) && !isProvider) {
      return res.status(403).json({ message: 'Only the provider can set this status' });
    }

    const updatedBooking = await prisma.booking.update({
      where: { id: bookingId },
      data: { status },
    });

    // 🔔 Notify the other party about the status change
    const notifMap: Record<string, { title: string; body: string; notifyId: string }> = {
      CANCELLED_BY_CLIENT:   { title: 'Booking Cancelled', body: 'The client has cancelled the booking.',   notifyId: booking.providerProfile.userId },
      CANCELLED_BY_PROVIDER: { title: 'Booking Cancelled', body: 'The provider has cancelled your booking.', notifyId: booking.clientId },
      COMPLETED:             { title: 'Session Completed', body: 'Your session is marked as completed. Leave a review!', notifyId: booking.clientId },
      NO_SHOW:               { title: 'Marked as No-Show', body: 'Your provider marked this appointment as no-show.', notifyId: booking.clientId },
    };
    const notif = notifMap[status];
    if (notif) {
      await createNotification(notif.notifyId, status, notif.title, notif.body, { bookingId });
    }

    // 🔔 Notify both parties of status change via Socket.io
    io.to(booking.clientId).emit('booking_update', { id: bookingId, status });
    io.to(booking.providerProfile.userId).emit('booking_update', { id: bookingId, status });

    res.json(updatedBooking);
  } catch (error) {
    console.error('Update Booking Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};

// ─────────────────────────────────────────────────────────────────────
// RESCHEDULE BOOKING  (new endpoint)
// ─────────────────────────────────────────────────────────────────────
export const rescheduleBooking = async (req: AuthRequest, res: Response) => {
  const { id } = req.params;
  const { date, startTime } = req.body;
  try {
    if (!req.user) return res.status(401).json({ message: 'Unauthorized' });

    const booking = await (prisma.booking as any).findUnique({
      where: { id: String(id) },
      include: { providerProfile: true, service: true },
    });
    if (!booking) return res.status(404).json({ message: 'Booking not found' });

    const isClient = booking.clientId === req.user.id;
    if (!isClient) return res.status(403).json({ message: 'Only the client can reschedule' });
    if (booking.status !== 'CONFIRMED') {
      return res.status(400).json({ message: 'Only confirmed bookings can be rescheduled' });
    }

    const startMins = timeToMinutes(startTime);
    const duration = booking.durationMinutes || 60;
    const endMins = startMins + duration;
    const endTime = minutesToTime(endMins);
    const normalizedStartTime = minutesToTime(startMins);

    // Force UTC midnight for reschedule to avoid timezone shifts
    const bookingDate = new Date(`${date}T00:00:00.000Z`);

    // Check overlap for new slot
    const existing = await prisma.booking.findMany({
      where: {
        providerProfileId: booking.providerProfileId,
        date: { equals: bookingDate },
        status: 'CONFIRMED',
        NOT: { id: booking.id },
      },
    });
    const hasOverlap = existing.some((b) => {
      const extStart = timeToMinutes(b.startTime);
      const extEnd = timeToMinutes(b.endTime);
      return startMins < extEnd && endMins > extStart;
    });
    if (hasOverlap) {
      return res.status(409).json({ message: 'This time slot is already taken.' });
    }

    const updated = await prisma.booking.update({
      where: { id: String(id) },
      data: { date: bookingDate, startTime: normalizedStartTime, endTime },
    });
    res.json(updated);
  } catch (error) {
    console.error('Reschedule Booking Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};
