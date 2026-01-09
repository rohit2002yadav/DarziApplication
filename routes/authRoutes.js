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
    const tailors = await User.find({ role: "tailor", status: "ACTIVE" }, { password: 0, otp: 0, otpExpires: 0 });
    res.status(200).json(tailors);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// --- NEARBY DISCOVERY (Corrected) ---
router.get("/tailors/nearby", async (req, res) => {
  try {
    const { lat, lng } = req.query;
    if (!lat || !lng) return res.status(400).json({ error: "Lat/Lng required" });

    const radius = Math.min(parseFloat(req.query.radius) || 1, 5);
    const maxDist = radius * 1000; 

    console.log(`📍 Searching tailors near: [${lng}, ${lat}] within ${radius}km`);

    const tailors = await User.aggregate([
      {
        $geoNear: {
          near: { type: "Point", coordinates: [parseFloat(lng), parseFloat(lat)] },
          distanceField: "distance",
          maxDistance: maxDist, 
          query: { 
            role: "tailor", 
            status: "ACTIVE",
          },
          spherical: true,
          key: "location"
        }
      },
      {
        $project: {
          _id: 1,
          name: 1,
          shopName: "$tailorDetails.shopName",
          rating: "$tailorDetails.rating",
          distance: { $divide: ["$distance", 1000] }, 
          basePrice: "$tailorDetails.pricing.basePrice",
          homePickup: "$tailorDetails.homePickup",
          specializations: "$tailorDetails.specializations",
          profilePictureUrl: "$tailorDetails.profilePictureUrl"
        }
      }
    ]);

    console.log(`✅ Found ${tailors.length} tailors`);

    res.status(200).json({
      radius: radius,
      count: tailors.length,
      tailors: tailors
    });
  } catch (err) {
    console.error("❌ GeoNear Error:", err.message);
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
    
    if (password) {
        const isValid = await bcrypt.compare(password, user.password);
        if (!isValid) return res.status(400).json({ error: "Invalid password" });
    }
    
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

    if (!email || !phone || !name) {
      return res.status(400).json({ error: "Name, Email, and Phone are required." });
    }

    const existingUser = await User.findOne({ $or: [{ email }, { phone }] });
    if (existingUser && existingUser.isVerified) {
      return res.status(400).json({ error: "Account already exists with this email or phone." });
    }

    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    
    let updateData = {
      ...req.body,
      otp,
      otpExpires: Date.now() + 10 * 60 * 1000,
      isVerified: false,
      status: "ACTIVE" 
    };

    if (password) {
        updateData.password = await bcrypt.hash(password, 10);
    }

    let user;
    if (!existingUser) {
      user = new User(updateData);
    } else {
      user = Object.assign(existingUser, updateData);
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
    user.status = "ACTIVE"; 
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

// --- FORGOT PASSWORD (Send OTP) ---
router.post("/forgot-password", async (req, res) => {
  try {
    const { email } = req.body;
    if (!email) return res.status(400).json({ error: "Email is required" });

    const user = await User.findOne({ email });
    if (!user) return res.status(404).json({ error: "No user found with this email." });

    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    user.otp = otp;
    user.otpExpires = Date.now() + 10 * 60 * 1000;
    
    await user.save();
    await sendOtpEmail(email, otp);
    res.status(200).json({ message: "A reset OTP has been sent to your email." });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// --- RESET PASSWORD ---
router.post("/reset-password", async (req, res) => {
  try {
    const { email, otp, newPassword } = req.body;
    if (!email || !otp || !newPassword) return res.status(400).json({ error: "All fields are required" });

    const user = await User.findOne({ email });
    if (!user || user.otp !== otp || user.otpExpires < Date.now()) {
      return res.status(400).json({ error: "Invalid or expired OTP." });
    }

    user.password = await bcrypt.hash(newPassword, 10);
    user.otp = undefined;
    user.otpExpires = undefined;
    await user.save();
    res.status(200).json({ message: "Password updated successfully!" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

export default router;
