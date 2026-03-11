'use client';

import { useState } from 'react';
import { Lock, Bell, Eye, Trash2, Plus } from 'lucide-react';
import { Button } from '@/components/ui/button';

export default function AdminSettingsPage() {
  const [activeTab, setActiveTab] = useState<'general' | 'commission' | 'policies' | 'notifications' | 'security'>('general');

  return (
    <div className="max-w-4xl mx-auto space-y-8">
      {/* Page Title */}
      <div>
        <h1 className="text-3xl font-bold text-foreground">Admin Settings</h1>
        <p className="text-muted-foreground">Configure system-wide settings and policies.</p>
      </div>

      {/* Tabs */}
      <div className="flex gap-2 border-b border-border overflow-x-auto">
        {[
          { id: 'general', label: 'General Settings' },
          { id: 'commission', label: 'Commission & Fees' },
          { id: 'policies', label: 'Policies' },
          { id: 'notifications', label: 'Notifications' },
          { id: 'security', label: 'Security' },
        ].map((tab) => (
          <button
            key={tab.id}
            onClick={() => setActiveTab(tab.id as typeof activeTab)}
            className={`px-4 py-3 font-medium text-sm whitespace-nowrap transition-all border-b-2 ${
              activeTab === tab.id
                ? 'text-primary border-primary'
                : 'text-muted-foreground border-transparent hover:text-foreground'
            }`}
          >
            {tab.label}
          </button>
        ))}
      </div>

      {/* General Settings */}
      {activeTab === 'general' && (
        <div className="space-y-6">
          <div className="rounded-xl border border-border bg-card p-6">
            <h2 className="text-xl font-semibold text-foreground mb-6">Platform Information</h2>

            <div className="space-y-4">
              <div>
                <label className="block text-sm font-semibold text-foreground mb-2">
                  Platform Name
                </label>
                <input
                  type="text"
                  defaultValue="BookApp"
                  className="w-full rounded-lg border border-border bg-background px-4 py-3 text-foreground focus:outline-none focus:ring-2 focus:ring-primary"
                />
              </div>

              <div>
                <label className="block text-sm font-semibold text-foreground mb-2">
                  Platform Description
                </label>
                <textarea
                  defaultValue="BookApp is a leading online booking platform connecting clients with service providers."
                  rows={4}
                  className="w-full rounded-lg border border-border bg-background px-4 py-3 text-foreground focus:outline-none focus:ring-2 focus:ring-primary resize-none"
                />
              </div>

              <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
                <div>
                  <label className="block text-sm font-semibold text-foreground mb-2">
                    Support Email
                  </label>
                  <input
                    type="email"
                    defaultValue="support@bookapp.com"
                    className="w-full rounded-lg border border-border bg-background px-4 py-3 text-foreground focus:outline-none focus:ring-2 focus:ring-primary"
                  />
                </div>

                <div>
                  <label className="block text-sm font-semibold text-foreground mb-2">
                    Support Phone
                  </label>
                  <input
                    type="tel"
                    defaultValue="+213 XXX XXXX"
                    className="w-full rounded-lg border border-border bg-background px-4 py-3 text-foreground focus:outline-none focus:ring-2 focus:ring-primary"
                  />
                </div>
              </div>
            </div>

            <Button className="mt-6 bg-primary hover:bg-primary/90">Save Changes</Button>
          </div>
        </div>
      )}

      {/* Commission & Fees */}
      {activeTab === 'commission' && (
        <div className="space-y-6">
          <div className="rounded-xl border border-border bg-card p-6">
            <h2 className="text-xl font-semibold text-foreground mb-6">Commission Structure</h2>

            <div className="space-y-6">
              {['Clinic & Healthcare', 'Salon & Spa', 'Tutoring & Education'].map((category) => (
                <div key={category} className="p-4 rounded-lg border border-border">
                  <h3 className="font-semibold text-foreground mb-4">{category}</h3>
                  <div className="grid grid-cols-1 gap-4 sm:grid-cols-3">
                    <div>
                      <label className="block text-xs font-semibold text-muted-foreground mb-2">
                        Commission Rate (%)
                      </label>
                      <input
                        type="number"
                        defaultValue="15"
                        min="0"
                        max="100"
                        className="w-full rounded-lg border border-border bg-background px-4 py-3 text-foreground focus:outline-none focus:ring-2 focus:ring-primary"
                      />
                    </div>
                    <div>
                      <label className="block text-xs font-semibold text-muted-foreground mb-2">
                        Minimum Fee (DZD)
                      </label>
                      <input
                        type="number"
                        defaultValue="500"
                        className="w-full rounded-lg border border-border bg-background px-4 py-3 text-foreground focus:outline-none focus:ring-2 focus:ring-primary"
                      />
                    </div>
                    <div>
                      <label className="block text-xs font-semibold text-muted-foreground mb-2">
                        Maximum Fee (DZD)
                      </label>
                      <input
                        type="number"
                        defaultValue="5000"
                        className="w-full rounded-lg border border-border bg-background px-4 py-3 text-foreground focus:outline-none focus:ring-2 focus:ring-primary"
                      />
                    </div>
                  </div>
                </div>
              ))}
            </div>

            <Button className="mt-6 bg-primary hover:bg-primary/90">Save Changes</Button>
          </div>
        </div>
      )}

      {/* Policies */}
      {activeTab === 'policies' && (
        <div className="space-y-6">
          <div className="rounded-xl border border-border bg-card p-6">
            <h2 className="text-xl font-semibold text-foreground mb-6">Platform Policies</h2>

            <div className="space-y-4">
              <div>
                <label className="block text-sm font-semibold text-foreground mb-2">
                  Cancellation Policy
                </label>
                <textarea
                  defaultValue="Bookings can be cancelled up to 24 hours before the scheduled time. Cancellations within 24 hours may incur a 50% fee."
                  rows={4}
                  className="w-full rounded-lg border border-border bg-background px-4 py-3 text-foreground focus:outline-none focus:ring-2 focus:ring-primary resize-none"
                />
              </div>

              <div>
                <label className="block text-sm font-semibold text-foreground mb-2">
                  Refund Policy
                </label>
                <textarea
                  defaultValue="Full refunds are issued for cancelled bookings. For completed services with issues, refunds are processed within 5-7 business days."
                  rows={4}
                  className="w-full rounded-lg border border-border bg-background px-4 py-3 text-foreground focus:outline-none focus:ring-2 focus:ring-primary resize-none"
                />
              </div>

              <div>
                <label className="block text-sm font-semibold text-foreground mb-2">
                  Terms of Service
                </label>
                <textarea
                  defaultValue="By using BookApp, you agree to our terms of service. Users must be 18+ years old. Providers must comply with all local regulations."
                  rows={4}
                  className="w-full rounded-lg border border-border bg-background px-4 py-3 text-foreground focus:outline-none focus:ring-2 focus:ring-primary resize-none"
                />
              </div>
            </div>

            <Button className="mt-6 bg-primary hover:bg-primary/90">Save Changes</Button>
          </div>
        </div>
      )}

      {/* Notifications */}
      {activeTab === 'notifications' && (
        <div className="rounded-xl border border-border bg-card p-6">
          <h2 className="text-xl font-semibold text-foreground mb-6 flex items-center gap-2">
            <Bell className="h-5 w-5" />
            Notification Settings
          </h2>

          <div className="space-y-3">
            {[
              { id: 'new-booking', label: 'New Booking Notifications', desc: 'Send alerts for new bookings' },
              { id: 'disputes', label: 'Dispute Alerts', desc: 'Notify admin about disputes' },
              { id: 'fraud', label: 'Fraud Detection', desc: 'Alert on suspicious activities' },
              { id: 'reports', label: 'Report Notifications', desc: 'Notify about new reports' },
              { id: 'provider-approval', label: 'Provider Approval Needed', desc: 'Alert when provider approval needed' },
            ].map((notif) => (
              <div
                key={notif.id}
                className="flex items-center justify-between p-4 rounded-lg border border-border"
              >
                <div>
                  <p className="font-semibold text-foreground">{notif.label}</p>
                  <p className="text-sm text-muted-foreground">{notif.desc}</p>
                </div>
                <input
                  type="checkbox"
                  defaultChecked
                  className="h-5 w-5 rounded border-border accent-primary cursor-pointer"
                />
              </div>
            ))}
          </div>

          <Button className="mt-6 bg-primary hover:bg-primary/90">Save Changes</Button>
        </div>
      )}

      {/* Security */}
      {activeTab === 'security' && (
        <div className="space-y-6">
          <div className="rounded-xl border border-border bg-card p-6">
            <h2 className="text-xl font-semibold text-foreground mb-6 flex items-center gap-2">
              <Lock className="h-5 w-5" />
              Security Settings
            </h2>

            <div className="space-y-4">
              <div>
                <label className="block text-sm font-semibold text-foreground mb-2">
                  Session Timeout (minutes)
                </label>
                <input
                  type="number"
                  defaultValue="30"
                  className="w-full rounded-lg border border-border bg-background px-4 py-3 text-foreground focus:outline-none focus:ring-2 focus:ring-primary"
                />
              </div>

              <div>
                <label className="block text-sm font-semibold text-foreground mb-2">
                  Maximum Login Attempts
                </label>
                <input
                  type="number"
                  defaultValue="5"
                  className="w-full rounded-lg border border-border bg-background px-4 py-3 text-foreground focus:outline-none focus:ring-2 focus:ring-primary"
                />
              </div>

              <div>
                <label className="block text-sm font-semibold text-foreground mb-3">
                  Security Features
                </label>
                <div className="space-y-3">
                  {[
                    { id: '2fa', label: '2FA for Admin Accounts', enabled: true },
                    { id: 'email-verification', label: 'Email Verification Required', enabled: true },
                    { id: 'phone-verification', label: 'Phone Verification for Providers', enabled: false },
                  ].map((feature) => (
                    <div key={feature.id} className="flex items-center gap-3 p-3 rounded-lg bg-muted">
                      <input
                        type="checkbox"
                        defaultChecked={feature.enabled}
                        className="h-4 w-4 rounded border-border accent-primary cursor-pointer"
                      />
                      <label className="flex-1 text-sm font-medium text-foreground cursor-pointer">
                        {feature.label}
                      </label>
                    </div>
                  ))}
                </div>
              </div>
            </div>

            <Button className="mt-6 bg-primary hover:bg-primary/90">Save Changes</Button>
          </div>

          {/* Audit Log */}
          <div className="rounded-xl border border-border bg-card p-6">
            <h3 className="text-lg font-semibold text-foreground mb-4">Recent Admin Activity</h3>
            <div className="space-y-3 max-h-64 overflow-y-auto">
              {[
                { admin: 'System Admin', action: 'Updated commission rates', time: '2 hours ago' },
                { admin: 'System Admin', action: 'Disabled user account', time: '5 hours ago' },
                { admin: 'Support Admin', action: 'Resolved dispute #RP001', time: '1 day ago' },
                { admin: 'System Admin', action: 'Approved new provider', time: '2 days ago' },
              ].map((log, idx) => (
                <div key={idx} className="flex items-start gap-3 p-3 rounded-lg border border-border">
                  <div className="text-xs text-muted-foreground font-mono">{log.time}</div>
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-semibold text-foreground">{log.admin}</p>
                    <p className="text-xs text-muted-foreground">{log.action}</p>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
