"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const booking_controller_1 = require("../controllers/booking.controller");
const auth_middleware_1 = require("../middlewares/auth.middleware");
const router = express_1.default.Router();
// @route   POST /api/bookings
// @desc    Initiate an auto-confirm booking
// @access  Private (Client/Provider)
router.post('/', auth_middleware_1.authMiddleware, booking_controller_1.createBooking);
// @route   GET /api/bookings/client
// @desc    Get all current clients bookings
// @access  Private (Client only)
router.get('/client', auth_middleware_1.authMiddleware, booking_controller_1.getClientBookings);
// @route   GET /api/bookings/provider
// @desc    Get all bookings for provider oversight
// @access  Private (Provider only)
router.get('/provider', auth_middleware_1.authMiddleware, booking_controller_1.getProviderBookings);
// @route   PATCH /api/bookings/:id/status
// @desc    Update booking status (CANCELLED, COMPLETED)
// @access  Private (Provider/Client oversight)
router.patch('/:id/status', auth_middleware_1.authMiddleware, booking_controller_1.updateBookingStatus);
exports.default = router;
