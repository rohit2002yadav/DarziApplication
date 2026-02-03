import express from "express";
import Order from "../models/Order.js";

const router = express.Router();

const STATUS_FLOW = {
  ACCEPTED: "CUTTING",
  CUTTING: "STITCHING",
  STITCHING: "FINISHING",
  FINISHING: "READY",
  READY: "DELIVERED", // Simplified final step
};

// CREATE ORDER
router.post("/", async (req, res) => {
  try {
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
    query.status = { $in: ["ACCEPTED", "CUTTING", "STITCHING", "FINISHING", "READY"] };
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
    const todayCount = await Order.countDocuments({ tailorId, createdAt: { $gte: new Date().setHours(0, 0, 0, 0) } });
    res.json({ todayOrders: todayCount });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// CONFIRM DEPOSIT
router.post("/:id/confirm-deposit", async (req, res) => {
  try {
    const order = await Order.findById(req.params.id);
    if (!order) return res.status(404).json({ error: "Order not found" });

    order.payment.depositStatus = "PAID";
    order.status = "ACCEPTED";
    
    const updatedOrder = await order.save();
    res.status(200).json(updatedOrder);
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

// UPDATE STATUS (Handles all steps including DELIVERED)
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

export default router;
