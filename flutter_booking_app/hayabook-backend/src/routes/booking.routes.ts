import express from 'express';
import {
  createBooking,
  getClientBookings,
  getProviderBookings,
  updateBookingStatus,
  getAvailableSlots,
  rescheduleBooking,
} from '../controllers/booking.controller';
import { authMiddleware } from '../middlewares/auth.middleware';

const router = express.Router();

// @route   GET /api/bookings/slots
// @access  Public
router.get('/slots', getAvailableSlots);

// @route   POST /api/bookings
router.post('/', authMiddleware, createBooking);

// @route   GET /api/bookings/client
router.get('/client', authMiddleware, getClientBookings);

// @route   GET /api/bookings/provider
router.get('/provider', authMiddleware, getProviderBookings);

// @route   PATCH /api/bookings/:id/status
router.patch('/:id/status', authMiddleware, updateBookingStatus);

// @route   PATCH /api/bookings/:id  (reschedule — change date/time)
router.patch('/:id', authMiddleware, rescheduleBooking);

export default router;
