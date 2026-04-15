// src/controllers/favorite.controller.ts
import { Request, Response } from 'express';
import { prisma } from '../lib/prisma';

// ─────────────────────────────────────────────────────────────────────
// GET /api/favorites — list all favorite providers for current user
// ─────────────────────────────────────────────────────────────────────
export const getMyFavorites = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user.id;
    const favorites = await prisma.favorite.findMany({
      where:   { userId },
      include: {
        providerProfile: {
          include: {
            user:     { select: { firstName: true, lastName: true, profileImage: true } },
            services: { take: 3, select: { id: true, name: true, price: true, durationMinutes: true } },
            portfolio: { take: 1, select: { url: true } },
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });

    res.json(favorites.map((f) => f.providerProfile));
  } catch (error) {
    console.error('Get Favorites Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};

// ─────────────────────────────────────────────────────────────────────
// POST /api/favorites/toggle — add or remove a provider from favorites
// Body: { providerProfileId }
// ─────────────────────────────────────────────────────────────────────
export const toggleFavorite = async (req: Request, res: Response) => {
  try {
    const userId             = (req as any).user.id;
    const { providerProfileId } = req.body;

    if (!providerProfileId) {
      return res.status(400).json({ message: 'providerProfileId is required' });
    }

    const existing = await prisma.favorite.findUnique({
      where: { userId_providerProfileId: { userId, providerProfileId } },
    });

    if (existing) {
      await prisma.favorite.delete({
        where: { userId_providerProfileId: { userId, providerProfileId } },
      });
      return res.json({ isFavorite: false, message: 'Removed from favorites' });
    } else {
      await prisma.favorite.create({ data: { userId, providerProfileId } });
      return res.json({ isFavorite: true, message: 'Added to favorites' });
    }
  } catch (error) {
    console.error('Toggle Favorite Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};

// ─────────────────────────────────────────────────────────────────────
// GET /api/favorites/check/:providerProfileId — check if favorited
// ─────────────────────────────────────────────────────────────────────
export const checkFavorite = async (req: Request, res: Response) => {
  try {
    const userId             = (req as any).user.id;
    const { providerProfileId } = req.params;

    const existing = await prisma.favorite.findUnique({
      where: { userId_providerProfileId: { userId, providerProfileId } },
    });

    res.json({ isFavorite: !!existing });
  } catch (error) {
    console.error('Check Favorite Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};

// ─────────────────────────────────────────────────────────────────────
// GET /api/favorites/ids — return only an array of favorited provider IDs
// Used by Flutter to quickly seed the local favorites set on startup
// ─────────────────────────────────────────────────────────────────────
export const getMyFavoriteIds = async (req: Request, res: Response) => {
  try {
    const userId   = (req as any).user.id;
    const favorites = await prisma.favorite.findMany({
      where:  { userId },
      select: { providerProfileId: true },
    });
    res.json(favorites.map((f) => f.providerProfileId));
  } catch (error) {
    console.error('Get Favorite IDs Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};
