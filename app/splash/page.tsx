'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import { BookOpen } from 'lucide-react'

export default function SplashScreen() {
  const router = useRouter()
  const [progress, setProgress] = useState(0)

  useEffect(() => {
    const interval = setInterval(() => {
      setProgress((prev) => {
        if (prev >= 100) {
          clearInterval(interval)
          return 100
        }
        return prev + 2
      })
    }, 40)

    const timeout = setTimeout(() => {
      router.push('/welcome')
    }, 2500)

    return () => {
      clearInterval(interval)
      clearTimeout(timeout)
    }
  }, [router])

  return (
    <div className="flex min-h-[100dvh] flex-col items-center justify-center bg-gradient-to-b from-[#0d968b] to-[#0a7a71] px-6">
      {/* Logo */}
      <div className="flex flex-col items-center">
        <div className="mb-6 flex h-28 w-28 items-center justify-center rounded-full bg-card shadow-xl">
          <BookOpen className="h-14 w-14 text-primary" />
        </div>
        <h1 className="text-3xl font-bold tracking-tight text-primary-foreground">
          BookApp
        </h1>
        <p className="mt-2 text-base text-primary-foreground/70">
          Book. Confirm. Done.
        </p>
      </div>

      {/* Loading indicator */}
      <div className="mt-24 flex flex-col items-center gap-4">
        <div className="h-6 w-6 animate-spin rounded-full border-2 border-primary-foreground/30 border-t-primary-foreground" />
        <div className="w-56">
          <div className="flex items-center justify-between mb-2">
            <span className="text-xs font-medium uppercase tracking-widest text-primary-foreground/50">
              Initializing
            </span>
            <span className="text-xs font-bold text-primary-foreground/70">
              {progress}%
            </span>
          </div>
          <div className="h-1.5 w-full overflow-hidden rounded-full bg-primary-foreground/20">
            <div
              className="h-full rounded-full bg-primary-foreground/60 transition-all duration-100"
              style={{ width: `${progress}%` }}
            />
          </div>
        </div>
      </div>
    </div>
  )
}
