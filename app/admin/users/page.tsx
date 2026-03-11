'use client';

import { useState } from 'react';
import { Search, MoreVertical, Trash2, Eye, Ban } from 'lucide-react';
import { Button } from '@/components/ui/button';

interface User {
  id: string;
  name: string;
  email: string;
  phone: string;
  joinDate: string;
  bookings: number;
  status: 'active' | 'inactive' | 'suspended';
}

const mockUsers: User[] = [
  {
    id: '1',
    name: 'Ahmed Hassan',
    email: 'ahmed@example.com',
    phone: '+213 XXX XXXX',
    joinDate: '2024-06-15',
    bookings: 12,
    status: 'active',
  },
  {
    id: '2',
    name: 'Fatima Bouali',
    email: 'fatima@example.com',
    phone: '+213 XXX XXXX',
    joinDate: '2024-08-20',
    bookings: 8,
    status: 'active',
  },
  {
    id: '3',
    name: 'Karim Belkacem',
    email: 'karim@example.com',
    phone: '+213 XXX XXXX',
    joinDate: '2024-07-10',
    bookings: 5,
    status: 'active',
  },
  {
    id: '4',
    name: 'Leila Amara',
    email: 'leila@example.com',
    phone: '+213 XXX XXXX',
    joinDate: '2024-05-30',
    bookings: 0,
    status: 'inactive',
  },
  {
    id: '5',
    name: 'Mohamed Saïdi',
    email: 'mohamed@example.com',
    phone: '+213 XXX XXXX',
    joinDate: '2024-04-12',
    bookings: 3,
    status: 'suspended',
  },
];

export default function UsersPage() {
  const [searchQuery, setSearchQuery] = useState('');
  const [statusFilter, setStatusFilter] = useState<'all' | 'active' | 'inactive' | 'suspended'>('all');

  const filteredUsers = mockUsers.filter((user) => {
    const matchesSearch =
      user.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      user.email.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesStatus = statusFilter === 'all' || user.status === statusFilter;
    return matchesSearch && matchesStatus;
  });

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'active':
        return 'bg-success/10 text-success';
      case 'inactive':
        return 'bg-warning/10 text-warning';
      case 'suspended':
        return 'bg-destructive/10 text-destructive';
      default:
        return 'bg-muted text-muted-foreground';
    }
  };

  return (
    <div className="max-w-7xl mx-auto space-y-6">
      {/* Page Title */}
      <div>
        <h1 className="text-3xl font-bold text-foreground">Manage Users</h1>
        <p className="text-muted-foreground">View and manage all registered users.</p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 gap-4 sm:grid-cols-3">
        <div className="rounded-lg border border-border bg-card p-4">
          <p className="text-sm text-muted-foreground mb-1">Total Users</p>
          <p className="text-2xl font-bold text-foreground">18,920</p>
        </div>
        <div className="rounded-lg border border-border bg-card p-4">
          <p className="text-sm text-muted-foreground mb-1">Active Users</p>
          <p className="text-2xl font-bold text-success">16,230</p>
        </div>
        <div className="rounded-lg border border-border bg-card p-4">
          <p className="text-sm text-muted-foreground mb-1">Inactive/Suspended</p>
          <p className="text-2xl font-bold text-warning">2,690</p>
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
            <option value="active">Active</option>
            <option value="inactive">Inactive</option>
            <option value="suspended">Suspended</option>
          </select>
        </div>
      </div>

      {/* Users Table */}
      <div className="rounded-xl border border-border bg-card overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="border-b border-border bg-muted">
                <th className="px-6 py-4 text-left text-sm font-semibold text-muted-foreground">
                  Name
                </th>
                <th className="px-6 py-4 text-left text-sm font-semibold text-muted-foreground">
                  Email
                </th>
                <th className="px-6 py-4 text-left text-sm font-semibold text-muted-foreground">
                  Join Date
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
              {filteredUsers.map((user) => (
                <tr key={user.id} className="border-b border-border hover:bg-muted/50 transition">
                  <td className="px-6 py-4">
                    <p className="font-semibold text-foreground">{user.name}</p>
                  </td>
                  <td className="px-6 py-4 text-muted-foreground">{user.email}</td>
                  <td className="px-6 py-4 text-muted-foreground">{user.joinDate}</td>
                  <td className="px-6 py-4">
                    <span className="font-semibold text-foreground">{user.bookings}</span>
                  </td>
                  <td className="px-6 py-4">
                    <span
                      className={`inline-flex px-3 py-1 rounded-full text-xs font-medium ${getStatusColor(
                        user.status
                      )}`}
                    >
                      {user.status.charAt(0).toUpperCase() + user.status.slice(1)}
                    </span>
                  </td>
                  <td className="px-6 py-4 text-right">
                    <div className="flex items-center justify-end gap-2">
                      <button className="p-2 hover:bg-muted rounded-lg transition text-muted-foreground hover:text-foreground">
                        <Eye className="h-4 w-4" />
                      </button>
                      <button className="p-2 hover:bg-warning/10 rounded-lg transition text-warning hover:text-warning">
                        <Ban className="h-4 w-4" />
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
        {filteredUsers.length === 0 && (
          <div className="px-6 py-12 text-center">
            <p className="text-muted-foreground">No users found matching your search.</p>
          </div>
        )}
      </div>
    </div>
  );
}
