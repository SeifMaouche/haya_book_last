'use client'

import { useState, useEffect, useRef, useCallback, Suspense } from 'react'
import { useRouter, useSearchParams } from 'next/navigation'
import { ArrowLeft, Delete } from 'lucide-react'

function OTPContent() {
  const router = useRouter()
  const searchParams = useSearchParams()
  const phone = searchParams.get('phone') || '+213 XXX XXXX'

  const [otp, setOtp] = useState<string[]>(Array(6).fill(''))
  const [timer, setTimer] = useState(30)
  const [canResend, setCanResend] = useState(false)
  const inputRefs = useRef<(HTMLInputElement | null)[]>([])

  useEffect(() => {
    if (timer > 0) {
      const interval = setInterval(() => setTimer((t) => t - 1), 1000)
      return () => clearInterval(interval)
    } else {
      setCanResend(true)
    }
  }, [timer])

  const focusInput = useCallback((index: number) => {
    inputRefs.current[index]?.focus()
  }, [])

  useEffect(() => {
    focusInput(0)
  }, [focusInput])

  const handleChange = (index: number, value: string) => {
    if (!/^\d*$/.test(value)) return
    const newOtp = [...otp]
    newOtp[index] = value.slice(-1)
    setOtp(newOtp)
    if (value && index < 5) {
      focusInput(index + 1)
    }
  }

  const handleKeyDown = (index: number, e: React.KeyboardEvent) => {
    if (e.key === 'Backspace' && !otp[index] && index > 0) {
      focusInput(index - 1)
    }
  }

  const handleKeypadPress = (key: string) => {
    const currentIndex = otp.findIndex((v) => v === '')
    if (key === 'backspace') {
      const lastFilledIndex = otp.map((v, i) => (v !== '' ? i : -1)).filter((i) => i !== -1)
      const idx = lastFilledIndex.length > 0 ? lastFilledIndex[lastFilledIndex.length - 1] : 0
      const newOtp = [...otp]
      newOtp[idx] = ''
      setOtp(newOtp)
      focusInput(idx)
    } else if (currentIndex !== -1) {
      const newOtp = [...otp]
      newOtp[currentIndex] = key
      setOtp(newOtp)
      if (currentIndex < 5) focusInput(currentIndex + 1)
    }
  }

  const handleVerify = () => {
    if (otp.every((d) => d !== '')) {
      router.push('/')
    }
  }

  const handleResend = () => {
    setTimer(30)
    setCanResend(false)
    setOtp(Array(6).fill(''))
    focusInput(0)
  }

  const minutes = Math.floor(timer / 60)
  const seconds = timer % 60

  return (
    <div className="flex min-h-[100dvh] flex-col bg-card">
      {/* Top App Bar */}
      <div className="flex items-center p-4">
        <button
          onClick={() => router.back()}
          className="rounded-full p-2 text-muted-foreground transition-colors hover:bg-muted"
        >
          <ArrowLeft className="h-5 w-5" />
        </button>
      </div>

      {/* Header */}
      <div className="px-6 pt-4 pb-8 text-center">
        <h1 className="text-2xl font-bold tracking-tight text-foreground">
          Verify Phone Number
        </h1>
        <p className="mt-3 text-base text-muted-foreground">
          We sent a code to{' '}
          <span className="font-medium text-foreground">{phone}</span>
        </p>
      </div>

      {/* OTP Inputs */}
      <div className="px-6 py-4">
        <div className="mx-auto flex max-w-xs justify-between gap-2">
          {otp.map((digit, i) => (
            <input
              key={i}
              ref={(el) => { inputRefs.current[i] = el }}
              type="text"
              inputMode="numeric"
              maxLength={1}
              value={digit}
              onChange={(e) => handleChange(i, e.target.value)}
              onKeyDown={(e) => handleKeyDown(i, e)}
              className={`h-14 w-12 rounded-lg border-2 bg-transparent text-center text-2xl font-bold transition-all focus:outline-none ${
                digit
                  ? 'border-primary/30 bg-primary/5'
                  : i === otp.findIndex((v) => v === '')
                    ? 'border-primary ring-2 ring-primary/10'
                    : 'border-border'
              }`}
            />
          ))}
        </div>

        {/* Timer */}
        <div className="mt-8 flex flex-col items-center gap-2">
          <div className="flex gap-4">
            <div className="flex flex-col items-center">
              <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-primary/10">
                <span className="text-lg font-bold text-primary">
                  {String(minutes).padStart(2, '0')}
                </span>
              </div>
              <span className="mt-1 text-xs uppercase tracking-wider text-muted-foreground">
                Min
              </span>
            </div>
            <div className="flex flex-col items-center">
              <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-primary/10">
                <span className="text-lg font-bold text-primary">
                  {String(seconds).padStart(2, '0')}
                </span>
              </div>
              <span className="mt-1 text-xs uppercase tracking-wider text-muted-foreground">
                Sec
              </span>
            </div>
          </div>
          <button
            onClick={handleResend}
            disabled={!canResend}
            className={`mt-4 text-sm font-medium ${
              canResend
                ? 'cursor-pointer text-primary'
                : 'cursor-not-allowed text-muted-foreground'
            }`}
          >
            {canResend ? 'Resend code' : `Resend code in ${timer}s`}
          </button>
        </div>
      </div>

      {/* Verify Button */}
      <div className="mt-auto px-6 py-6">
        <button
          onClick={handleVerify}
          disabled={otp.some((d) => d === '')}
          className="w-full rounded-xl bg-primary py-4 font-bold text-primary-foreground shadow-lg shadow-primary/20 transition-all active:scale-[0.98] disabled:opacity-50 disabled:cursor-not-allowed"
        >
          Verify
        </button>
      </div>

      {/* Numeric Keypad */}
      <div className="border-t border-border bg-muted p-4">
        <div className="mx-auto grid max-w-xs grid-cols-3 gap-2">
          {[1, 2, 3, 4, 5, 6, 7, 8, 9].map((num) => (
            <button
              key={num}
              onClick={() => handleKeypadPress(String(num))}
              className="flex h-12 items-center justify-center rounded-lg text-xl font-semibold transition-colors hover:bg-card"
            >
              {num}
            </button>
          ))}
          <div className="h-12" />
          <button
            onClick={() => handleKeypadPress('0')}
            className="flex h-12 items-center justify-center rounded-lg text-xl font-semibold transition-colors hover:bg-card"
          >
            0
          </button>
          <button
            onClick={() => handleKeypadPress('backspace')}
            className="flex h-12 items-center justify-center rounded-lg text-xl font-semibold transition-colors hover:bg-card"
          >
            <Delete className="h-5 w-5" />
          </button>
        </div>
      </div>
    </div>
  )
}

export default function VerifyPage() {
  return (
    <Suspense fallback={null}>
      <OTPContent />
    </Suspense>
  )
}
