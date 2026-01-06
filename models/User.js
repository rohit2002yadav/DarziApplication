import mongoose from "mongoose";

const orderSchema = new mongoose.Schema(
  {
    customerName: { type: String, required: true },
    customerPhone: { type: String, required: true },
    customerEmail: String,

    tailorId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },

    garmentType: String,
    items: [String],

    totalAmount: { type: Number, required: true },

    status: {
      type: String,
      enum: ["PLACED", "ACCEPTED", "CUTTING", "STITCHING", "READY", "DELIVERED"],
      default: "PLACED",
    },

    // 🔴 REQUIRED — this was missing before
    handoverType: {
      type: String,
      enum: ["pickup", "drop"],
      required: true,
    },

    // 🔴 MUST be nested object
    pickup: {
      address: String,
      date: String,
      time: String,
    },

    measurements: Object,
  },
  { timestamps: true }
);

export default mongoose.model("Order", orderSchema);
