"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const provider_controller_1 = require("../controllers/provider.controller");
const auth_middleware_1 = require("../middlewares/auth.middleware");
const router = express_1.default.Router();
// @route   POST /api/providers/become
// @desc    Register a user as a service provider
// @access  Private
router.post('/become', auth_middleware_1.authMiddleware, provider_controller_1.becomeProvider);
// @route   GET /api/providers/profile
// @desc    Get provider business profile
// @access  Private
router.get('/profile', auth_middleware_1.authMiddleware, provider_controller_1.getProviderProfile);
// @route   PATCH /api/providers/profile
// @desc    Update provider business profile
// @access  Private
router.patch('/profile', auth_middleware_1.authMiddleware, provider_controller_1.updateProviderProfile);
// @route   GET /api/providers/all
// @desc    Get all active service providers (publicly accessible)
// @access  Public
router.get('/all', provider_controller_1.getAllProviders);
exports.default = router;
