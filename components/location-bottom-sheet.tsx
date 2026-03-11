'use client'

import { X, Search, Navigation2 } from 'lucide-react'
import { useState } from 'react'

interface LocationBottomSheetProps {
  onSelect: (location: string) => void
  onClose: () => void
}

const popularCities = [
  'Algiers',
  'Oran',
  'Constantine',
  'Sétif',
  'Annaba',
  'Blida',
  'Tlemcen',
  'Batna'
]

export default function LocationBottomSheet({ onSelect, onClose }: LocationBottomSheetProps) {
  const [searchQuery, setSearchQuery] = useState('')
  
  const filteredCities = popularCities.filter(city =>
    city.toLowerCase().includes(searchQuery.toLowerCase())
  )

  const handleSelectCity = (city: string) => {
    onSelect(`${city}, Algeria`)
  }

  return (
    <>
      {/* Backdrop */}
      <div
        className="fixed inset-0 z-40 bg-black/50"
        onClick={onClose}
      />

      {/* Bottom Sheet */}
      <div className="fixed inset-x-0 bottom-0 z-50 flex flex-col rounded-t-3xl bg-background max-h-[90vh] animate-in slide-in-from-bottom-10">
        {/* Handle Bar */}
        <div className="flex justify-center pt-3 pb-2">
          <div className="h-1 w-12 rounded-full bg-muted" />
        </div>

        {/* Header */}
        <div className="flex items-center justify-between border-b border-border px-4 py-4">
          <h2 className="text-xl font-bold text-foreground">Select Location</h2>
          <button
            onClick={onClose}
            className="rounded-full p-1 hover:bg-muted transition-colors"
          >
            <X className="h-6 w-6 text-muted-foreground" />
          </button>
        </div>

        {/* Content */}
        <div className="flex-1 overflow-y-auto px-4 py-4">
          {/* Search Bar */}
          <div className="mb-6 flex items-center gap-3 rounded-2xl bg-muted px-4 py-3">
            <Search className="h-5 w-5 text-primary" />
            <input
              type="text"
              placeholder="Search city or area..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="flex-1 border-none bg-transparent text-foreground placeholder:text-muted-foreground focus:outline-none"
            />
          </div>

          {/* Use Current Location */}
          <div
            onClick={() => handleSelectCity('Algiers')}
            className="mb-6 flex items-center gap-4 rounded-2xl bg-primary/5 p-4 cursor-pointer hover:bg-primary/10 transition-colors"
          >
            <div className="flex h-12 w-12 items-center justify-center rounded-full bg-primary/10">
              <Navigation2 className="h-6 w-6 text-primary" />
            </div>
            <div className="flex-1">
              <h3 className="font-semibold text-foreground">Use Current Location</h3>
              <p className="text-xs text-muted-foreground">Enable GPS for better accuracy</p>
            </div>
          </div>

          {/* Popular Cities */}
          <div>
            <h3 className="mb-4 text-xs font-bold uppercase tracking-widest text-muted-foreground">
              Popular Cities
            </h3>
            <div className="space-y-2">
              {filteredCities.length > 0 ? (
                filteredCities.map((city) => (
                  <button
                    key={city}
                    onClick={() => handleSelectCity(city)}
                    className="w-full flex items-center gap-4 rounded-xl p-4 hover:bg-muted transition-colors text-left group"
                  >
                    <div className="flex h-10 w-10 items-center justify-center rounded-full bg-muted group-hover:bg-primary/10">
                      <svg className="h-5 w-5 text-muted-foreground group-hover:text-primary" fill="currentColor" viewBox="0 0 20 20">
                        <path fillRule="evenodd" d="M5.05 4.05a7 7 0 119.9 9.9L10 18.9l-4.95-4.95a7 7 0 010-9.9zM10 11a2 2 0 100-4 2 2 0 000 4z" clipRule="evenodd" />
                      </svg>
                    </div>
                    <div className="flex-1">
                      <p className="font-medium text-foreground">{city}</p>
                    </div>
                    <svg className="h-5 w-5 text-muted-foreground" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                    </svg>
                  </button>
                ))
              ) : (
                <p className="py-4 text-center text-sm text-muted-foreground">
                  No cities found matching "{searchQuery}"
                </p>
              )}
            </div>
          </div>

          {/* Footer */}
          <div className="mt-8 pt-4 border-t border-border text-center">
            <p className="text-sm text-muted-foreground">
              Can't find your city?{' '}
              <button className="font-bold text-primary hover:underline">
                Contact support
              </button>
            </p>
          </div>
        </div>
      </div>
    </>
  )
}
