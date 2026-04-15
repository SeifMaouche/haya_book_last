"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getProviderReviews = exports.createReview = void 0;
const client_1 = require("@prisma/client");
const prisma = new client_1.PrismaClient();
const createReview = async (req, res) => {
    const { bookingId, rating, comment } = req.body;
    try {
        if (!req.user) {
            return res.status(401).json({ message: 'Unauthorized' });
        }
        // 1. Fetch the booking and verify it's COMPLETED and owned by the client
        const booking = await prisma.booking.findUnique({
            where: { id: bookingId },
            include: { providerProfile: true },
        });
        if (!booking || booking.clientId !== req.user.id) {
            return res.status(403).json({ message: 'Access denied' });
        }
        if (booking.status !== 'COMPLETED') {
            return res.status(400).json({ message: 'Reviews can only be left for COMPLETED bookings' });
        }
        // Check if review already exists
        const existingReview = await prisma.review.findUnique({
            where: { bookingId },
        });
        if (existingReview) {
            return res.status(400).json({ message: 'Review already exists for this booking' });
        }
        // 2. Use a transaction to create the review and update provider rating
        const result = await prisma.$transaction(async (tx) => {
            const review = await tx.review.create({
                data: {
                    bookingId,
                    clientId: req.user.id,
                    providerProfileId: booking.providerProfileId,
                    rating,
                    comment,
                },
            });
            // Recalculate average rating for the provider
            const allReviews = await tx.review.findMany({
                where: { providerProfileId: booking.providerProfileId },
                select: { rating: true },
            });
            const reviewCount = allReviews.length;
            const totalRating = allReviews.reduce((sum, r) => sum + r.rating, 0);
            const averageRating = totalRating / reviewCount;
            await tx.providerProfile.update({
                where: { id: booking.providerProfileId },
                data: {
                    rating: averageRating,
                    reviewCount: reviewCount,
                },
            });
            return review;
        });
        res.status(201).json(result);
    }
    catch (error) {
        console.error('Create Review Error:', error);
        res.status(500).json({ message: 'Internal Server Error' });
    }
};
exports.createReview = createReview;
const getProviderReviews = async (req, res) => {
    const { providerId } = req.params;
    const targetProviderId = providerId;
    try {
        const reviews = await prisma.review.findMany({
            where: { providerProfileId: targetProviderId },
            include: {
                client: {
                    select: { firstName: true, lastName: true, profileImage: true },
                },
            },
            orderBy: { createdAt: 'desc' },
        });
        res.json(reviews);
    }
    catch (error) {
        console.error('Get Provider Reviews Error:', error);
        res.status(500).json({ message: 'Internal Server Error' });
    }
};
exports.getProviderReviews = getProviderReviews;
