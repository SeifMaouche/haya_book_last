'use client';

import { useState } from 'react';
import { Search, Eye, Trash2, CheckCircle, AlertCircle } from 'lucide-react';
import { Button } from '@/components/ui/button';

interface Report {
  id: string;
  type: 'complaint' | 'fraud' | 'inappropriate' | 'other';
  reporterName: string;
  subject: string;
  date: string;
  status: 'open' | 'investigating' | 'resolved' | 'closed';
  priority: 'low' | 'medium' | 'high' | 'urgent';
}

const mockReports: Report[] = [
  {
    id: 'RP001',
    type: 'complaint',
    reporterName: 'Ahmed Hassan',
    subject: 'Provider cancelled appointment without notice',
    date: '2025-01-25',
    status: 'investigating',
    priority: 'high',
  },
  {
    id: 'RP002',
    type: 'inappropriate',
    reporterName: 'Fatima Bouali',
    subject: 'Unprofessional behavior during service',
    date: '2025-01-24',
    status: 'open',
    priority: 'medium',
  },
  {
    id: 'RP003',
    type: 'fraud',
    reporterName: 'System',
    subject: 'Multiple duplicate bookings detected',
    date: '2025-01-23',
    status: 'investigating',
    priority: 'urgent',
  },
  {
    id: 'RP004',
    type: 'complaint',
    reporterName: 'Karim Belkacem',
    subject: 'Charged twice for single booking',
    date: '2025-01-22',
    status: 'resolved',
    priority: 'high',
  },
  {
    id: 'RP005',
    type: 'other',
    reporterName: 'Leila Amara',
    subject: 'Feature request: Add SMS notifications',
    date: '2025-01-20',
    status: 'closed',
    priority: 'low',
  },
];

export default function ReportsPage() {
  const [searchQuery, setSearchQuery] = useState('');
  const [statusFilter, setStatusFilter] = useState<'all' | 'open' | 'investigating' | 'resolved' | 'closed'>('all');
  const [priorityFilter, setPriorityFilter] = useState<'all' | 'low' | 'medium' | 'high' | 'urgent'>('all');

  const filteredReports = mockReports.filter((report) => {
    const matchesSearch =
      report.reporterName.toLowerCase().includes(searchQuery.toLowerCase()) ||
      report.subject.toLowerCase().includes(searchQuery.toLowerCase()) ||
      report.id.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesStatus = statusFilter === 'all' || report.status === statusFilter;
    const matchesPriority = priorityFilter === 'all' || report.priority === priorityFilter;
    return matchesSearch && matchesStatus && matchesPriority;
  });

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'open':
        return 'bg-warning/10 text-warning';
      case 'investigating':
        return 'bg-primary/10 text-primary';
      case 'resolved':
        return 'bg-success/10 text-success';
      case 'closed':
        return 'bg-muted text-muted-foreground';
      default:
        return 'bg-muted text-muted-foreground';
    }
  };

  const getPriorityColor = (priority: string) => {
    switch (priority) {
      case 'low':
        return 'bg-muted text-muted-foreground';
      case 'medium':
        return 'bg-warning/20 text-warning';
      case 'high':
        return 'bg-destructive/20 text-destructive';
      case 'urgent':
        return 'bg-destructive/30 text-destructive';
      default:
        return 'bg-muted text-muted-foreground';
    }
  };

  const stats = {
    total: mockReports.length,
    open: mockReports.filter((r) => r.status === 'open').length,
    investigating: mockReports.filter((r) => r.status === 'investigating').length,
    urgent: mockReports.filter((r) => r.priority === 'urgent').length,
  };

  return (
    <div className="max-w-7xl mx-auto space-y-6">
      {/* Page Title */}
      <div>
        <h1 className="text-3xl font-bold text-foreground">Reports & Support</h1>
        <p className="text-muted-foreground">Manage customer complaints and issues.</p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <div className="rounded-lg border border-border bg-card p-4">
          <p className="text-sm text-muted-foreground mb-1">Total Reports</p>
          <p className="text-2xl font-bold text-foreground">{stats.total}</p>
        </div>
        <div className="rounded-lg border border-border bg-card p-4">
          <p className="text-sm text-muted-foreground mb-1">Open Issues</p>
          <p className="text-2xl font-bold text-warning">{stats.open}</p>
        </div>
        <div className="rounded-lg border border-border bg-card p-4">
          <p className="text-sm text-muted-foreground mb-1">Investigating</p>
          <p className="text-2xl font-bold text-primary">{stats.investigating}</p>
        </div>
        <div className="rounded-lg border border-border bg-card p-4">
          <p className="text-sm text-muted-foreground mb-1">Urgent Issues</p>
          <p className="text-2xl font-bold text-destructive">{stats.urgent}</p>
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
              placeholder="Search by ID, reporter, or subject..."
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
            <option value="open">Open</option>
            <option value="investigating">Investigating</option>
            <option value="resolved">Resolved</option>
            <option value="closed">Closed</option>
          </select>

          {/* Priority Filter */}
          <select
            value={priorityFilter}
            onChange={(e) => setPriorityFilter(e.target.value as typeof priorityFilter)}
            className="rounded-lg border border-border bg-background px-4 py-2.5 text-foreground focus:outline-none focus:ring-2 focus:ring-primary"
          >
            <option value="all">All Priority</option>
            <option value="low">Low</option>
            <option value="medium">Medium</option>
            <option value="high">High</option>
            <option value="urgent">Urgent</option>
          </select>
        </div>
      </div>

      {/* Reports Table */}
      <div className="rounded-xl border border-border bg-card overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-border bg-muted">
                <th className="px-6 py-4 text-left font-semibold text-muted-foreground">ID</th>
                <th className="px-6 py-4 text-left font-semibold text-muted-foreground">Reporter</th>
                <th className="px-6 py-4 text-left font-semibold text-muted-foreground">Subject</th>
                <th className="px-6 py-4 text-left font-semibold text-muted-foreground">Type</th>
                <th className="px-6 py-4 text-left font-semibold text-muted-foreground">Date</th>
                <th className="px-6 py-4 text-left font-semibold text-muted-foreground">Priority</th>
                <th className="px-6 py-4 text-left font-semibold text-muted-foreground">Status</th>
                <th className="px-6 py-4 text-right font-semibold text-muted-foreground">Actions</th>
              </tr>
            </thead>
            <tbody>
              {filteredReports.map((report) => (
                <tr key={report.id} className="border-b border-border hover:bg-muted/50 transition">
                  <td className="px-6 py-4 font-mono font-semibold text-foreground">{report.id}</td>
                  <td className="px-6 py-4 text-foreground">{report.reporterName}</td>
                  <td className="px-6 py-4 max-w-xs text-foreground truncate">{report.subject}</td>
                  <td className="px-6 py-4 text-muted-foreground">
                    <span className="capitalize">{report.type}</span>
                  </td>
                  <td className="px-6 py-4 text-muted-foreground">{report.date}</td>
                  <td className="px-6 py-4">
                    <span
                      className={`inline-flex px-3 py-1 rounded-full text-xs font-medium ${getPriorityColor(
                        report.priority
                      )}`}
                    >
                      {report.priority.charAt(0).toUpperCase() + report.priority.slice(1)}
                    </span>
                  </td>
                  <td className="px-6 py-4">
                    <span
                      className={`inline-flex px-3 py-1 rounded-full text-xs font-medium ${getStatusColor(
                        report.status
                      )}`}
                    >
                      {report.status.charAt(0).toUpperCase() + report.status.slice(1)}
                    </span>
                  </td>
                  <td className="px-6 py-4 text-right">
                    <div className="flex items-center justify-end gap-2">
                      <button className="p-2 hover:bg-muted rounded-lg transition text-muted-foreground hover:text-foreground">
                        <Eye className="h-4 w-4" />
                      </button>
                      {report.status === 'open' && (
                        <button className="p-2 hover:bg-success/10 rounded-lg transition text-success hover:text-success">
                          <CheckCircle className="h-4 w-4" />
                        </button>
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
        {filteredReports.length === 0 && (
          <div className="px-6 py-12 text-center">
            <p className="text-muted-foreground">No reports found matching your filters.</p>
          </div>
        )}
      </div>
    </div>
  );
}
