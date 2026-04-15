"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const user_controller_1 = require("../controllers/user.controller");
const auth_middleware_1 = require("../middlewares/auth.middleware");
const router = express_1.default.Router();
// @route   GET /api/users/me
// @desc    Get current user profile
// @access  Private
router.get('/me', auth_middleware_1.authMiddleware, user_controller_1.getMe);
// @route   PATCH /api/users/me
// @desc    Update current user profile
// @access  Private
router.patch('/me', auth_middleware_1.authMiddleware, user_controller_1.updateMe);
exports.default = router;
