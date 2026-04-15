"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const message_controller_1 = require("../controllers/message.controller");
const auth_middleware_1 = require("../middlewares/auth.middleware");
const router = express_1.default.Router();
// @route   POST /api/messages
// @desc    Send a message to another user
// @access  Private
router.post('/', auth_middleware_1.authMiddleware, message_controller_1.sendMessage);
// @route   GET /api/messages/history/:secondUserId
// @desc    Fetch chat history with a specific user
// @access  Private
router.get('/history/:secondUserId', auth_middleware_1.authMiddleware, message_controller_1.getConversation);
// @route   GET /api/messages
// @desc    List all conversations for the authenticated user
// @access  Private
router.get('/', auth_middleware_1.authMiddleware, message_controller_1.getMyConversations);
exports.default = router;
