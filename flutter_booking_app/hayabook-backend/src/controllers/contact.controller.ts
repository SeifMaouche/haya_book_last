import { Response } from 'express';
import { prisma } from '../lib/prisma';

// ── POST /api/contact ─────────────────────────────────────────────────
// Receives support requests from authenticated users and saves them
// to the database for admin review.
export const submitContactMessage = async (req: any, res: Response) => {
  const { subject, message } = req.body;
  const userId = req.user?.id;

  if (!subject || !message) {
    return res.status(400).json({ message: 'Subject and message are required' });
  }

  if (!userId) {
    return res.status(401).json({ message: 'You must be logged in to contact support.' });
  }

  try {
    const entry = await prisma.supportMessage.create({
      data: {
        userId,
        subject:     subject.trim(),
        message:     message.trim(),
        status:      'OPEN',
      },
    });

    console.log('[Support] New message saved to DB:', entry.id);

    // TODO: Send email notification to admin group if needed

    res.status(201).json({ 
      message: 'Message received. Our team will get back to you via notifications within 24 hours.',
      ticketId: entry.id
    });
  } catch (error) {
    console.error('[Support] Error saving message:', error);
    res.status(500).json({ message: 'Failed to submit support request. Please try again later.' });
  }
};

// ── GET /api/contact/my-messages ──────────────────────────────────────
// Returns the support tickets sent by the logged-in user
export const getMyMessages = async (req: any, res: Response) => {
  const userId = req.user?.id;

  if (!userId) {
    return res.status(401).json({ message: 'Unauthorized' });
  }

  try {
    const messages = await prisma.supportMessage.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
    });

    res.json(messages);
  } catch (error) {
    console.error('[Support] Error fetching user messages:', error);
    res.status(500).json({ message: 'Failed to fetch support history.' });
  }
};
