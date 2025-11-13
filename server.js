import dotenv from "dotenv";
dotenv.config(); // Load environment variables FIRST

import express from "express";
import mongoose from "mongoose";
import cors from "cors";
import authRoutes, { initializeSendGrid } from "./routes/authRoutes.js";

// Initialize SendGrid now that the API key is loaded from .env
initializeSendGrid();

const app = express();
app.use(cors());
app.use(express.json());

// Connect MongoDB
mongoose
  .connect(process.env.MONGO_URI)
  .then(() => console.log("✅ MongoDB Connected"))
  .catch((err) => console.error("❌ MongoDB connection error:", err));

// Routes
app.use("/api/auth", authRoutes);

app.get("/", (req, res) => {
  res.send("Darzi backend is running ✅");
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`🚀 Server running on port ${PORT}`));
