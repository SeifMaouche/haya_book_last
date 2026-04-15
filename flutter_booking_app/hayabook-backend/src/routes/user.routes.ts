import express from 'express';
import { getMe, updateMe } from '../controllers/user.controller';
import { authMiddleware } from '../middlewares/auth.middleware';

const router = express.Router();

// @route   GET /api/users/me
// @desc    Get current user profile
// @access  Private
router.get('/me', authMiddleware, getMe);

// @route   PATCH /api/users/me
// @desc    Update current user profile
// @access  Private
router.patch('/me', authMiddleware, updateMe);

export default router;
