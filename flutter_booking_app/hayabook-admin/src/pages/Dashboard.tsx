import { useQuery } from '@tanstack/react-query';
import { Users, Briefcase, Calendar, DollarSign, TrendingUp, TrendingDown } from 'lucide-react';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, PieChart, Pie, Cell, Legend } from 'recharts';
import adminClient from '../api/client';

// ── Types ────────────────────────────────────────────────────────────
interface Stats {
  totalUsers: number;
  totalProviders: number;
  totalBookings: number;
  todayBookings: number;
  totalRevenue: number;
  categoryDistribution: { category: string; count: number }[];
}
interface Booking {
  id: string;
  client: { firstName: string; lastName: string };
  providerProfile: { businessName: string };
  service: { name: string };
  date: string;
  startTime: string;
  status: string;
  price: number;
}

const COLORS = ['#7C3AED', '#38BDF8', '#F59E0B', '#34D399', '#F87171'];

const statusColor: Record<string, string> = {
  CONFIRMED:           'bg-blue-100  text-blue-700',
  COMPLETED:           'bg-green-100 text-green-700',
  CANCELLED_BY_CLIENT:   'bg-red-100   text-red-700',
  CANCELLED_BY_PROVIDER: 'bg-red-100   text-red-700',
  PENDING:             'bg-yellow-100 text-yellow-700',
  NO_SHOW:             'bg-gray-100   text-gray-600',
};

// Historical revenue for chart (handled via useQuery below)

function StatCard({ title, value, icon: Icon, sub, positive }: {
  title: string; value: string | number; icon: any; sub?: string; positive?: boolean;
}) {
  return (
    <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
      <div className="flex items-center justify-between mb-4">
        <div className="w-10 h-10 bg-violet-100 rounded-xl flex items-center justify-center">
          <Icon className="w-5 h-5 text-violet-600" />
        </div>
        {sub && (
          <span className={`text-xs font-semibold flex items-center gap-1 ${positive ? 'text-emerald-500' : 'text-red-400'}`}>
            {positive ? <TrendingUp className="w-3 h-3" /> : <TrendingDown className="w-3 h-3" />}
            {sub}
          </span>
        )}
      </div>
      <p className="text-2xl font-bold text-gray-900">{value}</p>
      <p className="text-sm text-gray-500 mt-1">{title}</p>
    </div>
  );
}

export default function Dashboard() {
  const { data: stats, isLoading: statsLoading } = useQuery<Stats>({
    queryKey: ['admin-stats'],
    queryFn: () => adminClient.get('/stats').then(r => r.data),
    refetchInterval: 30_000,
  });

  const { data: revenueData = [] } = useQuery<{ month: string; revenue: number }[]>({
    queryKey: ['admin-revenue'],
    queryFn:  () => adminClient.get('/stats/revenue').then(r => r.data),
  });

  const { data: bookings, isLoading: bookingsLoading } = useQuery<Booking[]>({
    queryKey: ['admin-bookings-recent'],
    queryFn: () => adminClient.get('/bookings').then(r => r.data),
    refetchInterval: 30_000,
  });

  const pieData = stats?.categoryDistribution?.map(c => ({
    name: c.category, value: c.count,
  })) ?? [];

  const recentBookings = (bookings ?? []).slice(0, 7);

  return (
    <div className="space-y-6">
      {/* Stat Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {statsLoading ? (
          Array.from({ length: 4 }).map((_, i) => (
            <div key={i} className="bg-white rounded-2xl border border-gray-100 p-6 animate-pulse h-28" />
          ))
        ) : (
          <>
            <StatCard title="Total Users"      value={stats?.totalUsers ?? 0}    icon={Users}     />
            <StatCard title="Total Providers"  value={stats?.totalProviders ?? 0} icon={Briefcase} />
            <StatCard title="Today's Bookings" value={stats?.todayBookings ?? 0}  icon={Calendar}  />
            <StatCard title="Revenue (DZD)"    value={(stats?.totalRevenue ?? 0).toLocaleString()} icon={DollarSign} />
          </>
        )}
      </div>

      {/* Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100 lg:col-span-2">
          <h3 className="font-bold text-gray-800 mb-6">Revenue Summary</h3>
          <div className="h-[280px]">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={revenueData}>
                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#E5E7EB" />
                <XAxis dataKey="month" axisLine={false} tickLine={false} tick={{ fill: '#9CA3AF', fontSize: 12 }} dy={10} />
                <YAxis axisLine={false} tickLine={false} tick={{ fill: '#9CA3AF', fontSize: 12 }} dx={-10} />
                <Tooltip contentStyle={{ borderRadius: '12px', border: 'none', boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1)' }} />
                <Line type="monotone" dataKey="revenue" stroke="#7C3AED" strokeWidth={3} dot={{ r: 4, strokeWidth: 2 }} activeDot={{ r: 6 }} />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </div>

        <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100">
          <h3 className="font-bold text-gray-800 mb-6">Provider Categories</h3>
          <div className="h-[280px]">
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie data={pieData.length ? pieData : [{ name: 'No data', value: 1 }]}
                  cx="50%" cy="45%" innerRadius={60} outerRadius={80} paddingAngle={5} dataKey="value">
                  {(pieData.length ? pieData : [{ name: 'No data', value: 1 }]).map((_e, i) => (
                    <Cell key={i} fill={COLORS[i % COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip contentStyle={{ borderRadius: '12px', border: 'none' }} />
                <Legend verticalAlign="bottom" height={36} iconType="circle" wrapperStyle={{ fontSize: '12px' }} />
              </PieChart>
            </ResponsiveContainer>
          </div>
        </div>
      </div>

      {/* Recent Bookings */}
      <div className="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
        <div className="px-6 py-5 border-b border-gray-100 flex justify-between items-center bg-gray-50/50">
          <h3 className="font-semibold text-gray-800">Recent Bookings</h3>
          <a href="/bookings" className="text-violet-600 text-sm font-medium hover:underline">View All</a>
        </div>
        <div className="overflow-x-auto">
          {bookingsLoading ? (
            <div className="p-6 space-y-3">
              {Array.from({ length: 5 }).map((_, i) => (
                <div key={i} className="h-8 bg-gray-100 rounded-lg animate-pulse" />
              ))}
            </div>
          ) : (
            <table className="w-full text-left text-sm text-gray-600">
              <thead className="text-xs uppercase bg-gray-50 text-gray-500 border-b border-gray-100">
                <tr>
                  <th className="px-6 py-3 font-semibold">Client</th>
                  <th className="px-6 py-3 font-semibold">Provider</th>
                  <th className="px-6 py-3 font-semibold">Service</th>
                  <th className="px-6 py-3 font-semibold">Date</th>
                  <th className="px-6 py-3 font-semibold text-right">Price</th>
                  <th className="px-6 py-3 font-semibold text-center">Status</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100">
                {recentBookings.map((b) => (
                  <tr key={b.id} className="hover:bg-gray-50/50 transition-colors">
                    <td className="px-6 py-4 font-medium text-gray-800">{b.client.firstName} {b.client.lastName}</td>
                    <td className="px-6 py-4">{b.providerProfile.businessName}</td>
                    <td className="px-6 py-4">{b.service.name}</td>
                    <td className="px-6 py-4 text-gray-500">{new Date(b.date).toLocaleDateString()} • {b.startTime}</td>
                    <td className="px-6 py-4 font-mono font-medium text-right">DZD {b.price.toLocaleString()}</td>
                    <td className="px-6 py-4 text-center">
                      <span className={`inline-block text-xs font-semibold px-2.5 py-1 rounded-full ${statusColor[b.status] ?? 'bg-gray-100 text-gray-600'}`}>
                        {b.status.replace(/_/g, ' ')}
                      </span>
                    </td>
                  </tr>
                ))}
                {!recentBookings.length && (
                  <tr><td colSpan={6} className="px-6 py-10 text-center text-gray-400">No bookings yet</td></tr>
                )}
              </tbody>
            </table>
          )}
        </div>
      </div>
    </div>
  );
}
