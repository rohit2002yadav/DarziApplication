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
    
    // Customer specific data (Matches your Flutter Signup screen)
    customerDetails: {
      address: String,
      city: String,
      state: String,
      landmark: String,
      pin: String,
      location: {
        type: { type: String, default: 'Point' },
        coordinates: { type: [Number], default: [73.8567, 18.5204] } // Default to Pune [lng, lat]
      }
    },

    // Tailor specific data
    tailorDetails: {
      shopName: String,
      tailorType: String,
      address: String,
      city: String,
      state: String,
      zipCode: String,
      landmark: String,
      rating: { type: Number, default: 4.5 },
      isAvailable: { type: Boolean, default: true }
    }
  },
  { timestamps: true }
);

userSchema.index({ "customerDetails.location": "2dsphere" });

const User = mongoose.model("User", userSchema);
export default User;
