'use client';

import { useState } from 'react';
import { ChevronLeft, ChevronRight, Clock, Plus, Trash2 } from 'lucide-react';
import { Button } from '@/components/ui/button';

interface TimeSlot {
  id: string;
  time: string;
  booked: boolean;
  clientName?: string;
}

interface BreakTime {
  id: string;
  start: string;
  end: string;
}

export default function CalendarPage() {
  const [currentMonth, setCurrentMonth] = useState(new Date(2024, 2));
  const [selectedDate, setSelectedDate] = useState<Date | null>(new Date(2024, 2, 15));
  const [breaks, setBreaks] = useState<BreakTime[]>([
    { id: '1', start: '12:00', end: '13:00' },
  ]);
  const [workingDays, setWorkingDays] = useState({
    mon: true,
    tue: true,
    wed: true,
    thu: true,
    fri: true,
    sat: true,
    sun: false,
  });

  const timeSlots: TimeSlot[] = [
    { id: '1', time: '09:00', booked: false },
    { id: '2', time: '09:30', booked: true, clientName: 'Ahmed Hassan' },
    { id: '3', time: '10:00', booked: false },
    { id: '4', time: '10:30', booked: true, clientName: 'Fatima Ali' },
    { id: '5', time: '11:00', booked: false },
    { id: '6', time: '11:30', booked: false },
    { id: '7', time: '13:00', booked: false },
    { id: '8', time: '13:30', booked: true, clientName: 'Omar Mohamed' },
    { id: '9', time: '14:00', booked: false },
    { id: '10', time: '14:30', booked: false },
    { id: '11', time: '15:00', booked: false },
    { id: '12', time: '15:30', booked: true, clientName: 'Leila Ben' },
  ];

  const monthYear = currentMonth.toLocaleDateString('en-US', {
    month: 'long',
    year: 'numeric',
  });

  const getDaysInMonth = (date: Date) => {
    return new Date(date.getFullYear(), date.getMonth() + 1, 0).getDate();
  };

  const getFirstDayOfMonth = (date: Date) => {
    return new Date(date.getFullYear(), date.getMonth(), 1).getDay();
  };

  const daysInMonth = getDaysInMonth(currentMonth);
  const firstDay = getFirstDayOfMonth(currentMonth);
  const days = Array.from({ length: daysInMonth }, (_, i) => i + 1);

  const nextMonth = () => {
    setCurrentMonth(new Date(currentMonth.getFullYear(), currentMonth.getMonth() + 1));
  };

  const prevMonth = () => {
    setCurrentMonth(new Date(currentMonth.getFullYear(), currentMonth.getMonth() - 1));
  };

  const addBreak = () => {
    const newId = Math.random().toString();
    setBreaks([...breaks, { id: newId, start: '14:00', end: '15:00' }]);
  };

  const removeBreak = (id: string) => {
    setBreaks(breaks.filter((b) => b.id !== id));
  };

  return (
    <div className="max-w-7xl mx-auto space-y-8">
      {/* Page Title */}
      <div>
        <h1 className="text-3xl font-bold text-foreground">Calendar & Availability</h1>
        <p className="text-muted-foreground">Manage your schedule and availability.</p>
      </div>

      <div className="grid grid-cols-1 gap-8 lg:grid-cols-3">
        {/* Calendar */}
        <div className="lg:col-span-2 rounded-xl border border-border bg-card p-6">
          {/* Month Navigation */}
          <div className="mb-6 flex items-center justify-between">
            <button
              onClick={prevMonth}
              className="p-2 hover:bg-muted rounded-lg transition"
            >
              <ChevronLeft className="h-5 w-5" />
            </button>
            <h2 className="text-lg font-semibold text-foreground">{monthYear}</h2>
            <button
              onClick={nextMonth}
              className="p-2 hover:bg-muted rounded-lg transition"
            >
              <ChevronRight className="h-5 w-5" />
            </button>
          </div>

          {/* Day Headers */}
          <div className="mb-4 grid grid-cols-7 gap-2">
            {['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map((day) => (
              <div
                key={day}
                className="text-center text-sm font-semibold text-muted-foreground py-2"
              >
                {day}
              </div>
            ))}
          </div>

          {/* Calendar Grid */}
          <div className="grid grid-cols-7 gap-2">
            {Array(firstDay)
              .fill(0)
              .map((_, idx) => (
                <div key={`empty-${idx}`} />
              ))}
            {days.map((day) => {
              const isSelected =
                selectedDate?.getDate() === day &&
                selectedDate?.getMonth() === currentMonth.getMonth();

              return (
                <button
                  key={day}
                  onClick={() => {
                    setSelectedDate(
                      new Date(
                        currentMonth.getFullYear(),
                        currentMonth.getMonth(),
                        day
                      )
                    );
                  }}
                  className={`aspect-square rounded-lg font-semibold text-sm transition ${
                    isSelected
                      ? 'bg-primary text-primary-foreground'
                      : 'bg-background hover:bg-muted'
                  }`}
                >
                  {day}
                </button>
              );
            })}
          </div>
        </div>

        {/* Availability Settings */}
        <div className="space-y-6">
          {/* Working Days */}
          <div className="rounded-xl border border-border bg-card p-6">
            <h3 className="text-lg font-semibold text-foreground mb-4">Working Days</h3>
            <div className="space-y-3">
              {[
                { key: 'mon', label: 'Monday' },
                { key: 'tue', label: 'Tuesday' },
                { key: 'wed', label: 'Wednesday' },
                { key: 'thu', label: 'Thursday' },
                { key: 'fri', label: 'Friday' },
                { key: 'sat', label: 'Saturday' },
                { key: 'sun', label: 'Sunday' },
              ].map((day) => (
                <label key={day.key} className="flex items-center gap-3 cursor-pointer">
                  <input
                    type="checkbox"
                    checked={
                      workingDays[day.key as keyof typeof workingDays]
                    }
                    onChange={(e) =>
                      setWorkingDays({
                        ...workingDays,
                        [day.key]: e.target.checked,
                      })
                    }
                    className="h-4 w-4 rounded border-border accent-primary"
                  />
                  <span className="text-sm font-medium text-foreground">
                    {day.label}
                  </span>
                </label>
              ))}
            </div>
          </div>

          {/* Working Hours */}
          <div className="rounded-xl border border-border bg-card p-6">
            <h3 className="text-lg font-semibold text-foreground mb-4">Working Hours</h3>
            <div className="space-y-3">
              <div>
                <label className="text-sm text-muted-foreground block mb-2">
                  Start Time
                </label>
                <input
                  type="time"
                  defaultValue="09:00"
                  className="w-full rounded-lg border border-border bg-background px-3 py-2"
                />
              </div>
              <div>
                <label className="text-sm text-muted-foreground block mb-2">
                  End Time
                </label>
                <input
                  type="time"
                  defaultValue="18:00"
                  className="w-full rounded-lg border border-border bg-background px-3 py-2"
                />
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Time Slots for Selected Date */}
      {selectedDate && (
        <div className="rounded-xl border border-border bg-card p-6">
          <div className="flex items-center justify-between mb-6">
            <h3 className="text-lg font-semibold text-foreground">
              Time Slots - {selectedDate.toLocaleDateString('en-US', {
                weekday: 'long',
                month: 'short',
                day: 'numeric',
              })}
            </h3>
          </div>

          <div className="grid grid-cols-2 gap-3 sm:grid-cols-4 md:grid-cols-6 mb-8">
            {timeSlots.map((slot) => (
              <div
                key={slot.id}
                className={`rounded-lg border-2 p-3 text-center transition ${
                  slot.booked
                    ? 'border-primary bg-primary/10'
                    : 'border-border bg-background hover:border-primary'
                }`}
              >
                <p className="font-semibold text-sm text-foreground">{slot.time}</p>
                {slot.booked && (
                  <p className="text-xs text-primary mt-1 truncate">
                    {slot.clientName}
                  </p>
                )}
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Break Times */}
      <div className="rounded-xl border border-border bg-card p-6">
        <div className="flex items-center justify-between mb-6">
          <h3 className="text-lg font-semibold text-foreground">Break Times</h3>
          <Button
            size="sm"
            className="bg-primary hover:bg-primary/90 gap-2"
            onClick={addBreak}
          >
            <Plus className="h-4 w-4" />
            Add Break
          </Button>
        </div>

        <div className="space-y-3">
          {breaks.map((breakTime) => (
            <div
              key={breakTime.id}
              className="flex items-center gap-4 p-4 rounded-lg bg-muted"
            >
              <Clock className="h-5 w-5 text-muted-foreground" />
              <div className="flex-1 grid grid-cols-2 gap-3">
                <div>
                  <label className="text-xs text-muted-foreground block mb-1">
                    Start
                  </label>
                  <input
                    type="time"
                    defaultValue={breakTime.start}
                    className="w-full rounded-lg border border-border bg-background px-3 py-2 text-sm"
                  />
                </div>
                <div>
                  <label className="text-xs text-muted-foreground block mb-1">
                    End
                  </label>
                  <input
                    type="time"
                    defaultValue={breakTime.end}
                    className="w-full rounded-lg border border-border bg-background px-3 py-2 text-sm"
                  />
                </div>
              </div>
              <button
                onClick={() => removeBreak(breakTime.id)}
                className="p-2 hover:bg-destructive/10 rounded-lg transition text-destructive"
              >
                <Trash2 className="h-5 w-5" />
              </button>
            </div>
          ))}
        </div>

        {/* Save Button */}
        <div className="mt-6 pt-6 border-t border-border flex gap-3">
          <Button className="flex-1 bg-primary hover:bg-primary/90">
            Save Changes
          </Button>
          <Button variant="outline" className="flex-1 bg-transparent">
            Cancel
          </Button>
        </div>
      </div>
    </div>
  );
}
