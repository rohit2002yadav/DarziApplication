import mongoose from "mongoose";

const userSchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    phone: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    role: { type: String, enum: ["customer", "tailor"], default: "customer" },
    isVerified: { type: Boolean, default: false },
    otp: { type: String },
    otpExpires: { type: Date },
    
    // Customer specific data
    customerDetails: {
      city: String,
      location: {
        type: { type: String, default: 'Point' },
        coordinates: { type: [Number], default: [0, 0] } // [lng, lat]
      }
    },

    // Tailor specific data
    tailorDetails: {
      shopName: String,
      tailorType: String, // e.g., "Gents", "Ladies", "Suits"
      address: String,
      city: String,
      rating: { type: Number, default: 4.5 },
      isAvailable: { type: Boolean, default: true }
    }
  },
  { timestamps: true }
);

// Index for geo-spatial queries
userSchema.index({ "customerDetails.location": "2dsphere" });

const User = mongoose.model("User", userSchema);
export default User;
