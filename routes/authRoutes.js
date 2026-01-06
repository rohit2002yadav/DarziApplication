import express from "express";
import bcrypt from "bcryptjs";
import User from "../models/User.js";
import sendOtpEmail from "../utils/mailer.js";

const router = express.Router();

/**
 * SEND OTP
 * POST /api/auth/send-otp
 */
router.post("/send-otp", async (req, res) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({ message: "Email is required" });
    }

    // generate 6-digit OTP
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const hashedOtp = await bcrypt.hash(otp, 10);

    // save or update user
    let user = await User.findOne({ email });

    if (!user) {
      user = new User({
        email,
        otp: hashedOtp,
        otpExpires: Date.now() + 5 * 60 * 1000, // 5 minutes
        isVerified: false,
      });
    } else {
      user.otp = hashedOtp;
      user.otpExpires = Date.now() + 5 * 60 * 1000;
    }

    await user.save();

    const emailSent = await sendOtpEmail(email, otp);

    if (!emailSent) {
      return res.status(500).json({ message: "Failed to send OTP email" });
    }

    res.json({ message: "OTP sent successfully" });
  } catch (error) {
    console.error("Send OTP error:", error);
    res.status(500).json({ message: "Server error" });
  }
});

/**
 * VERIFY OTP
 * POST /api/auth/verify-otp
 */
router.post("/verify-otp", async (req, res) => {
  try {
    const { email, otp } = req.body;

    if (!email || !otp) {
      return res.status(400).json({ message: "Email and OTP are required" });
    }

    const user = await User.findOne({ email });

    if (!user || !user.otp) {
      return res.status(400).json({ message: "Invalid request" });
    }

    if (user.otpExpires < Date.now()) {
      return res.status(400).json({ message: "OTP expired" });
    }

    const isMatch = await bcrypt.compare(otp, user.otp);

    if (!isMatch) {
      return res.status(400).json({ message: "Invalid OTP" });
    }

    user.isVerified = true;
    user.otp = undefined;
    user.otpExpires = undefined;

    await user.save();

    res.json({ message: "OTP verified successfully", user });
  } catch (error) {
    console.error("Verify OTP error:", error);
    res.status(500).json({ message: "Server error" });
  }
});

export default router;
