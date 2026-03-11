'use client'

import { Suspense, use, useEffect, useState } from 'react'
import { useSearchParams, useRouter } from 'next/navigation'
import { X, CheckCircle2, CalendarDays } from 'lucide-react'
import Link from 'next/link'
import { useBookings } from '@/lib/booking-context'

function ConfirmationContent({ id }: { id: string }) {
  const searchParams = useSearchParams()
  const router = useRouter()
  const { addBooking } = useBookings()
  const [mounted, setMounted] = useState(false)
  const [formattedDate, setFormattedDate] = useState('')
  const dateStr = searchParams.get('date')
  const timeStr = searchParams.get('time') || '2:30 PM'
  const providerName = searchParams.get('provider') || 'General Consultation'
  const serviceName = searchParams.get('service') || 'General Consultation'

  useEffect(() => {
    setMounted(true)
    const date = dateStr ? new Date(dateStr) : new Date()
    const formatted = date.toLocaleDateString('en-US', {
      month: 'long',
      day: 'numeric',
      year: 'numeric',
    })
    setFormattedDate(formatted)
    
    // Add booking to context
    if (addBooking && formatted) {
      addBooking({
        provider: providerName,
        service: serviceName,
        date: formatted,
        time: timeStr,
        avatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBMPaHBMiyjJbLlvdNEiDoBsVDjpi93KLapwnWXFptmvX584YIxwL025WGYI7eQgWELQV_eG4Vu5W0tFnpK7hbmwiN7bcq_4Ly20V2MUFOMCX0pRhvzRYGWtq9VQ4_0ra-JnawE3mAfcFjEla4oK9pvigVSoZvH1jTiOAT1tm7U0GEiHKuxEPY9InLPL7JI0oLJd36kbdrcS7E0o0vkBqGK6HmLSdQCqCkQJVstJ6rfv7aKMLydbKL8PWU1kkSSs3jaEJTiuHg0wWI',
        status: 'upcoming',
      } as any)
    }
  }, [])

  return (
    <div className="flex min-h-[100dvh] items-center justify-center bg-background p-4">
      <div className="flex w-full max-w-md flex-col overflow-hidden rounded-2xl bg-card shadow-sm">
        {/* Top Navigation */}
        <div className="flex items-center justify-between p-4">
          <button
            onClick={() => router.push('/')}
            className="rounded-full p-2 text-primary transition-colors hover:bg-primary/10"
          >
            <X className="h-5 w-5" />
          </button>
          <h2 className="flex-1 pr-10 text-center text-lg font-bold tracking-tight text-foreground">
            Confirmation
          </h2>
        </div>

        {/* Success Header */}
        <div className="flex flex-col items-center px-4 pt-8 pb-6">
          <div className="mb-6 flex h-24 w-24 items-center justify-center rounded-full bg-primary/10">
            <CheckCircle2 className="h-16 w-16 text-primary" />
          </div>
          <h1 className="text-center text-3xl font-bold leading-tight text-foreground">
            Booking Confirmed!
          </h1>
          <p className="mt-2 text-center text-muted-foreground">
            Your appointment has been successfully scheduled.
          </p>
        </div>

        {/* Details Card */}
        <div className="p-4">
          <div className="overflow-hidden rounded-xl border border-border bg-background">
            {/* Service Image */}
            <div
              className="aspect-video w-full bg-cover bg-center bg-no-repeat"
              style={{
                backgroundImage: `url('https://lh3.googleusercontent.com/aida-public/AB6AXuAMFF4lXFzAKhiR7vUmHqJ-YAmi45-XxaL7T0xcQIOSq8SuDbKAZncQis_K3fCooYYFcrR3LXiv0YCSekp9wJ6zKqGLbs7FrjC-TnTcf5MxaSCYmaTkPPT-Yt4GL7QPpQGQh_izuY3O5hirZRpNVbjZCuYVDhpLEXGVH7ZWZJCUSncWpL6NvDOp7eUKH2oux13sqZBtBTl1qT8qCoNg_DPocMr0xEmKIFJGLJvOMTLhsX6cC8Zi8XNTgAV3v5eo3Mi3AKry92xoPHs')`,
              }}
              role="img"
              aria-label="Medical clinic consultation room"
            />
            <div className="space-y-4 p-5">
              {/* Ref Number */}
              <div className="flex items-center justify-between">
                <span className="text-xs font-medium uppercase tracking-wider text-muted-foreground">
                  Reference Number
                </span>
                <span className="text-sm font-bold text-primary">#BK2024001234</span>
              </div>

              {/* Service Title */}
              <div>
                <h3 className="text-xl font-bold text-foreground">{serviceName}</h3>
                <p className="mt-1 text-sm text-muted-foreground">
                  {providerName}
                </p>
              </div>

              <div className="h-px w-full bg-border" />

              {/* Details */}
              <div className="grid grid-cols-1 gap-3">
                <div className="flex items-center gap-3">
                  <CalendarDays className="h-5 w-5 text-primary/60" />
                  <div>
                    <p className="text-xs text-muted-foreground">Date & Time</p>
                    {mounted && <p className="font-medium text-foreground">
                      {formattedDate} at {timeStr}
                    </p>}
                  </div>
                </div>
                <div className="flex items-center gap-3">
                  <svg
                    className="h-5 w-5 text-primary/60"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth={2}
                      d="M17 9V7a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2m2 4h10a2 2 0 002-2v-6a2 2 0 00-2-2H9a2 2 0 00-2 2v6a2 2 0 002 2zm7-5a2 2 0 11-4 0 2 2 0 014 0z"
                    />
                  </svg>
                  <div>
                    <p className="text-xs text-muted-foreground">Service Fee</p>
                    <p className="text-lg font-bold text-foreground">DZD 3,000</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Footer Actions */}
        <div className="mt-auto p-4">
          <div className="flex flex-col gap-3">
            <Link
              href="/bookings"
              className="flex w-full items-center justify-center gap-2 rounded-xl bg-primary py-4 font-bold text-primary-foreground shadow-md shadow-primary/20 transition-all"
            >
              <CalendarDays className="h-5 w-5" />
              View My Bookings
            </Link>
            <Link
              href="/"
              className="flex w-full items-center justify-center rounded-xl py-3 font-semibold text-muted-foreground transition-all hover:bg-muted"
            >
              Go to Home
            </Link>
          </div>
        </div>

        <div className="h-4" />
      </div>
    </div>
  )
}

export default function ConfirmationPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = use(params)
  return (
    <Suspense fallback={null}>
      <ConfirmationContent id={id} />
    </Suspense>
  )
}
