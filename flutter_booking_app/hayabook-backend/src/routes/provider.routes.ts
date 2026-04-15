import express from 'express';
import {
  becomeProvider,
  getProviderProfile,
  updateProviderProfile,
  getAllProviders,
  getProviderById,
  getProviderStats,
  getAvailability,
  saveAvailability,
  uploadPortfolioImages,
  deletePortfolioImage,
} from '../controllers/provider.controller';
import { authMiddleware } from '../middlewares/auth.middleware';
import { upload } from '../middlewares/upload.middleware';

const router = express.Router();

// @route   POST /api/providers/become
// @access  Private
router.post('/become', authMiddleware, becomeProvider);

// @route   GET /api/providers/all  — public client browse
// @access  Public
router.get('/all', getAllProviders);

// @route   GET /api/providers/profile  — own provider profile
// @access  Private
router.get('/profile', authMiddleware, getProviderProfile);

// @route   PATCH /api/providers/profile
// @access  Private
router.patch('/profile', authMiddleware, upload.single('profileImage'), updateProviderProfile);

// @route   GET /api/providers/stats
// @access  Private
router.get('/stats', authMiddleware, getProviderStats);

// @route   GET /api/providers/availability
// @access  Private
router.get('/availability', authMiddleware, getAvailability);

// @route   PUT /api/providers/availability
// @access  Private
router.put('/availability', authMiddleware, saveAvailability);

// @route   POST /api/providers/portfolio
// @access  Private
router.post('/portfolio', authMiddleware, upload.array('images', 6), uploadPortfolioImages);

// @route   DELETE /api/providers/portfolio/:imageId
// @access  Private
router.delete('/portfolio/:imageId', authMiddleware, deletePortfolioImage);

// @route   GET /api/providers/:id  — single provider by ID (must be LAST to avoid shadowing named routes)
// @access  Public
router.get('/:id', getProviderById);

export default router;
