'use client'

import { useState, Suspense } from 'react'
import { MapPin, Star, ChevronDown, Plus } from 'lucide-react'
import Link from 'next/link'
import BottomNav from '@/components/bottom-nav'
import { useSearchParams } from 'next/navigation'

const providers = [
  {
    id: 1,
    name: 'City Health Specialists',
    category: 'CLINIC',
    rating: 4.9,
    location: 'Downtown',
    distance: '1.2 miles away',
    nextSlot: 'Next: 2:30 PM Today',
    image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBdCiuytJCU4K2UjXSqkf4CtyUZQ_1acYvR-DQo-wcu5W9eqB16ha9gIHJ96IRIrugRsdW59J7mLC_mzjHkciMaffs68dzgItdG7rVXg0zZKlcrwztkZyam1BNhyyOXFJHXfBxihqmE6z95qy9EYpQjJBAb83uu-nuz0-bGxocelptaVcuFXgY3S8WXTHeVKFUyGgpkOOOghU-t9CAr0tSr2TWvNA8mUEc_6EiSv7lLsaann2NyoQtcYEtP7Fgz83_xq4iTw0s0apI',
  },
  {
    id: 2,
    name: 'Glow Up Beauty Studio',
    category: 'SALON',
    rating: 4.7,
    location: 'Greenwich Village',
    distance: '0.8 miles away',
    nextSlot: 'Next: 4:00 PM Tomorrow',
    image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuD58O9sAwuQeuxjkT4V7XTtAL6Bzy0PJyDdklCjNqMtSYdgsqw_jm165mnOtdWfMqFi8NTN3KqK-9YV6QT7vRdcDarbWzYsvqEK_tf3PsCT0xHh0Df_VH78ut6zqruaNVaDm3vPCqX__7XwjOeMckEj-LPNpkok4HAGWU39pu2eelNJ3H33qaqb8f-9H6cU7sxO-PFC_OVrhQr1olgpOmkGxRnYmb4sAo6VX4gN50c4NP9tYqPI2WZrkbAz6QR-AKPsPsdPIH-VdAs',
  },
  {
    id: 3,
    name: 'Apex Math Tutoring',
    category: 'TUTOR',
    rating: 5.0,
    location: 'Chelsea',
    distance: '2.5 miles away',
    nextSlot: 'Next: 10:00 AM Sat',
    image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCakLGNctXB0gYEVj5qgAugU_tlBB3lZ7HIGqlmDMg7GBBFM5KVW6N8yQE_962w4m9uY4LMrjK3__2dGL8yJzKrvUU6uGbXQdFdsoa0m9q14wOJyJDcUFXy1oaTaBamMz8r-xhxDMLEb-4QXr-Aiwg9R5LyHeHnqGpaXtEmRNYFvqde2jD7styTels2lbpUHktmpflHOWUQiK-Zh9Aha0OYqcnkQGBKEjdy-WseojLs2jBuc7uaVrn7tXmpGAlHpl8F9dInUB4xrV0',
  },
]

const categoryColors: Record<string, string> = {
  CLINIC: 'bg-primary text-primary-foreground',
  SALON: 'bg-accent text-accent-foreground',
  TUTOR: 'bg-primary text-primary-foreground',
}

function BrowseContent() {
  const searchParams = useSearchParams()
  const initialCategory = searchParams.get('category') || 'clinics'
  const [activeCategory, setActiveCategory] = useState(initialCategory)
  const [showFilters, setShowFilters] = useState(false)

  const categoryOptions = [
    { key: 'clinics', label: 'Clinics', icon: Plus },
    { key: 'salons', label: 'Salons', icon: Plus },
    { key: 'tutors', label: 'Tutors', icon: Plus },
  ]

  return (
    <div className="min-h-[100dvh] bg-background pb-24">
      {/* Header */}
      <header className="sticky top-0 z-40 bg-primary px-4 pt-3 pb-3 text-primary-foreground">
        <div className="mx-auto flex max-w-md items-center justify-between">
          <div className="flex items-center gap-2">
            <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-primary-foreground/20">
              <svg className="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
              </svg>
            </div>
            <span className="text-lg font-bold">BookApp</span>
          </div>
          <div className="rounded-full bg-primary-foreground/20 px-3 py-1 text-xs font-semibold">
            <MapPin className="mr-1 inline h-3 w-3" />
            NEW YORK, NY
          </div>
          <Link href="/auth/login" className="text-sm font-semibold text-primary-foreground">
            Sign In
          </Link>
        </div>

        {/* Search */}
        <div className="mx-auto mt-3 max-w-md">
          <div className="flex items-center rounded-xl bg-card px-3 py-2.5">
            <svg className="mr-2 h-4 w-4 text-muted-foreground" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
            </svg>
            <input
              type="text"
              placeholder="Search clinics, salons, or tutors..."
              className="w-full border-none bg-transparent text-sm text-foreground placeholder:text-muted-foreground focus:ring-0 focus:outline-none"
            />
          </div>
        </div>
      </header>

      <main className="mx-auto max-w-md">
        {/* Category Pills */}
        <div className="flex gap-2 px-4 pt-4">
          {categoryOptions.map((cat) => (
            <button
              key={cat.key}
              onClick={() => setActiveCategory(cat.key)}
              className={`flex items-center gap-1.5 rounded-full px-4 py-2 text-sm font-semibold transition-all ${
                activeCategory === cat.key
                  ? 'bg-primary text-primary-foreground'
                  : 'bg-card text-foreground border border-border'
              }`}
            >
              {activeCategory === cat.key && <Plus className="h-3.5 w-3.5" />}
              {cat.label}
            </button>
          ))}
        </div>

        {/* Advanced Filters */}
        <button
          onClick={() => setShowFilters(!showFilters)}
          className="mx-4 mt-3 flex w-[calc(100%-2rem)] items-center justify-between border-b border-border pb-3 text-sm font-medium text-foreground"
        >
          <div className="flex items-center gap-2">
            <svg className="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 6V4m0 2a2 2 0 100 4m0-4a2 2 0 110 4m-6 8a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4m6 6v10m6-2a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4" />
            </svg>
            Advanced Filters
          </div>
          <ChevronDown className={`h-4 w-4 transition-transform ${showFilters ? 'rotate-180' : ''}`} />
        </button>

        {/* Provider List */}
        <section className="px-4 pt-4">
          <h2 className="mb-4 text-xl font-bold text-foreground">Available Near You</h2>
          <div className="flex flex-col gap-6">
            {providers.map((provider) => (
              <Link key={provider.id} href={`/provider/${provider.id}`}>
                <div className="overflow-hidden rounded-2xl border border-border bg-card shadow-sm transition-all hover:shadow-lg">
                  {/* Image */}
                  <div className="relative h-48">
                    <img
                      src={provider.image}
                      alt={provider.name}
                      className="h-full w-full object-cover"
                      crossOrigin="anonymous"
                    />
                    <span
                      className={`absolute left-3 top-3 rounded-md px-2.5 py-1 text-[10px] font-bold uppercase tracking-wider ${
                        categoryColors[provider.category] || 'bg-primary text-primary-foreground'
                      }`}
                    >
                      {provider.category}
                    </span>
                  </div>

                  {/* Info */}
                  <div className="p-4">
                    <div className="flex items-start justify-between">
                      <h3 className="text-base font-bold text-foreground">{provider.name}</h3>
                      <div className="flex items-center gap-1">
                        <Star className="h-4 w-4 fill-accent text-accent" />
                        <span className="text-sm font-bold text-accent">{provider.rating}</span>
                      </div>
                    </div>
                    <div className="mt-1 flex items-center gap-1 text-xs text-muted-foreground">
                      <MapPin className="h-3 w-3 text-primary" />
                      {provider.location} &bull; {provider.distance}
                    </div>
                    <div className="mt-3 flex items-center justify-between">
                      <p className="text-xs font-medium text-foreground">{provider.nextSlot}</p>
                      <span className="rounded-full bg-accent px-4 py-2 text-xs font-bold text-accent-foreground">
                        Book Now
                      </span>
                    </div>
                  </div>
                </div>
              </Link>
            ))}
          </div>
        </section>
      </main>

      <BottomNav />
    </div>
  )
}

export default function BrowsePage() {
  return (
    <Suspense fallback={null}>
      <BrowseContent />
    </Suspense>
  )
}
