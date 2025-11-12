import nodemailer from 'nodemailer';
import dotenv from 'dotenv';

dotenv.config();

// Create a transporter object using Gmail SMTP.
// IMPORTANT: You'll need to generate an "App Password" for your Gmail account.
// See: https://support.google.com/accounts/answer/185833
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER, // Your Gmail address from .env
    pass: process.env.EMAIL_PASS, // Your Gmail App Password from .env
  },
});

export default transporter;
