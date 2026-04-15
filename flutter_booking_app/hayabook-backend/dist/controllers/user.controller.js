"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.updateMe = exports.getMe = void 0;
const client_1 = require("@prisma/client");
const prisma = new client_1.PrismaClient();
const getMe = async (req, res) => {
    try {
        if (!req.user) {
            return res.status(401).json({ message: 'Unauthorized' });
        }
        const user = await prisma.user.findUnique({
            where: { id: req.user.id },
            include: {
                providerProfile: true, // Also include provider profile if it exists
            }
        });
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }
        const { passwordHash: _, ...userWithoutPassword } = user;
        res.json(userWithoutPassword);
    }
    catch (error) {
        console.error('Get User Error:', error);
        res.status(500).json({ message: 'Internal Server Error' });
    }
};
exports.getMe = getMe;
const updateMe = async (req, res) => {
    const { firstName, lastName, profileImage } = req.body;
    try {
        if (!req.user) {
            return res.status(401).json({ message: 'Unauthorized' });
        }
        const updatedUser = await prisma.user.update({
            where: { id: req.user.id },
            data: {
                firstName,
                lastName,
                profileImage,
            },
        });
        const { passwordHash: _, ...userWithoutPassword } = updatedUser;
        res.json(userWithoutPassword);
    }
    catch (error) {
        console.error('Update User Error:', error);
        res.status(500).json({ message: 'Internal Server Error' });
    }
};
exports.updateMe = updateMe;
