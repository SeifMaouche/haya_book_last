import { Request, Response } from 'express';
import { prisma } from '../lib/prisma';

interface AuthRequest extends Request {
  user?: { id: string; role: string };
}

export const createReview = async (req: AuthRequest, res: Response) => {
  const { providerProfileId, bookingId, rating, comment } = req.body;
  try {
    if (!req.user) return res.status(401).json({ message: 'Unauthorized' });

    let finalBookingId = bookingId;
    let finalProviderId = providerProfileId;

    if (!finalBookingId && finalProviderId) {
      // 1. Check if user already has A review for this provider (to allow editing)
      const existingReview = await prisma.review.findFirst({
        where: { clientId: req.user.id, providerProfileId: finalProviderId }
      });

      if (existingReview) {
        finalBookingId = existingReview.bookingId;
      } else {
        // 2. Find a completed booking for this user/provider that DOES NOT have a review yet
        const booking = await prisma.booking.findFirst({
          where: { 
            clientId: req.user.id, 
            providerProfileId: finalProviderId, 
            status: 'COMPLETED',
            review: null 
          },
          orderBy: { createdAt: 'desc' }
        });

        if (!booking) {
          return res.status(400).json({ 
            message: 'You must have a completed appointment with this provider to leave a review.' 
          });
        }
        finalBookingId = booking.id;
      }
    } else if (finalBookingId) {
      const booking = await prisma.booking.findUnique({ where: { id: finalBookingId } });
      if (!booking || booking.clientId !== req.user.id) return res.status(403).json({ message: 'Access denied' });
      // We allow reviewing even if not COMPLETED for some cases? No, let's stick to COMPLETED.
      if (booking.status !== 'COMPLETED') return res.status(400).json({ message: 'Reviews can only be left for COMPLETED bookings' });
      finalProviderId = booking.providerProfileId;
    } else {
      return res.status(400).json({ message: 'Missing providerProfileId or bookingId' });
    }

    const existingReview = await prisma.review.findUnique({ where: { bookingId: finalBookingId } });

    const result = await prisma.$transaction(async (tx) => {
      let review;
      if (existingReview) {
        review = await tx.review.update({
          where: { bookingId: finalBookingId },
          data: { rating, comment },
        });
      } else {
        review = await tx.review.create({
          data: {
            bookingId: finalBookingId,
            clientId: req.user!.id,
            providerProfileId: finalProviderId,
            rating,
            comment,
          },
        });
      }

      const allReviews = await tx.review.findMany({
        where: { providerProfileId: finalProviderId },
        select: { rating: true },
      });
      const reviewCount = allReviews.length;
      const averageRating = reviewCount === 0 ? 0 : allReviews.reduce((sum, r) => sum + r.rating, 0) / reviewCount;

      await tx.providerProfile.update({
        where: { id: finalProviderId },
        data: { rating: averageRating, reviewCount },
      });

      return review;
    });

    res.status(existingReview ? 200 : 201).json(result);
  } catch (error) {
    console.error('Create Review Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};

// ✅ Returns reviews with clientId field so Flutter can map it correctly
export const getProviderReviews = async (req: Request, res: Response) => {
  const { providerId } = req.params;
  try {
    const reviews = await prisma.review.findMany({
      where: { providerProfileId: String(providerId) },
      include: {
        client: {
          select: { id: true, firstName: true, lastName: true, profileImage: true },
        },
      },
      orderBy: { createdAt: 'desc' },
    });

    // Shape the response to match what Flutter expects
    const shaped = reviews.map((r) => ({
      ...r,
      clientId: r.clientId,           // explicit
      userId: r.clientId,             // Flutter compatibility alias
      userName: `${r.client.firstName ?? ''} ${r.client.lastName ?? ''}`.trim(),
      userImage: r.client.profileImage ?? '',
    }));

    res.json(shaped);
  } catch (error) {
    console.error('Get Provider Reviews Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};
