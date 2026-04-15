"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.deleteService = exports.updateService = exports.getMyServices = exports.createService = void 0;
const client_1 = require("@prisma/client");
const prisma = new client_1.PrismaClient();
const createService = async (req, res) => {
    const { name, description, options } = req.body;
    try {
        if (!req.user || req.user.role !== 'PROVIDER') {
            return res.status(403).json({ message: 'Only providers can create services' });
        }
        const provider = await prisma.providerProfile.findUnique({
            where: { userId: req.user.id },
        });
        if (!provider) {
            return res.status(404).json({ message: 'Provider profile not found' });
        }
        const service = await prisma.service.create({
            data: {
                providerProfileId: provider.id,
                name,
                description,
                options: {
                    create: options, // Array of { name, price, durationMinutes }
                },
            },
            include: {
                options: true,
            },
        });
        res.status(201).json(service);
    }
    catch (error) {
        console.error('Create Service Error:', error);
        res.status(500).json({ message: 'Internal Server Error' });
    }
};
exports.createService = createService;
const getMyServices = async (req, res) => {
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
        const services = await prisma.service.findMany({
            where: { providerProfileId: provider.id },
            include: { options: true },
        });
        res.json(services);
    }
    catch (error) {
        console.error('Get My Services Error:', error);
        res.status(500).json({ message: 'Internal Server Error' });
    }
};
exports.getMyServices = getMyServices;
const updateService = async (req, res) => {
    const { id } = req.params;
    const { name, description, options } = req.body;
    try {
        if (!req.user) {
            return res.status(401).json({ message: 'Unauthorized' });
        }
        // Check ownership
        const service = await prisma.service.findUnique({
            where: { id: id },
            include: { providerProfile: true },
        });
        if (!service || !service.providerProfile || service.providerProfile.userId !== req.user.id) {
            return res.status(403).json({ message: 'Access denied' });
        }
        // Update service and handle options (simple delete and recreate for options in this example)
        const updatedService = await prisma.service.update({
            where: { id: id },
            data: {
                name,
                description,
                options: {
                    deleteMany: {},
                    create: options,
                },
            },
            include: { options: true },
        });
        res.json(updatedService);
    }
    catch (error) {
        console.error('Update Service Error:', error);
        res.status(500).json({ message: 'Internal Server Error' });
    }
};
exports.updateService = updateService;
const deleteService = async (req, res) => {
    const { id } = req.params;
    try {
        if (!req.user) {
            return res.status(401).json({ message: 'Unauthorized' });
        }
        const serviceId = id;
        const service = await prisma.service.findUnique({
            where: { id: serviceId },
            include: { providerProfile: true },
        });
        if (!service || !service.providerProfile || service.providerProfile.userId !== req.user.id) {
            return res.status(403).json({ message: 'Access denied' });
        }
        await prisma.service.delete({ where: { id: serviceId } });
        res.json({ message: 'Service deleted successfully' });
    }
    catch (error) {
        console.error('Delete Service Error:', error);
        res.status(500).json({ message: 'Internal Server Error' });
    }
};
exports.deleteService = deleteService;
