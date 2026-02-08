import express from "express";
import Fabric from "../models/Fabric.js";
// import { protect } from "../middleware/authMiddleware.js"; // Optional: Add later for security

const router = express.Router();

// @desc    Get all fabrics for a specific tailor
// @route   GET /api/fabrics/tailor/:tailorId
// @access  Public
router.get("/tailor/:tailorId", async (req, res) => {
  try {
    const fabrics = await Fabric.find({ tailorId: req.params.tailorId, isAvailable: true });
    res.json(fabrics);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// @desc    Create a new fabric item for a tailor
// @route   POST /api/fabrics
// @access  Private (Tailor only)
router.post("/", async (req, res) => {
  // Here you would get tailorId from a JWT token in a real app
  // const { tailorId } = req.user; 
  const { tailorId, name, type, color, pricePerMeter, availableQty, imageUrl } = req.body;

  if (!tailorId || !name || !type || !pricePerMeter || !imageUrl) {
    return res.status(400).json({ message: "Please fill all required fields" });
  }

  const fabric = new Fabric({
    tailorId,
    name,
    type,
    color,
    pricePerMeter,
    availableQty,
    imageUrl,
  });

  try {
    const createdFabric = await fabric.save();
    res.status(201).json(createdFabric);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// @desc    Update a fabric item
// @route   PUT /api/fabrics/:id
// @access  Private (Tailor only)
router.put("/:id", async (req, res) => {
  const { name, type, color, pricePerMeter, availableQty, isAvailable } = req.body;

  try {
    const fabric = await Fabric.findById(req.params.id);

    if (fabric) {
      // Add security check later to ensure only the owner can edit
      fabric.name = name || fabric.name;
      fabric.type = type || fabric.type;
      fabric.color = color || fabric.color;
      fabric.pricePerMeter = pricePerMeter || fabric.pricePerMeter;
      fabric.availableQty = availableQty || fabric.availableQty;
      fabric.isAvailable = isAvailable !== undefined ? isAvailable : fabric.isAvailable;

      const updatedFabric = await fabric.save();
      res.json(updatedFabric);
    } else {
      res.status(404).json({ message: "Fabric not found" });
    }
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// @desc    Delete a fabric item
// @route   DELETE /api/fabrics/:id
// @access  Private (Tailor only)
router.delete("/:id", async (req, res) => {
  try {
    const fabric = await Fabric.findById(req.params.id);

    if (fabric) {
      // Add security check later
      await fabric.remove();
      res.json({ message: "Fabric removed" });
    } else {
      res.status(404).json({ message: "Fabric not found" });
    }
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

export default router;
