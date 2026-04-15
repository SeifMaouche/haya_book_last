import express from 'express';
import {
  getPlatformStats,
  getMonthlyRevenue,
  getAllUsers,
  toggleUserStatus,
  getGlobalBookings,
  adminUpdateBookingStatus,
  getAdminProviders,
  getAdminReviews,
  deleteReview,
  getAdminMessages,
  createAdminUser,
  getUserDetails,
  suspendUser,
  softDeleteUser,
  softDeleteProvider,
  getAdminConversationMessages,
  getSupportMessages,
  replyToSupportMessage,
} from '../controllers/admin.controller';
import { getAllCategories, createCategory, deleteCategory, updateCategory } from '../controllers/category.controller';
import { authMiddleware } from '../middlewares/auth.middleware';
import { adminMiddleware } from '../middlewares/admin.middleware';

const router = express.Router();

// Apply auth + admin guards to ALL routes in this module
router.use(authMiddleware);
router.use(adminMiddleware);

// ── Stats ────────────────────────────────────────────────────────────
router.get('/stats',         getPlatformStats);
router.get('/stats/revenue', getMonthlyRevenue);

// ── Users (includes ?role=ADMIN for Admins page) ─────────────────────
router.get('/users',              getAllUsers);
router.get('/users/:id',          getUserDetails);
router.patch('/users/:id/status', toggleUserStatus);
router.patch('/users/:id/suspend', suspendUser);
router.delete('/users/:id',        softDeleteUser);

// ── Admins — ✅ FIX B6: Create new admin account (admin-only) ─────────
router.post('/create-admin', createAdminUser);

// ── Providers ────────────────────────────────────────────────────────
router.get('/providers',              getAdminProviders);
router.delete('/providers/:id',        softDeleteProvider);

// ── Bookings ─────────────────────────────────────────────────────────
router.get('/bookings',              getGlobalBookings);
router.patch('/bookings/:id/status', adminUpdateBookingStatus);

// ── Reviews ──────────────────────────────────────────────────────────
router.get('/reviews',        getAdminReviews);
router.delete('/reviews/:id', deleteReview);

// ── Messages ─────────────────────────────────────────────────────────
router.get('/messages',                 getAdminMessages);
router.get('/messages/conversation/:id', getAdminConversationMessages);

// ── Support Messages ────────────────────────────────────────────────
router.get('/support',            getSupportMessages);
router.post('/support/:id/reply', replyToSupportMessage);

// ── Categories ───────────────────────────────────────────────────────
router.get('/categories',         getAllCategories);
router.post('/categories',        createCategory);
router.patch('/categories/:id',   updateCategory);
router.delete('/categories/:id',  deleteCategory);

export default router;
