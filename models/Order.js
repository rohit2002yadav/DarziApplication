import mongoose from "mongoose";

const orderSchema = new mongoose.Schema(
  {
    customerName: { type: String, required: true, trim: true },
    customerPhone: { type: String, required: true },
    customerEmail: { type: String },
    tailorId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
    garmentType: { type: String, required: true },
    items: { type: [String], default: [] },
    measurements: { type: mongoose.Schema.Types.Mixed, default: {} },
    
    isTailorProvidingFabric: { type: Boolean, default: false },

    fabricDetails: {
      type: { type: String },
      length: { type: String },
      color: { type: String },
      photoPath: { type: String },
      fabricId: { type: mongoose.Schema.Types.ObjectId, ref: "Fabric" },
      name: { type: String },
      pricePerMeter: { type: Number },
      quantity: { type: Number },
    },

    handoverType: { type: String, enum: ["pickup", "drop"], required: true },
    pickup: {
      address: String,
      date: String,
      timeSlot: String,
    },
    
    // *** THE FIX: Implement the exact Deposit Model schema ***
    payment: {
      depositAmount: { type: Number, required: true },
      depositMode: { type: String, enum: ["CASH", "ONLINE"] },
      depositStatus: { type: String, enum: ["PENDING", "PAID"], default: "PENDING" },
      remainingAmount: { type: Number, required: true },
      totalAmount: { type: Number, required: true },
    },

    status: {
      type: String,
      enum: [
        "PENDING_DEPOSIT", // Initial status
        "PLACED", 
        "ACCEPTED", 
        "CUTTING", 
        "STITCHING", 
        "FINISHING", 
        "READY",
        "OUT_FOR_DELIVERY", 
        "DELIVERED", 
        "REJECTED", 
        "CANCELLED",
      ],
      default: "PENDING_DEPOSIT",
    },
    deliveryOtp: { type: String },
  },
  { timestamps: true }
);

export default mongoose.model("Order", orderSchema);
