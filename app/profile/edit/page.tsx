'use client'

import { useState } from 'react'
import { ArrowLeft, Camera, User, Mail, Phone, Info, Save } from 'lucide-react'
import { useRouter } from 'next/navigation'

export default function EditProfilePage() {
  const router = useRouter()
  const [formData, setFormData] = useState({
    name: 'Alex Johnson',
    email: 'alex.johnson@email.com',
    phone: '+213 5XX XX XX XX',
  })

  const handleChange = (field: string, value: string) => {
    setFormData({ ...formData, [field]: value })
  }

  const handleSave = () => {
    router.push('/profile')
  }

  return (
    <div className="flex min-h-[100dvh] flex-col bg-card">
      {/* Header */}
      <header className="sticky top-0 z-10 flex items-center justify-between border-b border-border bg-card px-4 py-4">
        <button
          onClick={() => router.back()}
          className="flex h-10 w-10 items-center justify-center rounded-full text-muted-foreground transition-colors hover:bg-muted"
        >
          <ArrowLeft className="h-5 w-5" />
        </button>
        <h1 className="text-lg font-bold tracking-tight text-foreground">Edit Profile</h1>
        <div className="w-10" />
      </header>

      {/* Content */}
      <main className="flex-1 px-6 py-8">
        {/* Profile Photo */}
        <div className="mb-10 flex flex-col items-center">
          <div className="relative">
            <div className="h-32 w-32 overflow-hidden rounded-full border-4 border-primary/20 p-0.5">
              <img
                src="https://lh3.googleusercontent.com/aida-public/AB6AXuBVw76b-xK2GTT9ISplmBv5eftTAFNu-mHokbHhzhYZPVRDKRKmQBD29VTpdxhHu0YHciSgfCtxX2AzPtMxehufs89slBK8RqHbwCK8mCfXaZREV3u47ywKELIstz7XL3lBOfaTuBUDuLJta9QngTuPyszkyk-Cy4Gl2PRmaumsXkDXtzy0bqy_MNv0cYHQVHsc-zN01yGiXZEkh6HAzBNTHsc2kVak8ovbhlLCZNAn9qfCwHPvIQ6D8hcWExN14xPir53aFm77Axk"
                alt="Profile photo"
                className="h-full w-full rounded-full object-cover"
              />
            </div>
            <button className="absolute bottom-1 right-1 flex h-10 w-10 items-center justify-center rounded-full border-4 border-card bg-primary text-primary-foreground shadow-md transition-transform hover:scale-105">
              <Camera className="h-4 w-4" />
            </button>
          </div>
          <p className="mt-4 text-sm font-medium text-primary">Change Profile Picture</p>
        </div>

        {/* Form */}
        <div className="flex flex-col gap-6">
          {/* Full Name */}
          <div className="flex flex-col gap-2">
            <label htmlFor="full-name" className="ml-1 block text-sm font-semibold text-foreground/70">
              Full Name
            </label>
            <div className="group relative">
              <div className="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-4 text-primary/60 group-focus-within:text-primary">
                <User className="h-5 w-5" />
              </div>
              <input
                id="full-name"
                type="text"
                value={formData.name}
                onChange={(e) => handleChange('name', e.target.value)}
                placeholder="Enter your full name"
                className="w-full rounded-xl border border-border bg-background py-4 pl-12 pr-4 text-base text-foreground outline-none transition-all focus:border-primary focus:ring-2 focus:ring-primary/20"
              />
            </div>
          </div>

          {/* Email */}
          <div className="flex flex-col gap-2">
            <label htmlFor="email" className="ml-1 block text-sm font-semibold text-foreground/70">
              Email Address
            </label>
            <div className="group relative">
              <div className="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-4 text-primary/60 group-focus-within:text-primary">
                <Mail className="h-5 w-5" />
              </div>
              <input
                id="email"
                type="email"
                value={formData.email}
                onChange={(e) => handleChange('email', e.target.value)}
                placeholder="your.email@example.com"
                className="w-full rounded-xl border border-border bg-background py-4 pl-12 pr-4 text-base text-foreground outline-none transition-all focus:border-primary focus:ring-2 focus:ring-primary/20"
              />
            </div>
          </div>

          {/* Phone */}
          <div className="flex flex-col gap-2">
            <label htmlFor="phone" className="ml-1 block text-sm font-semibold text-foreground/70">
              Phone Number
            </label>
            <div className="group relative">
              <div className="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-4 text-primary/60 group-focus-within:text-primary">
                <Phone className="h-5 w-5" />
              </div>
              <input
                id="phone"
                type="tel"
                value={formData.phone}
                onChange={(e) => handleChange('phone', e.target.value)}
                placeholder="+213 5XX XX XX XX"
                className="w-full rounded-xl border border-border bg-background py-4 pl-12 pr-4 text-base text-foreground outline-none transition-all focus:border-primary focus:ring-2 focus:ring-primary/20"
              />
            </div>
          </div>

          {/* Info Notice */}
          <div className="mt-2 flex items-start gap-3 rounded-xl bg-primary/5 p-4">
            <Info className="mt-0.5 h-5 w-5 shrink-0 text-primary" />
            <p className="text-xs leading-relaxed text-foreground/60">
              Updating your email will require a verification link sent to your new address
              to confirm the change.
            </p>
          </div>
        </div>
      </main>

      {/* Footer */}
      <footer className="border-t border-border bg-card p-6 pb-10">
        <button
          onClick={handleSave}
          className="flex w-full items-center justify-center gap-2 rounded-xl bg-primary py-4 font-bold text-primary-foreground shadow-lg shadow-primary/20 transition-all active:scale-[0.98]"
        >
          <Save className="h-5 w-5" />
          Save Changes
        </button>
        <button className="mt-4 w-full py-2 text-sm font-medium text-muted-foreground transition-colors hover:text-[#ef4444]">
          Deactivate Account
        </button>
      </footer>
    </div>
  )
}
