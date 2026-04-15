import express from 'express';
import { search } from '../controllers/search.controller';

const router = express.Router();

// GET /api/search?q=<query>&limit=<max>
// Public — no auth required
router.get('/', search);

export default router;
