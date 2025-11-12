import mongoose from "mongoose";

const userSchema = new mongoose.Schema(
  {
    role: { type: String, required: true, enum: ["customer", "tailor"] },
    name: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    phone: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    isVerified: { type: Boolean, default: false }, // Added for email verification

    // Fields for customers
    customerDetails: {
      city: String,
      state: String,
      landmark: String,
      pin: String,
      other: String,
    },

    // Fields for tailorse
    tailorDetails: {
      shopName: String,
      services: String,
      experience: String,
      street: String,
      city: String,
      state: String,
      zip: String,
      other: String,
    },
  },
  { timestamps: true }
);

export default mongoose.model("User", userSchema);
