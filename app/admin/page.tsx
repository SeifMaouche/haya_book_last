'use client';

import { Users, Store, BookOpen, TrendingUp } from 'lucide-react';
import { LineChart, Line, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer, PieChart, Pie, Cell } from 'recharts';

const userGrowthData = [
  { month: 'Jan', users: 400, providers: 120 },
  { month: 'Feb', users: 620, providers: 180 },
  { month: 'Mar', users: 890, providers: 250 },
  { month: 'Apr', users: 1200, providers: 350 },
  { month: 'May', users: 1560, providers: 420 },
  { month: 'Jun', users: 1890, providers: 520 },
];

const categoryData = [
  { name: 'Clinics', value: 245, color: '#0D9488' },
  { name: 'Salons', value: 189, color: '#F97316' },
  { name: 'Tutors', value: 156, color: '#10B981' },
];

const bookingStatusData = [
  { name: 'Confirmed', value: 1850, color: '#0D9488' },
  { name: 'Pending', value: 340, color: '#F59E0B' },
  { name: 'Completed', value: 2890, color: '#10B981' },
  { name: 'Cancelled', value: 230, color: '#EF4444' },
];

const recentActivities = [
  { id: 1, type: 'new_user', message: 'New user registered: Ahmed Hassan', time: '5 min ago' },
  { id: 2, type: 'new_provider', message: 'New provider joined: Elite Hair Salon', time: '15 min ago' },
  { id: 3, type: 'booking', message: '342 bookings completed today', time: '1 hour ago' },
  { id: 4, type: 'report', message: 'New dispute reported by user', time: '2 hours ago' },
  { id: 5, type: 'new_provider', message: 'New provider pending approval', time: '3 hours ago' },
];

export default function AdminDashboardPage() {
  return (
    <div className="max-w-7xl mx-auto space-y-8">
      {/* Page Title */}
      <div>
        <h1 className="text-3xl font-bold text-foreground">Admin Dashboard</h1>
        <p className="text-muted-foreground">System overview and analytics.</p>
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-1 gap-6 md:grid-cols-2 lg:grid-cols-4">
        {/* Total Users */}
        <div className="rounded-xl border border-border bg-card p-6">
          <div className="flex items-start justify-between mb-4">
            <div>
              <p className="text-sm text-muted-foreground mb-1">Total Users</p>
              <p className="text-3xl font-bold text-foreground">18,920</p>
            </div>
            <div className="h-12 w-12 rounded-lg bg-primary/20 flex items-center justify-center">
              <Users className="h-6 w-6 text-primary" />
            </div>
          </div>
          <p className="text-xs text-success font-semibold">↑ 12% from last month</p>
        </div>

        {/* Total Providers */}
        <div className="rounded-xl border border-border bg-card p-6">
          <div className="flex items-start justify-between mb-4">
            <div>
              <p className="text-sm text-muted-foreground mb-1">Total Providers</p>
              <p className="text-3xl font-bold text-foreground">2,345</p>
            </div>
            <div className="h-12 w-12 rounded-lg bg-accent/20 flex items-center justify-center">
              <Store className="h-6 w-6 text-accent" />
            </div>
          </div>
          <p className="text-xs text-success font-semibold">↑ 8% from last month</p>
        </div>

        {/* Total Bookings */}
        <div className="rounded-xl border border-border bg-card p-6">
          <div className="flex items-start justify-between mb-4">
            <div>
              <p className="text-sm text-muted-foreground mb-1">Total Bookings</p>
              <p className="text-3xl font-bold text-foreground">45,230</p>
            </div>
            <div className="h-12 w-12 rounded-lg bg-warning/20 flex items-center justify-center">
              <BookOpen className="h-6 w-6 text-warning" />
            </div>
          </div>
          <p className="text-xs text-success font-semibold">↑ 25% from last month</p>
        </div>

        {/* Total Revenue */}
        <div className="rounded-xl border border-border bg-card p-6">
          <div className="flex items-start justify-between mb-4">
            <div>
              <p className="text-sm text-muted-foreground mb-1">Total Revenue</p>
              <p className="text-3xl font-bold text-foreground">DZD 2.3M</p>
            </div>
            <div className="h-12 w-12 rounded-lg bg-success/20 flex items-center justify-center">
              <TrendingUp className="h-6 w-6 text-success" />
            </div>
          </div>
          <p className="text-xs text-success font-semibold">↑ 18% from last month</p>
        </div>
      </div>

      {/* Charts */}
      <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
        {/* User Growth */}
        <div className="rounded-xl border border-border bg-card p-6">
          <h3 className="text-lg font-semibold text-foreground mb-6">User Growth</h3>
          <ResponsiveContainer width="100%" height={300}>
            <LineChart data={userGrowthData}>
              <CartesianGrid strokeDasharray="3 3" stroke="var(--color-border)" />
              <XAxis dataKey="month" stroke="var(--color-muted-foreground)" />
              <YAxis stroke="var(--color-muted-foreground)" />
              <Tooltip
                contentStyle={{
                  backgroundColor: 'var(--color-card)',
                  border: '1px solid var(--color-border)',
                  borderRadius: '8px',
                }}
              />
              <Legend />
              <Line
                type="monotone"
                dataKey="users"
                stroke="var(--color-primary)"
                strokeWidth={2}
                dot={{ fill: 'var(--color-primary)', r: 4 }}
              />
              <Line
                type="monotone"
                dataKey="providers"
                stroke="var(--color-accent)"
                strokeWidth={2}
                dot={{ fill: 'var(--color-accent)', r: 4 }}
              />
            </LineChart>
          </ResponsiveContainer>
        </div>

        {/* Provider Categories */}
        <div className="rounded-xl border border-border bg-card p-6">
          <h3 className="text-lg font-semibold text-foreground mb-6">Provider Distribution</h3>
          <ResponsiveContainer width="100%" height={300}>
            <PieChart>
              <Pie
                data={categoryData}
                cx="50%"
                cy="50%"
                labelLine={false}
                label={({ name, value }) => `${name}: ${value}`}
                outerRadius={100}
                fill="#8884d8"
                dataKey="value"
              >
                {categoryData.map((entry, index) => (
                  <Cell key={`cell-${index}`} fill={entry.color} />
                ))}
              </Pie>
              <Tooltip
                contentStyle={{
                  backgroundColor: 'var(--color-card)',
                  border: '1px solid var(--color-border)',
                  borderRadius: '8px',
                }}
              />
            </PieChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* Booking Status & Recent Activities */}
      <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
        {/* Booking Status */}
        <div className="rounded-xl border border-border bg-card p-6">
          <h3 className="text-lg font-semibold text-foreground mb-6">Booking Status</h3>
          <ResponsiveContainer width="100%" height={280}>
            <PieChart>
              <Pie
                data={bookingStatusData}
                cx="50%"
                cy="50%"
                labelLine={false}
                label={({ name, value }) => `${name}: ${value}`}
                outerRadius={80}
                fill="#8884d8"
                dataKey="value"
              >
                {bookingStatusData.map((entry, index) => (
                  <Cell key={`cell-${index}`} fill={entry.color} />
                ))}
              </Pie>
              <Tooltip
                contentStyle={{
                  backgroundColor: 'var(--color-card)',
                  border: '1px solid var(--color-border)',
                  borderRadius: '8px',
                }}
              />
            </PieChart>
          </ResponsiveContainer>
        </div>

        {/* Recent Activities */}
        <div className="lg:col-span-2 rounded-xl border border-border bg-card p-6">
          <h3 className="text-lg font-semibold text-foreground mb-6">Recent Activities</h3>
          <div className="space-y-3 max-h-96 overflow-y-auto">
            {recentActivities.map((activity) => (
              <div
                key={activity.id}
                className="flex items-start gap-3 p-3 rounded-lg hover:bg-muted transition"
              >
                <div
                  className={`h-2 w-2 mt-1.5 rounded-full flex-shrink-0 ${
                    activity.type === 'new_user'
                      ? 'bg-primary'
                      : activity.type === 'new_provider'
                        ? 'bg-accent'
                        : activity.type === 'booking'
                          ? 'bg-success'
                          : 'bg-warning'
                  }`}
                />
                <div className="flex-1 min-w-0">
                  <p className="text-sm text-foreground">{activity.message}</p>
                  <p className="text-xs text-muted-foreground">{activity.time}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
