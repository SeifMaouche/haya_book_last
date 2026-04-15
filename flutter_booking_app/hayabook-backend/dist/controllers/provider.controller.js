"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getAllProviders = exports.updateProviderProfile = exports.getProviderProfile = exports.becomeProvider = void 0;
const client_1 = require("@prisma/client");
const prisma = new client_1.PrismaClient();
const becomeProvider = async (req, res) => {
    const { businessName, category, description, address, latitude, longitude } = req.body;
    try {
        if (!req.user) {
            return res.status(401).json({ message: 'Unauthorized' });
        }
        // Check if provider profile already exists
        const existingProfile = await prisma.providerProfile.findUnique({
            where: { userId: req.user.id },
        });
        if (existingProfile) {
            return res.status(400).json({ message: 'User is already a provider' });
        }
        // Create provider profile and update user role
        const profile = await prisma.providerProfile.create({
            data: {
                userId: req.user.id,
                businessName,
                category,
                description,
                address,
                latitude,
                longitude,
                verificationStatus: 'PENDING', // All new providers start as PENDING
            },
        });
        // Update user role to PROVIDER
        await prisma.user.update({
            where: { id: req.user.id },
            data: { role: 'PROVIDER' },
        });
        res.status(201).json(profile);
    }
    catch (error) {
        console.error('Become Provider Error:', error);
        res.status(500).json({ message: 'Internal Server Error' });
    }
};
exports.becomeProvider = becomeProvider;
const getProviderProfile = async (req, res) => {
    try {
        if (!req.user) {
            return res.status(401).json({ message: 'Unauthorized' });
        }
        const profile = await prisma.providerProfile.findUnique({
            where: { userId: req.user.id },
            include: {
                services: true, // Also include services offered by the provider
            }
        });
        if (!profile) {
            return res.status(404).json({ message: 'Provider profile not found' });
        }
        res.json(profile);
    }
    catch (error) {
        console.error('Get Provider Profile Error:', error);
        res.status(500).json({ message: 'Internal Server Error' });
    }
};
exports.getProviderProfile = getProviderProfile;
const updateProviderProfile = async (req, res) => {
    const { businessName, category, description, address, latitude, longitude } = req.body;
    try {
        if (!req.user) {
            return res.status(401).json({ message: 'Unauthorized' });
        }
        const updatedProfile = await prisma.providerProfile.update({
            where: { userId: req.user.id },
            data: {
                businessName,
                category,
                description,
                address,
                latitude,
                longitude,
            },
        });
        res.json(updatedProfile);
    }
    catch (error) {
        console.error('Update Provider Profile Error:', error);
        res.status(500).json({ message: 'Internal Server Error' });
    }
};
exports.updateProviderProfile = updateProviderProfile;
const getAllProviders = async (req, res) => {
    const { category } = req.query;
    try {
        const providers = await prisma.providerProfile.findMany({
            where: {
                AND: [
                    { verificationStatus: 'APPROVED' }, // Only show approved providers
                    category ? { category: String(category) } : {},
                ],
            },
            include: {
                user: {
                    select: {
                        firstName: true,
                        lastName: true,
                        profileImage: true,
                    }
                },
                services: true,
            },
        });
        res.json(providers);
    }
    catch (error) {
        console.error('Get All Providers Error:', error);
        res.status(500).json({ message: 'Internal Server Error' });
    }
};
exports.getAllProviders = getAllProviders;
