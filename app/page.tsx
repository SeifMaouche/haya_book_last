'use client'

import { MapPin, Stethoscope, Scissors, BookOpen, Star, Clock } from 'lucide-react'
import Link from 'next/link'
import BottomNav from '@/components/bottom-nav'
import { useState } from 'react'
import LocationBottomSheet from '@/components/location-bottom-sheet'
import { useBookings } from '@/lib/booking-context'

const featuredProviders = [
  {
    id: 1,
    name: 'El-Djazair Medical Center',
    rating: 4.9,
    reviews: 120,
    distance: '2.5km away',
    image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBdCiuytJCU4K2UjXSqkf4CtyUZQ_1acYvR-DQo-wcu5W9eqB16ha9gIHJ96IRIrugRsdW59J7mLC_mzjHkciMaffs68dzgItdG7rVXg0zZKlcrwztkZyam1BNhyyOXFJHXfBxihqmE6z95qy9EYpQjJBAb83uu-nuz0-bGxocelptaVcuFXgY3S8WXTHeVKFUyGgpkOOOghU-t9CAr0tSr2TWvNA8mUEc_6EiSv7lLsaann2NyoQtcYEtP7Fgz83_xq4iTw0s0apI',
  },
  {
    id: 2,
    name: 'Oran Style Lounge',
    rating: 4.8,
    reviews: 85,
    distance: '1.2km away',
    image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuD58O9sAwuQeuxjkT4V7XTtAL6Bzy0PJyDdklCjNqMtSYdgsqw_jm165mnOtdWfMqFi8NTN3KqK-9YV6QT7vRdcDarbWzYsvqEK_tf3PsCT0xHh0Df_VH78ut6zqruaNVaDm3vPCqX__7XwjOeMckEj-LPNpkok4HAGWU39pu2eelNJ3H33qaqb8f-9H6cU7sxO-PFC_OVrhQr1olgpOmkGxRnYmb4sAo6VX4gN50c4NP9tYqPI2WZrkbAz6QR-AKPsPsdPIH-VdAs',
  },
  {
    id: 3,
    name: 'Advanced Math Tutoring',
    rating: 5.0,
    reviews: 42,
    distance: '3.8km away',
    image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCakLGNctXB0gYEVj5qgAugU_tlBB3lZ7HIGqlmDMg7GBBFM5KVW6N8yQE_962w4m9uY4LMrjK3__2dGL8yJzKrvUU6uGbXQdFdsoa0m9q14wOJyJDcUFXy1oaTaBamMz8r-xhxDMLEb-4QXr-Aiwg9R5LyHeHnqGpaXtEmRNYFvqde2jD7styTels2lbpUHktmpflHOWUQiK-Zh9Aha0OYqcnkQGBKEjdy-WseojLs2jBuc7uaVrn7tXmpGAlHpl8F9dInUB4xrV0',
  },
]

const categories = [
  { label: 'Clinics', icon: Stethoscope, bg: 'bg-primary/10', color: 'text-primary' },
  { label: 'Salons', icon: Scissors, bg: 'bg-accent/10', color: 'text-accent' },
  { label: 'Tutors', icon: BookOpen, bg: 'bg-primary/10', color: 'text-primary' },
]

export default function HomePage() {
  const { location, setLocation, bookings } = useBookings()
  const [showLocationSheet, setShowLocationSheet] = useState(false)
  
  const upcomingBookings = bookings.filter(b => b.status === 'upcoming')

  const handleLocationSelect = (selectedLocation: string) => {
    setLocation(selectedLocation)
    setShowLocationSheet(false)
  }
  return (
    <div className="min-h-[100dvh] bg-background pb-24">
      {/* Header */}
      <header className="sticky top-0 z-40 bg-primary px-4 pt-12 pb-4 text-primary-foreground shadow-md">
        <div className="mx-auto flex max-w-md items-center justify-between">
          <div className="flex flex-col flex-1">
            <h1 className="text-xl font-bold tracking-tight">BookApp</h1>
            <div className="flex items-center gap-1 text-xs text-primary-foreground/90">
              <MapPin className="h-3 w-3" />
              <span>{location}</span>
              <button 
                onClick={() => setShowLocationSheet(true)}
                className="ml-1 font-medium underline hover:opacity-80 transition-opacity"
              >
                Change
              </button>
            </div>
          </div>
          <Link
            href="/auth/login"
            className="rounded-full bg-primary-foreground/20 px-4 py-1.5 text-sm font-semibold text-primary-foreground transition-colors hover:bg-primary-foreground/30"
          >
            Sign In
          </Link>
        </div>
      </header>

      <main className="mx-auto max-w-md">
        {/* Search Bar */}
        <div className="sticky top-[84px] z-30 bg-background px-4 py-4">
          <div className="flex items-center overflow-hidden rounded-xl border border-primary/10 bg-card shadow-sm">
            <div className="flex items-center pl-3 text-primary">
              <svg className="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
              </svg>
            </div>
            <input
              type="text"
              placeholder="Search providers..."
              className="w-full border-none bg-transparent px-2 py-3 text-sm text-foreground placeholder:text-muted-foreground focus:ring-0 focus:outline-none"
            />
            <Link
              href="/browse"
              className="bg-accent px-5 py-3 text-sm font-bold text-accent-foreground transition-transform active:scale-95"
            >
              Search
            </Link>
          </div>
        </div>

        {/* Quick Access Categories */}
        <section className="px-4 py-6">
          <div className="grid grid-cols-3 gap-4">
            {categories.map((cat) => {
              const Icon = cat.icon
              return (
                <Link
                  key={cat.label}
                  href={`/browse?category=${cat.label.toLowerCase()}`}
                  className="flex flex-col items-center gap-2"
                >
                  <div
                    className={`flex aspect-square w-full items-center justify-center rounded-2xl ${cat.bg} transition-all active:scale-95`}
                  >
                    <Icon className={`h-10 w-10 ${cat.color}`} />
                  </div>
                  <span className="text-xs font-semibold text-foreground">{cat.label}</span>
                </Link>
              )
            })}
          </div>
        </section>

        {/* Upcoming Bookings */}
        <section className="px-4 py-4">
          <h2 className="mb-4 text-lg font-bold text-foreground">Upcoming Bookings</h2>
          {upcomingBookings.length === 0 ? (
            <div className="flex flex-col items-center rounded-2xl border border-border bg-card p-8 text-center shadow-sm">
              <div className="mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-muted">
                <Clock className="h-10 w-10 text-muted-foreground/50" />
              </div>
              <p className="mb-6 font-medium text-muted-foreground">
                No upcoming bookings
              </p>
              <Link
                href="/browse"
                className="w-full rounded-xl bg-primary py-3 text-center font-bold text-primary-foreground shadow-lg shadow-primary/20 transition-all hover:bg-primary/90"
              >
                Browse Now
              </Link>
            </div>
          ) : (
            <div className="space-y-3">
              {upcomingBookings.map((booking) => (
                <Link
                  key={booking.id}
                  href={`/booking/${booking.id}`}
                  className="flex gap-4 rounded-xl border border-border bg-card p-4 shadow-sm hover:shadow-md transition-shadow"
                >
                  <div className="flex h-16 w-16 items-center justify-center rounded-lg bg-primary/10">
                    <Stethoscope className="h-8 w-8 text-primary" />
                  </div>
                  <div className="flex-1">
                    <h3 className="font-bold text-foreground">{booking.doctorName}</h3>
                    <p className="text-xs text-muted-foreground">{booking.specialty}</p>
                    <p className="text-xs text-muted-foreground mt-1">
                      {new Date(booking.date).toLocaleDateString()} at {booking.time}
                    </p>
                    <p className="text-xs text-muted-foreground flex items-center gap-1 mt-1">
                      <MapPin className="h-3 w-3" />
                      {booking.location}
                    </p>
                  </div>
                </Link>
              ))}
            </div>
          )}
        </section>

        {/* Featured Providers */}
        <section className="py-6">
          <div className="mb-4 flex items-center justify-between px-4">
            <h2 className="text-lg font-bold text-foreground">Featured Providers</h2>
            <Link href="/browse" className="text-sm font-bold text-primary">
              View All
            </Link>
          </div>
          <div className="no-scrollbar flex gap-4 overflow-x-auto px-4 pb-4">
            {featuredProviders.map((provider) => (
              <Link
                key={provider.id}
                href={`/provider/${provider.id}`}
                className="min-w-[240px] overflow-hidden rounded-2xl border border-border bg-card shadow-sm"
              >
                <div className="relative h-36">
                  <img
                    src={provider.image}
                    alt={provider.name}
                    className="h-full w-full object-cover"
                    crossOrigin="anonymous"
                  />
                  <div className="absolute inset-0 bg-gradient-to-t from-foreground/60 to-transparent" />
                  <div className="absolute bottom-3 left-3 right-3">
                    <p className="text-sm font-bold text-primary-foreground">{provider.name}</p>
                  </div>
                </div>
                <div className="p-3">
                  <div className="mb-3 flex items-center justify-between">
                    <div className="flex items-center gap-1">
                      <Star className="h-3.5 w-3.5 fill-accent text-accent" />
                      <span className="text-xs font-bold text-foreground">{provider.rating}</span>
                      <span className="text-xs text-muted-foreground">({provider.reviews})</span>
                    </div>
                    <span className="rounded-full bg-muted px-2 py-0.5 text-[10px] font-medium text-muted-foreground">
                      {provider.distance}
                    </span>
                  </div>
                  <button className="w-full rounded-lg bg-primary/10 py-2 text-sm font-bold text-primary transition-all hover:bg-primary hover:text-primary-foreground">
                    Book Now
                  </button>
                </div>
              </Link>
            ))}
          </div>
        </section>
      </main>

      <BottomNav />

      {/* Location Bottom Sheet */}
      {showLocationSheet && (
        <LocationBottomSheet 
          onSelect={handleLocationSelect} 
          onClose={() => setShowLocationSheet(false)}
        />
      )}
    </div>
  )
}
