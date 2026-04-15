import express from 'express';
import {
  getMyFavorites,
  toggleFavorite,
  checkFavorite,
  getMyFavoriteIds,
} from '../controllers/favorite.controller';
import { authMiddleware } from '../middlewares/auth.middleware';

const router = express.Router();

// GET  /api/favorites           — full provider objects for favorites list
router.get('/',                          authMiddleware, getMyFavorites);

// GET  /api/favorites/ids       — array of just providerProfileId strings (fast hydration)
router.get('/ids',                       authMiddleware, getMyFavoriteIds);

// POST /api/favorites/toggle    — body: { providerProfileId }
router.post('/toggle',                   authMiddleware, toggleFavorite);

// GET  /api/favorites/check/:id — check single provider
router.get('/check/:providerProfileId',  authMiddleware, checkFavorite);

export default router;
