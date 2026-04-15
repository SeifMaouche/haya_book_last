'use client'

import React, { createContext, useContext, useState, useCallback, useEffect } from 'react'
import { adminFetch } from './api-admin'

export interface Booking {
  id: string
  provider: string
  service: string
  date: string
  time: string
  avatar: string
  status: 'upcoming' | 'past' | 'cancelled'
  fee?: string
}

interface BookingContextType {
  bookings: Booking[]
  addBooking: (booking: Omit<Booking, 'id' | 'status'>) => void
  cancelBooking: (id: string) => void
  rescheduleBooking: (id: string, newDate: string, newTime: string) => void
  location: string
  setLocation: (loc: string) => void
  isLoading: boolean
  error: string | null
}

const BookingContext = createContext<BookingContextType>({
  bookings: [],
  addBooking: () => {},
  cancelBooking: () => {},
  rescheduleBooking: () => {},
  location: 'Algiers, Algeria',
  setLocation: () => {},
  isLoading: false,
  error: null,
})

export function BookingProvider({ children }: { children: React.ReactNode }) {
  const [bookings, setBookings] = useState<Booking[]>([])
  const [location, setLocationState] = useState('Algiers, Algeria')
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const fetchBookings = useCallback(async () => {
    setIsLoading(true)
    setError(null)
    try {
      const data = await adminFetch('/admin/bookings')
      const mapped: Booking[] = data.map((b: any) => {
        const provider = b.providerProfile || {}
        const user = provider.user || {}
        const service = b.service || {}
        
        let status: 'upcoming' | 'past' | 'cancelled' = 'upcoming'
        if (b.status === 'COMPLETED') status = 'past'
        if (b.status.startsWith('CANCELLED')) status = 'cancelled'

        return {
          id: b.id,
          provider: provider.businessName || `${user.firstName || ''} ${user.lastName || ''}`.trim() || 'Haya Provider',
          service: service.name || 'Haya Service',
          date: new Date(b.date).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' }),
          time: b.startTime,
          avatar: user.profileImage || '',
          status: status,
          fee: `DZD ${b.price?.toLocaleString() || '0'}`,
        }
      })
      setBookings(mapped)
    } catch (err: any) {
      console.error('Failed to fetch admin bookings:', err)
      setError(err.message)
    } finally {
      setIsLoading(false)
    }
  }, [])

  useEffect(() => {
    fetchBookings()
    const savedLocation = typeof window !== 'undefined' ? localStorage.getItem('bookapp-location') : null
    if (savedLocation) setLocationState(savedLocation)
  }, [fetchBookings])

  const addBooking = useCallback((booking: Omit<Booking, 'id' | 'status'>) => {
     // Admin manually adding a booking (optional, usually handled by client)
     console.log('Add booking not yet implemented via API for admin')
  }, [])

  const cancelBooking = useCallback(async (id: string) => {
    try {
      await adminFetch(`/bookings/${id}/status`, {
        method: 'PATCH',
        body: JSON.stringify({ status: 'CANCELLED_BY_PROVIDER' }) // Admin act as proxy
      })
      await fetchBookings()
    } catch (err) {
      console.error('Failed to cancel booking:', err)
    }
  }, [fetchBookings])

  const rescheduleBooking = useCallback(async (id: string, newDate: string, newTime: string) => {
    // Ported from mock to console warning as backend might need specific logic for re-scheduling
    console.warn('Reschedule via admin not yet fully implemented in backend')
  }, [])

  const setLocation = useCallback((loc: string) => {
    setLocationState(loc)
    if (typeof window !== 'undefined') localStorage.setItem('bookapp-location', loc)
  }, [])

  return (
    <BookingContext.Provider value={{ 
      bookings, 
      addBooking, 
      cancelBooking, 
      rescheduleBooking, 
      location, 
      setLocation, 
      isLoading, 
      error 
    }}>
      {children}
    </BookingContext.Provider>
  )
}

export function useBookings() {
  return useContext(BookingContext)
}
