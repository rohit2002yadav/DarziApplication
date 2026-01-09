import dotenv from "dotenv";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const envPath = path.resolve(__dirname, ".env");
dotenv.config({ path: envPath });

import express from "express";
import mongoose from "mongoose";
import cors from "cors";

// Import all routes
import authRoutes from "./routes/authRoutes.js";
import orderRoutes from "./routes/orderRoutes.js";
import fabricRoutes from "./routes/fabricRoutes.js"; // This was missing from your live server

const app = express();

app.use(cors());
app.use(express.json());

// Use all routes
app.use("/api/auth", authRoutes);
app.use("/api/orders", orderRoutes);
app.use("/api/fabrics", fabricRoutes); // This line makes the fabric API work

app.get("/", (req, res) => {
  res.json({ message: "Darzi backend is running ✅" });
});

// Connect to DB and start server
mongoose
  .connect(process.env.MONGO_URI)
  .then(() => {
    console.log("✅ MongoDB Connected");
    const PORT = process.env.PORT || 10000;
    app.listen(PORT, () => console.log(`🚀 Server running on port ${PORT}`));
  })
  .catch((err) => console.error("❌ MongoDB Error:", err));
