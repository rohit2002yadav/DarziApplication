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
    
    // This flag determines which fabric flow was used
    isTailorProvidingFabric: { type: Boolean, default: false },

    fabricDetails: {
      // For when customer provides fabric
      type: { type: String },
      length: { type: String },
      color: { type: String },
      photoPath: { type: String },
      
      // For when tailor provides fabric
      fabricId: { type: mongoose.Schema.Types.ObjectId, ref: "Fabric" },
      name: { type: String },
      pricePerMeter: { type: Number },
      quantity: { type: Number },
    },

    // Costs
    fabricCost: { type: Number, default: 0 },
    stitchingCost: { type: Number },
    totalAmount: { type: Number, required: true },

    handoverType: { type: String, enum: ["pickup", "drop"], required: true },
    pickup: { address: String, date: String, time: String },
    status: {
      type: String,
      enum: [
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
      default: "PLACED",
    },
    deliveryOtp: { type: String },
  },
  { timestamps: true }
);

export default mongoose.model("Order", orderSchema);
