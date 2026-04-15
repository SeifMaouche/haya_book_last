import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { Search, UserCheck, UserX, Trash2, ShieldAlert, Eye } from 'lucide-react';
import adminClient from '../api/client';
import UserDetailsModal from '../components/UserDetailsModal';
import HayaAvatar from '../components/HayaAvatar';

interface User {
  id: string;
  email: string | null;
  phone: string | null;
  firstName: string | null;
  lastName: string | null;
  role: string;
  isActive: boolean;
  isVerified: boolean;
  isSuspended: boolean;
  suspensionReason: string | null;
  deletedAt: string | null;
  profileImage: string | null;
  createdAt: string;
  _count: { clientBookings: number };
}

const roleBadge: Record<string, string> = {
  CLIENT:   'bg-blue-100 text-blue-700',
  PROVIDER: 'bg-violet-100 text-violet-700',
  ADMIN:    'bg-amber-100 text-amber-700',
};

export default function Users() {
  const qc = useQueryClient();
  const [search, setSearch] = useState('');
  
  // ── Detail Modal State ───────────────────────────────────────────
  const [viewingUserId, setViewingUserId] = useState<string | null>(null);

  // ── Suspension Modal State ──────────────────────────────────────
  const [suspendingUser, setSuspendingUser] = useState<User | null>(null);
  const [suspendReason, setSuspendReason] = useState('');

  const { data: users = [], isLoading } = useQuery<User[]>({
    queryKey:  ['admin-users'],
    queryFn:   () => adminClient.get('/users').then(r => r.data),
    refetchInterval: 30_000,
  });

  const suspendMutation = useMutation({
    mutationFn: ({ id, isSuspended, reason }: { id: string; isSuspended: boolean; reason?: string }) =>
      adminClient.patch(`/users/${id}/suspend`, { isSuspended, suspensionReason: reason }),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['admin-users'] });
      setSuspendingUser(null);
      setSuspendReason('');
    },
  });

  const deleteMutation = useMutation({
    mutationFn: (id: string) => adminClient.delete(`/users/${id}`),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin-users'] }),
  });

  const filtered = users.filter(u => {
    const q = search.toLowerCase();
    return (
      `${u.firstName} ${u.lastName}`.toLowerCase().includes(q) ||
      (u.email ?? '').toLowerCase().includes(q) ||
      (u.phone ?? '').includes(q)
    );
  });

  const handleDelete = (u: User) => {
    if (window.confirm(`Are you sure you want to PERMANENTLY DELETE and anonymize ${u.firstName}? This cannot be undone.`)) {
      deleteMutation.mutate(u.id);
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Users</h1>
          <p className="text-sm text-gray-500 mt-1">{users.length} registered users</p>
        </div>
      </div>

      {/* Search */}
      <div className="relative max-w-sm">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
        <input
          value={search} onChange={e => setSearch(e.target.value)}
          placeholder="Search by name, email or phone…"
          className="w-full pl-9 pr-4 py-2.5 text-sm border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-violet-400/40"
        />
      </div>

      {/* Table */}
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
                  <th className="px-6 py-3">User</th>
                  <th className="px-6 py-3">Contact</th>
                  <th className="px-6 py-3">Role</th>
                  <th className="px-6 py-3 text-center">Bookings</th>
                  <th className="px-6 py-3">Joined</th>
                  <th className="px-6 py-3 text-center">Status</th>
                  <th className="px-6 py-3 text-center">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100">
                {filtered.map(u => (
                  <tr key={u.id} className={`hover:bg-gray-50/50 transition-colors ${u.deletedAt ? 'opacity-50 grayscale' : ''}`}>
                    <td className="px-6 py-4 font-medium text-gray-800">
                      <div className="flex items-center gap-3">
                        <HayaAvatar 
                          src={u.profileImage} 
                          firstName={u.firstName} 
                          lastName={u.lastName} 
                          role={u.role} 
                          size={32}
                        />
                        <div>
                          {u.firstName} {u.lastName}
                          {u.isVerified && <span title="Verified" className="ml-1 text-emerald-500">✓</span>}
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4 text-gray-500">
                      <div>{u.email}</div>
                      {u.phone && <div className="text-xs">{u.phone}</div>}
                    </td>
                    <td className="px-6 py-4">
                      <span className={`text-xs font-semibold px-2.5 py-1 rounded-full ${roleBadge[u.role] ?? 'bg-gray-100 text-gray-600'}`}>
                        {u.role}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-center font-mono">{u._count.clientBookings}</td>
                    <td className="px-6 py-4 text-gray-500">{new Date(u.createdAt).toLocaleDateString()}</td>
                    <td className="px-6 py-4 text-center">
                      {u.deletedAt ? (
                        <span className="text-xs font-semibold px-2.5 py-1 rounded-full bg-gray-100 text-gray-500 flex items-center justify-center gap-1 mx-auto">
                          <Trash2 className="w-3 h-3" /> DELETED
                        </span>
                      ) : u.isSuspended ? (
                        <span title={u.suspensionReason || ''} className="text-xs font-semibold px-2.5 py-1 rounded-full bg-red-100 text-red-600 flex items-center justify-center gap-1 mx-auto cursor-help">
                          <ShieldAlert className="w-3 h-3" /> SUSPENDED
                        </span>
                      ) : (
                        <span className="text-xs font-semibold px-2.5 py-1 rounded-full bg-emerald-100 text-emerald-700 flex items-center justify-center gap-1 mx-auto">
                          <UserCheck className="w-3 h-3" /> ACTIVE
                        </span>
                      )}
                    </td>
                    <td className="px-6 py-4 text-center">
                      <div className="flex items-center justify-center gap-2">
                        {/* Details */}
                        <button 
                          onClick={() => setViewingUserId(u.id)}
                          className="p-1.5 hover:bg-violet-50 text-violet-600 rounded-lg transition-colors" 
                          title="View Detail Stats"
                        >
                          <Eye className="w-4 h-4" />
                        </button>

                        {/* Suspend/Activate */}
                        {!u.deletedAt && (
                          <button
                            onClick={() => {
                              if (u.isSuspended) {
                                suspendMutation.mutate({ id: u.id, isSuspended: false });
                              } else {
                                setSuspendingUser(u);
                              }
                            }}
                            disabled={u.role === 'ADMIN'}
                            className={`p-1.5 rounded-lg transition-colors ${u.isSuspended ? 'hover:bg-emerald-50 text-emerald-600' : 'hover:bg-amber-50 text-amber-600'}`}
                            title={u.isSuspended ? 'Activate User' : 'Suspend User'}
                          >
                            {u.isSuspended ? <UserCheck className="w-4 h-4" /> : <UserX className="w-4 h-4" />}
                          </button>
                        )}

                        {/* Delete */}
                        {!u.deletedAt && (
                          <button
                            onClick={() => handleDelete(u)}
                            disabled={u.role === 'ADMIN'}
                            className="p-1.5 hover:bg-red-50 text-red-600 rounded-lg transition-colors"
                            title="Delete User"
                          >
                            <Trash2 className="w-4 h-4" />
                          </button>
                        )}
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>
      </div>

      {/* ── Suspension Modal ────────────────────────────────────────── */}
      {suspendingUser && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-sm p-4">
          <div className="bg-white rounded-2xl shadow-2xl w-full max-w-md p-6 animate-in fade-in zoom-in duration-200">
            <div className="flex items-center gap-3 mb-4">
              <div className="w-10 h-10 rounded-full bg-amber-100 flex items-center justify-center text-amber-600">
                <ShieldAlert className="w-5 h-5" />
              </div>
              <h3 className="text-lg font-bold text-gray-900">Suspend User</h3>
            </div>
            
            <p className="text-sm text-gray-500 mb-6 font-medium">
              You are suspending <span className="text-gray-900">{suspendingUser.firstName} {suspendingUser.lastName}</span>. 
              They will be blocked from logging in immediately.
            </p>

            <label className="block text-xs font-bold text-gray-400 mb-2 uppercase tracking-wider">Reason for Suspension</label>
            <textarea
              value={suspendReason}
              onChange={e => setSuspendReason(e.target.value)}
              placeholder="e.g. Terms of Service violation, repeated cancellations..."
              className="w-full px-4 py-3 text-sm border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-amber-500/20 mb-6 min-h-[100px]"
            />

            <div className="flex gap-3">
              <button
                onClick={() => setSuspendingUser(null)}
                className="flex-1 py-2.5 text-sm font-semibold text-gray-600 bg-gray-50 hover:bg-gray-100 rounded-xl transition-colors"
              >
                Cancel
              </button>
              <button
                onClick={() => suspendMutation.mutate({ id: suspendingUser.id, isSuspended: true, reason: suspendReason })}
                disabled={!suspendReason.trim() || suspendMutation.isPending}
                className="flex-1 py-2.5 text-sm font-semibold text-white bg-amber-600 hover:bg-amber-700 disabled:opacity-50 rounded-xl transition-colors shadow-lg shadow-amber-600/20"
              >
                Confirm Suspension
              </button>
            </div>
          </div>
        </div>
      )}

      {/* ── User Details Modal ─────────────────────────────────────── */}
      {viewingUserId && (
        <UserDetailsModal 
          userId={viewingUserId} 
          onClose={() => setViewingUserId(null)} 
        />
      )}
    </div>
  );
}
