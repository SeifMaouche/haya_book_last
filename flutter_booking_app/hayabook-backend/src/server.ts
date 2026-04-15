import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import dotenv from 'dotenv';
import { createServer } from 'http';
import { Server as SocketIOServer } from 'socket.io';
import { prisma } from './lib/prisma';

import authRoutes         from './routes/auth.routes';
import userRoutes         from './routes/user.routes';
import providerRoutes     from './routes/provider.routes';
import serviceRoutes      from './routes/service.routes';
import bookingRoutes      from './routes/booking.routes';
import adminRoutes        from './routes/admin.routes';
import reviewRoutes       from './routes/review.routes';
import messageRoutes      from './routes/message.routes';
import notificationRoutes from './routes/notification.routes';
import favoriteRoutes     from './routes/favorite.routes';
import searchRoutes       from './routes/search.routes';
import { getAllCategories } from './controllers/category.controller';
import { submitContactMessage, getMyMessages } from './controllers/contact.controller'; // ✅ FIX C-contact
import { authMiddleware } from './middlewares/auth.middleware';
import { runBookingStatusWorker } from './services/booking-worker.service';


dotenv.config();

const app        = express();
const httpServer = createServer(app);          // wrap Express in HTTP server for Socket.io
const port       = process.env.PORT || 5000;

// ── Socket.io ────────────────────────────────────────────────────────
export const io = new SocketIOServer(httpServer, {
  cors: {
    origin: '*',                               // tighten in production
    methods: ['GET', 'POST'],
  },
});

io.on('connection', (socket) => {
  console.log(`[Socket.io] Client connected: ${socket.id}`);

  // Client joins its own conversation rooms after auth
  socket.on('join_conversation', (conversationId: string) => {
    socket.join(conversationId);
    console.log(`[Socket.io] ${socket.id} joined room: ${conversationId}`);
  });

  socket.on('leave_conversation', (conversationId: string) => {
    socket.leave(conversationId);
  });

  // Client joins their OWN user room (e.g. for booking/notification updates)
  socket.on('join_user', (userId: string) => {
    socket.join(userId);
    console.log(`[Socket.io] User ${userId} joined their personal room`);
  });

  socket.on('leave_user', (userId: string) => {
    socket.leave(userId);
  });

  socket.on('disconnect', () => {
    console.log(`[Socket.io] Client disconnected: ${socket.id}`);
  });
});

import path from 'path';

// ... (other imports)

// ── Middleware ───────────────────────────────────────────────────────
app.use(cors());
app.use(helmet({ crossOriginResourcePolicy: { policy: 'cross-origin' } }));
app.use(express.json());
app.use('/uploads', express.static(path.join(process.cwd(), 'public/uploads')));

// ── API Routes ───────────────────────────────────────────────────────
app.use('/api/auth',       authRoutes);
app.use('/api/users',      userRoutes);
app.use('/api/providers',  providerRoutes);
app.use('/api/services',   serviceRoutes);
app.use('/api/bookings',   bookingRoutes);
app.use('/api/admin',         adminRoutes);
app.use('/api/reviews',       reviewRoutes);
app.use('/api/messages',      messageRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/favorites',     favoriteRoutes);
app.use('/api/search',        searchRoutes);
// ✅ Public categories endpoint — no auth required for Flutter browse screen
app.get('/api/categories', getAllCategories);
// ✅ FIX C-contact: Contact form endpoint — receives in-app support messages
app.post('/api/contact',             authMiddleware, submitContactMessage);
app.get('/api/contact/my-messages', authMiddleware, getMyMessages);

// ── Root & Health ────────────────────────────────────────────────────
app.get('/', (_req, res) => {
  res.json({ message: '🚀 HayaBook Backend Engine is live!', version: '1.0.0' });
});
app.get('/api/health', (_req, res) => {
  res.status(200).json({ status: 'ok', timestamp: new Date().toISOString() });
});

// ── Start (use httpServer, not app, so Socket.io works) ──────────────
httpServer.listen(port, () => {
  console.log(`🚀 HayaBook Backend  →  http://localhost:${port}`);
  console.log(`🔌 Socket.io ready   →  ws://localhost:${port}`);

  // Start the Booking Status Worker (runs every 1 minute)
  setInterval(() => {
    runBookingStatusWorker();
  }, 60 * 1000);
});
