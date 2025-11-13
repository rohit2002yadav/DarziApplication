import express from "express";
import bcrypt from "bcryptjs";
import otpGenerator from 'otp-generator';
import User from "../models/User.js";
import resend from "../utils/email.js";

const router = express.Router();

// 1. SEND OTP FOR NEW REGISTRATION
router.post("/send-otp", async (req, res) => {
  try {
    const { email, phone } = req.body;

    const existingVerifiedUser = await User.findOne({ $or: [{ email }, { phone }], isVerified: true });
    if (existingVerifiedUser) {
      return res.status(400).json({ error: "An account with this email or phone already exists." });
    }

    const otp = otpGenerator.generate(6, { 
      upperCaseAlphabets: false, 
      specialChars: false,
      lowerCaseAlphabets: false,
    });
    const otpExpires = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes
    const hashedPassword = await bcrypt.hash(req.body.password, 10);

    const user = await User.findOneAndUpdate(
      { email }, 
      { 
        ...req.body, 
        password: hashedPassword, 
        otp,
        otpExpires,
        isVerified: false, 
      },
      { new: true, upsert: true } 
    );

    await resend.emails.send({
      from: 'onboarding@resend.dev',
      to: email,
      subject: 'Your OTP for Darzi App Registration',
      html: `<h1>Your OTP is ${otp}</h1>`
    });

    res.status(200).json({ message: "OTP sent successfully to your email." });

  } catch (err) {
    console.error("Error in /send-otp:", err);
    res.status(500).json({ error: "Failed to send OTP. " + err.message });
  }
});

// 2. VERIFY OTP AND COMPLETE REGISTRATION
router.post("/verify-and-register", async (req, res) => {
  try {
    const { email, otp } = req.body;

    const user = await User.findOne({ email, isVerified: false });

    if (!user || user.otp !== otp || user.otpExpires < new Date()) {
      return res.status(400).json({ error: "Invalid or expired OTP. Please try again." });
    }

    user.isVerified = true;
    user.otp = undefined;
    user.otpExpires = undefined;
    await user.save();

    res.status(201).json({ message: "Registration successful! You can now log in." });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 3. RESEND OTP FOR UNVERIFIED USERS
router.post("/resend-otp", async (req, res) => {
  try {
    const { email } = req.body;
    const user = await User.findOne({ email });

    if (!user) {
      return res.status(404).json({ error: "No account found with this email." });
    }

    if (user.isVerified) {
      return res.status(400).json({ error: "This account is already verified." });
    }

    const otp = otpGenerator.generate(6, { 
      upperCaseAlphabets: false, 
      specialChars: false,
      lowerCaseAlphabets: false,
    });
    user.otp = otp;
    user.otpExpires = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes
    await user.save();

    await resend.emails.send({
      from: 'onboarding@resend.dev',
      to: email,
      subject: 'Your New OTP for Darzi App',
      html: `<h1>Your new OTP is ${otp}</h1>`
    });

    res.status(200).json({ message: "A new OTP has been sent to your email." });

  } catch (err) {
     console.error("Error in /resend-otp:", err);
    res.status(500).json({ error: "Failed to resend OTP. " + err.message });
  }
});


// 4. LOGIN
router.post("/login", async (req, res) => {
  try {
    const { email, phone, password } = req.body;

    const user = await User.findOne({ $or: [{ email }, { phone }] });
    if (!user) {
      return res.status(400).json({ error: "User not found" });
    }

    if (!user.isVerified) {
        // Use a special status code (e.g., 403 Forbidden) for this case
        return res.status(403).json({ 
          error: "Account not verified.",
          needsVerification: true 
        });
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
