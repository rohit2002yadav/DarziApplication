import express from "express";
import bcrypt from "bcryptjs";
import otpGenerator from 'otp-generator';
import User from "../models/User.js";
import resend from "../utils/email.js"; // Import the Resend instance

const router = express.Router();

const otpStore = {};

// 1. SEND OTP FOR REGISTRATION
router.post("/send-otp", async (req, res) => {
  try {
    const { email, phone } = req.body;

    const existingUser = await User.findOne({ $or: [{ email }, { phone }], isVerified: true });
    if (existingUser) {
      return res.status(400).json({ error: "User already exists" });
    }

    const otp = otpGenerator.generate(6, { 
      upperCaseAlphabets: false, 
      specialChars: false,
      lowerCaseAlphabets: false,
    });

    const hashedPassword = await bcrypt.hash(req.body.password, 10);
    otpStore[email] = { ...req.body, password: hashedPassword, otp, timestamp: Date.now() };

    // Send the email using Resend
    await resend.emails.send({
      from: 'onboarding@resend.dev', // Use Resend's test email address
      to: email,
      subject: 'Your OTP for Darzi App Registration',
      html: `
        <h2>Welcome to Darzi App!</h2>
        <p>Thank you for registering. Please use the following One-Time Password (OTP) to verify your account:</p>
        <h1 style="font-size: 36px; letter-spacing: 4px; margin: 20px 0;">${otp}</h1>
        <p>This OTP is valid for 10 minutes. If you did not request this, please ignore this email.</p>
      `
    });

    res.status(200).json({ message: "OTP sent successfully to your email." });

  } catch (err) {
    console.error("Error in /send-otp:", err); // Log the actual error
    res.status(500).json({ error: "Failed to send OTP. " + err.message });
  }
});

// 2. VERIFY OTP AND COMPLETE REGISTRATION
router.post("/verify-and-register", async (req, res) => {
  try {
    const { email, otp } = req.body;

    const storedData = otpStore[email];

    if (!storedData) {
      return res.status(400).json({ error: "Invalid request or OTP expired. Please try again." });
    }
    if (storedData.otp !== otp) {
      return res.status(400).json({ error: "Invalid OTP." });
    }
    const tenMinutes = 10 * 60 * 1000;
    if (Date.now() - storedData.timestamp > tenMinutes) {
      delete otpStore[email]; // Clean up expired OTP
      return res.status(400).json({ error: "OTP expired. Please request a new one." });
    }

    const newUser = new User({ ...storedData, isVerified: true });
    await newUser.save();

    delete otpStore[email];

    res.status(201).json({ message: "Registration successful! You can now log in." });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});


// LOGIN
router.post("/login", async (req, res) => {
  try {
    const { email, phone, password } = req.body;

    const user = await User.findOne({ $or: [{ email }, { phone }] });
    if (!user) {
      return res.status(400).json({ error: "User not found" });
    }

    if (!user.isVerified) {
        return res.status(401).json({ error: "Account not verified. Please complete the registration process." });
    }

    const isValid = await bcrypt.compare(password, user.password);
    if (!isValid) {
      return res.status(400).json({ error: "Invalid password" });
    }

    res.status(200).json({
      message: "Login successful",
      user: {
        name: user.name,
        role: user.role,
        email: user.email,
        phone: user.phone,
      },
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

export default router;
