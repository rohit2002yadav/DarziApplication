import mongoose from "mongoose";

const userSchema = new mongoose.Schema(
  {
    role: { type: String, required: true, enum: ["customer", "tailor"] },
    name: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    phone: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    isVerified: { type: Boolean, default: false },

    // Fields for OTP Verification
    otp: { type: String },
    otpExpires: { type: Date },

    // Fields for Password Reset
    resetPasswordToken: { type: String },
    resetPasswordExpires: { type: Date },

    // Fields for customers
    customerDetails: {
      city: String,
      state: String,
      landmark: String,
      pin: String,
      other: String,
    },

    // Fields for tailors - EXPANDED STRUCTURE
    tailorDetails: {
      shopName: String,
      profilePictureUrl: String,
      shopPictureUrl: String,
      tailorType: String,
      // New Address Fields for Tailor
      address: String,
      city: String,
      state: String,
      landmark: String,
      zipCode: String,
    },
  },
  { timestamps: true }
);

export default mongoose.model("User", userSchema);
