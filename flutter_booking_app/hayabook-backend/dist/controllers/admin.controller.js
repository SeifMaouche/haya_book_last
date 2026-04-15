"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getGlobalBookings = exports.verifyProvider = exports.toggleUserStatus = exports.getAllUsers = exports.getPlatformStats = void 0;
const client_1 = require("@prisma/client");
const prisma = new client_1.PrismaClient();
const getPlatformStats = async (req, res) => {
    try {
        const [userCount, providerCount, bookingCount, completedBookings] = await Promise.all([
            prisma.user.count(),
            prisma.providerProfile.count(),
            prisma.booking.count(),
            prisma.booking.findMany({
                where: { status: 'COMPLETED' },
                select: { price: true },
            }),
        ]);
        const totalRevenue = completedBookings.reduce((sum, b) => sum + b.price, 0);
        // Grouping by category for the donut chart
        const providersByCategory = await prisma.providerProfile.groupBy({
            by: ['category'],
            _count: {
                id: true,
            },
        });
        res.json({
            totalUsers: userCount,
            totalProviders: providerCount,
            totalBookings: bookingCount,
            totalRevenue,
            categoryDistribution: providersByCategory.map((c) => ({
                category: c.category,
                count: c._count.id,
            })),
        });
    }
    catch (error) {
        console.error('Get Stats Error:', error);
        res.status(500).json({ message: 'Internal Server Error' });
    }
};
exports.getPlatformStats = getPlatformStats;
const getAllUsers = async (req, res) => {
    try {
        const users = await prisma.user.findMany({
            orderBy: { createdAt: 'desc' },
            select: {
                id: true,
                email: true,
                firstName: true,
                lastName: true,
                role: true,
                isActive: true,
                createdAt: true,
            }
        });
        res.json(users);
    }
    catch (error) {
        console.error('Get All Users Error:', error);
        res.status(500).json({ message: 'Internal Server Error' });
    }
};
exports.getAllUsers = getAllUsers;
const toggleUserStatus = async (req, res) => {
    const { id } = req.params;
    const userId = id;
    const { isActive } = req.body;
    try {
        const user = await prisma.user.update({
            where: { id: userId },
            data: { isActive },
        });
        res.json({ message: `User ${isActive ? 'activated' : 'deactivated'} successfully`, user });
    }
    catch (error) {
        console.error('Toggle User Status Error:', error);
        res.status(500).json({ message: 'Internal Server Error' });
    }
};
exports.toggleUserStatus = toggleUserStatus;
const verifyProvider = async (req, res) => {
    const { id } = req.params;
    const profileId = id;
    const { status } = req.body; // APPROVED or REJECTED
    try {
        const profile = await prisma.providerProfile.update({
            where: { id: profileId },
            data: { verificationStatus: status },
        });
        res.json({ message: `Provider status updated to ${status}`, profile });
    }
    catch (error) {
        console.error('Verify Provider Error:', error);
        res.status(500).json({ message: 'Internal Server Error' });
    }
};
exports.verifyProvider = verifyProvider;
const getGlobalBookings = async (req, res) => {
    try {
        const bookings = await prisma.booking.findMany({
            include: {
                client: { select: { firstName: true, lastName: true } },
                providerProfile: { select: { businessName: true } },
                service: { select: { name: true } },
            },
            orderBy: { date: 'desc' },
        });
        res.json(bookings);
    }
    catch (error) {
        console.error('Global Bookings Error:', error);
        res.status(500).json({ message: 'Internal Server Error' });
    }
};
exports.getGlobalBookings = getGlobalBookings;
