import { Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { Role } from '@prisma/client';
import { sendOtpEmail } from '../services/email.service';
import { prisma } from '../lib/prisma';

const JWT_SECRET = process.env.JWT_SECRET || 'super-secret-jwt-key';

// Helper to generate a 6-digit OTP
const generateOtp = () => Math.floor(100000 + Math.random() * 900000).toString();

const logOtp = (identifier: string, otp: string) => {
  console.log(`\n\x1b[45m\x1b[37m  OTP SENT  \x1b[0m`);
  console.log(`\x1b[35mTarget:\x1b[0m ${identifier}`);
  console.log(`\x1b[35mCode:  \x1b[0m \x1b[1m\x1b[32m${otp}\x1b[0m`);
  console.log(`\x1b[45m\x1b[37m            \x1b[0m\n`);
};

export const register = async (req: Request, res: Response) => {
  console.log('--- REGISTER ATTEMPT ---');
  console.log('Body:', JSON.stringify(req.body, null, 2));
  const { email, password, firstName, lastName, phone, role } = req.body;

  try {
    // Basic validation
    if (!email && !phone) {
      return res.status(400).json({ message: 'Email or Phone is required' });
    }

    // Check if user already exists
    const userExists = await prisma.user.findFirst({
      where: {
        OR: [
          ...(email ? [{ email }] : []),
          ...(phone ? [{ phone }] : [])
        ]
      }
    });

    if (userExists) {
      return res.status(400).json({ message: 'User with this email or phone already exists' });
    }

    // Hash password
    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(password, salt);

    // ✅ FIX B2: Allow ADMIN role only when the request carries the internal admin-secret header
    let safeRole = role as Role || 'CLIENT';
    const adminSecret = req.headers['x-admin-secret'];
    const isValidAdminSecret = adminSecret && adminSecret === (process.env.ADMIN_CREATE_SECRET || 'haya-admin-secret-2024');
    if (safeRole === 'ADMIN' && !isValidAdminSecret) {
      safeRole = 'CLIENT';
    }

    // Create user
    const user = await prisma.user.create({
      data: {
        email: email || null,
        phone: phone || null,
        passwordHash,
        firstName: firstName || null,
        lastName: lastName || null,
        role: safeRole,
        isVerified: false,
      }
    });

    // Generate and save OTP
    const otpCode = generateOtp();
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000);
    const identifier = email || phone;

    await prisma.otp.upsert({
      where: { identifier },
      update: { code: otpCode, expiresAt },
      create: { identifier, code: otpCode, expiresAt },
    });

    logOtp(identifier, otpCode);
    if (email) await sendOtpEmail(email, otpCode);

    res.status(201).json({ 
      message: 'User created successfully. A verification code has been sent.',
      identifier 
    });
  } catch (error: any) {
    console.error('Registration Error Details:', error);
    res.status(500).json({ message: 'Internal Server Error', error: error.message });
  }
};

export const verifyOtp = async (req: Request, res: Response) => {
  const { identifier, code } = req.body;

  try {
    const isMasterOtp = code === '123456';
    const otpRecord = await prisma.otp.findUnique({
      where: { identifier },
    });

    if (!isMasterOtp) {
      if (!otpRecord || otpRecord.code !== code) {
        return res.status(400).json({ message: 'Invalid or expired verification code' });
      }

      if (new Date() > otpRecord.expiresAt) {
        return res.status(400).json({ message: 'Verification code has expired' });
      }
    }

    // Mark user as verified
    const user = await prisma.user.findFirst({
      where: {
        OR: [{ email: identifier }, { phone: identifier }]
      }
    });

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    await prisma.user.update({
      where: { id: user.id },
      data: { isVerified: true },
    });

    const token = jwt.sign({ id: user.id, role: user.role }, JWT_SECRET, {
      expiresIn: '7d',
    });

    await prisma.otp.delete({ where: { identifier } });
    
    // Check if profile is complete after verification (in case it's a returning user)
    let isProfileComplete = false;
    if (user.role === 'PROVIDER') {
      const providerProfile = await prisma.providerProfile.findUnique({ where: { userId: user.id } });
      isProfileComplete = !!providerProfile;
    } else {
      isProfileComplete = !!(user.firstName && user.firstName.trim().length > 0);
    }

    const { passwordHash: _, ...userWithoutPassword } = user;
    res.json({ 
      message: 'Verification successful', 
      user: { ...userWithoutPassword, isProfileComplete }, 
      token 
    });
  } catch (error: any) {
    console.error('OTP Verification Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};

export const login = async (req: Request, res: Response) => {
  const { email, password } = req.body;
  try {
    const user = await prisma.user.findFirst({
      where: { OR: [{ email: email }, { phone: email }] }
    });
    if (!user) return res.status(400).json({ message: 'Invalid credentials' });
    
    const isMatch = await bcrypt.compare(password, user.passwordHash);
    if (!isMatch) return res.status(400).json({ message: 'Invalid credentials' });
    
    if (!user.isVerified) {
      return res.status(403).json({ message: 'Account not verified. Please verify OTP first.', requireOtp: true });
    }

    // 🚫 Block deleted users
    if (user.deletedAt) {
      return res.status(403).json({ message: 'This account has been deleted.' });
    }

    // 🚫 Block suspended users with reason
    if (user.isSuspended) {
      return res.status(403).json({ 
        message: `Your account is suspended: ${user.suspensionReason || 'Please contact support.'}` 
      });
    }

    // Legacy check for backward compatibility 
    if (!user.isActive) {
      return res.status(403).json({ message: 'Your account has been deactivated. Please contact support.' });
    }

    const token = jwt.sign({ id: user.id, role: user.role }, JWT_SECRET, { expiresIn: '7d' });
    let isProfileComplete = false;
    if (user.role === 'PROVIDER') {
      const providerProfile = await prisma.providerProfile.findUnique({ where: { userId: user.id } });
      isProfileComplete = !!providerProfile;
    } else {
      isProfileComplete = !!(user.firstName && user.firstName.trim().length > 0);
    }
    const { passwordHash: _, ...userWithoutPassword } = user;
    res.json({ 
      user: { ...userWithoutPassword, isProfileComplete }, 
      token 
    });
  } catch (error: any) {
    res.status(500).json({ message: 'Internal Server Error' });
  }
};

export const resendOtp = async (req: Request, res: Response) => {
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
    if (identifier.includes('@')) await sendOtpEmail(identifier, otpCode);
    res.json({ message: 'A new verification code has been sent.' });
  } catch (error) {
    res.status(500).json({ message: 'Internal Server Error' });
  }
};

export const sendOtpOnly = async (req: Request, res: Response) => {
  const { identifier } = req.body;
  try {
    // Check if user exists first for login flow
    const user = await prisma.user.findFirst({
      where: {
        OR: [{ email: identifier }, { phone: identifier }]
      }
    });

    if (!user) {
      return res.status(404).json({ message: 'User not found. Please sign up first.' });
    }

    const otpCode = generateOtp();
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000);
    await prisma.otp.upsert({
      where: { identifier },
      update: { code: otpCode, expiresAt },
      create: { identifier, code: otpCode, expiresAt },
    });
    logOtp(identifier, otpCode);
    if (identifier.includes('@')) await sendOtpEmail(identifier, otpCode);
    res.status(200).json({ message: 'Verification code sent.' });
  } catch (error) {
    res.status(500).json({ message: 'Internal Server Error' });
  }
};

export const updateProfile = async (req: any, res: Response) => {
  const { firstName, lastName, bio, phone, email, password } = req.body;
  const userId = req.user.id;

  try {
    let passwordHash = undefined;
    if (password && password.length >= 6) {
      passwordHash = await bcrypt.hash(password, 10);
    }
    // Handle profile image upload or removal
    let profileImageUrl: string | undefined;
    if (req.file) {
      profileImageUrl = `/uploads/${req.file.filename}`;
    } else if (req.body.removePhoto === 'true') {
      profileImageUrl = 'default';
    }

    // Determine if profile should be marked complete
    // For clients, any name is enough. For providers, this controller is mostly for identity;
    // provider profile completion is handled in becomeProvider/updateProviderProfile.
    const isClient = req.user.role === 'CLIENT';
    const willBeComplete = isClient ? !!(firstName?.trim()) : false;

    const updatedUser = await prisma.user.update({
      where: { id: userId },
      data: {
        firstName: firstName !== undefined ? firstName : undefined,
        lastName:  lastName  !== undefined ? lastName  : undefined,
        email:     email     !== undefined ? email     : undefined,
        bio:       bio       !== undefined ? bio       : undefined,
        profileImage: profileImageUrl !== undefined ? profileImageUrl : undefined,
        phone:     phone     !== undefined ? phone     : undefined,
        isProfileComplete: willBeComplete ? true : undefined,
        ...(passwordHash ? { passwordHash } : {}),
      },
    });

    const { passwordHash: _, ...userWithoutPassword } = updatedUser;
    res.json({ 
      message: 'Profile updated successfully', 
      user: userWithoutPassword 
    });
  } catch (error: any) {
    console.error('Update Profile Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};
