'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { ArrowLeft, ArrowRight, Mail } from 'lucide-react'
import Link from 'next/link'

export default function SignUpPage() {
  const router = useRouter()
  const [phone, setPhone] = useState('')
  const [agreed, setAgreed] = useState(false)
  const [countryCode, setCountryCode] = useState('+213')

  const handleSendOTP = () => {
    if (phone.trim().length >= 8 && agreed) {
      router.push(`/auth/verify?phone=${encodeURIComponent(countryCode + phone)}`)
    }
  }

  return (
    <div className="flex min-h-[100dvh] flex-col bg-background">
      {/* Top App Bar */}
      <div className="flex items-center justify-between p-4 pb-2">
        <button
          onClick={() => router.back()}
          className="flex h-12 w-12 shrink-0 items-center justify-center rounded-full text-foreground transition-colors hover:bg-primary/10"
        >
          <ArrowLeft className="h-5 w-5" />
        </button>
        <h2 className="flex-1 text-center pr-12 text-lg font-bold leading-tight tracking-tight text-foreground">
          Create Account
        </h2>
      </div>

      {/* Content */}
      <div className="flex flex-1 flex-col justify-center px-6 w-full max-w-[480px] mx-auto">
        {/* Header */}
        <div className="mb-10 text-center">
          <h1 className="text-[32px] font-bold leading-tight tracking-tight text-foreground mb-3">
            Create Account
          </h1>
          <p className="text-base text-primary/70">
            Enter your phone number to continue
          </p>
        </div>

        {/* Form */}
        <div className="flex flex-col gap-6">
          {/* Phone Input */}
          <div className="flex flex-col gap-2">
            <label className="ml-1 text-sm font-semibold text-foreground">
              Phone Number
            </label>
            <div className="flex h-14 gap-3">
              {/* Country Selector */}
              <div className="relative flex shrink-0 items-center">
                <select
                  value={countryCode}
                  onChange={(e) => setCountryCode(e.target.value)}
                  className="h-full w-28 appearance-none rounded-xl border border-border bg-card px-4 pr-8 text-base font-medium text-foreground focus:border-primary focus:ring-1 focus:ring-primary"
                >
                  <option value="+213">+213</option>
                  <option value="+1">+1</option>
                  <option value="+44">+44</option>
                  <option value="+33">+33</option>
                </select>
              </div>
              {/* Number Input */}
              <input
                type="tel"
                value={phone}
                onChange={(e) => setPhone(e.target.value)}
                placeholder="5xx xx xx xx"
                className="flex-1 rounded-xl border border-border bg-card px-4 text-base font-medium text-foreground placeholder:text-muted-foreground/50 focus:border-primary focus:ring-1 focus:ring-primary focus:outline-none transition-all"
              />
            </div>
          </div>

          {/* Terms Checkbox */}
          <div className="flex items-start gap-3 px-1">
            <div className="flex h-6 items-center">
              <input
                id="terms"
                type="checkbox"
                checked={agreed}
                onChange={(e) => setAgreed(e.target.checked)}
                className="h-5 w-5 rounded border-border accent-primary text-primary focus:ring-primary"
              />
            </div>
            <label
              htmlFor="terms"
              className="cursor-pointer select-none text-sm leading-tight text-muted-foreground"
            >
              By continuing, I agree to the{' '}
              <span className="font-medium text-primary underline underline-offset-2">
                Terms of Service
              </span>{' '}
              and{' '}
              <span className="font-medium text-primary underline underline-offset-2">
                Privacy Policy
              </span>
              .
            </label>
          </div>

          {/* Primary Action */}
          <button
            onClick={handleSendOTP}
            disabled={phone.trim().length < 8 || !agreed}
            className="flex w-full items-center justify-center gap-2 rounded-xl bg-primary py-4 font-bold text-primary-foreground shadow-lg shadow-primary/20 transition-all active:scale-[0.98] disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <span>Send OTP</span>
            <ArrowRight className="h-4 w-4" />
          </button>

          {/* Divider */}
          <div className="relative flex items-center py-4">
            <div className="flex-grow border-t border-border" />
            <span className="mx-4 flex-shrink text-xs font-medium uppercase tracking-widest text-muted-foreground">
              or
            </span>
            <div className="flex-grow border-t border-border" />
          </div>

          {/* Secondary */}
          <button className="flex w-full items-center justify-center gap-2 rounded-xl py-4 font-semibold text-primary transition-colors hover:bg-primary/5">
            <Mail className="h-5 w-5" />
            Sign up with Email
          </button>
        </div>

        <div className="h-10" />
      </div>

      {/* Decorative blurs */}
      <div className="pointer-events-none fixed -top-24 -right-24 h-64 w-64 rounded-full bg-primary/5 blur-3xl" />
      <div className="pointer-events-none fixed -bottom-24 -left-24 h-64 w-64 rounded-full bg-primary/5 blur-3xl" />
    </div>
  )
}
