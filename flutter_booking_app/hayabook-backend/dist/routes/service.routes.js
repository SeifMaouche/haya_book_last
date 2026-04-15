"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const service_controller_1 = require("../controllers/service.controller");
const auth_middleware_1 = require("../middlewares/auth.middleware");
const router = express_1.default.Router();
// @route   POST /api/services
// @desc    Create a new service with options
// @access  Private (Provider only)
router.post('/', auth_middleware_1.authMiddleware, service_controller_1.createService);
// @route   GET /api/services/my
// @desc    Get all services for the authenticated provider
// @access  Private (Provider only)
router.get('/my', auth_middleware_1.authMiddleware, service_controller_1.getMyServices);
// @route   PATCH /api/services/:id
// @desc    Update service and options
// @access  Private (Provider only)
router.patch('/:id', auth_middleware_1.authMiddleware, service_controller_1.updateService);
// @route   DELETE /api/services/:id
// @desc    Delete a service
// @access  Private (Provider only)
router.delete('/:id', auth_middleware_1.authMiddleware, service_controller_1.deleteService);
exports.default = router;
