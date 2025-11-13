import express from "express";
import bcrypt from "bcryptjs";
import User from "../models/User.js";

const router = express.Router();

// INSTANT SIGNUP (register)
router.post("/register", async (req, res) => {
  try {
    const { email, phone, password } = req.body;

    // 1. Check if user already exists
    const existingUser = await User.findOne({ $or: [{ email }, { phone }] });
    if (existingUser) {
      return res.status(400).json({ error: "A user with this email or phone number already exists." });
    }

    // 2. Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // 3. Create a new, instantly verified user
    const newUser = new User({ 
      ...req.body, 
      password: hashedPassword, 
      isVerified: true // User is instantly verified
    });
    await newUser.save();

    // 4. Send success response
    res.status(201).json({ message: "Registration successful! You can now log in." });

  } catch (err) {
    if (err.code === 11000) {
      return res.status(400).json({ error: "A user with this email or phone number already exists." });
    }
    console.error("Error in /register:", err);
    res.status(500).json({ error: "Failed to register user. Please try again later." });
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
