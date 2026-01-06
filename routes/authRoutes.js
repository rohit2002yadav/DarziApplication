import express from "express";
import bcrypt from "bcryptjs";
import otpGenerator from 'otp-generator';
import sgMail from '@sendgrid/mail';
import User from "../models/User.js";

export const initializeSendGrid = () => {
  sgMail.setApiKey(process.env.SENDGRID_API_KEY);
  console.log("✅ SendGrid Initialized");
};

const router = express.Router();

// --- NEARBY DISCOVERY (With Distance Calculation) ---

router.get("/tailors/nearby", async (req, res) => {
  try {
    const { lat, lng, radius = 5 } = req.query;
    if (!lat || !lng) return res.status(400).json({ error: "Latitude and Longitude are required" });

    const tailors = await User.aggregate([
      {
        $geoNear: {
          near: { type: "Point", coordinates: [parseFloat(lng), parseFloat(lat)] },
          distanceField: "distance", // This adds a 'distance' field to each result
          maxDistance: parseFloat(radius) * 1000, // Convert km to meters
          query: { role: "tailor" },
          spherical: true
        }
      },
      { $project: { password: 0, otp: 0, otpExpires: 0 } } // Exclude sensitive fields
    ]);

    res.status(200).json(tailors);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// --- MAIN USER & DATA ROUTES ---

router.get("/tailors", async (req, res) => {
  try {
    const tailors = await User.find({ role: "tailor" }).select('-password');
    res.status(200).json(tailors);
  } catch (err) {
    res.status(500).json({ error: "Failed to fetch tailors." });
  }
});

router.post("/login", async (req, res) => {
  try {
    const { email, phone, password } = req.body;
    const user = await User.findOne({ $or: [{ email }, { phone }] });
    if (!user) return res.status(400).json({ error: "User not found" });
    if (!user.isVerified) return res.status(403).json({ error: "Account not verified.", needsVerification: true });
    const isValid = await bcrypt.compare(password, user.password);
    if (!isValid) return res.status(400).json({ error: "Invalid password" });
    res.status(200).json({ message: "Login successful", user: { name: user.name, role: user.role, email: user.email, phone: user.phone, customerDetails: user.customerDetails, tailorDetails: user.tailorDetails }});
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// --- MEASUREMENT PROFILE ROUTES ---

router.post("/measurements", async (req, res) => {
  try {
    const { phone, profile } = req.body;
    const user = await User.findOneAndUpdate(
      { phone },
      { $push: { "customerDetails.measurementProfiles": profile } },
      { new: true }
    );
    res.status(200).json(user.customerDetails.measurementProfiles);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.delete("/measurements/:phone/:profileId", async (req, res) => {
  try {
    const { phone, profileId } = req.params;
    const user = await User.findOneAndUpdate(
      { phone },
      { $pull: { "customerDetails.measurementProfiles": { _id: profileId } } },
      { new: true }
    );
    res.status(200).json(user.customerDetails.measurementProfiles);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// --- REGISTRATION FLOW ---

router.post("/send-otp", async (req, res) => {
  try {
    const { email, phone, role } = req.body;
    let user = await User.findOne({ $or: [{ email }, { phone }] });

    if (user && user.isVerified) {
      return res.status(400).json({ error: "A verified account with this email or phone already exists." });
    }

    const otp = otpGenerator.generate(6, { upperCaseAlphabets: false, specialChars: false, lowerCaseAlphabets: false });
    const otpExpires = new Date(Date.now() + 10 * 60 * 1000);
    const hashedPassword = await bcrypt.hash(req.body.password, 10);

    if (user) {
      user.name = req.body.name;
      user.password = hashedPassword;
      user.role = role;
      user.otp = otp;
      user.otpExpires = otpExpires;
      if (role === 'customer') {
        user.customerDetails = req.body.customerDetails;
        user.tailorDetails = undefined;
      } else if (role === 'tailor') {
        user.tailorDetails = req.body.tailorDetails;
        user.customerDetails = undefined;
      }
    } else {
      user = new User({ ...req.body, password: hashedPassword, otp, otpExpires, isVerified: false });
    }

    await user.save();
    const msg = { to: email, from: process.env.VERIFIED_EMAIL, subject: 'Your OTP for Darzi App Registration', html: `<h1>Your OTP is ${otp}</h1>` };
    await sgMail.send(msg);
    res.status(200).json({ message: "OTP sent successfully to your email." });
  } catch (err) {
    if (err.code === 11000) return res.status(400).json({ error: "A user with this email or phone number already exists." });
    res.status(500).json({ error: "Failed to send OTP. Please try again later." });
  }
});

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

router.post("/forgot-password", async (req, res) => {
  try {
    const { email } = req.body;
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(200).json({ message: "If an account with this email exists, an OTP has been sent." });
    }
    const otp = otpGenerator.generate(6, { upperCaseAlphabets: false, specialChars: false, lowerCaseAlphabets: false });
    user.otp = otp;
    user.otpExpires = new Date(Date.now() + 10 * 60 * 1000);
    await user.save();
    const msg = { to: email, from: process.env.VERIFIED_EMAIL, subject: 'Your Password Reset OTP for Darzi App', html: `<h1>Your password reset OTP is: ${otp}</h1><p>This OTP will expire in 10 minutes.</p>` };
    await sgMail.send(msg);
    res.status(200).json({ message: "An OTP has been sent to your email address." });
  } catch (err) {
    res.status(500).json({ error: "An error occurred while sending the OTP." });
  }
});

router.post("/reset-password", async (req, res) => {
  try {
    const { email, otp, password } = req.body;
    const user = await User.findOne({ email, otp, otpExpires: { $gt: Date.now() } });
    if (!user) {
      return res.status(400).json({ error: "Invalid OTP or OTP has expired. Please request a new one." });
    }
    user.password = await bcrypt.hash(password, 10);
    user.otp = undefined;
    user.otpExpires = undefined;
    await user.save();
    res.status(200).json({ message: "Password has been successfully reset. You can now log in." });
  } catch (err) {
    res.status(500).json({ error: "An error occurred. Please try again later." });
  }
});

export default router;
