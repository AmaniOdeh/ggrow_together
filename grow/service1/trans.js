const express = require("express");
const router = express.Router();
const transController = require("./transController");
const { authenticateJWT } = require("../middleware/middleware.js");

router.post("/", authenticateJWT, transController.createTransportAd);
router.put("/:adId", authenticateJWT, transController.updateTransportAd);
router.delete("/:adId", authenticateJWT, transController.deleteTransportAd);
router.get("/all", authenticateJWT,transController.getTransportAdsForService4);
module.exports = router;