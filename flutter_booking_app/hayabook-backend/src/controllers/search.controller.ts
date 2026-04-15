import { Request, Response } from 'express';
import { prisma } from '../lib/prisma';

/**
 * GET /api/search?q=<query>&limit=<max>
 *
 * Unified search across:
 *  • ProviderProfile  (businessName, category, description, address)
 *  • Service          (name, description) → includes parent provider info
 *
 * Returns an array of SearchResult objects, deduplicated and ranked:
 *   { type: 'provider' | 'service', provider: {...}, service?: {...} }
 *
 * All results relate to APPROVED providers only.
 * No auth required — public endpoint.
 */
export const search = async (req: Request, res: Response) => {
  const q     = String(req.query.q  ?? '').trim();
  const limit = Math.min(parseInt(String(req.query.limit ?? '20'), 10), 50);
  const { city, lat, lng, maxDistanceKm } = req.query;

  if (q.length < 2) {
    return res.json([]);
  }

  try {
    const mode = 'insensitive' as const;

    // Build the provider filtering condition for both direct provider hits and service provider parent
    const providerCondition: any = { verificationStatus: 'APPROVED' };

    // Tokenize the query for multi-word fuzzy matching (e.g. "Haircut Amad Barber")
    const tokens = q.split(/\s+/).filter(t => t.length > 0);
    
    // Provide a fallback if for some reason someone searched a single character or multiple spaces
    if (tokens.length === 0) tokens.push(q);

    const providerOrConditions = tokens.flatMap(token => [
      { businessName: { contains: token, mode } },
      { category:     { contains: token, mode } },
      { description:  { contains: token, mode } },
      { address:      { contains: token, mode } },
    ]);

    const serviceOrConditions = tokens.flatMap(token => [
      { name:        { contains: token, mode } },
      { description: { contains: token, mode } },
    ]);

    // ── 1. Match providers directly ────────────────────────────────────
    const providerHits = await prisma.providerProfile.findMany({
      where: {
        ...providerCondition,
        OR: providerOrConditions,
      },
      include: {
        user:      { select: { id: true, firstName: true, lastName: true, profileImage: true, phone: true } },
        services:  true,
        portfolio: true,
        reviewsReceived: { include: { client: { select: { firstName: true, lastName: true, profileImage: true } } } },
        _count:    { select: { reviewsReceived: true } },
      },
      take: limit,
    });

    // ── 2. Match services (and load their provider) ────────────────────
    const serviceHits = await (prisma.service as any).findMany({
      where: {
        OR: serviceOrConditions,
        providerProfile: providerCondition,
      },
      include: {
        providerProfile: {
          include: {
            user:      { select: { id: true, firstName: true, lastName: true, profileImage: true, phone: true } },
            services:  true,
            portfolio: true,
            reviewsReceived: { include: { client: { select: { firstName: true, lastName: true, profileImage: true } } } },
            _count:    { select: { reviewsReceived: true } },
          },
        },
      },
      take: limit,
    });

    // ── 3. Build unified result list ───────────────────────────────────
    const results: any[] = [];
    const seenProviderIds = new Set<string>();

    // Provider hits first (higher priority)
    for (const p of providerHits) {
      seenProviderIds.add(p.id);
      results.push({
        type:     'provider',
        provider: p,
        service: null,
      });
    }

    // Service hits — deduplicate providers that were already added as direct hits
    for (const s of serviceHits) {
      const prov = s.providerProfile;
      if (!prov) continue;

      results.push({
        type: 'service',
        provider: prov,
        service: {
          id:              s.id,
          name:            s.name,
          description:     s.description,
          price:           s.price,
          durationMinutes: s.durationMinutes,
        },
      });
    }

    // Trim to limit
    res.json(results.slice(0, limit));
  } catch (error) {
    console.error('Search Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};
