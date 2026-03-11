'use client'

import React, { createContext, useContext, useState, useCallback, useEffect } from 'react'

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
}

const BookingContext = createContext<BookingContextType>({
  bookings: [],
  addBooking: () => {},
  cancelBooking: () => {},
  rescheduleBooking: () => {},
  location: 'Algiers, Algeria',
  setLocation: () => {},
})

const defaultBookings: Booking[] = [
  {
    id: 'default-1',
    provider: 'Dr. Sarah Jenkins',
    service: 'General Consultation',
    date: 'Oct 24, 2023',
    time: '10:00 AM',
    avatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBMPaHBMiyjJbLlvdNEiDoBsVDjpi93KLapwnWXFptmvX584YIxwL025WGYI7eQgWELQV_eG4Vu5W0tFnpK7hbmwiN7bcq_4Ly20V2MUFOMCX0pRhvzRYGWtq9VQ4_0ra-JnawE3mAfcFjEla4oK9pvigVSoZvH1jTiOAT1tm7U0GEiHKuxEPY9InLPL7JI0oLJd36kbdrcS7E0o0vkBqGK6HmLSdQCqCkQJVstJ6rfv7aKMLydbKL8PWU1kkSSs3jaEJTiuHg0wWI',
    status: 'upcoming',
    fee: 'DZD 3,000',
  },
  {
    id: 'default-2',
    provider: 'Dr. Marcus Chen',
    service: 'Dental Cleaning',
    date: 'Oct 28, 2023',
    time: '02:30 PM',
    avatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuA5XiEEsIXwqxICBdsIGs3Mbht1Hh4UHfo7kAijOZ_zE7ss_fkX4o5BZyAyl6fniF3bh4Pku85i3s5x6oPpuJEuwBlLJ4NnOAyV6bTytXPj8Wl16tJmE4QyNP0SFVch3bJUVdq75rRW7z60Lv4d5WBdQKbj-iS9MofjBCjOvJDsJX4q6YRgnFUEkoK7_HsXylEOZMC8X-XdDB0Jjv0mEYE2Q8N8jF0kFPGEs9viY5X0uKH_DIYm5Gbg1w40egsl6-ZCWNdsAN-czAg',
    status: 'upcoming',
    fee: 'DZD 5,500',
  },
  {
    id: 'default-3',
    provider: 'Dr. Elena Rodriguez',
    service: 'Pediatric Follow-up',
    date: 'Oct 15, 2023',
    time: '09:00 AM',
    avatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBE-r0o-6UzFFrN64npT94cO4od7-qFk7SaqtJA7AzX1CqWx2moJmQPrj-5R3JXmsRozgc5yE0HXn3aLBapHZZS8_fR05s5DbZwBuo-a67bQC_1i8Np7f8RDB_4PL5qQ0EQdt_jUtHLY1yz-lT8Y9fMqYi-ZApEQB8t4NkNJVj_n8WGnnBhiAFOswODcAhKcOofi0W_-N70DQwdOtj_LjnboI7OxNQsw5-EfvfUA6WURLWS1VVok0LwprxUK_FB4d_je5-mTzoVs9Y',
    status: 'past',
    fee: 'DZD 3,000',
  },
]

export function BookingProvider({ children }: { children: React.ReactNode }) {
  const [bookings, setBookings] = useState<Booking[]>(defaultBookings)
  const [location, setLocationState] = useState('Algiers, Algeria')

  useEffect(() => {
    const savedLocation = localStorage.getItem('bookapp-location')
    if (savedLocation) setLocationState(savedLocation)
    const savedBookings = localStorage.getItem('bookapp-bookings')
    if (savedBookings) {
      try {
        setBookings(JSON.parse(savedBookings))
      } catch { /* ignore */ }
    }
  }, [])

  const persist = useCallback((updated: Booking[]) => {
    setBookings(updated)
    localStorage.setItem('bookapp-bookings', JSON.stringify(updated))
  }, [])

  const addBooking = useCallback((booking: Omit<Booking, 'id' | 'status'>) => {
    const newBooking: Booking = {
      ...booking,
      id: `bk-${Date.now()}`,
      status: 'upcoming',
    }
    setBookings(prev => {
      const updated = [newBooking, ...prev]
      localStorage.setItem('bookapp-bookings', JSON.stringify(updated))
      return updated
    })
  }, [])

  const cancelBooking = useCallback((id: string) => {
    setBookings(prev => {
      const updated = prev.map(b => b.id === id ? { ...b, status: 'cancelled' as const } : b)
      localStorage.setItem('bookapp-bookings', JSON.stringify(updated))
      return updated
    })
  }, [])

  const rescheduleBooking = useCallback((id: string, newDate: string, newTime: string) => {
    setBookings(prev => {
      const updated = prev.map(b =>
        b.id === id ? { ...b, date: newDate, time: newTime } : b
      )
      localStorage.setItem('bookapp-bookings', JSON.stringify(updated))
      return updated
    })
  }, [])

  const setLocation = useCallback((loc: string) => {
    setLocationState(loc)
    localStorage.setItem('bookapp-location', loc)
  }, [])

  return (
    <BookingContext.Provider value={{ bookings, addBooking, cancelBooking, rescheduleBooking, location, setLocation }}>
      {children}
    </BookingContext.Provider>
  )
}

export function useBookings() {
  return useContext(BookingContext)
}
