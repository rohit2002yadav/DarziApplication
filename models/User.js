import mongoose from "mongoose";

/**
 * User Schema
 * -----------
 * This schema represents both CUSTOMER and TAILOR accounts
 * in the Darzi Direct platform.
 *
 * It handles:
 * - Authentication (email + password + OTP)
 * - Role-based behavior (customer / tailor)
 * - Location-based search
 * - Customer & Tailor profile data
 */

const userSchema = new mongoose.Schema(
  {
    /**
     * Full name of the user
     * Used across the app for greetings, orders, and dashboards
     */
    name: {
      type: String,
      required: true
    },

    /**
     * Email address
     * Used for:
     * - Login
     * - OTP verification
     * - Notifications
     */
    email: {
      type: String,
      required: true,
      unique: true
    },

    /**
     * Phone number
     * Used for:
     * - Contact during pickup/delivery
     * - Alternate communication
     */
    phone: {
      type: String,
      required: true,
      unique: true
    },

    /**
     * Password (hashed using bcrypt)
     * Required for login
     * OTP is used only for verification, not authentication
     */
    password: {
      type: String,
      required: true
    },

    /**
     * Role of the user
     * customer → places orders
     * tailor   → receives and fulfills orders
     */
    role: {
      type: String,
      enum: ["customer", "tailor"],
      default: "customer"
    },

    /**
     * Email verification status
     * User can log in only if this is true
     */
    isVerified: {
      type: Boolean,
      default: false
    },

    /**
     * Account status
     * Kept for future flexibility (blocking, moderation, etc.)
     * Currently defaults to ACTIVE as per your requirement
     */
    status: {
      type: String,
      enum: ["PENDING_VERIFICATION", "ACTIVE", "REJECTED"],
      default: "ACTIVE"
    },

    /**
     * One-Time Password (OTP)
     * Used only for email verification & password reset
     */
    otp: {
      type: String
    },

    /**
     * OTP expiry time
     * OTP becomes invalid after this timestamp
     */
    otpExpires: {
      type: Date
    },

    /**
     * Location stored as GeoJSON Point
     * Used for:
     * - Finding nearby tailors
     * - Location-based search
     */
    location: {
      type: {
        type: String,
        default: "Point"
      },

      /**
       * Coordinates format: [longitude, latitude]
       * Default set to Pune (can be updated on signup)
       */
      coordinates: {
        type: [Number],
        default: [73.8567, 18.5204]
      }
    },

    /**
     * Customer-specific details
     * Used only when role = customer
     */
    customerDetails: {
      address: String,
      city: String,
      state: String,
      landmark: String,
      pin: String
    },

    /**
     * Tailor-specific details
     * Used only when role = tailor
     */
    tailorDetails: {
      /**
       * Shop name displayed to customers
       */
      shopName: String,

      /**
       * Type of tailor (men / women / all)
       */
      tailorType: String,

      /**
       * Years of experience
       */
      experience: Number,

      /**
       * Specializations offered by tailor
       * Example: Shirt, Kurta, Blouse
       */
      specializations: [String],

      /**
       * Working days of the week
       */
      workingDays: [String],

      /**
       * Daily working hours
       */
      workingHours: {
        open: String,
        close: String
      },

      /**
       * Pricing information
       */
      pricing: {
        basePrice: Number,
        alterationPrice: Number
      },

      /**
       * Whether tailor provides home pickup service
       */
      homePickup: {
        type: Boolean,
        default: false
      },

      /**
       * Whether tailor can visit customer for measurement
       */
      measurementVisit: {
        type: Boolean,
        default: false
      },

      /**
       * Tailor shop address details
       */
      address: String,
      city: String,
      state: String,
      zipCode: String,
      landmark: String,

      /**
       * Average rating (can be recalculated from reviews)
       */
      rating: {
        type: Number,
        default: 4.5
      },

      /**
       * Availability status
       * Used to hide tailor when busy/unavailable
       */
      isAvailable: {
        type: Boolean,
        default: true
      },

      /**
       * Profile and shop images
       */
      profilePictureUrl: String,
      shopPictureUrl: String,

      /**
       * Photos of previous work
       * Builds trust with customers
       */
      workPhotos: [String]
    }
  },

  /**
   * Automatically adds:
   * - createdAt
   * - updatedAt
   */
  { timestamps: true }
);

/**
 * GeoSpatial index for location-based search
 * Enables efficient "find nearby tailors" queries
 */
userSchema.index({ location: "2dsphere" });

const User = mongoose.model("User", userSchema);
export default User;
