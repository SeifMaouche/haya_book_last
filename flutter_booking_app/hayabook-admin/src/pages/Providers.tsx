import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { Search, Star, MapPin, Trash2 } from 'lucide-react';
import adminClient from '../api/client';
import HayaAvatar from '../components/HayaAvatar';

interface Provider {
  id: string;
  businessName: string;
  category: string;
  description: string | null;
  address: string | null;
  rating: number;
  reviewCount: number;
  user: { firstName: string | null; lastName: string | null; email: string | null; phone: string | null; profileImage: string | null; deletedAt: string | null };
  _count: { bookings: number; services: number };
  createdAt: string;
}

export default function Providers() {
  const qc = useQueryClient();
  const [search, setSearch] = useState('');
  
  const { data: providers = [], isLoading } = useQuery<Provider[]>({
    queryKey:  ['admin-providers'],
    queryFn:   () => adminClient.get('/providers').then(r => r.data),
    refetchInterval: 30_000,
  });
  
  const deleteMutation = useMutation({
    mutationFn: (id: string) => adminClient.delete(`/admin/providers/${id}`),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin-providers'] }),
  });
  
  const handleDelete = (p: Provider) => {
    if (window.confirm(`Are you sure you want to PERMANENTLY DELETE and anonymize the provider "${p.businessName}"? Historical bookings will be preserved.`)) {
      deleteMutation.mutate(p.id);
    }
  };
  
  const activeProviders = providers.filter(p => !p.user.deletedAt);
  
  const filtered = activeProviders.filter(p => {
    const q = search.toLowerCase();
    return (
      p.businessName.toLowerCase().includes(q) ||
      p.category.toLowerCase().includes(q) ||
      `${p.user.firstName} ${p.user.lastName}`.toLowerCase().includes(q)
    );
  });

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Providers</h1>
        <p className="text-sm text-gray-500 mt-1">{activeProviders.length} active registered providers</p>
      </div>

      {/* Filters */}
      <div className="flex flex-wrap gap-3">
        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
          <input
            value={search} onChange={e => setSearch(e.target.value)}
            placeholder="Search providers…"
            className="pl-9 pr-4 py-2.5 text-sm border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-violet-400/40"
          />
        </div>
      </div>

      {/* Table */}
      <div className="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
        <div className="overflow-x-auto">
          {isLoading ? (
            <div className="p-6 space-y-3">
              {Array.from({ length: 5 }).map((_, i) => <div key={i} className="h-16 bg-gray-100 rounded-lg animate-pulse" />)}
            </div>
          ) : (
            <table className="w-full text-sm text-left text-gray-600">
              <thead className="text-xs uppercase bg-gray-50 text-gray-500 border-b border-gray-100">
                <tr>
                  <th className="px-6 py-3">Business</th>
                  <th className="px-6 py-3">Owner</th>
                  <th className="px-6 py-3">Category</th>
                  <th className="px-6 py-3 text-center">Bookings</th>
                  <th className="px-6 py-3 text-center">Rating</th>
                  <th className="px-6 py-3 text-center">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100">
                {filtered.map(p => (
                  <tr key={p.id} className="hover:bg-gray-50/50 transition-colors">
                    <td className="px-6 py-4">
                      <p className="font-semibold text-gray-800">{p.businessName}</p>
                      {p.address && (
                        <p className="text-xs text-gray-400 flex items-center gap-1 mt-0.5">
                          <MapPin className="w-3 h-3" /> {p.address}
                        </p>
                      )}
                    </td>
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-3">
                        <HayaAvatar 
                          src={p.user.profileImage} 
                          firstName={p.user.firstName} 
                          lastName={p.user.lastName} 
                          role="PROVIDER"
                          size={32}
                        />
                        <div>
                          <p className="text-sm font-medium text-gray-900">{p.user.firstName} {p.user.lastName}</p>
                          <p className="text-xs text-gray-400">{p.user.email}</p>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <span className="bg-violet-50 text-violet-700 text-xs font-medium px-2.5 py-1 rounded-full">
                        {p.category}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-center font-mono">{p._count.bookings}</td>
                    <td className="px-6 py-4 text-center">
                      <span className="flex items-center justify-center gap-1">
                        <Star className="w-3.5 h-3.5 text-amber-400 fill-amber-400" />
                        {p.rating.toFixed(1)} <span className="text-gray-400 text-xs">({p.reviewCount})</span>
                      </span>
                    </td>
                    <td className="px-6 py-4 text-center">
                      <button
                        onClick={() => handleDelete(p)}
                        className="p-1.5 hover:bg-red-50 text-red-600 rounded-lg transition-colors inline-flex"
                        title="Delete Provider"
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </td>
                  </tr>
                ))}
                {!filtered.length && (
                  <tr><td colSpan={6} className="px-6 py-10 text-center text-gray-400">No providers found</td></tr>
                )}
              </tbody>
            </table>
          )}
        </div>
      </div>
    </div>
  );
}
