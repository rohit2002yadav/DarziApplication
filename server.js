import express from "express";
import mongoose from "mongoose";
import cors from "cors";
import dotenv from "dotenv";

import authRoutes from "./routes/authRoutes.js";
import orderRoutes from "./routes/orderRoutes.js";

dotenv.config();

const app = express();

// middleware
app.use(cors({ origin: "*", credentials: true }));
app.use(express.json());

// routes
app.use("/api/auth", authRoutes);
app.use("/api/orders", orderRoutes);

// test route
app.get("/", (req, res) => {
  res.json({
    message: "Darzi backend is running ✅",
    endpoints: ["/api/auth", "/api/orders"],
  });
});

// database
mongoose
  .connect(process.env.MONGO_URI)
  .then(() => console.log("✅ MongoDB Connected"))
  .catch((err) => console.error("❌ MongoDB error:", err));

// port
const PORT = process.env.PORT || 5000;
app.listen(PORT, "0.0.0.0", () => {
  console.log(`🚀 Server running on port ${PORT}`);
});
