import express from 'express';
import { createReview, getProviderReviews } from '../controllers/review.controller';
import { authMiddleware } from '../middlewares/auth.middleware';

const router = express.Router();

// @route   POST /api/reviews
// @desc    Add a review for a completed service
// @access  Private (Client only)
router.post('/', authMiddleware, createReview);

// @route   GET /api/reviews/provider/:providerId
// @desc    Get all reviews for a specific provider business
// @access  Public (Used for listing profile)
router.get('/provider/:providerId', getProviderReviews);

export default router;
