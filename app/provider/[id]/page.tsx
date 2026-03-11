'use client'

import { useState, use } from 'react'
import { ArrowLeft, Share2, Heart, Star, MapPin, Plus } from 'lucide-react'
import Link from 'next/link'
import { useRouter } from 'next/navigation'

const providerData = {
  id: 1,
  name: 'El-Djazair Medical Center',
  status: 'OPEN',
  type: 'Specialized Polyclinic',
  rating: 4.8,
  reviews: 124,
  ratingBreakdown: [
    { stars: 5, percentage: 85 },
    { stars: 4, percentage: 10 },
    { stars: 3, percentage: 3 },
    { stars: 2, percentage: 1 },
    { stars: 1, percentage: 1 },
  ],
  about:
    'El-Djazair Medical Center is a premier healthcare facility dedicated to providing comprehensive medical services with a focus on patient-centered care and advanced diagnostics. Our team of specialists is committed to excellence in every treatment.',
  services: [
    { name: 'General Consultation', duration: '20-30 mins', price: 3000, icon: Plus },
    { name: 'Cardiology Screening', duration: '45 mins', price: 5500, icon: Plus },
  ],
  location: '12 Rue des Freres Bouadou, Hydra, Algiers, Algeria',
  image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBdCiuytJCU4K2UjXSqkf4CtyUZQ_1acYvR-DQo-wcu5W9eqB16ha9gIHJ96IRIrugRsdW59J7mLC_mzjHkciMaffs68dzgItdG7rVXg0zZKlcrwztkZyam1BNhyyOXFJHXfBxihqmE6z95qy9EYpQjJBAb83uu-nuz0-bGxocelptaVcuFXgY3S8WXTHeVKFUyGgpkOOOghU-t9CAr0tSr2TWvNA8mUEc_6EiSv7lLsaann2NyoQtcYEtP7Fgz83_xq4iTw0s0apI',
}

export default function ProviderProfilePage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = use(params)
  const router = useRouter()
  const [liked, setLiked] = useState(false)

  return (
    <div className="min-h-[100dvh] bg-background pb-24">
      {/* Hero Image */}
      <div className="relative h-64">
        <img
          src={providerData.image}
          alt={providerData.name}
          className="h-full w-full object-cover"
          crossOrigin="anonymous"
        />
        <div className="absolute inset-0 bg-gradient-to-t from-foreground/70 via-foreground/20 to-transparent" />

        {/* Navigation */}
        <div className="absolute inset-x-0 top-0 flex items-center justify-between p-4 pt-12">
          <button
            onClick={() => router.back()}
            className="flex h-10 w-10 items-center justify-center rounded-full bg-foreground/30 text-primary-foreground backdrop-blur-sm transition-colors hover:bg-foreground/50"
          >
            <ArrowLeft className="h-5 w-5" />
          </button>
          <div className="flex gap-2">
            <button className="flex h-10 w-10 items-center justify-center rounded-full bg-foreground/30 text-primary-foreground backdrop-blur-sm">
              <Share2 className="h-5 w-5" />
            </button>
            <button
              onClick={() => setLiked(!liked)}
              className="flex h-10 w-10 items-center justify-center rounded-full bg-foreground/30 text-primary-foreground backdrop-blur-sm"
            >
              <Heart className={`h-5 w-5 ${liked ? 'fill-destructive text-destructive' : ''}`} />
            </button>
          </div>
        </div>

        {/* Name overlay */}
        <div className="absolute bottom-4 left-4 right-4">
          <h1 className="text-2xl font-bold text-primary-foreground">{providerData.name}</h1>
          <div className="mt-1 flex items-center gap-2">
            <span className="rounded bg-success px-2 py-0.5 text-[10px] font-bold uppercase text-success-foreground">
              {providerData.status}
            </span>
            <span className="text-sm text-primary-foreground/80">{providerData.type}</span>
          </div>
        </div>
      </div>

      <main className="mx-auto max-w-md">
        {/* Rating Section */}
        <section className="border-b border-border px-4 py-5">
          <div className="flex items-start gap-6">
            <div>
              <div className="flex items-center gap-2">
                <span className="text-3xl font-bold text-primary">{providerData.rating}</span>
                <div className="flex">
                  {[1, 2, 3, 4, 5].map((s) => (
                    <Star
                      key={s}
                      className={`h-5 w-5 ${
                        s <= Math.floor(providerData.rating)
                          ? 'fill-primary text-primary'
                          : s <= providerData.rating + 0.5
                            ? 'fill-primary/50 text-primary'
                            : 'text-border'
                      }`}
                    />
                  ))}
                </div>
              </div>
              <p className="mt-1 text-sm text-muted-foreground">
                {providerData.reviews} patient reviews
              </p>
            </div>
            <div className="flex-1 space-y-1">
              {providerData.ratingBreakdown.slice(0, 2).map((r) => (
                <div key={r.stars} className="flex items-center gap-2 text-xs">
                  <span className="w-3 text-muted-foreground">{r.stars}</span>
                  <div className="h-2 flex-1 overflow-hidden rounded-full bg-muted">
                    <div
                      className="h-full rounded-full bg-primary"
                      style={{ width: `${r.percentage}%` }}
                    />
                  </div>
                  <span className="w-8 text-right text-muted-foreground">{r.percentage}%</span>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* About */}
        <section className="border-b border-border px-4 py-5">
          <h2 className="mb-3 text-lg font-bold text-foreground">About</h2>
          <p className="text-sm leading-relaxed text-muted-foreground">{providerData.about}</p>
        </section>

        {/* Services */}
        <section className="border-b border-border px-4 py-5">
          <h2 className="mb-4 text-lg font-bold text-foreground">Services</h2>
          <div className="flex flex-col gap-3">
            {providerData.services.map((service, idx) => (
              <div
                key={idx}
                className="flex items-center justify-between rounded-xl bg-muted p-4"
              >
                <div className="flex items-center gap-3">
                  <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-primary/10">
                    <service.icon className="h-5 w-5 text-primary" />
                  </div>
                  <div>
                    <h3 className="text-sm font-semibold text-foreground">{service.name}</h3>
                    <p className="text-xs text-muted-foreground">Duration: {service.duration}</p>
                  </div>
                </div>
                <span className="text-sm font-bold text-primary">
                  DZD {service.price.toLocaleString()}
                </span>
              </div>
            ))}
          </div>
        </section>

        {/* Location */}
        <section className="px-4 py-5">
          <div className="mb-3 flex items-center justify-between">
            <h2 className="text-lg font-bold text-foreground">Location</h2>
            <button className="text-xs font-bold uppercase tracking-wider text-primary">
              Get Directions
            </button>
          </div>
          <div className="mb-3 flex items-start gap-2 text-sm text-muted-foreground">
            <MapPin className="mt-0.5 h-4 w-4 shrink-0 text-primary" />
            <p>{providerData.location}</p>
          </div>
          {/* Map placeholder */}
          <div className="h-48 overflow-hidden rounded-xl bg-muted">
            <iframe
              title="Map"
              src="https://www.openstreetmap.org/export/embed.html?bbox=3.0%2C36.7%2C3.1%2C36.8&layer=mapnik"
              className="h-full w-full border-0"
            />
          </div>
        </section>
      </main>

      {/* Sticky CTA */}
      <div className="fixed inset-x-0 bottom-0 z-50 border-t border-border bg-card p-4">
        <div className="mx-auto max-w-md">
          <Link
            href={`/booking/${id}`}
            className="flex w-full items-center justify-center gap-2 rounded-xl bg-primary py-4 font-bold text-primary-foreground shadow-lg shadow-primary/25 transition-all active:scale-[0.98]"
          >
            <svg className="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
            </svg>
            Book Appointment
          </Link>
        </div>
      </div>
    </div>
  )
}
