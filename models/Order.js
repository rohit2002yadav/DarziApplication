import mongoose from "mongoose";

/**
 * Order Schema
 * -------------
 * This schema represents a single tailoring order placed by a customer
 * and fulfilled by a tailor.
 *
 * It stores:
 * - Customer contact details
 * - Selected tailor
 * - Garment & fabric details
 * - Measurements
 * - Pickup / drop handover info
 * - Order status lifecycle
 */

const orderSchema = new mongoose.Schema(
  {
    /**
     * Customer name
     * Used for:
     * - Display in tailor dashboard
     * - Order identification
     * - Communication clarity
     */
    customerName: {
      type: String,
      required: true,
      trim: true,
    },

    /**
     * Customer phone number
     * Used for:
     * - Contact during pickup/delivery
     * - Order-related communication
     */
    customerPhone: {
      type: String,
      required: true,
    },

    /**
     * Customer email
     * Optional because:
     * - Some users may rely only on phone
     * - Useful for order confirmations & receipts
     */
    customerEmail: {
      type: String,
    },

    /**
     * Tailor assigned to this order
     * References the User collection (role = TAILOR)
     * Used for:
     * - Order ownership
     * - Tailor dashboard & earnings
     */
    tailorId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },

    /**
     * Type of garment to be stitched
     * Example: Shirt, Kurta, Blouse, Pant
     */
    garmentType: {
      type: String,
      required: true,
    },

    /**
     * Extra items / add-ons selected by customer
     * Example:
     * - Collar type
     * - Sleeve type
     * - Pocket
     */
    items: {
      type: [String],
      default: [],
    },

    /**
     * Measurement details
     * Stored as flexible JSON because:
     * - Different garments need different measurements
     * - Allows future expansion
     */
    measurements: {
      type: mongoose.Schema.Types.Mixed,
      default: {},
    },

    /**
     * Fabric information provided by customer
     * Used so tailor clearly understands fabric type
     */
    fabricDetails: {
      /**
       * Fabric type
       * Example: Cotton, Silk, Velvet
       */
      type: { type: String },

      /**
       * Fabric length (meters / pieces)
       */
      length: { type: String },

      /**
       * Fabric color
       */
      color: { type: String },

      /**
       * Uploaded fabric photo path / URL
       * Helps tailor visually confirm fabric
       */
      photoPath: { type: String }
    },

    /**
     * Fabric handover method
     * pickup → tailor or delivery partner collects fabric
     * drop   → customer drops fabric at tailor shop
     */
    handoverType: {
      type: String,
      enum: ["pickup", "drop"],
      required: true,
    },

    /**
     * Pickup details
     * Used only when handoverType = "pickup"
     */
    pickup: {
      address: String,
      date: String,
      time: String,
    },

    /**
     * Final amount charged to customer
     * Includes:
     * - Stitching cost
     * - Pickup charges (if any)
     */
    totalAmount: {
      type: Number,
      required: true,
    },

    /**
     * Order lifecycle status
     * Controls what actions are allowed
     * and what customer sees in tracking
     */
    status: {
      type: String,
      enum: [
        "PLACED",     // Order created by customer
        "ACCEPTED",   // Tailor accepted the order
        "CUTTING",    // Fabric cutting started
        "STITCHING",  // Stitching in progress
        "FINISHING",  // Final finishing
        "READY",      // Ready for pickup/delivery
        "DELIVERED",  // Customer received order
        "REJECTED",   // Tailor rejected order
        "CANCELLED",  // Cancelled by customer/system
      ],
      default: "PLACED",
    },
  },

  /**
   * Automatically adds:
   * - createdAt
   * - updatedAt
   */
  { timestamps: true }
);

export default mongoose.model("Order", orderSchema);
