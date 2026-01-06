import mongoose from "mongoose";

const orderSchema = new mongoose.Schema(
  {
    customerName: {
      type: String,
      required: true,
      trim: true,
    },

    customerPhone: {
      type: String,
      required: true,
    },

    customerEmail: {
      type: String,
    },

    tailorId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },

    garmentType: {
      type: String,
      required: true,
    },

    items: {
      type: [String],
      default: [],
    },

    measurements: {
      type: mongoose.Schema.Types.Mixed, // flexible for future
      default: {},
    },

    handoverType: {
      type: String,
      enum: ["pickup", "drop"],
      required: true,
    },

    pickup: {
      address: String,
      date: String,
      time: String,
    },

    totalAmount: {
      type: Number,
      required: true,
    },

    status: {
      type: String,
      enum: [
        "PLACED",
        "ACCEPTED",
        "CUTTING",
        "STITCHING",
        "FINISHING",
        "DELIVERED",
        "REJECTED",
        "CANCELLED",
      ],
      default: "PLACED",
    },
  },
  { timestamps: true }
);

export default mongoose.model("Order", orderSchema);
