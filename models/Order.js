import mongoose from "mongoose";

const orderSchema = new mongoose.Schema(
  {
    customerName: { type: String, required: true, trim: true },
    customerPhone: { type: String, required: true },
    customerEmail: { type: String },
    tailorId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
    tailorName: { type: String, required: true },
    tailorPhone: { type: String }, // THE FIX
    tailorAddress: { type: String }, // THE FIX
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
    
    payment: {
      totalAmount: { type: Number, required: true },
      depositAmount: { type: Number, required: true },
      remainingAmount: { type: Number, required: true },
      depositMode: { type: String, enum: ["CASH", "ONLINE"] },
      depositStatus: { type: String, enum: ["PENDING", "PAID"], default: "PENDING" },
      paymentStatus: { 
        type: String, 
        enum: ["PENDING_DEPOSIT", "DEPOSIT_PAID", "PAID"], 
        default: "PENDING_DEPOSIT" 
      },
    },

    status: {
      type: String,
      enum: [
        "PLACED", 
        "ACCEPTED", 
        "CUTTING", 
        "STITCHING", 
        "FINISHING", 
        "READY",
        "DELIVERED", 
        "REJECTED", 
        "CANCELLED",
      ],
      default: "PLACED",
    },
    deliveryOtp: { type: String },
  },
  { timestamps: true }
);

export default mongoose.model("Order", orderSchema);
