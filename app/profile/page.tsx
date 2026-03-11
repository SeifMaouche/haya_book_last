'use client'

import { useState } from 'react'
import {
  ChevronRight,
  Bell,
  Globe,
  CreditCard,
  MapPin,
  CircleHelp,
  Mail,
  LogOut,
  Pencil,
  Calendar,
  CalendarClock,
} from 'lucide-react'
import Link from 'next/link'
import BottomNav from '@/components/bottom-nav'

export default function ProfilePage() {
  const [pushEnabled, setPushEnabled] = useState(true)

  return (
    <div className="flex min-h-[100dvh] flex-col bg-background pb-24">
      {/* Profile Header */}
      <div className="flex flex-col items-center bg-card px-6 pt-10 pb-6">
        {/* Avatar */}
        <div className="relative mb-4">
          <div className="h-28 w-28 overflow-hidden rounded-full border-4 border-primary/20 p-0.5">
            <img
              src="https://lh3.googleusercontent.com/aida-public/AB6AXuBVw76b-xK2GTT9ISplmBv5eftTAFNu-mHokbHhzhYZPVRDKRKmQBD29VTpdxhHu0YHciSgfCtxX2AzPtMxehufs89slBK8RqHbwCK8mCfXaZREV3u47ywKELIstz7XL3lBOfaTuBUDuLJta9QngTuPyszkyk-Cy4Gl2PRmaumsXkDXtzy0bqy_MNv0cYHQVHsc-zN01yGiXZEkh6HAzBNTHsc2kVak8ovbhlLCZNAn9qfCwHPvIQ6D8hcWExN14xPir53aFm77Axk"
              alt="Alex Johnson profile"
              className="h-full w-full rounded-full object-cover"
            />
          </div>
          <button className="absolute bottom-0 right-0 flex h-9 w-9 items-center justify-center rounded-full border-3 border-card bg-primary text-primary-foreground shadow-md">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
              <path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"/>
              <circle cx="12" cy="13" r="4"/>
            </svg>
          </button>
        </div>

        <h2 className="text-xl font-bold text-foreground">Alex Johnson</h2>
        <p className="mt-0.5 text-sm text-muted-foreground">alex.johnson@email.com</p>
        <p className="text-sm text-muted-foreground">+1 (555) 000-1234</p>

        {/* Edit Profile Button */}
        <Link
          href="/profile/edit"
          className="mt-5 flex w-full max-w-xs items-center justify-center gap-2 rounded-full bg-primary py-3.5 font-bold text-primary-foreground shadow-lg shadow-primary/20 transition-all active:scale-[0.98]"
        >
          <Pencil className="h-4 w-4" />
          Edit Profile
        </Link>
      </div>

      <main className="mx-auto w-full max-w-md px-4 pt-4">
        {/* My Bookings Stats */}
        <p className="mb-2 px-1 text-xs font-bold uppercase tracking-widest text-primary">
          My Bookings
        </p>
        <div className="mb-6 grid grid-cols-2 gap-3">
          <div className="rounded-xl border border-border bg-card p-4">
            <Calendar className="mb-2 h-5 w-5 text-primary" />
            <p className="text-2xl font-bold text-foreground">24</p>
            <p className="text-xs text-muted-foreground">Total Bookings</p>
          </div>
          <div className="rounded-xl border border-border bg-card p-4">
            <CalendarClock className="mb-2 h-5 w-5 text-primary" />
            <p className="text-2xl font-bold text-foreground">3</p>
            <p className="text-xs text-muted-foreground">Upcoming</p>
          </div>
        </div>

        {/* Settings */}
        <p className="mb-2 px-1 text-xs font-bold uppercase tracking-widest text-primary">
          Settings
        </p>
        <div className="mb-6 overflow-hidden rounded-xl border border-border bg-card">
          {/* Push Notifications */}
          <div className="flex items-center justify-between px-4 py-4 border-b border-border">
            <div className="flex items-center gap-3">
              <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-primary/10">
                <Bell className="h-4 w-4 text-primary" />
              </div>
              <span className="text-sm font-medium text-foreground">Push Notifications</span>
            </div>
            <button
              onClick={() => setPushEnabled(!pushEnabled)}
              className={`relative h-7 w-12 rounded-full transition-colors ${
                pushEnabled ? 'bg-primary' : 'bg-muted-foreground/30'
              }`}
            >
              <span
                className={`absolute top-0.5 left-0.5 h-6 w-6 rounded-full bg-card shadow transition-transform ${
                  pushEnabled ? 'translate-x-5' : 'translate-x-0'
                }`}
              />
            </button>
          </div>
          {/* Language */}
          <div className="flex items-center justify-between px-4 py-4">
            <div className="flex items-center gap-3">
              <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-primary/10">
                <Globe className="h-4 w-4 text-primary" />
              </div>
              <span className="text-sm font-medium text-foreground">Language</span>
            </div>
            <div className="flex items-center gap-1 text-muted-foreground">
              <span className="text-sm">English</span>
              <ChevronRight className="h-4 w-4" />
            </div>
          </div>
        </div>

        {/* Account */}
        <p className="mb-2 px-1 text-xs font-bold uppercase tracking-widest text-primary">
          Account
        </p>
        <div className="mb-6 overflow-hidden rounded-xl border border-border bg-card">
          <Link href="#" className="flex items-center justify-between px-4 py-4 border-b border-border transition-colors hover:bg-muted">
            <div className="flex items-center gap-3">
              <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-primary/10">
                <CreditCard className="h-4 w-4 text-primary" />
              </div>
              <span className="text-sm font-medium text-foreground">Payment Methods</span>
            </div>
            <ChevronRight className="h-4 w-4 text-muted-foreground" />
          </Link>
          <Link href="#" className="flex items-center justify-between px-4 py-4 transition-colors hover:bg-muted">
            <div className="flex items-center gap-3">
              <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-primary/10">
                <MapPin className="h-4 w-4 text-primary" />
              </div>
              <span className="text-sm font-medium text-foreground">Saved Addresses</span>
            </div>
            <ChevronRight className="h-4 w-4 text-muted-foreground" />
          </Link>
        </div>

        {/* Support */}
        <p className="mb-2 px-1 text-xs font-bold uppercase tracking-widest text-primary">
          Support
        </p>
        <div className="mb-6 overflow-hidden rounded-xl border border-border bg-card">
          <Link href="#" className="flex items-center justify-between px-4 py-4 border-b border-border transition-colors hover:bg-muted">
            <div className="flex items-center gap-3">
              <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-primary/10">
                <CircleHelp className="h-4 w-4 text-primary" />
              </div>
              <span className="text-sm font-medium text-foreground">{'Help & FAQ'}</span>
            </div>
            <ChevronRight className="h-4 w-4 text-muted-foreground" />
          </Link>
          <Link href="#" className="flex items-center justify-between px-4 py-4 transition-colors hover:bg-muted">
            <div className="flex items-center gap-3">
              <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-primary/10">
                <Mail className="h-4 w-4 text-primary" />
              </div>
              <span className="text-sm font-medium text-foreground">Contact Us</span>
            </div>
            <ChevronRight className="h-4 w-4 text-muted-foreground" />
          </Link>
        </div>

        {/* Log Out */}
        <button className="flex w-full items-center justify-center gap-2 rounded-xl bg-destructive/10 py-4 text-sm font-bold text-destructive transition-colors hover:bg-destructive/20">
          <LogOut className="h-4 w-4" />
          Log Out
        </button>

        <p className="mt-4 mb-4 text-center text-xs italic text-muted-foreground">
          {'BookApp v2.4.0 \u2022 Made with love'}
        </p>
      </main>

      <BottomNav />
    </div>
  )
}
