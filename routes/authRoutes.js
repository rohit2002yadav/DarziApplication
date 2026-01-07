import express from "express";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import User from "../models/User.js";
import { sendOtpEmail } from "../utils/mailer.js";

const router = express.Router();

const JWT_SECRET = process.env.JWT_SECRET || "your_super_secret_key_darzi";

// Helper to generate Token
const generateToken = (id) => {
  return jwt.sign({ id }, JWT_SECRET, { expiresIn: "30d" });
};

// --- ALL TAILORS ---
router.get("/tailors", async (req, res) => {
  try {
    const tailors = await User.find({ role: "tailor" }, { password: 0, otp: 0, otpExpires: 0 });
    res.status(200).json(tailors);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

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
          spherical: true,
          key: "location"
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
    
    res.status(200).json({ 
      message: "Login successful", 
      user,
      token: generateToken(user._id)
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// --- SEND OTP (Signup) ---
router.post("/send-otp", async (req, res) => {
  try {
    const { email, phone, name, password, role } = req.body;

    if (!email || !phone || !name || !password) {
      return res.status(400).json({ error: "All fields are required." });
    }

    // DEBUG: Check what's happening
    const existingEmail = await User.findOne({ email });
    const existingPhone = await User.findOne({ phone });

    if (existingEmail && existingEmail.isVerified) {
      return res.status(400).json({ error: "Email already registered and verified." });
    }
    if (existingPhone && existingPhone.isVerified) {
      return res.status(400).json({ error: "Phone number already registered and verified." });
    }

    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const hashedPassword = await bcrypt.hash(password, 10);

    // Find if there's an unverified account to update
    let user = await User.findOne({ $or: [{ email }, { phone }], isVerified: false });

    if (!user) {
      user = new User({
        ...req.body,
        password: hashedPassword,
        otp,
        otpExpires: Date.now() + 10 * 60 * 1000,
        isVerified: false
      });
    } else {
      user.name = name;
      user.password = hashedPassword;
      user.phone = phone;
      user.email = email;
      user.otp = otp;
      user.otpExpires = Date.now() + 10 * 60 * 1000;
      if (req.body.location) user.location = req.body.location;
      if (req.body.customerDetails) user.customerDetails = req.body.customerDetails;
      if (req.body.tailorDetails) user.tailorDetails = req.body.tailorDetails;
    }

    await user.save();
    await sendOtpEmail(email, otp);
    res.status(200).json({ message: "OTP sent successfully" });
  } catch (err) {
    console.error("Signup error:", err);
    res.status(500).json({ error: err.message });
  }
});

// --- VERIFY OTP & REGISTER ---
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
    
    res.status(201).json({ 
      message: "Registration successful!",
      user,
      token: generateToken(user._id)
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// --- FORGOT PASSWORD ---
router.post("/forgot-password", async (req, res) => {
  try {
    const { email } = req.body;
    const user = await User.findOne({ email });
    if (!user) return res.status(404).json({ error: "No user found." });

    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    user.otp = otp;
    user.otpExpires = Date.now() + 10 * 60 * 1000;
    
    await user.save();
    await sendOtpEmail(email, otp);
    res.status(200).json({ message: "Reset OTP sent." });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// --- RESET PASSWORD ---
router.post("/reset-password", async (req, res) => {
  try {
    const { email, otp, newPassword } = req.body;
    const user = await User.findOne({ email });
    if (!user || user.otp !== otp || user.otpExpires < Date.now()) {
      return res.status(400).json({ error: "Invalid or expired OTP." });
    }

    user.password = await bcrypt.hash(newPassword, 10);
    user.otp = undefined;
    user.otpExpires = undefined;
    user.isVerified = true; 
    await user.save();
    res.status(200).json({ message: "Password updated!" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

export default router;
