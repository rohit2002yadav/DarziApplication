import mongoose from "mongoose";

/**
 * Fabric Schema
 * --------------
 * Represents a single fabric item uploaded by a tailor to their personal inventory.
 */
const fabricSchema = new mongoose.Schema({
  /**
   * Link to the tailor who owns this fabric.
   */
  tailorId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true
  },

  /**
   * Name or title of the fabric (e.g., "Italian Cotton Giza").
   */
  name: {
    type: String,
    required: true,
    trim: true
  },

  /**
   * Fabric type (e.g., "Cotton", "Silk", "Linen").
   */
  type: {
    type: String,
    required: true
  },

  /**
   * Color of the fabric.
   */
  color: {
    type: String
  },

  /**
   * Price per meter, set by the tailor.
   */
  pricePerMeter: {
    type: Number,
    required: true,
    min: 0
  },

  /**
   * Available quantity in meters.
   */
  availableQty: {
    type: Number,
    default: 10 // Default to 10 meters
  },

  /**
   * URL of the uploaded fabric photo.
   */
  imageUrl: {
    type: String,
    required: true
  },

  /**
   * Simple flag to show/hide fabric from customers.
   */
  isAvailable: {
    type: Boolean,
    default: true
  }
}, { timestamps: true });

export default mongoose.model("Fabric", fabricSchema);
