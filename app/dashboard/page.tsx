'use client';

import { TrendingUp, Calendar, Users, DollarSign, AlertCircle } from 'lucide-react';
import { LineChart, Line, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer, PieChart, Pie, Cell } from 'recharts';

// Sample data for charts
const bookingData = [
  { date: 'Mon', bookings: 8 },
  { date: 'Tue', bookings: 12 },
  { date: 'Wed', bookings: 10 },
  { date: 'Thu', bookings: 14 },
  { date: 'Fri', bookings: 16 },
  { date: 'Sat', bookings: 9 },
  { date: 'Sun', bookings: 4 },
];

const revenueData = [
  { name: 'General Consultation', value: 45000, color: '#0D9488' },
  { name: 'Specialist Appointment', value: 35000, color: '#F97316' },
  { name: 'Health Screening', value: 28000, color: '#10B981' },
];

const recentBookings = [
  { id: 1, client: 'Ahmed Hassan', service: 'General Consultation', date: '2024-03-15', amount: 3000, status: 'confirmed' },
  { id: 2, client: 'Fatima Ali', service: 'Health Screening', date: '2024-03-14', amount: 4000, status: 'completed' },
  { id: 3, client: 'Omar Mohamed', service: 'Specialist Appointment', date: '2024-03-13', amount: 5000, status: 'confirmed' },
  { id: 4, client: 'Leila Ben', service: 'General Consultation', date: '2024-03-12', amount: 3000, status: 'completed' },
  { id: 5, client: 'Karim Abd', service: 'Health Screening', date: '2024-03-11', amount: 4000, status: 'pending' },
];

export default function DashboardPage() {
  return (
    <div className="max-w-7xl mx-auto space-y-8">
      {/* Page Title */}
      <div>
        <h1 className="text-3xl font-bold text-foreground">Dashboard</h1>
        <p className="text-muted-foreground">Welcome back! Here's your business overview.</p>
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-1 gap-6 md:grid-cols-2 lg:grid-cols-4">
        {/* Today's Bookings */}
        <div className="rounded-xl border border-border bg-card p-6">
          <div className="flex items-start justify-between mb-4">
            <div>
              <p className="text-sm text-muted-foreground mb-1">Today's Bookings</p>
              <p className="text-3xl font-bold text-foreground">12</p>
            </div>
            <div className="h-12 w-12 rounded-lg bg-primary/20 flex items-center justify-center">
              <Calendar className="h-6 w-6 text-primary" />
            </div>
          </div>
          <p className="text-xs text-success font-semibold">↑ 5% from last week</p>
        </div>

        {/* Total Revenue */}
        <div className="rounded-xl border border-border bg-card p-6">
          <div className="flex items-start justify-between mb-4">
            <div>
              <p className="text-sm text-muted-foreground mb-1">Total Revenue</p>
              <p className="text-3xl font-bold text-foreground">DZD 45,000</p>
            </div>
            <div className="h-12 w-12 rounded-lg bg-accent/20 flex items-center justify-center">
              <DollarSign className="h-6 w-6 text-accent" />
            </div>
          </div>
          <p className="text-xs text-success font-semibold">↑ 2.3% from last month</p>
        </div>

        {/* Average Rating */}
        <div className="rounded-xl border border-border bg-card p-6">
          <div className="flex items-start justify-between mb-4">
            <div>
              <p className="text-sm text-muted-foreground mb-1">Average Rating</p>
              <p className="text-3xl font-bold text-foreground">4.8/5</p>
            </div>
            <div className="h-12 w-12 rounded-lg bg-warning/20 flex items-center justify-center">
              <span className="text-2xl">⭐</span>
            </div>
          </div>
          <p className="text-xs text-muted-foreground">Based on 124 reviews</p>
        </div>

        {/* Pending Approvals */}
        <div className="rounded-xl border border-border bg-card p-6">
          <div className="flex items-start justify-between mb-4">
            <div>
              <p className="text-sm text-muted-foreground mb-1">Pending Approvals</p>
              <p className="text-3xl font-bold text-destructive">3</p>
            </div>
            <div className="h-12 w-12 rounded-lg bg-destructive/20 flex items-center justify-center">
              <AlertCircle className="h-6 w-6 text-destructive" />
            </div>
          </div>
          <p className="text-xs text-destructive font-semibold">Needs your attention</p>
        </div>
      </div>

      {/* Charts Section */}
      <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
        {/* Bookings Chart */}
        <div className="rounded-xl border border-border bg-card p-6">
          <h3 className="text-lg font-semibold text-foreground mb-6">Bookings This Week</h3>
          <ResponsiveContainer width="100%" height={300}>
            <LineChart data={bookingData}>
              <CartesianGrid strokeDasharray="3 3" stroke="var(--color-border)" />
              <XAxis dataKey="date" stroke="var(--color-muted-foreground)" />
              <YAxis stroke="var(--color-muted-foreground)" />
              <Tooltip 
                contentStyle={{
                  backgroundColor: 'var(--color-card)',
                  border: '1px solid var(--color-border)',
                  borderRadius: '8px',
                }}
                labelStyle={{ color: 'var(--color-foreground)' }}
              />
              <Line
                type="monotone"
                dataKey="bookings"
                stroke="var(--color-primary)"
                strokeWidth={2}
                dot={{ fill: 'var(--color-primary)', r: 4 }}
              />
            </LineChart>
          </ResponsiveContainer>
        </div>

        {/* Revenue by Service */}
        <div className="rounded-xl border border-border bg-card p-6">
          <h3 className="text-lg font-semibold text-foreground mb-6">Revenue by Service</h3>
          <ResponsiveContainer width="100%" height={300}>
            <PieChart>
              <Pie
                data={revenueData}
                cx="50%"
                cy="50%"
                labelLine={false}
                label={({ name, value }) => `${name}: ${(value / 1000).toFixed(0)}K`}
                outerRadius={100}
                fill="#8884d8"
                dataKey="value"
              >
                {revenueData.map((entry, index) => (
                  <Cell key={`cell-${index}`} fill={entry.color} />
                ))}
              </Pie>
              <Tooltip
                contentStyle={{
                  backgroundColor: 'var(--color-card)',
                  border: '1px solid var(--color-border)',
                  borderRadius: '8px)',
                }}
                labelStyle={{ color: 'var(--color-foreground)' }}
                formatter={(value) => `DZD ${(value as number).toLocaleString()}`}
              />
            </PieChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* Recent Bookings Table */}
      <div className="rounded-xl border border-border bg-card overflow-hidden">
        <div className="px-6 py-4 border-b border-border">
          <h3 className="text-lg font-semibold text-foreground">Recent Bookings</h3>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="border-b border-border">
                <th className="px-6 py-4 text-left text-xs font-semibold text-muted-foreground uppercase">
                  Client
                </th>
                <th className="px-6 py-4 text-left text-xs font-semibold text-muted-foreground uppercase">
                  Service
                </th>
                <th className="px-6 py-4 text-left text-xs font-semibold text-muted-foreground uppercase">
                  Date
                </th>
                <th className="px-6 py-4 text-left text-xs font-semibold text-muted-foreground uppercase">
                  Amount
                </th>
                <th className="px-6 py-4 text-left text-xs font-semibold text-muted-foreground uppercase">
                  Status
                </th>
                <th className="px-6 py-4 text-left text-xs font-semibold text-muted-foreground uppercase">
                  Action
                </th>
              </tr>
            </thead>
            <tbody>
              {recentBookings.map((booking) => {
                let statusColor = 'bg-muted text-muted-foreground';
                if (booking.status === 'confirmed') statusColor = 'bg-success/10 text-success';
                if (booking.status === 'pending') statusColor = 'bg-warning/10 text-warning';
                if (booking.status === 'completed') statusColor = 'bg-success/10 text-success';

                return (
                  <tr
                    key={booking.id}
                    className="border-b border-border hover:bg-muted/50 transition-colors"
                  >
                    <td className="px-6 py-4">
                      <p className="font-semibold text-foreground">{booking.client}</p>
                    </td>
                    <td className="px-6 py-4 text-sm text-muted-foreground">
                      {booking.service}
                    </td>
                    <td className="px-6 py-4 text-sm text-muted-foreground">
                      {booking.date}
                    </td>
                    <td className="px-6 py-4 font-semibold text-foreground">
                      DZD {booking.amount.toLocaleString()}
                    </td>
                    <td className="px-6 py-4">
                      <span
                        className={`inline-block px-3 py-1 rounded-full text-xs font-medium capitalize ${statusColor}`}
                      >
                        {booking.status}
                      </span>
                    </td>
                    <td className="px-6 py-4">
                      <button className="text-primary hover:underline text-sm font-medium">
                        View Details
                      </button>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
