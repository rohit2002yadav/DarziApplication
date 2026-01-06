import express from "express";
import otpGenerator from "otp-generator";
import User from "../models/User.js";
import { sendOtpEmail } from "../utils/mailer.js";

const router = express.Router();

/**
 * @route   POST /api/auth/send-otp
 * @desc    Send OTP to email
 */
router.post("/send-otp", async (req, res) => {
  try {
    console.log("🔥 /api/auth/send-otp HIT");
    console.log("Request body:", req.body);

    const { email } = req.body;

    if (!email) {
      return res.status(400).json({ error: "Email is required" });
    }

    // Generate 6-digit OTP
    const otp = otpGenerator.generate(6, {
      upperCaseAlphabets: false,
      lowerCaseAlphabets: false,
      specialChars: false,
    });

    console.log("Generated OTP:", otp);

    // Save or update OTP in DB
    await User.findOneAndUpdate(
      { email },
      { otp, otpExpiry: Date.now() + 5 * 60 * 1000 },
      { upsert: true, new: true }
    );

    // Send OTP email
    const sent = await sendOtpEmail(email, otp);
    console.log("SendGrid result:", sent);

    if (!sent) {
      return res.status(500).json({
        error: "Failed to send OTP. Please try again later.",
      });
    }

    return res.json({
      message: "OTP sent successfully",
    });
  } catch (error) {
    console.error("❌ send-otp error:", error);
    return res.status(500).json({
      error: "Internal server error",
    });
  }
});

export default router;
