import express from "express";
import bcrypt from "bcryptjs";
import User from "../models/User.js";
import { sendOtpEmail } from "../utils/mailer.js";

const router = express.Router();

// --- NEARBY DISCOVERY ---
router.get("/tailors/nearby", async (req, res) => {
  try {
    const { lat, lng, radius = 5 } = req.query;
    if (!lat || !lng) return res.status(400).json({ error: "Lat/Lng required" });

    const tailors = await User.aggregate([
      {
        $geoNear: {
          near: { type: "Point", coordinates: [parseFloat(lng), parseFloat(lat)] },
          distanceField: "distance",
          maxDistance: parseFloat(radius) * 1000, 
          query: { role: "tailor" },
          spherical: true
        }
      },
      { $project: { password: 0, otp: 0, otpExpires: 0 } }
    ]);
    res.status(200).json(tailors);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// --- LOGIN ---
router.post("/login", async (req, res) => {
  try {
    const { email, phone, password } = req.body;
    const user = await User.findOne({ $or: [{ email }, { phone }] });
    if (!user) return res.status(400).json({ error: "User not found" });
    if (!user.isVerified) return res.status(403).json({ error: "Please verify your email first.", needsVerification: true });
    
    const isValid = await bcrypt.compare(password, user.password);
    if (!isValid) return res.status(400).json({ error: "Invalid password" });
    
    res.status(200).json({ message: "Login successful", user });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// --- SEND OTP ---
router.post("/send-otp", async (req, res) => {
  try {
    const { email, phone, name, password, role } = req.body;

    if (!email || !phone || !name || !password) {
      return res.status(400).json({ error: "All fields (name, email, phone, password) are required." });
    }

    let user = await User.findOne({ $or: [{ email }, { phone }] });
    if (user && user.isVerified) {
      return res.status(400).json({ error: "User already exists and is verified." });
    }

    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const hashedPassword = await bcrypt.hash(password, 10);

    if (!user) {
      // Create new user with ALL required fields
      user = new User({
        ...req.body,
        password: hashedPassword,
        otp,
        otpExpires: Date.now() + 10 * 60 * 1000,
        isVerified: false
      });
    } else {
      // Update existing unverified user
      user.name = name;
      user.password = hashedPassword;
      user.phone = phone;
      user.otp = otp;
      user.otpExpires = Date.now() + 10 * 60 * 1000;
    }

    await user.save();
    await sendOtpEmail(email, otp);
    res.status(200).json({ message: "OTP sent successfully" });
  } catch (err) {
    console.error("Send OTP error:", err);
    res.status(500).json({ error: "Failed to process request." });
  }
});

// --- VERIFY OTP ---
router.post("/verify-and-register", async (req, res) => {
  try {
    const { email, otp } = req.body;
    const user = await User.findOne({ email, isVerified: false });
    if (!user || user.otp !== otp || user.otpExpires < Date.now()) {
      return res.status(400).json({ error: "Invalid or expired OTP." });
    }
    user.isVerified = true;
    user.otp = undefined;
    user.otpExpires = undefined;
    await user.save();
    res.status(201).json({ message: "Registration successful!" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

export default router;
