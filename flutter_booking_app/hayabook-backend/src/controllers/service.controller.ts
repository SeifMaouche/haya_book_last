import { Request, Response } from 'express';
import { prisma } from '../lib/prisma';

interface AuthRequest extends Request {
  user?: {
    id: string;
    role: string;
  };
}

export const createService = async (req: AuthRequest, res: Response) => {
  const { name, description, price, durationMinutes, options } = req.body;

  try {
    if (!req.user || req.user.role !== 'PROVIDER') {
      return res.status(403).json({ message: 'Only providers can create services' });
    }

    if (!name || !price || !durationMinutes) {
      return res.status(400).json({ 
        message: 'Missing required fields: name, price, and durationMinutes are mandatory' 
      });
    }

    const p = Number(price);
    const d = Number(durationMinutes);
    if (isNaN(p) || p < 0 || isNaN(d) || d <= 0) {
      return res.status(400).json({ 
        message: 'Invalid values: price must be >= 0 and duration must be > 0' 
      });
    }

    const provider = await prisma.providerProfile.findUnique({
      where: { userId: req.user.id },
    });

    if (!provider) {
      return res.status(404).json({ message: 'Provider profile not found' });
    }

    const service = await (prisma.service as any).create({
      data: {
        providerProfileId: provider.id,
        name,
        description,
        price: p,
        durationMinutes: d,
        options: {
          create: options, // Array of { name, price, durationMinutes }
        },
      },
      include: {
        options: true,
      },
    });

    res.status(201).json(service);
  } catch (error) {
    console.error('Create Service Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};

export const getMyServices = async (req: AuthRequest, res: Response) => {
  try {
    if (!req.user) {
      return res.status(401).json({ message: 'Unauthorized' });
    }

    const provider = await prisma.providerProfile.findUnique({
      where: { userId: req.user.id },
    });

    if (!provider) {
      return res.status(404).json({ message: 'Provider profile not found' });
    }

    const services = await (prisma.service as any).findMany({
      where: { providerProfileId: provider.id },
      include: { options: true },
    });

    res.json(services);
  } catch (error) {
    console.error('Get My Services Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};

export const updateService = async (req: AuthRequest, res: Response) => {
  const { id } = req.params;
  const { name, description, price, durationMinutes, options } = req.body;

  try {
    if (!req.user) {
      return res.status(401).json({ message: 'Unauthorized' });
    }

    // Check ownership
    const service = await prisma.service.findUnique({
      where: { id: id as string },
      include: { providerProfile: true },
    });

    if (!service || !service.providerProfile || service.providerProfile.userId !== req.user.id) {
      return res.status(403).json({ message: 'Access denied' });
    }

    // Strict validation for updates if they are provided
    let p = service.price;
    let d = service.durationMinutes;

    if (price !== undefined) {
      if (price === null) return res.status(400).json({ message: 'Price cannot be null' });
      p = Number(price);
      if (isNaN(p) || p < 0) return res.status(400).json({ message: 'Invalid price' });
    }
    if (durationMinutes !== undefined) {
      if (durationMinutes === null) return res.status(400).json({ message: 'Duration cannot be null' });
      d = Number(durationMinutes);
      if (isNaN(d) || d <= 0) return res.status(400).json({ message: 'Invalid duration' });
    }

    if (p === null || d === null) {
      return res.status(400).json({ message: 'Service must have a valid price and duration' });
    }

    // Update service and handle options (simple delete and recreate for options in this example)
    const updatedService = await (prisma.service as any).update({
      where: { id: id as string },
      data: {
        name,
        description,
        price: p,
        durationMinutes: d,
        options: {
          deleteMany: {},
          create: options,
        },
      },
      include: { options: true },
    });

    res.json(updatedService);
  } catch (error) {
    console.error('Update Service Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};

export const deleteService = async (req: AuthRequest, res: Response) => {
  const { id } = req.params;

  try {
    if (!req.user) {
      return res.status(401).json({ message: 'Unauthorized' });
    }

    const serviceId = id as string;
    const service = await prisma.service.findUnique({
      where: { id: serviceId },
      include: { providerProfile: true },
    });

    if (!service || !service.providerProfile || service.providerProfile.userId !== req.user.id) {
      return res.status(403).json({ message: 'Access denied' });
    }

    await prisma.service.delete({ where: { id: serviceId } });
    res.json({ message: 'Service deleted successfully' });
  } catch (error) {
    console.error('Delete Service Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};
