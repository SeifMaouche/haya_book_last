'use client';

import { useState } from 'react';
import { Search, Filter, Check, X, MessageCircle, ChevronDown } from 'lucide-react';
import { Button } from '@/components/ui/button';

interface Appointment {
  id: string;
  clientName: string;
  phone: string;
  email: string;
  service: string;
  date: string;
  time: string;
  amount: number;
  status: 'pending' | 'confirmed' | 'completed' | 'cancelled';
  notes?: string;
}

export default function AppointmentsPage() {
  const [searchQuery, setSearchQuery] = useState('');
  const [statusFilter, setStatusFilter] = useState<'all' | 'pending' | 'confirmed' | 'completed' | 'cancelled'>('all');
  const [showFilters, setShowFilters] = useState(false);
  const [expandedId, setExpandedId] = useState<string | null>(null);

  const appointments: Appointment[] = [
    {
      id: '1',
      clientName: 'Ahmed Hassan',
      phone: '+213 XXX XXXX',
      email: 'ahmed@example.com',
      service: 'General Consultation',
      date: '2024-03-15',
      time: '09:00',
      amount: 3000,
      status: 'pending',
      notes: 'First-time patient, needs initial assessment',
    },
    {
      id: '2',
      clientName: 'Fatima Ali',
      phone: '+213 XXX XXXX',
      email: 'fatima@example.com',
      service: 'Health Screening',
      date: '2024-03-14',
      time: '10:30',
      amount: 4000,
      status: 'confirmed',
    },
    {
      id: '3',
      clientName: 'Omar Mohamed',
      phone: '+213 XXX XXXX',
      email: 'omar@example.com',
      service: 'Specialist Appointment',
      date: '2024-03-13',
      time: '14:00',
      amount: 5000,
      status: 'completed',
    },
    {
      id: '4',
      clientName: 'Leila Ben',
      phone: '+213 XXX XXXX',
      email: 'leila@example.com',
      service: 'General Consultation',
      date: '2024-03-12',
      time: '11:00',
      amount: 3000,
      status: 'confirmed',
    },
    {
      id: '5',
      clientName: 'Karim Abdullahi',
      phone: '+213 XXX XXXX',
      email: 'karim@example.com',
      service: 'Health Screening',
      date: '2024-03-11',
      time: '15:30',
      amount: 4000,
      status: 'pending',
    },
  ];

  const filteredAppointments = appointments.filter((apt) => {
    const matchesSearch =
      apt.clientName.toLowerCase().includes(searchQuery.toLowerCase()) ||
      apt.service.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesStatus = statusFilter === 'all' || apt.status === statusFilter;
    return matchesSearch && matchesStatus;
  });

  const getStatusColor = (status: Appointment['status']) => {
    switch (status) {
      case 'pending':
        return 'bg-warning/10 text-warning';
      case 'confirmed':
        return 'bg-success/10 text-success';
      case 'completed':
        return 'bg-success/10 text-success';
      case 'cancelled':
        return 'bg-destructive/10 text-destructive';
      default:
        return 'bg-muted text-muted-foreground';
    }
  };

  const getStatusLabel = (status: Appointment['status']) => {
    return status.charAt(0).toUpperCase() + status.slice(1);
  };

  return (
    <div className="max-w-7xl mx-auto space-y-6">
      {/* Page Title */}
      <div>
        <h1 className="text-3xl font-bold text-foreground">Appointments</h1>
        <p className="text-muted-foreground">Manage your booking requests and appointments.</p>
      </div>

      {/* Search and Filter */}
      <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-3 h-5 w-5 text-muted-foreground" />
          <input
            type="text"
            placeholder="Search by client name or service..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full rounded-lg border border-border bg-card pl-10 pr-4 py-2 text-foreground placeholder-muted-foreground focus:outline-none focus:ring-2 focus:ring-primary"
          />
        </div>

        <Button
          variant="outline"
          size="sm"
          onClick={() => setShowFilters(!showFilters)}
          className="gap-2"
        >
          <Filter className="h-4 w-4" />
          Filters
        </Button>
      </div>

      {/* Status Filter Bar */}
      {showFilters && (
        <div className="rounded-lg border border-border bg-card p-4">
          <div className="flex flex-wrap gap-2">
            {(['all', 'pending', 'confirmed', 'completed', 'cancelled'] as const).map((status) => (
              <Button
                key={status}
                variant={statusFilter === status ? 'default' : 'outline'}
                size="sm"
                onClick={() => setStatusFilter(status)}
                className="capitalize"
              >
                {status === 'all' ? 'All Status' : getStatusLabel(status as Appointment['status'])}
              </Button>
            ))}
          </div>
        </div>
      )}

      {/* Appointments List */}
      <div className="space-y-4">
        {filteredAppointments.map((appointment) => (
          <div
            key={appointment.id}
            className="rounded-xl border border-border bg-card overflow-hidden hover:shadow-lg transition-all"
          >
            {/* Header */}
            <button
              onClick={() =>
                setExpandedId(expandedId === appointment.id ? null : appointment.id)
              }
              className="w-full px-6 py-4 flex items-center justify-between hover:bg-muted/50 transition"
            >
              <div className="flex items-center gap-4 flex-1 text-left">
                <div className="flex-1">
                  <h3 className="font-semibold text-foreground mb-1">
                    {appointment.clientName}
                  </h3>
                  <p className="text-sm text-muted-foreground">
                    {appointment.service}
                  </p>
                </div>

                <div className="hidden sm:block text-right">
                  <p className="font-semibold text-foreground">
                    {appointment.date} at {appointment.time}
                  </p>
                  <p className="text-sm text-muted-foreground">
                    DZD {appointment.amount.toLocaleString()}
                  </p>
                </div>

                <div className="hidden md:block">
                  <span
                    className={`inline-block px-3 py-1 rounded-full text-xs font-medium ${getStatusColor(
                      appointment.status
                    )}`}
                  >
                    {getStatusLabel(appointment.status)}
                  </span>
                </div>
              </div>

              <ChevronDown
                className={`h-5 w-5 text-muted-foreground transition-transform ${
                  expandedId === appointment.id ? 'rotate-180' : ''
                }`}
              />
            </button>

            {/* Expanded Details */}
            {expandedId === appointment.id && (
              <>
                <div className="border-t border-border px-6 py-4 bg-muted/30">
                  <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
                    <div>
                      <p className="text-xs text-muted-foreground uppercase mb-1">
                        Client Details
                      </p>
                      <p className="font-semibold text-foreground">
                        {appointment.clientName}
                      </p>
                      <a
                        href={`tel:${appointment.phone}`}
                        className="text-sm text-primary hover:underline"
                      >
                        {appointment.phone}
                      </a>
                      <a
                        href={`mailto:${appointment.email}`}
                        className="text-sm text-primary hover:underline block"
                      >
                        {appointment.email}
                      </a>
                    </div>

                    <div>
                      <p className="text-xs text-muted-foreground uppercase mb-1">
                        Appointment Details
                      </p>
                      <p className="font-semibold text-foreground mb-1">
                        {appointment.date} at {appointment.time}
                      </p>
                      <p className="text-sm text-muted-foreground">
                        {appointment.service}
                      </p>
                      <p className="text-lg font-bold text-accent mt-1">
                        DZD {appointment.amount.toLocaleString()}
                      </p>
                    </div>
                  </div>

                  {appointment.notes && (
                    <div className="mt-4 p-3 rounded-lg bg-background">
                      <p className="text-xs text-muted-foreground uppercase mb-1">
                        Notes
                      </p>
                      <p className="text-sm text-foreground">{appointment.notes}</p>
                    </div>
                  )}
                </div>

                {/* Action Buttons */}
                <div className="border-t border-border px-6 py-4 flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-end">
                  {appointment.status === 'pending' && (
                    <>
                      <Button
                        size="sm"
                        className="bg-success hover:bg-success/90 gap-2 text-success-foreground"
                      >
                        <Check className="h-4 w-4" />
                        Confirm
                      </Button>
                      <Button
                        size="sm"
                        variant="outline"
                        className="border-destructive text-destructive hover:bg-destructive/10 gap-2 bg-transparent"
                      >
                        <X className="h-4 w-4" />
                        Reject
                      </Button>
                    </>
                  )}

                  {(appointment.status === 'confirmed' ||
                    appointment.status === 'pending') && (
                    <>
                      <Button
                        size="sm"
                        variant="outline"
                        className="border-warning text-warning hover:bg-warning/10 gap-2 bg-transparent"
                      >
                        Reschedule
                      </Button>
                      <Button
                        size="sm"
                        variant="outline"
                        className="border-destructive text-destructive hover:bg-destructive/10 gap-2 bg-transparent"
                      >
                        <X className="h-4 w-4" />
                        Cancel
                      </Button>
                    </>
                  )}

                  <Button
                    size="sm"
                    variant="outline"
                    className="border-primary text-primary hover:bg-primary/10 gap-2 bg-transparent"
                  >
                    <MessageCircle className="h-4 w-4" />
                    Message
                  </Button>
                </div>
              </>
            )}
          </div>
        ))}
      </div>

      {filteredAppointments.length === 0 && (
        <div className="text-center py-12">
          <p className="text-muted-foreground mb-4">No appointments found</p>
          <Button variant="outline" onClick={() => setSearchQuery('')}>
            Clear filters
          </Button>
        </div>
      )}
    </div>
  );
}
