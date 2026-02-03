import mongoose from "mongoose";

const userSchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    phone: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    role: { type: String, enum: ["customer", "tailor"], required: true },

    isVerified: { type: Boolean, default: false },
    status: { type: String, enum: ["ACTIVE", "INACTIVE", "SUSPENDED"], default: "ACTIVE" },

    otp: { type: String },
    otpExpires: { type: Date },

    // *** THE FIX: Added the correct schema and index for location ***
    location: {
      type: {
        type: String,
        enum: ["Point"],
        default: "Point",
      },
      coordinates: {
        type: [Number], // [longitude, latitude]
      },
    },

    customerDetails: {
      address: { type: String },
      city: { type: String },
      state: { type: String },
      landmark: { type: String },
      pin: { type: String },
    },

    tailorDetails: {
      shopName: { type: String },
      experience: { type: Number },
      specializations: { type: [String] },
      workingDays: { type: [String] },
      workingHours: { open: String, close: String },
      pricing: { basePrice: Number, alterationPrice: Number },
      homePickup: { type: Boolean, default: false },
      measurementVisit: { type: Boolean, default: false },
      providesFabric: { type: Boolean, default: false },
      address: { type: String },
      city: { type: String },
      state: { type: String },
      zipCode: { type: String },
      landmark: { type: String },
      profilePictureUrl: { type: String },
      shopImageUrl: { type: String },
      workPhotoUrls: { type: [String] },
      rating: { type: Number, default: 4.5 },
    },
  },
  { timestamps: true }
);

// Add the geospatial index
userSchema.index({ location: "2dsphere" });

export default mongoose.model("User", userSchema);
