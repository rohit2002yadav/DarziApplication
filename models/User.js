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
    
    // Unified location for GeoSpatial queries
    location: {
      type: { type: String, default: 'Point' },
      coordinates: { type: [Number], default: [73.8567, 18.5204] } // [longitude, latitude]
    },

    // Customer specific data
    customerDetails: {
      address: String,
      city: String,
      state: String,
      landmark: String,
      pin: String
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
      isAvailable: { type: Boolean, default: true },
      profilePictureUrl: String,
      shopPictureUrl: String
    }
  },
  { timestamps: true }
);

// Index for nearby searching
userSchema.index({ "location": "2dsphere" });

const User = mongoose.model("User", userSchema);
export default User;
