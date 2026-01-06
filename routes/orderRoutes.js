import express from "express";
import Order from "../models/Order.js";

const router = express.Router();

const STATUS_FLOW = {
  ACCEPTED: "CUTTING",
  CUTTING: "STITCHING",
  STITCHING: "FINISHING",
  FINISHING: "DELIVERED",
};

// CREATE ORDER
router.post("/", async (req, res) => {
  try {
    const order = new Order(req.body);
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

  const orders = await Order.find({ customerPhone: phone });
  res.json(orders);
});

// TAILOR ORDERS
router.get("/tailor", async (req, res) => {
  const { tailorId, status } = req.query;
  if (!tailorId) return res.status(400).json({ error: "tailorId required" });

  let query = { tailorId };

  if (status === "ONGOING") {
    query.status = { $in: ["ACCEPTED", "CUTTING", "STITCHING", "FINISHING"] };
  } else if (status) {
    query.status = status;
  }

  const orders = await Order.find(query);
  res.json(orders);
});

// ACCEPT ORDER
router.post("/:id/accept", async (req, res) => {
  const order = await Order.findByIdAndUpdate(
    req.params.id,
    { status: "ACCEPTED" },
    { new: true }
  );

  if (!order) return res.status(404).json({ error: "Order not found" });
  res.json(order);
});

// UPDATE STATUS
router.post("/:id/update-status", async (req, res) => {
  const order = await Order.findById(req.params.id);
  if (!order) return res.status(404).json({ error: "Order not found" });

  const next = STATUS_FLOW[order.status];
  if (!next) return res.status(400).json({ error: "Cannot update further" });

  order.status = next;
  await order.save();

  res.json(order);
});

export default router;
