import nodemailer from 'nodemailer';
import dotenv from 'dotenv';

dotenv.config();

// Create a transporter object using explicit SMTP settings for better compatibility.
const transporter = nodemailer.createTransport({
  host: 'smtp.gmail.com', // Google's SMTP server
  port: 587, // Port for TLS/STARTTLS
  secure: false, // Use STARTTLS. `true` is for port 465 (SSL)
  auth: {
    user: process.env.EMAIL_USER, // Your Gmail address from .env
    pass: process.env.EMAIL_PASS, // Your Gmail App Password from .env
  },
});

export default transporter;
