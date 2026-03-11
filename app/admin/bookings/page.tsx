'use client';

import { useState } from 'react';
import { Search, Eye, Trash2, Calendar } from 'lucide-react';

interface Booking {
  id: string;
  clientName: string;
  providerName: string;
  service: string;
  date: string;
  time: string;
  amount: number;
  status: 'completed' | 'confirmed' | 'pending' | 'cancelled';
}

const mockBookings: Booking[] = [
  {
    id: 'BK001',
    clientName: 'Ahmed Hassan',
    providerName: 'Central Medical Clinic',
    service: 'General Consultation',
    date: '2025-01-25',
    time: '10:00 AM',
    amount: 3000,
    status: 'completed',
  },
  {
    id: 'BK002',
    clientName: 'Fatima Bouali',
    providerName: 'Elite Hair Salon',
    service: 'Hair Coloring',
    date: '2025-01-26',
    time: '2:30 PM',
    amount: 4500,
    status: 'confirmed',
  },
  {
    id: 'BK003',
    clientName: 'Karim Belkacem',
    providerName: 'Pro Tutoring Center',
    service: 'Math Tuition',
    date: '2025-01-27',
    time: '4:00 PM',
    amount: 2000,
    status: 'pending',
  },
  {
    id: 'BK004',
    clientName: 'Leila Amara',
    providerName: 'Green Spa & Wellness',
    service: 'Full Body Massage',
    date: '2025-01-20',
    time: '3:00 PM',
    amount: 5000,
    status: 'cancelled',
  },
  {
    id: 'BK005',
    clientName: 'Mohamed Saïdi',
    providerName: 'Central Medical Clinic',
    service: 'Health Screening',
    date: '2025-01-28',
    time: '9:00 AM',
    amount: 4000,
    status: 'confirmed',
  },
];

export default function BookingsPage() {
  const [searchQuery, setSearchQuery] = useState('');
  const [statusFilter, setStatusFilter] = useState<'all' | 'completed' | 'confirmed' | 'pending' | 'cancelled'>('all');

  const filteredBookings = mockBookings.filter((booking) => {
    const matchesSearch =
      booking.clientName.toLowerCase().includes(searchQuery.toLowerCase()) ||
      booking.providerName.toLowerCase().includes(searchQuery.toLowerCase()) ||
      booking.id.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesStatus = statusFilter === 'all' || booking.status === statusFilter;
    return matchesSearch && matchesStatus;
  });

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'completed':
        return 'bg-success/10 text-success';
      case 'confirmed':
        return 'bg-primary/10 text-primary';
      case 'pending':
        return 'bg-warning/10 text-warning';
      case 'cancelled':
        return 'bg-destructive/10 text-destructive';
      default:
        return 'bg-muted text-muted-foreground';
    }
  };

  const stats = {
    total: mockBookings.length,
    completed: mockBookings.filter((b) => b.status === 'completed').length,
    confirmed: mockBookings.filter((b) => b.status === 'confirmed').length,
    pending: mockBookings.filter((b) => b.status === 'pending').length,
  };

  return (
    <div className="max-w-7xl mx-auto space-y-6">
      {/* Page Title */}
      <div>
        <h1 className="text-3xl font-bold text-foreground">Monitor Bookings</h1>
        <p className="text-muted-foreground">View and manage all bookings in the system.</p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <div className="rounded-lg border border-border bg-card p-4">
          <p className="text-sm text-muted-foreground mb-1">Total Bookings</p>
          <p className="text-2xl font-bold text-foreground">{stats.total}</p>
        </div>
        <div className="rounded-lg border border-border bg-card p-4">
          <p className="text-sm text-muted-foreground mb-1">Completed</p>
          <p className="text-2xl font-bold text-success">{stats.completed}</p>
        </div>
        <div className="rounded-lg border border-border bg-card p-4">
          <p className="text-sm text-muted-foreground mb-1">Confirmed</p>
          <p className="text-2xl font-bold text-primary">{stats.confirmed}</p>
        </div>
        <div className="rounded-lg border border-border bg-card p-4">
          <p className="text-sm text-muted-foreground mb-1">Pending</p>
          <p className="text-2xl font-bold text-warning">{stats.pending}</p>
        </div>
      </div>

      {/* Filters & Search */}
      <div className="rounded-xl border border-border bg-card p-6">
        <div className="flex flex-col gap-4 sm:flex-row sm:items-center">
          {/* Search */}
          <div className="flex-1 relative">
            <Search className="absolute left-3 top-3 h-5 w-5 text-muted-foreground pointer-events-none" />
            <input
              type="text"
              placeholder="Search by booking ID, client, or provider..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full rounded-lg border border-border bg-background pl-10 pr-4 py-2.5 text-foreground placeholder-muted-foreground focus:outline-none focus:ring-2 focus:ring-primary"
            />
          </div>

          {/* Status Filter */}
          <select
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value as typeof statusFilter)}
            className="rounded-lg border border-border bg-background px-4 py-2.5 text-foreground focus:outline-none focus:ring-2 focus:ring-primary"
          >
            <option value="all">All Status</option>
            <option value="completed">Completed</option>
            <option value="confirmed">Confirmed</option>
            <option value="pending">Pending</option>
            <option value="cancelled">Cancelled</option>
          </select>
        </div>
      </div>

      {/* Bookings Table */}
      <div className="rounded-xl border border-border bg-card overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-border bg-muted">
                <th className="px-6 py-4 text-left font-semibold text-muted-foreground">ID</th>
                <th className="px-6 py-4 text-left font-semibold text-muted-foreground">Client</th>
                <th className="px-6 py-4 text-left font-semibold text-muted-foreground">Provider</th>
                <th className="px-6 py-4 text-left font-semibold text-muted-foreground">Service</th>
                <th className="px-6 py-4 text-left font-semibold text-muted-foreground">Date & Time</th>
                <th className="px-6 py-4 text-right font-semibold text-muted-foreground">Amount</th>
                <th className="px-6 py-4 text-left font-semibold text-muted-foreground">Status</th>
                <th className="px-6 py-4 text-right font-semibold text-muted-foreground">Actions</th>
              </tr>
            </thead>
            <tbody>
              {filteredBookings.map((booking) => (
                <tr key={booking.id} className="border-b border-border hover:bg-muted/50 transition">
                  <td className="px-6 py-4 font-mono font-semibold text-foreground">{booking.id}</td>
                  <td className="px-6 py-4 text-foreground">{booking.clientName}</td>
                  <td className="px-6 py-4 text-foreground">{booking.providerName}</td>
                  <td className="px-6 py-4 text-muted-foreground">{booking.service}</td>
                  <td className="px-6 py-4 text-muted-foreground">
                    <div className="flex items-center gap-2">
                      <Calendar className="h-4 w-4" />
                      {booking.date} {booking.time}
                    </div>
                  </td>
                  <td className="px-6 py-4 text-right font-semibold text-foreground">
                    DZD {booking.amount.toLocaleString()}
                  </td>
                  <td className="px-6 py-4">
                    <span
                      className={`inline-flex px-3 py-1 rounded-full text-xs font-medium ${getStatusColor(
                        booking.status
                      )}`}
                    >
                      {booking.status.charAt(0).toUpperCase() + booking.status.slice(1)}
                    </span>
                  </td>
                  <td className="px-6 py-4 text-right">
                    <div className="flex items-center justify-end gap-2">
                      <button className="p-2 hover:bg-muted rounded-lg transition text-muted-foreground hover:text-foreground">
                        <Eye className="h-4 w-4" />
                      </button>
                      <button className="p-2 hover:bg-destructive/10 rounded-lg transition text-destructive hover:text-destructive">
                        <Trash2 className="h-4 w-4" />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {/* Empty State */}
        {filteredBookings.length === 0 && (
          <div className="px-6 py-12 text-center">
            <p className="text-muted-foreground">No bookings found matching your search.</p>
          </div>
        )}
      </div>
    </div>
  );
}
