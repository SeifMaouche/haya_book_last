"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const auth_controller_1 = require("../controllers/auth.controller");
const router = express_1.default.Router();
// @route   POST /api/auth/register
// @desc    Register a new user
// @access  Public
router.post('/register', auth_controller_1.register);
// @route   POST /api/auth/login
// @desc    Authenticate user & get token
// @access  Public
router.post('/login', auth_controller_1.login);
// @route   POST /api/auth/verify-otp
// @desc    Verify OTP
// @access  Public
router.post('/verify-otp', auth_controller_1.verifyOtp);
// @route   POST /api/auth/resend-otp
// @desc    Resend OTP
// @access  Public
router.post('/resend-otp', auth_controller_1.resendOtp);
// @route   POST /api/auth/send-otp
// @desc    Send OTP
// @access  Public
router.post('/send-otp', auth_controller_1.sendOtpOnly);
exports.default = router;
