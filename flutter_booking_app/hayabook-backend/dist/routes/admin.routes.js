"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const admin_controller_1 = require("../controllers/admin.controller");
const auth_middleware_1 = require("../middlewares/auth.middleware");
const admin_middleware_1 = require("../middlewares/admin.middleware");
const router = express_1.default.Router();
// Apply global admin guards to all routes in this module
router.use(auth_middleware_1.authMiddleware);
router.use(admin_middleware_1.adminMiddleware);
// @route   GET /api/admin/stats
// @desc    Retrieve data for dashboard charts (Revenue, Categories, etc.)
// @access  Admin only
router.get('/stats', admin_controller_1.getPlatformStats);
// @route   GET /api/admin/users
// @desc    List all platform users
// @access  Admin only
router.get('/users', admin_controller_1.getAllUsers);
// @route   PATCH /api/admin/users/:id/status
// @desc    Ban or Unban a user
// @access  Admin only
router.patch('/users/:id/status', admin_controller_1.toggleUserStatus);
// @route   PATCH /api/admin/providers/:id/verify
// @desc    Approve or Reject a provider profile
// @access  Admin only
router.patch('/providers/:id/verify', admin_controller_1.verifyProvider);
// @route   GET /api/admin/bookings
// @desc    Full oversight of platform-wide bookings
// @access  Admin only
router.get('/bookings', admin_controller_1.getGlobalBookings);
exports.default = router;
