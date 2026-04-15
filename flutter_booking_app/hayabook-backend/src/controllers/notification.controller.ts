// src/controllers/notification.controller.ts
import { Request, Response } from 'express';
import { prisma } from '../lib/prisma';
import { io } from '../server';

// ─────────────────────────────────────────────────────────────────────
// GET /api/notifications — list the current user's notifications
// ─────────────────────────────────────────────────────────────────────
export const getMyNotifications = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user.id;
    const notifications = await prisma.notification.findMany({
      where:   { userId },
      orderBy: { createdAt: 'desc' },
      take:    50,
    });
    res.json(notifications);
  } catch (error) {
    console.error('Get Notifications Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};

// ─────────────────────────────────────────────────────────────────────
// GET /api/notifications/unread-count
// ─────────────────────────────────────────────────────────────────────
export const getUnreadCount = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user.id;
    const count = await prisma.notification.count({
      where: { userId, isRead: false },
    });
    res.json({ count });
  } catch (error) {
    console.error('Unread Count Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};

// ─────────────────────────────────────────────────────────────────────
// PATCH /api/notifications/read-all — mark all as read
// ─────────────────────────────────────────────────────────────────────
export const markAllRead = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user.id;
    await prisma.notification.updateMany({
      where: { userId, isRead: false },
      data:  { isRead: true },
    });
    res.json({ message: 'All notifications marked as read' });
  } catch (error) {
    console.error('Mark All Read Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};

// ─────────────────────────────────────────────────────────────────────
// PATCH /api/notifications/:id/read — mark one as read
// ─────────────────────────────────────────────────────────────────────
export const markOneRead = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user.id;
    const { id }  = req.params;
    await prisma.notification.updateMany({
      where: { id: String(id), userId },
      data:  { isRead: true },
    });
    res.json({ message: 'Notification marked as read' });
  } catch (error) {
    console.error('Mark One Read Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};

// ─────────────────────────────────────────────────────────────────────
// Helper — called internally from other controllers to push notifications
// ─────────────────────────────────────────────────────────────────────
export const createNotification = async (
  userId:  string,
  type:    string,
  title:   string,
  body:    string,
  data?:   object,
) => {
  try {
    await prisma.notification.create({
      data: {
        userId,
        type,
        title,
        body,
        data: data ? JSON.stringify(data) : null,
      },
    });

    // 🔔 Emit real-time notification to the user's room
    io.to(userId).emit('notification_received', {
      type,
      title,
      body,
      data: data ? JSON.stringify(data) : null,
      createdAt: new Date().toISOString(),
    });
  } catch (error) {
    // Non-fatal — notifications must never block the main flow
    console.error('[Notification] Create Error:', error);
  }
};
