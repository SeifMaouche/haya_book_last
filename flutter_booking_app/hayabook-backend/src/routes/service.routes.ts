import express from 'express';
import { 
  createService, 
  getMyServices, 
  updateService, 
  deleteService 
} from '../controllers/service.controller';
import { authMiddleware } from '../middlewares/auth.middleware';

const router = express.Router();

// @route   POST /api/services
// @desc    Create a new service with options
// @access  Private (Provider only)
router.post('/', authMiddleware, createService);

// @route   GET /api/services/my
// @desc    Get all services for the authenticated provider
// @access  Private (Provider only)
router.get('/my', authMiddleware, getMyServices);

// @route   PATCH /api/services/:id
// @desc    Update service and options
// @access  Private (Provider only)
router.patch('/:id', authMiddleware, updateService);

// @route   DELETE /api/services/:id
// @desc    Delete a service
// @access  Private (Provider only)
router.delete('/:id', authMiddleware, deleteService);

export default router;
