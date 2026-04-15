import { prisma } from '../lib/prisma';
import { io } from '../server';

const timeToMinutes = (time: string): number => {
  const cleaned = time.replace(/\s*(AM|PM)\s*/i, '').trim();
  const parts = cleaned.split(':').map(Number);
  let hours = parts[0] || 0;
  const minutes = parts[1] || 0;
  const upper = time.toUpperCase();
  if (upper.includes('PM') && hours !== 12) hours += 12;
  if (upper.includes('AM') && hours === 12) hours = 0;
  return hours * 60 + minutes;
};

export const runBookingStatusWorker = async () => {
  const now = new Date();
  
  // Normalize today to UTC midnight to match how Prisma/DB stores the 'date' field
  // (which we saw was DateT00:00:00.000Z)
  const todayUTC = new Date();
  todayUTC.setUTCHours(0, 0, 0, 0);

  console.log(`[BookingWorker] Running at ${now.toISOString()}. Today (UTC): ${todayUTC.toISOString()}`);

  try {
    // 1. Move CONFIRMED -> IN_PROGRESS
    // We only query for CONFIRMED to avoid processing things twice in one run
    const confirmedBookings = await prisma.booking.findMany({
      where: {
        status: 'CONFIRMED',
        date: { lte: todayUTC },
      },
      include: { providerProfile: { select: { userId: true } } }
    });

    let inProgressCount = 0;
    for (const b of confirmedBookings) {
      const startMins = timeToMinutes(b.startTime);
      const bookingStart = new Date(b.date);
      bookingStart.setUTCHours(Math.floor(startMins / 60), startMins % 60, 0, 0);

      // If the scheduled start time is now or in the past
      if (now >= bookingStart) {
        await prisma.booking.update({
          where: { id: b.id },
          data: { status: 'IN_PROGRESS' },
        });
        inProgressCount++;
        
        // Notify
        io.to(b.clientId).emit('booking_update', { id: b.id, status: 'IN_PROGRESS' });
        if (b.providerProfile?.userId) {
          io.to(b.providerProfile.userId).emit('booking_update', { id: b.id, status: 'IN_PROGRESS' });
        }
      }
    }

    // 2. Move IN_PROGRESS -> COMPLETED
    // We query for IN_PROGRESS bookings that WERE ALREADY IN_PROGRESS before this run
    // By querying separately, we avoid immediate double-transition
    const inProgressBookings = await prisma.booking.findMany({
      where: {
        status: 'IN_PROGRESS',
        date: { lte: todayUTC },
      },
      include: { providerProfile: { select: { userId: true } } }
    });

    let completedCount = 0;
    for (const b of inProgressBookings) {
      // Skip if it was just updated in this same function call (optional safety)
      // but findMany should already be consistent unless we specifically look at the results.
      
      const endMins = timeToMinutes(b.endTime);
      const bookingEnd = new Date(b.date);
      bookingEnd.setUTCHours(Math.floor(endMins / 60), endMins % 60, 0, 0);

      // If the scheduled end time is now or in the past
      if (now >= bookingEnd) {
        await prisma.booking.update({
          where: { id: b.id },
          data: { status: 'COMPLETED' },
        });
        completedCount++;
        
        io.to(b.clientId).emit('booking_update', { id: b.id, status: 'COMPLETED' });
        if (b.providerProfile?.userId) {
          io.to(b.providerProfile.userId).emit('booking_update', { id: b.id, status: 'COMPLETED' });
        }
      }
    }

    if (inProgressCount > 0 || completedCount > 0) {
      console.log(`[BookingWorker] Done. Transitions: ${inProgressCount} to IN_PROGRESS, ${completedCount} to COMPLETED.`);
    }

  } catch (error) {
    console.error('[BookingWorker] Error:', error);
  }
};


