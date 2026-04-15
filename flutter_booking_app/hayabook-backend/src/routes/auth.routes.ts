import express from 'express';
import rateLimit from 'express-rate-limit';
import { register, login, verifyOtp, resendOtp, sendOtpOnly, updateProfile } from '../controllers/auth.controller';
import { authMiddleware } from '../middlewares/auth.middleware';
import { upload } from '../middlewares/upload.middleware';

const router = express.Router();

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, 
  max: 10, 
  message: { message: 'Too many requests, please try again later.' },
  standardHeaders: true,
  legacyHeaders: false,
});

router.post('/register', authLimiter, register);
router.post('/login', authLimiter, login);
router.post('/verify-otp', authLimiter, verifyOtp);
router.post('/resend-otp', authLimiter, resendOtp);
router.post('/send-otp', authLimiter, sendOtpOnly);
router.put('/update-profile', authMiddleware, upload.single('profileImage'), updateProfile);

export default router;
