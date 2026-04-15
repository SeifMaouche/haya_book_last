import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { Search } from 'lucide-react';
import adminClient from '../api/client';

interface Booking {
  id: string;
  client: { firstName: string; lastName: string; email: string | null };
  providerProfile: { businessName: string };
  service: { name: string };
  date: string;
  startTime: string;
  endTime: string;
  status: string;
  price: number;
  notes: string | null;
  createdAt: string;
}

const statusStyle: Record<string, string> = {
  CONFIRMED:             'bg-blue-100   text-blue-700',
  COMPLETED:             'bg-emerald-100 text-emerald-700',
  CANCELLED_BY_CLIENT:   'bg-red-100    text-red-600',
  CANCELLED_BY_PROVIDER: 'bg-red-100    text-red-600',
  NO_SHOW:               'bg-gray-100   text-gray-500',
};

const STATUSES = ['ALL', 'CONFIRMED', 'COMPLETED', 'CANCELLED_BY_CLIENT', 'CANCELLED_BY_PROVIDER', 'NO_SHOW'];

export default function Bookings() {
  const qc = useQueryClient();
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('ALL');

  const { data: bookings = [], isLoading } = useQuery<Booking[]>({
    queryKey:  ['admin-bookings'],
    queryFn:   () => adminClient.get('/bookings').then(r => r.data),
    refetchInterval: 30_000,
  });

  // ── Admin status-change mutation ────────────────────────────────
  const statusMutation = useMutation({
    mutationFn: ({ id, status }: { id: string; status: string }) =>
      adminClient.patch(`/bookings/${id}/status`, { status }),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin-bookings'] }),
  });

  const filtered = bookings.filter(b => {
    const q = search.toLowerCase();
    const matchSearch =
      `${b.client.firstName} ${b.client.lastName}`.toLowerCase().includes(q) ||
      b.providerProfile.businessName.toLowerCase().includes(q) ||
      b.service.name.toLowerCase().includes(q);
    const matchStatus = statusFilter === 'ALL' || b.status === statusFilter;
    return matchSearch && matchStatus;
  });

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Bookings</h1>
        <p className="text-sm text-gray-500 mt-1">{bookings.length} total bookings on the platform</p>
      </div>

      <div className="flex flex-wrap gap-3">
        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
          <input value={search} onChange={e => setSearch(e.target.value)}
            placeholder="Search by client, provider or service…"
            className="pl-9 pr-4 py-2.5 text-sm border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-violet-400/40 w-72"
          />
        </div>
        <select value={statusFilter} onChange={e => setStatusFilter(e.target.value)}
          className="px-4 py-2.5 text-sm border border-gray-200 rounded-xl bg-white focus:outline-none focus:ring-2 focus:ring-violet-400/40">
          {STATUSES.map(s => <option key={s} value={s}>{s.replace(/_/g, ' ')}</option>)}
        </select>
      </div>

      <div className="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
        <div className="overflow-x-auto">
          {isLoading ? (
            <div className="p-6 space-y-3">
              {Array.from({ length: 6 }).map((_, i) => <div key={i} className="h-10 bg-gray-100 rounded-lg animate-pulse" />)}
            </div>
          ) : (
            <table className="w-full text-sm text-left text-gray-600">
              <thead className="text-xs uppercase bg-gray-50 text-gray-500 border-b border-gray-100">
                <tr>
                  <th className="px-6 py-3">Client</th>
                  <th className="px-6 py-3">Provider</th>
                  <th className="px-6 py-3">Service</th>
                  <th className="px-6 py-3">Date & Time</th>
                  <th className="px-6 py-3 text-right">Price</th>
                  <th className="px-6 py-3 text-center">Status</th>
                  <th className="px-6 py-3 text-center">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100">
                {filtered.map(b => (
                  <tr key={b.id} className="hover:bg-gray-50/50 transition-colors">
                    <td className="px-6 py-4 font-medium text-gray-800">{b.client.firstName} {b.client.lastName}</td>
                    <td className="px-6 py-4">{b.providerProfile.businessName}</td>
                    <td className="px-6 py-4">{b.service.name}</td>
                    <td className="px-6 py-4 text-gray-500">
                      {new Date(b.date).toLocaleDateString()} <span className="text-gray-300 mx-1">•</span> {b.startTime}
                    </td>
                    <td className="px-6 py-4 font-mono font-medium text-right">DZD {b.price.toLocaleString()}</td>
                    <td className="px-6 py-4 text-center">
                      <span className={`text-xs font-semibold px-2.5 py-1 rounded-full ${statusStyle[b.status] ?? 'bg-gray-100 text-gray-600'}`}>
                        {b.status.replace(/_/g, ' ')}
                      </span>
                    </td>
                    {/* ── Admin action: change booking status ── */}
                    <td className="px-6 py-4 text-center">
                      <select
                        value={b.status}
                        disabled={statusMutation.isPending}
                        onChange={e => {
                          if (e.target.value !== b.status) {
                            statusMutation.mutate({ id: b.id, status: e.target.value });
                          }
                        }}
                        className="text-xs font-medium px-2 py-1.5 border border-gray-200 rounded-lg bg-white focus:outline-none focus:ring-2 focus:ring-violet-400/40 cursor-pointer disabled:opacity-50"
                      >
                        {['CONFIRMED','COMPLETED','CANCELLED_BY_CLIENT','CANCELLED_BY_PROVIDER','NO_SHOW'].map(s => (
                          <option key={s} value={s}>{s.replace(/_/g, ' ')}</option>
                        ))}
                      </select>
                    </td>
                  </tr>
                ))}
                {!filtered.length && (
                  <tr><td colSpan={7} className="px-6 py-10 text-center text-gray-400">No bookings found</td></tr>
                )}
              </tbody>
            </table>
          )}
        </div>
      </div>
    </div>
  );
}
