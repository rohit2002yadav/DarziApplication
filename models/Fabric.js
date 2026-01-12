import mongoose from "mongoose";

const fabricSchema = new mongoose.Schema({
  tailorId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  name: String,
  type: String,
  color: String,
  pricePerMeter: Number,
  availableQty: Number,
  imageUrl: String,
  isAvailable: { type: Boolean, default: true }
});

export default mongoose.model("Fabric", fabricSchema);
