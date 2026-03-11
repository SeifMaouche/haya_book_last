'use client'

import { useState } from 'react'
import { ArrowLeft, Calendar, Star, RotateCcw, XCircle, Check } from 'lucide-react'
import Link from 'next/link'
import BottomNav from '@/components/bottom-nav'
import { useBookings } from '@/lib/booking-context'

type TabType = 'upcoming' | 'past' | 'cancelled'

export default function BookingsPage() {
  const { bookings, cancelBooking, rescheduleBooking } = useBookings()
  const [activeTab, setActiveTab] = useState<TabType>('upcoming')
  const [showCancelDialog, setShowCancelDialog] = useState<string | null>(null)
  const [showRescheduleDialog, setShowRescheduleDialog] = useState<string | null>(null)
  const [rescheduleDate, setRescheduleDate] = useState('')
  const [rescheduleTime, setRescheduleTime] = useState('')

  const upcomingBookings = bookings.filter(b => b.status === 'upcoming')
  const pastBookings = bookings.filter(b => b.status === 'past')
  const cancelledBookings = bookings.filter(b => b.status === 'cancelled')

  const handleCancelBooking = (bookingId: string) => {
    cancelBooking(bookingId)
    setShowCancelDialog(null)
  }

  const handleRescheduleBooking = (bookingId: string) => {
    if (!rescheduleDate || !rescheduleTime) return
    rescheduleBooking(bookingId, rescheduleDate, rescheduleTime)
    setShowRescheduleDialog(null)
    setRescheduleDate('')
    setRescheduleTime('')
  }

  const tabs: { key: TabType; label: string }[] = [
    { key: 'upcoming', label: 'Upcoming' },
    { key: 'past', label: 'Past' },
    { key: 'cancelled', label: 'Cancelled' },
  ]

  return (
    <div className="flex min-h-[100dvh] flex-col bg-background pb-24">
      {/* Header */}
      <header className="sticky top-0 z-10 flex items-center border-b border-border bg-card px-4 py-4">
        <Link href="/" className="p-1 text-primary">
          <ArrowLeft className="h-5 w-5" />
        </Link>
        <h1 className="flex-1 text-center text-xl font-bold text-foreground pr-6">My Bookings</h1>
      </header>

      {/* Tabs */}
      <nav className="border-b border-border bg-card">
        <div className="flex">
          {tabs.map((tab) => (
            <button
              key={tab.key}
              onClick={() => setActiveTab(tab.key)}
              className={`flex-1 py-4 text-sm font-semibold transition-colors border-b-[3px] ${
                activeTab === tab.key
                  ? 'border-primary text-foreground'
                  : 'border-transparent text-primary/60'
              }`}
            >
              {tab.label}
            </button>
          ))}
        </div>
      </nav>

      {/* Content */}
      <main className="mx-auto w-full max-w-md flex-1 px-4 pt-4">
        {activeTab === 'upcoming' && (
          <div className="flex flex-col gap-4">
            {upcomingBookings.length === 0 ? (
              <div className="flex flex-col items-center justify-center py-20">
                <Calendar className="mx-auto mb-4 h-16 w-16 text-muted-foreground" />
                <h3 className="text-lg font-semibold text-foreground">No upcoming bookings</h3>
                <p className="text-sm text-muted-foreground">{"You don't have any upcoming appointments"}</p>
              </div>
            ) : (
              upcomingBookings.map((booking) => (
                <div key={booking.id} className="rounded-xl border border-border bg-card p-4 shadow-sm">
                  <div className="mb-4 flex items-start gap-4">
                    <div className="h-16 w-16 shrink-0 overflow-hidden rounded-full bg-primary/10">
                      <img src={booking.avatar} alt={booking.provider} className="h-full w-full object-cover" />
                    </div>
                    <div className="flex-1">
                      <h3 className="text-lg font-bold leading-tight text-foreground">{booking.provider}</h3>
                      <p className="text-sm text-primary/70">{booking.service}</p>
                      <p className="mt-2 text-sm font-semibold text-muted-foreground">
                        {booking.date} &bull; {booking.time}
                      </p>
                    </div>
                  </div>
                  <div className="flex-1">
                    <h3 className="text-lg font-bold leading-tight text-foreground">{booking.doctor}</h3>
                    <p className="text-sm text-primary/70">{booking.service}</p>
                    <div className="mt-2 flex items-center gap-2 text-sm font-semibold text-primary">
                      <Calendar className="h-3.5 w-3.5" />
                      <span>{booking.date} &bull; {booking.time}</span>
                    </div>
                  </div>
                </div>
                  <div className="flex gap-3 border-t border-border pt-3">
                    <button 
                      onClick={() => setShowRescheduleDialog(booking.id)}
                      className="flex flex-1 items-center justify-center gap-2 rounded-lg border border-primary/20 py-2.5 text-sm font-bold text-primary transition-colors hover:bg-primary/5"
                    >
                      <RotateCcw className="h-4 w-4" />
                      Reschedule
                    </button>
                    <button 
                      onClick={() => setShowCancelDialog(booking.id)}
                      className="flex flex-1 items-center justify-center gap-2 rounded-lg bg-[#ef4444]/10 py-2.5 text-sm font-bold text-[#ef4444] transition-colors hover:bg-[#ef4444]/20"
                    >
                      <XCircle className="h-4 w-4" />
                      Cancel
                    </button>
                  </div>
                </div>
              ))
            )}
          </div>
        )}

        {activeTab === 'past' && (
          <div>
            {pastBookings.length > 0 ? (
              <div className="flex flex-col gap-4">
                {pastBookings.map((booking) => (
                  <div key={booking.id} className="rounded-xl border border-border bg-card p-4 shadow-sm opacity-70">
                    <div className="mb-4 flex items-start gap-4">
                      <div className="h-16 w-16 shrink-0 overflow-hidden rounded-full bg-primary/10 grayscale">
                        <img src={booking.avatar} alt={booking.provider} className="h-full w-full object-cover" />
                      </div>
                      <div className="flex-1">
                        <h3 className="text-lg font-bold leading-tight text-foreground">{booking.provider}</h3>
                        <p className="text-sm text-primary/70">{booking.service}</p>
                        <p className="mt-2 text-sm font-semibold text-muted-foreground">
                          {booking.date} &bull; {booking.time}
                        </p>
                      </div>
                    </div>
                    <button className="flex w-full items-center justify-center gap-2 rounded-lg bg-primary py-3 font-bold text-primary-foreground shadow-md transition-colors hover:bg-primary/90">
                      <Star className="h-4 w-4" />
                      Rate Service
                    </button>
                  </div>
                ))}
              </div>
            ) : (
              <div className="flex flex-col items-center justify-center py-20">
                <Calendar className="mx-auto mb-4 h-16 w-16 text-muted-foreground" />
                <h3 className="text-lg font-semibold text-foreground">No past bookings</h3>
                <p className="text-sm text-muted-foreground">{"You haven't completed any appointments yet"}</p>
              </div>
            )}
          </div>
        )}

        {activeTab === 'cancelled' && (
          <div>
            {cancelledBookings.length > 0 ? (
              <div className="flex flex-col gap-4">
                {cancelledBookings.map((booking) => (
                  <div key={booking.id} className="rounded-xl border border-border/50 bg-card/50 p-4 shadow-sm opacity-60">
                    <div className="mb-4 flex items-start gap-4">
                      <div className="h-16 w-16 shrink-0 overflow-hidden rounded-full bg-primary/10 grayscale">
                        <img src={booking.avatar} alt={booking.provider} className="h-full w-full object-cover" />
                      </div>
                      <div className="flex-1">
                        <h3 className="text-lg font-bold leading-tight text-foreground line-through">{booking.provider}</h3>
                        <p className="text-sm text-primary/70">{booking.service}</p>
                        <p className="mt-2 text-sm font-semibold text-muted-foreground line-through">
                          {booking.date} &bull; {booking.time}
                        </p>
                      </div>
                    </div>
                    <p className="text-center text-sm font-medium text-muted-foreground">Cancelled</p>
                  </div>
                ))}
              </div>
            ) : (
              <div className="flex flex-col items-center justify-center py-20">
                <XCircle className="mx-auto mb-4 h-16 w-16 text-muted-foreground" />
                <h3 className="text-lg font-semibold text-foreground">No cancelled bookings</h3>
                <p className="text-sm text-muted-foreground">{"You haven't cancelled any bookings"}</p>
              </div>
            )}
          </div>
        )}
      </main>

      <BottomNav />

      {/* Cancel Confirmation Dialog */}
      {showCancelDialog && (
        <>
          <div className="fixed inset-0 z-50 bg-black/50" onClick={() => setShowCancelDialog(null)} />
          <div className="fixed left-1/2 top-1/2 z-50 w-11/12 max-w-sm -translate-x-1/2 -translate-y-1/2 rounded-2xl bg-background p-6 shadow-xl animate-in">
            <h2 className="text-xl font-bold text-foreground mb-2">Cancel Appointment?</h2>
            <p className="text-sm text-muted-foreground mb-6">Are you sure you want to cancel this appointment? This action cannot be undone.</p>
            <div className="flex gap-3">
              <button
                onClick={() => setShowCancelDialog(null)}
                className="flex-1 rounded-lg border border-border py-3 font-semibold text-foreground transition-colors hover:bg-muted"
              >
                Keep It
              </button>
              <button
                onClick={() => handleCancelBooking(showCancelDialog)}
                className="flex-1 rounded-lg bg-[#ef4444] py-3 font-semibold text-white transition-colors hover:bg-[#ef4444]/90"
              >
                Cancel Appointment
              </button>
            </div>
          </div>
        </>
      )}

      {/* Reschedule Dialog */}
      {showRescheduleDialog && (
        <>
          <div className="fixed inset-0 z-50 bg-black/50" onClick={() => setShowRescheduleDialog(null)} />
          <div className="fixed left-1/2 top-1/2 z-50 w-11/12 max-w-sm -translate-x-1/2 -translate-y-1/2 rounded-2xl bg-background p-6 shadow-xl animate-in max-h-[90vh] overflow-y-auto">
            <h2 className="text-xl font-bold text-foreground mb-4">Reschedule Appointment</h2>
            <div className="space-y-4 mb-6">
              <div>
                <label className="block text-sm font-semibold text-foreground mb-2">New Date</label>
                <input
                  type="date"
                  value={rescheduleDate}
                  onChange={(e) => setRescheduleDate(e.target.value)}
                  className="w-full rounded-lg border border-border bg-card px-3 py-2 text-foreground focus:outline-none focus:ring-2 focus:ring-primary"
                />
              </div>
              <div>
                <label className="block text-sm font-semibold text-foreground mb-2">New Time</label>
                <input
                  type="time"
                  value={rescheduleTime}
                  onChange={(e) => setRescheduleTime(e.target.value)}
                  className="w-full rounded-lg border border-border bg-card px-3 py-2 text-foreground focus:outline-none focus:ring-2 focus:ring-primary"
                />
              </div>
            </div>
            <div className="flex gap-3">
              <button
                onClick={() => setShowRescheduleDialog(null)}
                className="flex-1 rounded-lg border border-border py-3 font-semibold text-foreground transition-colors hover:bg-muted"
              >
                Cancel
              </button>
              <button
                onClick={() => handleRescheduleBooking(showRescheduleDialog)}
                disabled={!rescheduleDate || !rescheduleTime}
                className="flex-1 rounded-lg bg-primary py-3 font-semibold text-primary-foreground transition-colors hover:bg-primary/90 disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
              >
                <Check className="h-4 w-4" />
                Confirm
              </button>
            </div>
          </div>
        </>
      )}
    </div>
  )
}
