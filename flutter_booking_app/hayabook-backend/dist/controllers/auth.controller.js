"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.sendOtpOnly = exports.resendOtp = exports.login = exports.verifyOtp = exports.register = void 0;
const bcryptjs_1 = __importDefault(require("bcryptjs"));
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const client_1 = require("@prisma/client");
const email_service_1 = require("../services/email.service");
const prisma = new client_1.PrismaClient();
const JWT_SECRET = process.env.JWT_SECRET || 'super-secret-jwt-key';
// Helper to generate a 6-digit OTP
const generateOtp = () => Math.floor(100000 + Math.random() * 900000).toString();
const logOtp = (identifier, otp) => {
    console.log(`\n******************************************`);
    console.log(`[DEBUG] OTP for ${identifier} is: ${otp}`);
    console.log(`******************************************\n`);
};
const register = async (req, res) => {
    const { email, password, firstName, lastName, phone, role } = req.body;
    try {
        // Check if user already exists
        const userExists = await prisma.user.findFirst({
            where: {
                OR: [
                    { email: email },
                    { phone: phone }
                ]
            }
        });
        if (userExists) {
            return res.status(400).json({ message: 'User with this email or phone already exists' });
        }
        // Hash password
        const salt = await bcryptjs_1.default.genSalt(10);
        const passwordHash = await bcryptjs_1.default.hash(password, salt);
        // Create user
        const user = await prisma.user.create({
            data: {
                email,
                passwordHash,
                firstName: firstName || null,
                lastName: lastName || null,
                phone,
                role: role || 'CLIENT',
                isVerified: false,
            }
        });
        // Generate and save OTP
        const otpCode = generateOtp();
        const expiresAt = new Date(Date.now() + 10 * 60 * 1000);
        await prisma.otp.upsert({
            where: { identifier: email },
            update: { code: otpCode, expiresAt },
            create: { identifier: email, code: otpCode, expiresAt },
        });
        logOtp(email, otpCode);
        await (0, email_service_1.sendOtpEmail)(email, otpCode);
        res.status(201).json({
            message: 'User created successfully. A verification code has been sent.',
            identifier: email
        });
    }
    catch (error) {
        console.error('Registration Error:', error);
        res.status(500).json({ message: 'Internal Server Error' });
    }
};
exports.register = register;
const verifyOtp = async (req, res) => {
    const { identifier, code } = req.body;
    try {
        const otpRecord = await prisma.otp.findUnique({
            where: { identifier },
        });
        if (!otpRecord || otpRecord.code !== code) {
            return res.status(400).json({ message: 'Invalid or expired verification code' });
        }
        if (new Date() > otpRecord.expiresAt) {
            return res.status(400).json({ message: 'Verification code has expired' });
        }
        // Mark user as verified
        const user = await prisma.user.update({
            where: {
                // We try email then phone
                email: identifier
            },
            data: { isVerified: true },
        }).catch(() => {
            // Fallback to phone if email update failed due to 'email' field unique constraint
            return prisma.user.update({
                where: { phone: identifier },
                data: { isVerified: true }
            });
        });
        const token = jsonwebtoken_1.default.sign({ id: user.id, role: user.role }, JWT_SECRET, {
            expiresIn: '7d',
        });
        await prisma.otp.delete({ where: { identifier } });
        const { passwordHash: _, ...userWithoutPassword } = user;
        res.json({ message: 'Verification successful', user: userWithoutPassword, token });
    }
    catch (error) {
        console.error('OTP Verification Error:', error);
        res.status(500).json({ message: 'Internal Server Error' });
    }
};
exports.verifyOtp = verifyOtp;
const login = async (req, res) => {
    const { email, password } = req.body;
    try {
        const user = await prisma.user.findUnique({ where: { email } });
        if (!user)
            return res.status(400).json({ message: 'Invalid credentials' });
        const isMatch = await bcryptjs_1.default.compare(password, user.passwordHash);
        if (!isMatch)
            return res.status(400).json({ message: 'Invalid credentials' });
        const token = jsonwebtoken_1.default.sign({ id: user.id, role: user.role }, JWT_SECRET, { expiresIn: '7d' });
        const { passwordHash: _, ...userWithoutPassword } = user;
        res.json({ user: userWithoutPassword, token });
    }
    catch (error) {
        res.status(500).json({ message: 'Internal Server Error' });
    }
};
exports.login = login;
const resendOtp = async (req, res) => {
    const { identifier } = req.body;
    try {
        const otpCode = generateOtp();
        const expiresAt = new Date(Date.now() + 10 * 60 * 1000);
        await prisma.otp.upsert({
            where: { identifier },
            update: { code: otpCode, expiresAt },
            create: { identifier, code: otpCode, expiresAt },
        });
        logOtp(identifier, otpCode);
        if (identifier.includes('@'))
            await (0, email_service_1.sendOtpEmail)(identifier, otpCode);
        res.json({ message: 'A new verification code has been sent.' });
    }
    catch (error) {
        res.status(500).json({ message: 'Internal Server Error' });
    }
};
exports.resendOtp = resendOtp;
const sendOtpOnly = async (req, res) => {
    const { identifier } = req.body;
    try {
        const otpCode = generateOtp();
        const expiresAt = new Date(Date.now() + 10 * 60 * 1000);
        await prisma.otp.upsert({
            where: { identifier },
            update: { code: otpCode, expiresAt },
            create: { identifier, code: otpCode, expiresAt },
        });
        logOtp(identifier, otpCode);
        if (identifier.includes('@'))
            await (0, email_service_1.sendOtpEmail)(identifier, otpCode);
        res.status(200).json({ message: 'Verification code sent.' });
    }
    catch (error) {
        res.status(500).json({ message: 'Internal Server Error' });
    }
};
exports.sendOtpOnly = sendOtpOnly;
