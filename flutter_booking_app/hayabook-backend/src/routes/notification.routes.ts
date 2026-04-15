import express from 'express';
import {
  getMyNotifications,
  getUnreadCount,
  markAllRead,
  markOneRead,
} from '../controllers/notification.controller';
import { authMiddleware } from '../middlewares/auth.middleware';

const router = express.Router();

// GET  /api/notifications              — list notifications (newest first)
router.get('/',             authMiddleware, getMyNotifications);

// GET  /api/notifications/unread-count — badge number
router.get('/unread-count', authMiddleware, getUnreadCount);

// PATCH /api/notifications/read-all   — mark everything read
router.patch('/read-all',   authMiddleware, markAllRead);

// PATCH /api/notifications/:id/read   — mark one read
router.patch('/:id/read',   authMiddleware, markOneRead);

export default router;
