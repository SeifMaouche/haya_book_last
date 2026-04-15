"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.sendOtpEmail = void 0;
const nodemailer_1 = __importDefault(require("nodemailer"));
// Configure SMTP with your credentials
// These should be set in for environment variables (.env)
const transporter = nodemailer_1.default.createTransport({
    host: process.env.SMTP_HOST || 'smtp.mailtrap.io',
    port: parseInt(process.env.SMTP_PORT || '2525'),
    auth: {
        user: process.env.SMTP_USER,
        pass: process.env.SMTP_PASS,
    },
});
const sendOtpEmail = async (email, otp) => {
    const mailOptions = {
        from: '"HayaBook" <no-reply@hayabook.dz>',
        to: email,
        subject: 'Your HayaBook Verification Code',
        text: `Your verification code is: ${otp}. It will expire in 10 minutes.`,
        html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: auto; padding: 20px; border: 1px solid #e0e0e0; border-radius: 10px;">
        <h2 style="color: #4CAF50; text-align: center;">HayaBook Verification</h2>
        <p>Hello,</p>
        <p>Thank you for registering with <strong>HayaBook</strong>. To complete your account setup, please use the 6-digit verification code below:</p>
        <div style="background-color: #f9f9f9; padding: 15px; border-radius: 5px; text-align: center; font-size: 24px; font-weight: bold; letter-spacing: 5px; color: #333; margin: 20px 0;">
          ${otp}
        </div>
        <p>This code is valid for <strong>10 minutes</strong>. If you did not request this, please ignore this email.</p>
        <hr style="border: 0; border-top: 1px solid #eee; margin: 20px 0;" />
        <p style="font-size: 12px; color: #888; text-align: center;">© 2026 HayaBook. All rights reserved.</p>
      </div>
    `,
    };
    try {
        // FOR TESTING: Always log to console so you aren't blocked by SMTP setup
        console.log(`\n==========================================`);
        console.log(`[VERIFICATION CODE] ${email}: ${otp}`);
        console.log(`==========================================\n`);
        const info = await transporter.sendMail(mailOptions);
        console.log('Email sent: %s', info.messageId);
        return true;
    }
    catch (error) {
        console.error('Email send error:', error);
        return false;
    }
};
exports.sendOtpEmail = sendOtpEmail;
