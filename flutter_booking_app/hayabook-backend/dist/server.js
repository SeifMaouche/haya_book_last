"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.prisma = void 0;
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const helmet_1 = __importDefault(require("helmet"));
const dotenv_1 = __importDefault(require("dotenv"));
const client_1 = require("@prisma/client");
const auth_routes_1 = __importDefault(require("./routes/auth.routes"));
const user_routes_1 = __importDefault(require("./routes/user.routes"));
const provider_routes_1 = __importDefault(require("./routes/provider.routes"));
const service_routes_1 = __importDefault(require("./routes/service.routes"));
const booking_routes_1 = __importDefault(require("./routes/booking.routes"));
const admin_routes_1 = __importDefault(require("./routes/admin.routes"));
const review_routes_1 = __importDefault(require("./routes/review.routes"));
const message_routes_1 = __importDefault(require("./routes/message.routes"));
dotenv_1.default.config();
const app = (0, express_1.default)();
const port = process.env.PORT || 5000;
exports.prisma = new client_1.PrismaClient();
// Middleware
app.use((0, cors_1.default)());
app.use((0, helmet_1.default)());
app.use(express_1.default.json());
// Routes
app.use('/api/auth', auth_routes_1.default);
app.use('/api/users', user_routes_1.default);
app.use('/api/providers', provider_routes_1.default);
app.use('/api/services', service_routes_1.default);
app.use('/api/bookings', booking_routes_1.default);
app.use('/api/admin', admin_routes_1.default);
app.use('/api/reviews', review_routes_1.default);
app.use('/api/messages', message_routes_1.default);
// Root Endpoint
app.get('/', (req, res) => {
    res.json({
        message: '🚀 HayaBook Backend Engine is live!',
        version: '1.0.0',
        documentation: '/api/health',
    });
});
// Health Check
app.get('/api/health', (req, res) => {
    res.status(200).json({ status: 'ok', timestamp: new Date().toISOString() });
});
// Start Server
app.listen(port, () => {
    console.log(`🚀 HayaBook Backend Engine running on http://localhost:${port}`);
});
