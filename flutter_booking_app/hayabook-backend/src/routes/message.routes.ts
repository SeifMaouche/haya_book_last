import express from 'express';
import { sendMessage, getConversation, getMyConversations } from '../controllers/message.controller';
import { authMiddleware } from '../middlewares/auth.middleware';

const router = express.Router();

// @route   POST /api/messages/send
// @desc    Send a message to another user
// @access  Private
router.post('/send', authMiddleware, sendMessage);

// @route   GET /api/messages/conversation/:secondUserId
// @desc    Fetch chat history with a specific user
// @access  Private
router.get('/conversation/:secondUserId', authMiddleware, getConversation);

// @route   GET /api/messages/my-conversations
// @desc    List all conversations for the authenticated user
// @access  Private
router.get('/my-conversations', authMiddleware, getMyConversations);
router.get('/', authMiddleware, getMyConversations);

export default router;
