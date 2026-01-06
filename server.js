import dotenv from "dotenv";
import path from "path";
import { fileURLToPath } from "url";

// Manually specify the path to .env
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const envPath = path.resolve(__dirname, ".env");

console.log("📂 Looking for .env at:", envPath);
dotenv.config({ path: envPath });

import express from "express";
import mongoose from "mongoose";
import cors from "cors";

import authRoutes from "./routes/authRoutes.js";
import orderRoutes from "./routes/orderRoutes.js";

const app = express();

// middleware
app.use(cors());
app.use(express.json());

// Verify ENV variables immediately
if (process.env.SENDGRID_API_KEY) {
  console.log("✅ SENDGRID_API_KEY is loaded!");
} else {
  console.log("❌ SENDGRID_API_KEY is STILL missing in process.env");
}

// routes
app.use("/api/auth", authRoutes);
app.use("/api/orders", orderRoutes);

// health check
app.get("/", (req, res) => {
  res.json({ message: "Darzi backend is running ✅", env_status: !!process.env.SENDGRID_API_KEY });
});

// database
mongoose
  .connect(process.env.MONGO_URI)
  .then(() => console.log("✅ MongoDB Connected"))
  .catch((err) => console.error("❌ MongoDB Error:", err));

const PORT = process.env.PORT || 10000;
app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
});
