'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { Building2, CalendarCheck, CheckCircle2, MapPin } from 'lucide-react'

const slides = [
  {
    icon: Building2,
    accent: MapPin,
    title: 'Find Providers Near You',
    description:
      'Access thousands of certified healthcare professionals in your area.',
  },
  {
    icon: CalendarCheck,
    accent: null,
    title: 'Book in Seconds',
    description:
      'Choose a date and time that works for you. Scheduling has never been easier.',
  },
  {
    icon: CheckCircle2,
    accent: null,
    title: 'Get Confirmed Instantly',
    description:
      'Receive instant confirmation and reminders for your appointments.',
  },
]

export default function WelcomePage() {
  const router = useRouter()
  const [activeSlide, setActiveSlide] = useState(0)

  const handleNext = () => {
    if (activeSlide < slides.length - 1) {
      setActiveSlide(activeSlide + 1)
    }
  }

  const current = slides[activeSlide]
  const Icon = current.icon

  return (
    <div className="flex min-h-[100dvh] flex-col bg-background px-6 pt-12">
      {/* Slide Content */}
      <div className="flex flex-1 flex-col items-center justify-center">
        {/* Visual Container */}
        <div className="relative mb-10 flex aspect-square w-full max-w-[320px] items-center justify-center rounded-2xl bg-primary/10">
          <div className="absolute inset-0 rounded-2xl bg-gradient-to-br from-primary/20 to-transparent" />
          <Icon className="relative z-10 h-28 w-28 text-primary" />
          {current.accent && (
            <div className="absolute bottom-4 right-4 rounded-lg border border-primary/10 bg-card p-3 shadow-sm">
              <current.accent className="h-5 w-5 text-primary" />
            </div>
          )}
        </div>

        {/* Text Content */}
        <h1 className="text-center text-3xl font-bold leading-tight text-foreground text-balance">
          {current.title}
        </h1>
        <p className="mt-4 max-w-[300px] text-center text-base leading-relaxed text-primary/70">
          {current.description}
        </p>
      </div>

      {/* Navigation & CTA Footer */}
      <div className="mx-auto w-full max-w-[480px] pb-12 pt-6">
        {/* Dot Indicators */}
        <div className="mb-8 flex items-center justify-center gap-2">
          {slides.map((_, i) => (
            <button
              key={i}
              onClick={() => setActiveSlide(i)}
              className={`h-2 rounded-full transition-all duration-300 ${
                i === activeSlide ? 'w-6 bg-primary' : 'w-2 bg-primary/20'
              }`}
              aria-label={`Go to slide ${i + 1}`}
            />
          ))}
        </div>

        {/* Action Buttons */}
        <div className="flex flex-col gap-3">
          <button
            onClick={() => router.push('/auth/signup')}
            className="flex h-14 w-full items-center justify-center rounded-xl bg-primary text-base font-semibold text-primary-foreground transition-colors hover:bg-primary/90"
          >
            Sign Up
          </button>
          <button
            onClick={() => router.push('/auth/login')}
            className="flex h-14 w-full items-center justify-center rounded-xl border-2 border-primary text-base font-semibold text-primary transition-colors hover:bg-primary/5"
          >
            Log In
          </button>
        </div>

        {/* Skip option */}
        <div className="mt-6 text-center">
          <button
            onClick={() => router.push('/')}
            className="text-sm font-medium text-primary/60 transition-colors hover:text-primary"
          >
            Skip for now
          </button>
        </div>
      </div>
    </div>
  )
}
