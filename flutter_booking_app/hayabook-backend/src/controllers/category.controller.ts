import { Request, Response } from 'express';
import { prisma } from '../lib/prisma';

// Public — no auth required (Flutter browse screen fetches this)
export const getAllCategories = async (req: Request, res: Response) => {
  const { all } = req.query;
  const showAll = all === 'true';

  try {
    const categories = await prisma.category.findMany({
      where: showAll ? {} : { isActive: true },
      orderBy: { name: 'asc' },
    });
    res.json(categories);
  } catch (error) {
    console.error('Get All Categories Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};

export const createCategory = async (req: Request, res: Response) => {
  const { name, description, icon } = req.body;
  try {
    const category = await prisma.category.create({
      data: { name, description, icon },
    });
    res.status(201).json(category);
  } catch (error) {
    console.error('Create Category Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};

// ✅ New: toggle isActive or rename a category
export const updateCategory = async (req: Request, res: Response) => {
  const id = String(req.params.id);
  const { name, description, icon, isActive } = req.body;
  try {
    const category = await prisma.category.update({
      where: { id },
      data: {
        ...(name !== undefined && { name }),
        ...(description !== undefined && { description }),
        ...(icon !== undefined && { icon }),
        ...(isActive !== undefined && { isActive }),
      },
    });
    res.json(category);
  } catch (error) {
    console.error('Update Category Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};

export const deleteCategory = async (req: Request, res: Response) => {
  const id = String(req.params.id);
  try {
    await prisma.category.delete({ where: { id } });
    res.json({ message: 'Category deleted successfully' });
  } catch (error) {
    console.error('Delete Category Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};
