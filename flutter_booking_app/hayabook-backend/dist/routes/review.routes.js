"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const review_controller_1 = require("../controllers/review.controller");
const auth_middleware_1 = require("../middlewares/auth.middleware");
const router = express_1.default.Router();
// @route   POST /api/reviews
// @desc    Add a review for a completed service
// @access  Private (Client only)
router.post('/', auth_middleware_1.authMiddleware, review_controller_1.createReview);
// @route   GET /api/reviews/provider/:providerId
// @desc    Get all reviews for a specific provider business
// @access  Public (Used for listing profile)
router.get('/provider/:providerId', review_controller_1.getProviderReviews);
exports.default = router;
