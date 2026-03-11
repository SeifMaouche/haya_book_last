'use client';

import { useState } from 'react';
import { Lock, Bell, CreditCard, LogOut } from 'lucide-react';
import { Button } from '@/components/ui/button';

export default function SettingsPage() {
  const [activeTab, setActiveTab] = useState<'account' | 'notifications' | 'billing' | 'security'>('account');

  return (
    <div className="max-w-4xl mx-auto space-y-8">
      {/* Page Title */}
      <div>
        <h1 className="text-3xl font-bold text-foreground">Settings</h1>
        <p className="text-muted-foreground">Manage your account settings and preferences.</p>
      </div>

      {/* Tabs */}
      <div className="flex gap-2 border-b border-border overflow-x-auto">
        {[
          { id: 'account', label: 'Account Settings', icon: '⚙️' },
          { id: 'notifications', label: 'Notifications', icon: '🔔' },
          { id: 'billing', label: 'Billing', icon: '💳' },
          { id: 'security', label: 'Security', icon: '🔒' },
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

      {/* Account Settings */}
      {activeTab === 'account' && (
        <div className="space-y-6">
          <div className="rounded-xl border border-border bg-card p-6">
            <h2 className="text-xl font-semibold text-foreground mb-6">Account Information</h2>

            <div className="space-y-4">
              <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
                <div>
                  <label className="block text-sm font-semibold text-foreground mb-2">
                    First Name
                  </label>
                  <input
                    type="text"
                    defaultValue="Ahmed"
                    className="w-full rounded-lg border border-border bg-background px-4 py-3 text-foreground focus:outline-none focus:ring-2 focus:ring-primary"
                  />
                </div>
                <div>
                  <label className="block text-sm font-semibold text-foreground mb-2">
                    Last Name
                  </label>
                  <input
                    type="text"
                    defaultValue="Hassan"
                    className="w-full rounded-lg border border-border bg-background px-4 py-3 text-foreground focus:outline-none focus:ring-2 focus:ring-primary"
                  />
                </div>
              </div>

              <div>
                <label className="block text-sm font-semibold text-foreground mb-2">
                  Email Address
                </label>
                <input
                  type="email"
                  defaultValue="ahmed@example.com"
                  className="w-full rounded-lg border border-border bg-background px-4 py-3 text-foreground focus:outline-none focus:ring-2 focus:ring-primary"
                />
              </div>

              <div>
                <label className="block text-sm font-semibold text-foreground mb-2">
                  Phone Number
                </label>
                <input
                  type="tel"
                  defaultValue="+213 XXX XXXX"
                  className="w-full rounded-lg border border-border bg-background px-4 py-3 text-foreground focus:outline-none focus:ring-2 focus:ring-primary"
                />
              </div>

              <div>
                <label className="block text-sm font-semibold text-foreground mb-2">
                  Language
                </label>
                <select className="w-full rounded-lg border border-border bg-background px-4 py-3 text-foreground focus:outline-none focus:ring-2 focus:ring-primary">
                  <option>English</option>
                  <option>French</option>
                  <option>Arabic</option>
                </select>
              </div>
            </div>

            <Button className="mt-6 bg-primary hover:bg-primary/90">Save Changes</Button>
          </div>

          {/* Delete Account */}
          <div className="rounded-xl border-2 border-destructive/30 bg-destructive/5 p-6">
            <h3 className="text-lg font-semibold text-destructive mb-2">Danger Zone</h3>
            <p className="text-sm text-muted-foreground mb-4">
              Once you delete your account, there is no going back. Please be certain.
            </p>
            <Button variant="outline" className="border-destructive text-destructive hover:bg-destructive/10 bg-transparent">
              Delete Account
            </Button>
          </div>
        </div>
      )}

      {/* Notifications */}
      {activeTab === 'notifications' && (
        <div className="rounded-xl border border-border bg-card p-6">
          <h2 className="text-xl font-semibold text-foreground mb-6 flex items-center gap-2">
            <Bell className="h-5 w-5" />
            Notification Preferences
          </h2>

          <div className="space-y-4">
            {[
              { id: 'booking', label: 'New Booking Notifications', desc: 'Get notified when you receive a new booking request' },
              { id: 'confirmation', label: 'Booking Confirmations', desc: 'Receive confirmation emails for accepted bookings' },
              { id: 'reminder', label: 'Appointment Reminders', desc: 'Get reminded 24 hours before appointments' },
              { id: 'review', label: 'Review Notifications', desc: 'Get notified when you receive a new review' },
              { id: 'marketing', label: 'Marketing Emails', desc: 'Receive tips, feature updates, and promotional offers' },
            ].map((notif) => (
              <div key={notif.id} className="flex items-center justify-between p-4 rounded-lg border border-border">
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

          <Button className="mt-6 bg-primary hover:bg-primary/90">Save Preferences</Button>
        </div>
      )}

      {/* Billing */}
      {activeTab === 'billing' && (
        <div className="space-y-6">
          <div className="rounded-xl border border-border bg-card p-6">
            <h2 className="text-xl font-semibold text-foreground mb-6 flex items-center gap-2">
              <CreditCard className="h-5 w-5" />
              Subscription Plan
            </h2>

            <div className="bg-muted rounded-lg p-6 mb-6">
              <div className="flex items-center justify-between mb-4">
                <div>
                  <p className="text-sm text-muted-foreground">Current Plan</p>
                  <p className="text-2xl font-bold text-foreground">Premium</p>
                </div>
                <span className="px-3 py-1 rounded-full bg-success/10 text-success text-sm font-medium">
                  Active
                </span>
              </div>
              <p className="text-sm text-muted-foreground mb-4">
                Your subscription renews on March 31, 2025
              </p>
              <Button variant="outline" className="border-primary text-primary hover:bg-primary/10 bg-transparent">
                Manage Subscription
              </Button>
            </div>

            <div className="space-y-3">
              <h3 className="font-semibold text-foreground">Plan Comparison</h3>
              <div className="grid grid-cols-1 gap-4 sm:grid-cols-3">
                {[
                  { name: 'Free', price: '0', features: ['5 bookings/month', 'Basic analytics'] },
                  { name: 'Pro', price: '999', features: ['Unlimited bookings', 'Advanced analytics', 'Custom branding'], active: true },
                  { name: 'Enterprise', price: 'Custom', features: ['Custom features', 'Priority support', 'Dedicated manager'] },
                ].map((plan) => (
                  <div
                    key={plan.name}
                    className={`rounded-lg border-2 p-4 ${
                      plan.active ? 'border-primary bg-primary/10' : 'border-border'
                    }`}
                  >
                    <p className="font-semibold text-foreground mb-1">{plan.name}</p>
                    <p className="text-2xl font-bold text-foreground mb-3">
                      DZD {plan.price} <span className="text-sm text-muted-foreground">/mo</span>
                    </p>
                    <ul className="space-y-2 text-sm text-muted-foreground mb-4">
                      {plan.features.map((feature, idx) => (
                        <li key={idx}>✓ {feature}</li>
                      ))}
                    </ul>
                    <Button
                      variant={plan.active ? 'default' : 'outline'}
                      className="w-full"
                      disabled={plan.active}
                    >
                      {plan.active ? 'Current Plan' : 'Upgrade'}
                    </Button>
                  </div>
                ))}
              </div>
            </div>
          </div>

          {/* Billing History */}
          <div className="rounded-xl border border-border bg-card p-6">
            <h3 className="font-semibold text-foreground mb-4">Billing History</h3>
            <div className="overflow-x-auto">
              <table className="w-full text-sm">
                <thead>
                  <tr className="border-b border-border">
                    <th className="text-left py-3 text-muted-foreground">Date</th>
                    <th className="text-left py-3 text-muted-foreground">Amount</th>
                    <th className="text-left py-3 text-muted-foreground">Status</th>
                    <th className="text-left py-3 text-muted-foreground">Invoice</th>
                  </tr>
                </thead>
                <tbody>
                  {[
                    { date: 'Mar 1, 2025', amount: 'DZD 999', status: 'Paid' },
                    { date: 'Feb 1, 2025', amount: 'DZD 999', status: 'Paid' },
                    { date: 'Jan 1, 2025', amount: 'DZD 999', status: 'Paid' },
                  ].map((row, idx) => (
                    <tr key={idx} className="border-b border-border hover:bg-muted">
                      <td className="py-3 text-foreground">{row.date}</td>
                      <td className="py-3 font-semibold text-foreground">{row.amount}</td>
                      <td className="py-3">
                        <span className="px-2 py-1 rounded-full bg-success/10 text-success text-xs font-medium">
                          {row.status}
                        </span>
                      </td>
                      <td className="py-3">
                        <button className="text-primary hover:underline">Download</button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      )}

      {/* Security */}
      {activeTab === 'security' && (
        <div className="space-y-6">
          <div className="rounded-xl border border-border bg-card p-6">
            <h2 className="text-xl font-semibold text-foreground mb-6 flex items-center gap-2">
              <Lock className="h-5 w-5" />
              Password & Security
            </h2>

            <div className="space-y-4">
              <div>
                <label className="block text-sm font-semibold text-foreground mb-2">
                  Current Password
                </label>
                <input
                  type="password"
                  className="w-full rounded-lg border border-border bg-background px-4 py-3 text-foreground focus:outline-none focus:ring-2 focus:ring-primary"
                />
              </div>

              <div>
                <label className="block text-sm font-semibold text-foreground mb-2">
                  New Password
                </label>
                <input
                  type="password"
                  className="w-full rounded-lg border border-border bg-background px-4 py-3 text-foreground focus:outline-none focus:ring-2 focus:ring-primary"
                />
              </div>

              <div>
                <label className="block text-sm font-semibold text-foreground mb-2">
                  Confirm New Password
                </label>
                <input
                  type="password"
                  className="w-full rounded-lg border border-border bg-background px-4 py-3 text-foreground focus:outline-none focus:ring-2 focus:ring-primary"
                />
              </div>
            </div>

            <Button className="mt-6 bg-primary hover:bg-primary/90">Update Password</Button>
          </div>

          {/* Two-Factor Authentication */}
          <div className="rounded-xl border border-border bg-card p-6">
            <h3 className="text-lg font-semibold text-foreground mb-4">Two-Factor Authentication</h3>
            <p className="text-sm text-muted-foreground mb-4">
              Add an extra layer of security to your account with two-factor authentication.
            </p>
            <Button className="bg-primary hover:bg-primary/90">Enable 2FA</Button>
          </div>

          {/* Active Sessions */}
          <div className="rounded-xl border border-border bg-card p-6">
            <h3 className="text-lg font-semibold text-foreground mb-4">Active Sessions</h3>
            <div className="space-y-3">
              {[
                { device: 'Chrome on MacOS', location: 'Algiers, Algeria', lastActive: 'Just now' },
                { device: 'Safari on iPhone', location: 'Algiers, Algeria', lastActive: '2 hours ago' },
              ].map((session, idx) => (
                <div key={idx} className="flex items-center justify-between p-4 rounded-lg border border-border">
                  <div>
                    <p className="font-semibold text-foreground">{session.device}</p>
                    <p className="text-xs text-muted-foreground">
                      {session.location} • {session.lastActive}
                    </p>
                  </div>
                  <button className="text-destructive hover:text-destructive/80 text-sm font-medium">
                    Sign Out
                  </button>
                </div>
              ))}
            </div>
            <Button variant="outline" className="mt-4 w-full gap-2 border-destructive text-destructive hover:bg-destructive/10 bg-transparent">
              <LogOut className="h-4 w-4" />
              Sign Out All Devices
            </Button>
          </div>
        </div>
      )}
    </div>
  );
}
