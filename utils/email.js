import nodemailer from 'nodemailer';
import dotenv from 'dotenv';

dotenv.config();

// --- VITAL DEBUGGING CHECK ---
console.log("\n\n--- EMAIL CONFIG CHECK ---");
console.log(`EMAIL_USER found: ${process.env.EMAIL_USER}`)
console.log(`EMAIL_PASS found: ${process.env.EMAIL_PASS ? 'Yes' : 'No'}`)
console.log("--------------------------\n\n");


// Create a transporter object using explicit SMTP settings for better compatibility.
const transporter = nodemailer.createTransport({
  host: 'smtp.gmail.com', // Google's SMTP server
  port: 587, // Port for TLS/STARTTLS
  secure: false, // Use STARTTLS. `true` is for port 465 (SSL)
  auth: {
    user: process.env.EMAIL_USER, // Your Gmail address from .env
    pass: process.env.EMAIL_PASS, // Your Gmail App Password from .env
  },
  tls: {
    ciphers:'SSLv3' // Adding a specific TLS option for compatibility
  }
});

export default transporter;
