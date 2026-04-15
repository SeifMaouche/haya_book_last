import { Request, Response } from 'express';
import { prisma } from '../lib/prisma';
import { io } from '../server';
import { createNotification } from './notification.controller';

interface AuthRequest extends Request {
  user?: { id: string; role: string };
}

const generateConversationId = (id1: string, id2: string) =>
  [id1, id2].sort().join('_');

// ─────────────────────────────────────────────────────────────────────
// SEND MESSAGE  (also emits real-time socket event + push notification)
// ─────────────────────────────────────────────────────────────────────
export const sendMessage = async (req: AuthRequest, res: Response) => {
  const { receiverId, content } = req.body;
  try {
    if (!req.user) return res.status(401).json({ message: 'Unauthorized' });
    if (!receiverId) return res.status(400).json({ message: 'receiverId is required' });

    const conversationId = generateConversationId(req.user.id, receiverId);

    const message = await (prisma.message as any).create({
      data: {
        senderId:       req.user.id,
        receiverId,
        conversationId,
        content,
      },
      include: {
        sender:   { select: { id: true, firstName: true, lastName: true, profileImage: true, role: true, providerProfile: { select: { businessName: true } } } },
        receiver: { select: { id: true, firstName: true, lastName: true, profileImage: true, role: true, providerProfile: { select: { businessName: true } } } },
      },
    });

    // 🔌 Emit to all clients in the conversation room (real-time delivery)
    io.to(conversationId).emit('new_message', message);

    // 🔔 Notify the receiver of a new message (non-blocking)
    const senderName = message.sender
      ? `${message.sender.firstName ?? ''} ${message.sender.lastName ?? ''}`.trim() || 'Someone'
      : 'Someone';
    await createNotification(
      receiverId,
      'NEW_MESSAGE',
      'New Message',
      `${senderName}: ${content.length > 60 ? content.slice(0, 60) + '…' : content}`,
      { conversationId, senderId: req.user.id },
    );

    res.status(201).json(message);
  } catch (error) {
    console.error('Send Message Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};

// ─────────────────────────────────────────────────────────────────────
// GET CONVERSATION HISTORY
// ─────────────────────────────────────────────────────────────────────
export const getConversation = async (req: AuthRequest, res: Response) => {
  const { secondUserId } = req.params;
  try {
    if (!req.user) return res.status(401).json({ message: 'Unauthorized' });

    const conversationId = generateConversationId(req.user.id, secondUserId as string);

    const messages = await (prisma.message as any).findMany({
      where: { conversationId },
      orderBy: { createdAt: 'asc' },
      include: {
        sender:   { select: { id: true, firstName: true, lastName: true, profileImage: true, role: true, providerProfile: { select: { businessName: true } } } },
        receiver: { select: { id: true, firstName: true, lastName: true, profileImage: true, role: true, providerProfile: { select: { businessName: true } } } },
      },
    });

    // Mark incoming messages as read
    await (prisma.message as any).updateMany({
      where: { conversationId, senderId: secondUserId as string, isRead: false },
      data: { isRead: true },
    });

    res.json(messages);
  } catch (error) {
    console.error('Get Conversation Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};

// ─────────────────────────────────────────────────────────────────────
// GET MY CONVERSATIONS  (list of latest message per conversation)
// Uses receiverId for reliable participant lookup — no string parsing
// ─────────────────────────────────────────────────────────────────────
export const getMyConversations = async (req: AuthRequest, res: Response) => {
  try {
    if (!req.user) return res.status(401).json({ message: 'Unauthorized' });

    // Find all messages where the current user is either sender OR receiver
    const messages = await (prisma.message as any).findMany({
      where: {
        OR: [
          { senderId:   req.user.id },
          { receiverId: req.user.id },
        ],
      },
      orderBy: { createdAt: 'desc' },
      include: {
        sender:   { select: { id: true, firstName: true, lastName: true, profileImage: true, role: true, providerProfile: { select: { businessName: true } } } },
        receiver: { select: { id: true, firstName: true, lastName: true, profileImage: true, role: true, providerProfile: { select: { businessName: true } } } },
      },
    });

    // One latest message per conversation
    const seen = new Map<string, any>();
    for (const msg of messages) {
      if (!seen.has(msg.conversationId)) seen.set(msg.conversationId, msg);
    }

    // Enrich with the "other user" (always reliable because we have receiverId/senderId)
    const enriched = Array.from(seen.values()).map((msg: any) => {
      const otherUser =
        msg.senderId === req.user!.id ? msg.receiver : msg.sender;
      return { ...msg, otherUser };
    });

    res.json(enriched);
  } catch (error) {
    console.error('Get My Conversations Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};
