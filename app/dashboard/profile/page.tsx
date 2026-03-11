'use client';

import { useState } from 'react';
import { Upload, MapPin, Clock, Plus, Trash2 } from 'lucide-react';
import { Button } from '@/components/ui/button';

interface Service {
  id: string;
  name: string;
  description: string;
  price: number;
  duration: string;
}

export default function ProfilePage() {
  const [services, setServices] = useState<Service[]>([
    {
      id: '1',
      name: 'General Consultation',
      description: 'Standard medical consultation',
      price: 3000,
      duration: '30 min',
    },
    {
      id: '2',
      name: 'Specialist Appointment',
      description: 'Consultation with specialists',
      price: 5000,
      duration: '45 min',
    },
    {
      id: '3',
      name: 'Health Screening',
      description: 'Comprehensive health check-up',
      price: 4000,
      duration: '1 hour',
    },
  ]);

  const [hours, setHours] = useState({
    mon: { start: '09:00', end: '18:00' },
    tue: { start: '09:00', end: '18:00' },
    wed: { start: '09:00', end: '18:00' },
    thu: { start: '09:00', end: '18:00' },
    fri: { start: '09:00', end: '18:00' },
    sat: { start: '10:00', end: '16:00' },
    sun: { start: '', end: '' },
  });

  const addService = () => {
    const newService: Service = {
      id: Math.random().toString(),
      name: 'New Service',
      description: '',
      price: 0,
      duration: '30 min',
    };
    setServices([...services, newService]);
  };

  const removeService = (id: string) => {
    setServices(services.filter((s) => s.id !== id));
  };

  return (
    <div className="max-w-4xl mx-auto space-y-8">
      {/* Page Title */}
      <div>
        <h1 className="text-3xl font-bold text-foreground">Profile Management</h1>
        <p className="text-muted-foreground">Manage your business information and services.</p>
      </div>

      {/* Basic Information */}
      <div className="rounded-xl border border-border bg-card p-6">
        <h2 className="text-xl font-semibold text-foreground mb-6">Basic Information</h2>

        <div className="space-y-4">
          {/* Business Logo/Avatar */}
          <div>
            <label className="block text-sm font-semibold text-foreground mb-3">
              Business Logo
            </label>
            <div className="flex items-center gap-4">
              <div className="h-24 w-24 rounded-lg bg-gradient-to-br from-primary/20 to-accent/20 flex items-center justify-center border-2 border-dashed border-border">
                <Upload className="h-8 w-8 text-muted-foreground" />
              </div>
              <div>
                <Button variant="outline" className="border-primary text-primary hover:bg-primary/10 gap-2 mb-2 bg-transparent">
                  <Upload className="h-4 w-4" />
                  Upload Logo
                </Button>
                <p className="text-xs text-muted-foreground">PNG, JPG up to 5MB</p>
              </div>
            </div>
          </div>

          {/* Business Details */}
          <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
            <div>
              <label className="block text-sm font-semibold text-foreground mb-2">
                Business Name
              </label>
              <input
                type="text"
                defaultValue="Central Medical Clinic"
                className="w-full rounded-lg border border-border bg-background px-4 py-3 text-foreground focus:outline-none focus:ring-2 focus:ring-primary"
              />
            </div>

            <div>
              <label className="block text-sm font-semibold text-foreground mb-2">
                Category
              </label>
              <select className="w-full rounded-lg border border-border bg-background px-4 py-3 text-foreground focus:outline-none focus:ring-2 focus:ring-primary">
                <option>Clinic & Healthcare</option>
                <option>Salon & Spa</option>
                <option>Tutoring & Education</option>
              </select>
            </div>
          </div>

          {/* Description */}
          <div>
            <label className="block text-sm font-semibold text-foreground mb-2">
              Business Description
            </label>
            <textarea
              defaultValue="Central Medical Clinic is a leading healthcare provider offering comprehensive medical services. Our team of experienced doctors and modern facilities ensure quality care for all our patients."
              rows={4}
              className="w-full rounded-lg border border-border bg-background px-4 py-3 text-foreground focus:outline-none focus:ring-2 focus:ring-primary resize-none"
            />
          </div>

          {/* Cover Image */}
          <div>
            <label className="block text-sm font-semibold text-foreground mb-3">
              Cover Image
            </label>
            <div className="h-40 rounded-lg bg-gradient-to-br from-primary/10 to-accent/10 border-2 border-dashed border-border flex items-center justify-center hover:bg-primary/20 transition cursor-pointer">
              <div className="text-center">
                <Upload className="h-8 w-8 text-muted-foreground mx-auto mb-2" />
                <p className="text-sm text-muted-foreground">Click to upload cover image</p>
              </div>
            </div>
          </div>
        </div>

        <Button className="mt-6 bg-primary hover:bg-primary/90">Save Changes</Button>
      </div>

      {/* Contact & Location */}
      <div className="rounded-xl border border-border bg-card p-6">
        <h2 className="text-xl font-semibold text-foreground mb-6 flex items-center gap-2">
          <MapPin className="h-5 w-5" />
          Contact & Location
        </h2>

        <div className="space-y-4">
          <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
            <div>
              <label className="block text-sm font-semibold text-foreground mb-2">
                Phone Number
              </label>
              <input
                type="tel"
                defaultValue="+213 36 XX XX XX"
                className="w-full rounded-lg border border-border bg-background px-4 py-3 text-foreground focus:outline-none focus:ring-2 focus:ring-primary"
              />
            </div>

            <div>
              <label className="block text-sm font-semibold text-foreground mb-2">
                Email Address
              </label>
              <input
                type="email"
                defaultValue="clinic@example.com"
                className="w-full rounded-lg border border-border bg-background px-4 py-3 text-foreground focus:outline-none focus:ring-2 focus:ring-primary"
              />
            </div>
          </div>

          <div>
            <label className="block text-sm font-semibold text-foreground mb-2">
              Address
            </label>
            <input
              type="text"
              defaultValue="123 Boulevard Didouche Mourad, Sétif, Algeria"
              className="w-full rounded-lg border border-border bg-background px-4 py-3 text-foreground focus:outline-none focus:ring-2 focus:ring-primary"
            />
          </div>

          <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
            <div>
              <label className="block text-sm font-semibold text-foreground mb-2">
                City
              </label>
              <input
                type="text"
                defaultValue="Sétif"
                className="w-full rounded-lg border border-border bg-background px-4 py-3 text-foreground focus:outline-none focus:ring-2 focus:ring-primary"
              />
            </div>

            <div>
              <label className="block text-sm font-semibold text-foreground mb-2">
                Postal Code
              </label>
              <input
                type="text"
                defaultValue="19000"
                className="w-full rounded-lg border border-border bg-background px-4 py-3 text-foreground focus:outline-none focus:ring-2 focus:ring-primary"
              />
            </div>
          </div>
        </div>

        <Button className="mt-6 bg-primary hover:bg-primary/90">Save Changes</Button>
      </div>

      {/* Working Hours */}
      <div className="rounded-xl border border-border bg-card p-6">
        <h2 className="text-xl font-semibold text-foreground mb-6 flex items-center gap-2">
          <Clock className="h-5 w-5" />
          Working Hours
        </h2>

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
            <div key={day.key} className="flex items-center gap-4 p-3 rounded-lg bg-muted">
              <span className="font-semibold text-foreground w-20">{day.label}</span>
              <input
                type="time"
                className="flex-1 rounded-lg border border-border bg-background px-3 py-2 text-foreground"
              />
              <span className="text-muted-foreground">to</span>
              <input
                type="time"
                className="flex-1 rounded-lg border border-border bg-background px-3 py-2 text-foreground"
              />
              {day.key === 'sun' && (
                <label className="flex items-center gap-2 cursor-pointer">
                  <input type="checkbox" defaultChecked className="accent-primary" />
                  <span className="text-sm text-muted-foreground">Closed</span>
                </label>
              )}
            </div>
          ))}
        </div>

        <Button className="mt-6 bg-primary hover:bg-primary/90">Save Changes</Button>
      </div>

      {/* Services & Pricing */}
      <div className="rounded-xl border border-border bg-card p-6">
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-xl font-semibold text-foreground">Services & Pricing</h2>
          <Button
            size="sm"
            className="bg-primary hover:bg-primary/90 gap-2"
            onClick={addService}
          >
            <Plus className="h-4 w-4" />
            Add Service
          </Button>
        </div>

        <div className="space-y-3">
          {services.map((service) => (
            <div key={service.id} className="p-4 rounded-lg border border-border flex items-start gap-4">
              <div className="flex-1 space-y-2">
                <input
                  type="text"
                  defaultValue={service.name}
                  className="w-full font-semibold bg-transparent text-foreground focus:outline-none focus:ring-2 focus:ring-primary rounded px-2 py-1"
                />
                <input
                  type="text"
                  placeholder="Service description"
                  defaultValue={service.description}
                  className="w-full text-sm bg-transparent text-muted-foreground focus:outline-none focus:ring-2 focus:ring-primary rounded px-2 py-1"
                />
                <div className="flex gap-4">
                  <div className="flex-1">
                    <label className="text-xs text-muted-foreground">Price (DZD)</label>
                    <input
                      type="number"
                      defaultValue={service.price}
                      className="w-full rounded-lg border border-border bg-background px-3 py-2 text-foreground text-sm"
                    />
                  </div>
                  <div className="flex-1">
                    <label className="text-xs text-muted-foreground">Duration</label>
                    <select className="w-full rounded-lg border border-border bg-background px-3 py-2 text-foreground text-sm">
                      <option>30 min</option>
                      <option>45 min</option>
                      <option>1 hour</option>
                      <option>1.5 hours</option>
                    </select>
                  </div>
                </div>
              </div>
              <button
                onClick={() => removeService(service.id)}
                className="p-2 hover:bg-destructive/10 rounded-lg transition text-destructive"
              >
                <Trash2 className="h-5 w-5" />
              </button>
            </div>
          ))}
        </div>

        <Button className="mt-6 bg-primary hover:bg-primary/90">Save Changes</Button>
      </div>
    </div>
  );
}
