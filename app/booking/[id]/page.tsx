'use client'

import { useState, use } from 'react'
import { ArrowLeft, ChevronLeft, ChevronRight, Clock, Ban, CheckCircle2 } from 'lucide-react'
import { useRouter } from 'next/navigation'
import Link from 'next/link'

type TimeSlot = {
  time: string
  available: boolean
}

const timeSlots: TimeSlot[] = [
  { time: '09:00 AM', available: true },
  { time: '09:30 AM', available: true },
  { time: '10:00 AM', available: true },
  { time: '10:30 AM', available: true },
  { time: '11:00 AM', available: true },
  { time: '11:30 AM', available: true },
  { time: '12:00 PM', available: false },
  { time: '12:30 PM', available: true },
]

export default function BookingCalendarPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = use(params)
  const router = useRouter()
  const [currentMonth, setCurrentMonth] = useState(new Date(2023, 9)) // October 2023
  const [selectedDay, setSelectedDay] = useState(5)
  const [selectedTime, setSelectedTime] = useState('09:00 AM')

  const getDaysInMonth = (date: Date) =>
    new Date(date.getFullYear(), date.getMonth() + 1, 0).getDate()
  const getFirstDayOfMonth = (date: Date) =>
    new Date(date.getFullYear(), date.getMonth(), 1).getDay()

  const daysInMonth = getDaysInMonth(currentMonth)
  const firstDay = getFirstDayOfMonth(currentMonth)
  const days = Array.from({ length: daysInMonth }, (_, i) => i + 1)
  const emptyDays = Array.from({ length: firstDay }, (_, i) => i)

  const monthYear = currentMonth.toLocaleDateString('en-US', {
    month: 'long',
    year: 'numeric',
  })

  const selectedDateLabel = new Date(
    currentMonth.getFullYear(),
    currentMonth.getMonth(),
    selectedDay
  ).toLocaleDateString('en-US', {
    weekday: 'long',
    month: 'short',
    day: 'numeric',
  })

  const nextMonth = () =>
    setCurrentMonth(new Date(currentMonth.getFullYear(), currentMonth.getMonth() + 1))
  const prevMonth = () =>
    setCurrentMonth(new Date(currentMonth.getFullYear(), currentMonth.getMonth() - 1))

  const handleConfirm = () => {
    const dateStr = new Date(
      currentMonth.getFullYear(),
      currentMonth.getMonth(),
      selectedDay
    ).toISOString()
    router.push(`/confirmation/${id}?date=${dateStr}&time=${selectedTime}`)
  }

  return (
    <div className="flex min-h-[100dvh] flex-col bg-background">
      {/* Header */}
      <header className="sticky top-0 z-50 border-b border-primary/10 bg-background/80 backdrop-blur-md">
        <div className="mx-auto flex w-full max-w-2xl items-center justify-between p-4">
          <button
            onClick={() => router.back()}
            className="rounded-full p-2 text-primary transition-colors hover:bg-primary/10"
          >
            <ArrowLeft className="h-5 w-5" />
          </button>
          <h1 className="flex-1 text-center text-lg font-bold tracking-tight text-primary">
            Select Date & Time
          </h1>
          <div className="w-10" />
        </div>
      </header>

      <main className="mx-auto flex-1 w-full max-w-2xl pb-32">
        {/* Provider Info */}
        <div className="px-4 pt-6 pb-2">
          <div className="mb-1 flex items-center gap-2">
            <div className="flex h-6 w-6 items-center justify-center rounded bg-primary/10">
              <svg className="h-4 w-4 text-primary" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
              </svg>
            </div>
            <span className="text-sm font-semibold uppercase tracking-wider text-primary">
              Healthcare Provider
            </span>
          </div>
          <h2 className="text-2xl font-bold leading-tight text-foreground">
            El-Djazair Medical Center
          </h2>
          <div className="mt-2 flex items-center gap-1 text-sm text-muted-foreground">
            <svg className="h-3.5 w-3.5 text-primary" fill="currentColor" viewBox="0 0 24 24">
              <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z" />
            </svg>
            <span>123 Boulevard des Martyrs, Algiers</span>
          </div>
        </div>

        {/* Calendar */}
        <section className="mt-6 px-4">
          <div className="rounded-xl border border-primary/5 bg-card p-4 shadow-sm">
            <div className="mb-4 flex items-center justify-between">
              <button
                onClick={prevMonth}
                className="rounded-full p-2 text-muted-foreground hover:bg-primary/10"
              >
                <ChevronLeft className="h-5 w-5" />
              </button>
              <p className="text-lg font-bold text-foreground">{monthYear}</p>
              <button
                onClick={nextMonth}
                className="rounded-full p-2 text-muted-foreground hover:bg-primary/10"
              >
                <ChevronRight className="h-5 w-5" />
              </button>
            </div>

            <div className="mb-2 grid grid-cols-7">
              {['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'].map((d) => (
                <div
                  key={d}
                  className="py-2 text-center text-xs font-bold uppercase text-muted-foreground"
                >
                  {d}
                </div>
              ))}
            </div>

            <div className="grid grid-cols-7 gap-1">
              {emptyDays.map((_, i) => (
                <div key={`e-${i}`} className="h-12" />
              ))}
              {days.map((day) => {
                const isSelected = selectedDay === day
                const isDisabled = day === 2 || day === 24
                return (
                  <button
                    key={day}
                    disabled={isDisabled}
                    onClick={() => setSelectedDay(day)}
                    className={`flex h-12 w-full items-center justify-center rounded-lg font-medium transition-all ${
                      isDisabled
                        ? 'cursor-not-allowed text-border'
                        : isSelected
                          ? 'bg-primary font-bold text-primary-foreground shadow-lg shadow-primary/30'
                          : 'text-foreground hover:bg-primary/10'
                    }`}
                  >
                    {day}
                  </button>
                )
              })}
            </div>
          </div>
        </section>

        {/* Time Slots */}
        <section className="mt-8 px-4">
          <div className="mb-4 flex items-center justify-between">
            <h3 className="text-lg font-bold text-foreground">Available Slots</h3>
            <span className="rounded bg-muted px-2 py-1 text-xs font-medium text-muted-foreground">
              {selectedDateLabel}
            </span>
          </div>
          <div className="grid grid-cols-2 gap-3">
            {timeSlots.map((slot) => {
              const isSelected = selectedTime === slot.time && slot.available
              return (
                <button
                  key={slot.time}
                  disabled={!slot.available}
                  onClick={() => setSelectedTime(slot.time)}
                  className={`flex items-center justify-center gap-3 rounded-xl border-2 p-4 transition-all ${
                    !slot.available
                      ? 'cursor-not-allowed border-muted bg-muted text-muted-foreground'
                      : isSelected
                        ? 'border-primary bg-primary/5 text-primary'
                        : 'border-primary/20 bg-card text-foreground hover:border-primary'
                  }`}
                >
                  {!slot.available ? (
                    <Ban className="h-4 w-4 opacity-40" />
                  ) : (
                    <Clock className={`h-4 w-4 ${isSelected ? '' : 'opacity-60'}`} />
                  )}
                  <span
                    className={`text-base font-medium ${
                      !slot.available ? 'line-through' : isSelected ? 'font-bold' : ''
                    }`}
                  >
                    {slot.time}
                  </span>
                </button>
              )
            })}
          </div>
        </section>

        {/* Legend */}
        <div className="mt-8 flex flex-wrap justify-center gap-4 px-4">
          <div className="flex items-center gap-2">
            <div className="h-3 w-3 rounded-full bg-primary" />
            <span className="text-xs text-muted-foreground">Selected</span>
          </div>
          <div className="flex items-center gap-2">
            <div className="h-3 w-3 rounded-full border border-primary/30 bg-card" />
            <span className="text-xs text-muted-foreground">Available</span>
          </div>
          <div className="flex items-center gap-2">
            <div className="h-3 w-3 rounded-full bg-muted" />
            <span className="text-xs text-muted-foreground">Fully Booked</span>
          </div>
        </div>
      </main>

      {/* Sticky CTA */}
      <footer className="fixed inset-x-0 bottom-0 border-t border-primary/10 bg-background/90 p-4 backdrop-blur-lg">
        <div className="mx-auto max-w-2xl">
          <button
            onClick={handleConfirm}
            disabled={!selectedDay || !selectedTime}
            className="flex w-full items-center justify-center gap-2 rounded-xl bg-primary py-4 font-bold text-primary-foreground shadow-lg shadow-primary/25 transition-all active:scale-[0.98] disabled:opacity-50"
          >
            <span>Confirm Booking</span>
            <CheckCircle2 className="h-5 w-5" />
          </button>
        </div>
      </footer>
    </div>
  )
}
