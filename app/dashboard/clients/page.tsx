'use client';

import { useState } from 'react';
import { Search, MoreVertical, Eye, MessageCircle, Star } from 'lucide-react';
import { Button } from '@/components/ui/button';

interface Client {
  id: string;
  name: string;
  phone: string;
  email: string;
  totalBookings: number;
  lastBooking: string;
  joined: string;
  rating?: number;
  image?: string;
}

export default function ClientsPage() {
  const [searchQuery, setSearchQuery] = useState('');
  const [sortBy, setSortBy] = useState<'name' | 'bookings' | 'recent'>('bookings');

  const clients: Client[] = [
    {
      id: '1',
      name: 'Ahmed Hassan',
      phone: '+213 XXX XXXX',
      email: 'ahmed@example.com',
      totalBookings: 8,
      lastBooking: '2024-03-15',
      joined: '2023-06-12',
      rating: 5,
    },
    {
      id: '2',
      name: 'Fatima Ali',
      phone: '+213 XXX XXXX',
      email: 'fatima@example.com',
      totalBookings: 12,
      lastBooking: '2024-03-14',
      joined: '2023-04-05',
      rating: 4,
    },
    {
      id: '3',
      name: 'Omar Mohamed',
      phone: '+213 XXX XXXX',
      email: 'omar@example.com',
      totalBookings: 5,
      lastBooking: '2024-03-13',
      joined: '2023-09-22',
      rating: 5,
    },
    {
      id: '4',
      name: 'Leila Ben',
      phone: '+213 XXX XXXX',
      email: 'leila@example.com',
      totalBookings: 15,
      lastBooking: '2024-03-12',
      joined: '2023-02-14',
      rating: 4,
    },
    {
      id: '5',
      name: 'Karim Abdullahi',
      phone: '+213 XXX XXXX',
      email: 'karim@example.com',
      totalBookings: 3,
      lastBooking: '2024-03-11',
      joined: '2024-01-10',
      rating: 5,
    },
    {
      id: '6',
      name: 'Nora Hassan',
      phone: '+213 XXX XXXX',
      email: 'nora@example.com',
      totalBookings: 7,
      lastBooking: '2024-03-10',
      joined: '2023-07-18',
      rating: 4,
    },
  ];

  const filteredClients = clients
    .filter((client) =>
      client.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      client.email.toLowerCase().includes(searchQuery.toLowerCase())
    )
    .sort((a, b) => {
      if (sortBy === 'name') return a.name.localeCompare(b.name);
      if (sortBy === 'bookings') return b.totalBookings - a.totalBookings;
      if (sortBy === 'recent') return new Date(b.lastBooking).getTime() - new Date(a.lastBooking).getTime();
      return 0;
    });

  return (
    <div className="max-w-7xl mx-auto space-y-6">
      {/* Page Title */}
      <div>
        <h1 className="text-3xl font-bold text-foreground">Clients</h1>
        <p className="text-muted-foreground">Manage your clients and their booking history.</p>
      </div>

      {/* Search and Sort */}
      <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-3 h-5 w-5 text-muted-foreground" />
          <input
            type="text"
            placeholder="Search by name or email..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full rounded-lg border border-border bg-card pl-10 pr-4 py-2 text-foreground placeholder-muted-foreground focus:outline-none focus:ring-2 focus:ring-primary"
          />
        </div>

        <select
          value={sortBy}
          onChange={(e) => setSortBy(e.target.value as typeof sortBy)}
          className="rounded-lg border border-border bg-card px-4 py-2 text-foreground focus:outline-none focus:ring-2 focus:ring-primary"
        >
          <option value="bookings">Sort by: Bookings</option>
          <option value="name">Sort by: Name</option>
          <option value="recent">Sort by: Recent</option>
        </select>
      </div>

      {/* Clients Table */}
      <div className="rounded-xl border border-border bg-card overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="border-b border-border bg-muted">
                <th className="px-6 py-4 text-left text-xs font-semibold text-muted-foreground uppercase">
                  Name
                </th>
                <th className="px-6 py-4 text-left text-xs font-semibold text-muted-foreground uppercase">
                  Contact
                </th>
                <th className="px-6 py-4 text-left text-xs font-semibold text-muted-foreground uppercase">
                  Bookings
                </th>
                <th className="px-6 py-4 text-left text-xs font-semibold text-muted-foreground uppercase">
                  Last Booking
                </th>
                <th className="px-6 py-4 text-left text-xs font-semibold text-muted-foreground uppercase">
                  Joined
                </th>
                <th className="px-6 py-4 text-left text-xs font-semibold text-muted-foreground uppercase">
                  Rating
                </th>
                <th className="px-6 py-4 text-left text-xs font-semibold text-muted-foreground uppercase">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody>
              {filteredClients.map((client) => (
                <tr
                  key={client.id}
                  className="border-b border-border hover:bg-muted/50 transition-colors"
                >
                  <td className="px-6 py-4">
                    <div className="flex items-center gap-3">
                      <div className="h-10 w-10 rounded-full bg-primary/20 flex items-center justify-center flex-shrink-0">
                        <span className="text-sm font-semibold text-primary">
                          {client.name.charAt(0)}
                        </span>
                      </div>
                      <p className="font-semibold text-foreground">{client.name}</p>
                    </div>
                  </td>
                  <td className="px-6 py-4">
                    <div className="text-sm">
                      <a
                        href={`mailto:${client.email}`}
                        className="text-primary hover:underline block"
                      >
                        {client.email}
                      </a>
                      <a
                        href={`tel:${client.phone}`}
                        className="text-muted-foreground hover:text-foreground"
                      >
                        {client.phone}
                      </a>
                    </div>
                  </td>
                  <td className="px-6 py-4">
                    <p className="font-semibold text-foreground">{client.totalBookings}</p>
                  </td>
                  <td className="px-6 py-4 text-sm text-muted-foreground">
                    {new Date(client.lastBooking).toLocaleDateString('en-US', {
                      month: 'short',
                      day: 'numeric',
                      year: 'numeric',
                    })}
                  </td>
                  <td className="px-6 py-4 text-sm text-muted-foreground">
                    {new Date(client.joined).toLocaleDateString('en-US', {
                      month: 'short',
                      day: 'numeric',
                      year: 'numeric',
                    })}
                  </td>
                  <td className="px-6 py-4">
                    {client.rating && (
                      <div className="flex items-center gap-1">
                        {[...Array(5)].map((_, i) => (
                          <Star
                            key={i}
                            className={`h-4 w-4 ${
                              i < client.rating!
                                ? 'fill-warning text-warning'
                                : 'text-border'
                            }`}
                          />
                        ))}
                      </div>
                    )}
                  </td>
                  <td className="px-6 py-4">
                    <div className="flex items-center gap-2">
                      <button className="p-2 hover:bg-primary/10 rounded-lg transition text-primary">
                        <Eye className="h-4 w-4" />
                      </button>
                      <button className="p-2 hover:bg-primary/10 rounded-lg transition text-primary">
                        <MessageCircle className="h-4 w-4" />
                      </button>
                      <button className="p-2 hover:bg-muted rounded-lg transition text-muted-foreground">
                        <MoreVertical className="h-4 w-4" />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {filteredClients.length === 0 && (
        <div className="text-center py-12">
          <p className="text-muted-foreground mb-4">No clients found</p>
          <Button variant="outline" onClick={() => setSearchQuery('')}>
            Clear search
          </Button>
        </div>
      )}
    </div>
  );
}
