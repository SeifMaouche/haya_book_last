"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.updateBookingStatus = exports.getProviderBookings = exports.getClientBookings = exports.createBooking = void 0;
const client_1 = require("@prisma/client");
const prisma = new client_1.PrismaClient();
// Helper to convert "HH:mm" to minutes from midnight
const timeToMinutes = (time) => {
    const [hours, minutes] = time.split(':').map(Number);
    return hours * 60 + minutes;
};
// Helper to convert minutes back to "HH:mm"
const minutesToTime = (totalMinutes) => {
    const hours = Math.floor(totalMinutes / 60);
    const minutes = totalMinutes % 60;
    return `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}`;
};
const createBooking = async (req, res) => {
    const { providerProfileId, serviceId, serviceOptionId, date, startTime, notes } = req.body;
    try {
        if (!req.user) {
            return res.status(401).json({ message: 'Unauthorized' });
        }
        // 1. Fetch the service/option to get duration and price
        let duration = 0;
        let price = 0;
        if (serviceOptionId) {
            const option = await prisma.serviceOption.findUnique({
                where: { id: serviceOptionId },
            });
            if (!option)
                return res.status(404).json({ message: 'Service option not found' });
            duration = option.durationMinutes;
            price = option.price;
        }
        else {
            const service = await prisma.service.findUnique({
                where: { id: serviceId },
            });
            if (!service || !service.durationMinutes || !service.price) {
                return res.status(400).json({ message: 'Invalid service selected or missing duration' });
            }
            duration = service.durationMinutes;
            price = service.price;
        }
        // 2. Calculate End Time
        const startMins = timeToMinutes(startTime);
        const endMins = startMins + duration;
        const endTime = minutesToTime(endMins);
        // 3. Overlap Prevention Logic
        // Convert date string to Date object (start of day)
        const bookingDate = new Date(date);
        bookingDate.setHours(0, 0, 0, 0);
        const isOverlap = await prisma.$transaction(async (tx) => {
            const existing = await tx.booking.findMany({
                where: {
                    providerProfileId,
                    date: {
                        equals: bookingDate,
                    },
                    status: 'CONFIRMED', // Only check confirmed ones
                },
            });
            // Simple overlap check in memory for the specific date
            return existing.some((b) => {
                const extStart = timeToMinutes(b.startTime);
                const extEnd = timeToMinutes(b.endTime);
                return startMins < extEnd && endMins > extStart;
            });
        });
        if (isOverlap) {
            return res.status(409).json({ message: 'Time slot is already booked. Please choose another time.' });
        }
        // 4. Create Confirmed Booking (Auto-Confirm)
        const booking = await prisma.booking.create({
            data: {
                clientId: req.user.id,
                providerProfileId,
                serviceId,
                serviceOptionId,
                date: bookingDate,
                startTime,
                endTime,
                durationMinutes: duration,
                status: 'CONFIRMED', // Set to confirmed immediately
                price,
                notes,
            },
        });
        res.status(201).json(booking);
    }
    catch (error) {
        console.error('Create Booking Error:', error);
        res.status(500).json({ message: 'Internal Server Error' });
    }
};
exports.createBooking = createBooking;
const getClientBookings = async (req, res) => {
    try {
        if (!req.user) {
            return res.status(401).json({ message: 'Unauthorized' });
        }
        const bookings = await prisma.booking.findMany({
            where: { clientId: req.user.id },
            include: {
                providerProfile: true,
                service: true,
                serviceOption: true,
            },
            orderBy: { date: 'desc' },
        });
        res.json(bookings);
    }
    catch (error) {
        console.error('Get Client Bookings Error:', error);
        res.status(500).json({ message: 'Internal Server Error' });
    }
};
exports.getClientBookings = getClientBookings;
const getProviderBookings = async (req, res) => {
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
        const bookings = await prisma.booking.findMany({
            where: { providerProfileId: provider.id },
            include: {
                client: {
                    select: { firstName: true, lastName: true, phone: true }
                },
                service: true,
                serviceOption: true,
            },
            orderBy: { date: 'desc' },
        });
        res.json(bookings);
    }
    catch (error) {
        console.error('Get Provider Bookings Error:', error);
        res.status(500).json({ message: 'Internal Server Error' });
    }
};
exports.getProviderBookings = getProviderBookings;
const updateBookingStatus = async (req, res) => {
    const { id } = req.params;
    const { status } = req.body;
    try {
        if (!req.user) {
            return res.status(401).json({ message: 'Unauthorized' });
        }
        const bookingId = id;
        // Verify ownership
        const booking = await prisma.booking.findUnique({
            where: { id: bookingId },
            include: { providerProfile: true },
        });
        if (!booking || !booking.providerProfile || booking.providerProfile.userId !== req.user.id) {
            return res.status(403).json({ message: 'Access denied' });
        }
        const updatedBooking = await prisma.booking.update({
            where: { id: bookingId },
            data: { status },
        });
        res.json(updatedBooking);
    }
    catch (error) {
        console.error('Update Booking Error:', error);
        res.status(500).json({ message: 'Internal Server Error' });
    }
};
exports.updateBookingStatus = updateBookingStatus;
