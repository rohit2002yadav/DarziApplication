import express from "express";
import Order from "../models/Order.js";

const router = express.Router();

const STATUS_FLOW = {
  ACCEPTED: "CUTTING",
  CUTTING: "STITCHING",
  STITCHING: "FINISHING",
  FINISHING: "READY",
  READY: "OUT_FOR_DELIVERY",
};

// CREATE ORDER
router.post("/", async (req, res) => {
  try {
    // Generate a simple 4-digit OTP for delivery
    const deliveryOtp = Math.floor(1000 + Math.random() * 9000).toString();
    const order = new Order({ ...req.body, deliveryOtp });
    const saved = await order.save();
    res.status(201).json(saved);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// CUSTOMER ORDERS
router.get("/customer", async (req, res) => {
  const { phone } = req.query;
  if (!phone) return res.status(400).json({ error: "Phone required" });

  const orders = await Order.find({ customerPhone: phone }).sort({ createdAt: -1 });
  res.json(orders);
});

// TAILOR ORDERS
router.get("/tailor", async (req, res) => {
  const { tailorId, status } = req.query;
  if (!tailorId) return res.status(400).json({ error: "tailorId required" });

  let query = { tailorId };

  if (status === "ONGOING") {
    query.status = { $in: ["ACCEPTED", "CUTTING", "STITCHING", "FINISHING", "READY", "OUT_FOR_DELIVERY"] };
  } else if (status) {
    query.status = status;
  }

  const orders = await Order.find(query).sort({ updatedAt: -1 });
  res.json(orders);
});

// ANALYTICS
router.get("/analytics", async (req, res) => {
  try {
    const { tailorId } = req.query;
    if (!tailorId) return res.status(400).json({ error: "tailorId required" });

    const todayCount = await Order.countDocuments({
      tailorId,
      createdAt: { $gte: new Date().setHours(0, 0, 0, 0) }
    });
    res.json({ todayOrders: todayCount });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ACCEPT ORDER
router.post("/:id/accept", async (req, res) => {
  try {
    const order = await Order.findByIdAndUpdate(req.params.id, { status: "ACCEPTED" }, { new: true });
    if (!order) return res.status(404).json({ error: "Order not found" });
    res.json(order);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// REJECT ORDER
router.post("/:id/reject", async (req, res) => {
  try {
    const order = await Order.findByIdAndUpdate(req.params.id, { status: "REJECTED" }, { new: true });
    if (!order) return res.status(404).json({ error: "Order not found" });
    res.json(order);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// UPDATE STATUS
router.post("/:id/update-status", async (req, res) => {
  try {
    const order = await Order.findById(req.params.id);
    if (!order) return res.status(404).json({ error: "Order not found" });

    const next = STATUS_FLOW[order.status];
    if (!next) return res.status(400).json({ error: "No further status updates available" });

    order.status = next;
    await order.save();
    res.json(order);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// VERIFY DELIVERY OTP
router.post("/:id/verify-delivery", async (req, res) => {
  try {
    const { otp } = req.body;
    const order = await Order.findById(req.params.id);

    if (!order) return res.status(404).json({ error: "Order not found" });
    if (order.status !== 'OUT_FOR_DELIVERY') return res.status(400).json({ error: "Order is not out for delivery" });
    if (order.deliveryOtp !== otp) return res.status(400).json({ error: "Invalid OTP" });

    order.status = "DELIVERED";
    await order.save();
    res.json(order);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

export default router;
