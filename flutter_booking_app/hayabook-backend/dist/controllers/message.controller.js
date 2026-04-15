"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getMyConversations = exports.getConversation = exports.sendMessage = void 0;
const client_1 = require("@prisma/client");
const prisma = new client_1.PrismaClient();
// Generate a deterministic convo ID from two IDs (e.g. userA_userB)
const generateConversationId = (id1, id2) => {
    return [id1, id2].sort().join('_');
};
const sendMessage = async (req, res) => {
    const { receiverId, content } = req.body;
    try {
        if (!req.user) {
            return res.status(401).json({ message: 'Unauthorized' });
        }
        const conversationId = generateConversationId(req.user.id, receiverId);
        const message = await prisma.message.create({
            data: {
                senderId: req.user.id,
                conversationId,
                content,
            },
        });
        res.status(201).json(message);
    }
    catch (error) {
        console.error('Send Message Error:', error);
        res.status(500).json({ message: 'Internal Server Error' });
    }
};
exports.sendMessage = sendMessage;
const getConversation = async (req, res) => {
    const { secondUserId } = req.params;
    try {
        if (!req.user) {
            return res.status(401).json({ message: 'Unauthorized' });
        }
        const targetUserId = secondUserId;
        const conversationId = generateConversationId(req.user.id, targetUserId);
        const messages = await prisma.message.findMany({
            where: { conversationId },
            orderBy: { createdAt: 'asc' },
            include: {
                sender: {
                    select: { firstName: true, profileImage: true },
                },
            },
        });
        // Mark messages as read
        await prisma.message.updateMany({
            where: {
                conversationId,
                senderId: targetUserId,
                isRead: false,
            },
            data: { isRead: true },
        });
        res.json(messages);
    }
    catch (error) {
        console.error('Get Conversation Error:', error);
        res.status(500).json({ message: 'Internal Server Error' });
    }
};
exports.getConversation = getConversation;
const getMyConversations = async (req, res) => {
    try {
        if (!req.user) {
            return res.status(401).json({ message: 'Unauthorized' });
        }
        // This is a complex query to get the latest message from each conversation
        // For this MVP, we'll simplify by getting all messages where the user was a participant
        // and letting the frontend handle the grouping or using a distinct query.
        const messages = await prisma.message.findMany({
            where: {
                conversationId: {
                    contains: req.user.id,
                },
            },
            orderBy: { createdAt: 'desc' },
            include: {
                sender: {
                    select: { firstName: true, lastName: true, profileImage: true },
                },
            },
        });
        // Extract unique conversations
        const conversationMap = new Map();
        messages.forEach((msg) => {
            if (!conversationMap.has(msg.conversationId)) {
                conversationMap.set(msg.conversationId, msg);
            }
        });
        res.json(Array.from(conversationMap.values()));
    }
    catch (error) {
        console.error('Get My Conversations Error:', error);
        res.status(500).json({ message: 'Internal Server Error' });
    }
};
exports.getMyConversations = getMyConversations;
