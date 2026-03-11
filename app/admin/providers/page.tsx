'use client';

import { useState } from 'react';
import { Search, MoreVertical, Trash2, Eye, Check, X } from 'lucide-react';
import { Button } from '@/components/ui/button';

interface Provider {
  id: string;
  name: string;
  email: string;
  category: string;
  city: string;
  joinDate: string;
  bookings: number;
  rating: number;
  status: 'approved' | 'pending' | 'rejected';
}

const mockProviders: Provider[] = [
  {
    id: '1',
    name: 'Central Medical Clinic',
    email: 'clinic@example.com',
    category: 'Clinic & Healthcare',
    city: 'Sétif',
    joinDate: '2024-05-20',
    bookings: 245,
    rating: 4.8,
    status: 'approved',
  },
  {
    id: '2',
    name: 'Elite Hair Salon',
    email: 'salon@example.com',
    category: 'Salon & Spa',
    city: 'Algiers',
    joinDate: '2024-06-10',
    bookings: 189,
    rating: 4.6,
    status: 'approved',
  },
  {
    id: '3',
    name: 'Pro Tutoring Center',
    email: 'tutor@example.com',
    category: 'Tutoring & Education',
    city: 'Constantine',
    joinDate: '2024-09-01',
    bookings: 0,
    rating: 0,
    status: 'pending',
  },
  {
    id: '4',
    name: 'Green Spa & Wellness',
    email: 'spa@example.com',
    category: 'Salon & Spa',
    city: 'Oran',
    joinDate: '2024-04-15',
    bookings: 156,
    rating: 4.5,
    status: 'approved',
  },
  {
    id: '5',
    name: 'Downtown Clinic',
    email: 'downtown@example.com',
    category: 'Clinic & Healthcare',
    city: 'Blida',
    joinDate: '2024-08-30',
    bookings: 0,
    rating: 0,
    status: 'pending',
  },
];

export default function ProvidersPage() {
  const [searchQuery, setSearchQuery] = useState('');
  const [statusFilter, setStatusFilter] = useState<'all' | 'approved' | 'pending' | 'rejected'>('all');

  const filteredProviders = mockProviders.filter((provider) => {
    const matchesSearch =
      provider.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      provider.email.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesStatus = statusFilter === 'all' || provider.status === statusFilter;
    return matchesSearch && matchesStatus;
  });

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'approved':
        return 'bg-success/10 text-success';
      case 'pending':
        return 'bg-warning/10 text-warning';
      case 'rejected':
        return 'bg-destructive/10 text-destructive';
      default:
        return 'bg-muted text-muted-foreground';
    }
  };

  return (
    <div className="max-w-7xl mx-auto space-y-6">
      {/* Page Title */}
      <div>
        <h1 className="text-3xl font-bold text-foreground">Manage Providers</h1>
        <p className="text-muted-foreground">View and manage service providers.</p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 gap-4 sm:grid-cols-3">
        <div className="rounded-lg border border-border bg-card p-4">
          <p className="text-sm text-muted-foreground mb-1">Total Providers</p>
          <p className="text-2xl font-bold text-foreground">2,345</p>
        </div>
        <div className="rounded-lg border border-border bg-card p-4">
          <p className="text-sm text-muted-foreground mb-1">Approved</p>
          <p className="text-2xl font-bold text-success">2,150</p>
        </div>
        <div className="rounded-lg border border-border bg-card p-4">
          <p className="text-sm text-muted-foreground mb-1">Pending Review</p>
          <p className="text-2xl font-bold text-warning">195</p>
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
              placeholder="Search by name or email..."
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
            <option value="approved">Approved</option>
            <option value="pending">Pending</option>
            <option value="rejected">Rejected</option>
          </select>
        </div>
      </div>

      {/* Providers Table */}
      <div className="rounded-xl border border-border bg-card overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="border-b border-border bg-muted">
                <th className="px-6 py-4 text-left text-sm font-semibold text-muted-foreground">
                  Business Name
                </th>
                <th className="px-6 py-4 text-left text-sm font-semibold text-muted-foreground">
                  Category
                </th>
                <th className="px-6 py-4 text-left text-sm font-semibold text-muted-foreground">
                  City
                </th>
                <th className="px-6 py-4 text-left text-sm font-semibold text-muted-foreground">
                  Rating
                </th>
                <th className="px-6 py-4 text-left text-sm font-semibold text-muted-foreground">
                  Bookings
                </th>
                <th className="px-6 py-4 text-left text-sm font-semibold text-muted-foreground">
                  Status
                </th>
                <th className="px-6 py-4 text-right text-sm font-semibold text-muted-foreground">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody>
              {filteredProviders.map((provider) => (
                <tr key={provider.id} className="border-b border-border hover:bg-muted/50 transition">
                  <td className="px-6 py-4">
                    <p className="font-semibold text-foreground">{provider.name}</p>
                  </td>
                  <td className="px-6 py-4 text-muted-foreground">{provider.category}</td>
                  <td className="px-6 py-4 text-muted-foreground">{provider.city}</td>
                  <td className="px-6 py-4">
                    {provider.rating > 0 ? (
                      <div className="flex items-center gap-1">
                        <span className="font-semibold text-foreground">{provider.rating}</span>
                        <span className="text-warning">★</span>
                      </div>
                    ) : (
                      <span className="text-muted-foreground">No rating</span>
                    )}
                  </td>
                  <td className="px-6 py-4">
                    <span className="font-semibold text-foreground">{provider.bookings}</span>
                  </td>
                  <td className="px-6 py-4">
                    <span
                      className={`inline-flex px-3 py-1 rounded-full text-xs font-medium ${getStatusColor(
                        provider.status
                      )}`}
                    >
                      {provider.status.charAt(0).toUpperCase() + provider.status.slice(1)}
                    </span>
                  </td>
                  <td className="px-6 py-4 text-right">
                    <div className="flex items-center justify-end gap-2">
                      <button className="p-2 hover:bg-muted rounded-lg transition text-muted-foreground hover:text-foreground">
                        <Eye className="h-4 w-4" />
                      </button>
                      {provider.status === 'pending' && (
                        <>
                          <button className="p-2 hover:bg-success/10 rounded-lg transition text-success hover:text-success">
                            <Check className="h-4 w-4" />
                          </button>
                          <button className="p-2 hover:bg-destructive/10 rounded-lg transition text-destructive hover:text-destructive">
                            <X className="h-4 w-4" />
                          </button>
                        </>
                      )}
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
        {filteredProviders.length === 0 && (
          <div className="px-6 py-12 text-center">
            <p className="text-muted-foreground">No providers found matching your search.</p>
          </div>
        )}
      </div>
    </div>
  );
}
