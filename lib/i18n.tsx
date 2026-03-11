'use client'

import React, { createContext, useContext, useState, useEffect, useCallback } from 'react'

export type Language = 'en' | 'fr' | 'ar'

const translations: Record<Language, Record<string, string>> = {
  en: {
    // Bottom Nav
    'nav.home': 'Home',
    'nav.browse': 'Browse',
    'nav.bookings': 'Bookings',
    'nav.messages': 'Messages',
    'nav.profile': 'Profile',
    // Home
    'home.signIn': 'Sign In',
    'home.change': 'Change',
    'home.searchPlaceholder': 'Search providers...',
    'home.search': 'Search',
    'home.clinics': 'Clinics',
    'home.salons': 'Salons',
    'home.tutors': 'Tutors',
    'home.upcomingBookings': 'Upcoming Bookings',
    'home.noUpcoming': 'No upcoming bookings',
    'home.browseNow': 'Browse Now',
    'home.featuredProviders': 'Featured Providers',
    'home.viewAll': 'View All',
    'home.bookNow': 'Book Now',
    'home.changeLocation': 'Change Location',
    'home.selectLocation': 'Select your location',
    'home.cancel': 'Cancel',
    'home.confirm': 'Confirm',
    // Browse
    'browse.searchPlaceholder': 'Search clinics, salons, or tutors...',
    'browse.advancedFilters': 'Advanced Filters',
    'browse.availableNearYou': 'Available Near You',
    // Bookings
    'bookings.title': 'My Bookings',
    'bookings.upcoming': 'Upcoming',
    'bookings.past': 'Past',
    'bookings.cancelled': 'Cancelled',
    'bookings.reschedule': 'Reschedule',
    'bookings.cancel': 'Cancel',
    'bookings.rateService': 'Rate Service',
    'bookings.recentlyCompleted': 'Recently Completed',
    'bookings.noPast': 'No past bookings',
    'bookings.noPastDesc': "You haven't completed any appointments yet",
    'bookings.noCancelled': 'No cancelled bookings',
    'bookings.noCancelledDesc': "You haven't cancelled any bookings",
    'bookings.cancelConfirm': 'Are you sure you want to cancel this booking?',
    'bookings.cancelYes': 'Yes, Cancel',
    'bookings.cancelNo': 'Keep Booking',
    'bookings.rescheduleTitle': 'Reschedule Booking',
    'bookings.bookingCancelled': 'Booking cancelled',
    // Messages
    'messages.title': 'Messages',
    // Chat
    'chat.online': 'Online',
    'chat.typePlaceholder': 'Type a message...',
    // Profile
    'profile.editProfile': 'Edit Profile',
    'profile.myBookings': 'My Bookings',
    'profile.totalBookings': 'Total Bookings',
    'profile.upcoming': 'Upcoming',
    'profile.settings': 'Settings',
    'profile.pushNotifications': 'Push Notifications',
    'profile.language': 'Language',
    'profile.account': 'Account',
    'profile.paymentMethods': 'Payment Methods',
    'profile.savedAddresses': 'Saved Addresses',
    'profile.support': 'Support',
    'profile.helpFaq': 'Help & FAQ',
    'profile.contactUs': 'Contact Us',
    'profile.logOut': 'Log Out',
    'profile.version': 'BookApp v2.4.0 - Made with love',
    'profile.selectLanguage': 'Select Language',
    'profile.english': 'English',
    'profile.french': 'French',
    'profile.arabic': 'Arabic',
    // Edit Profile
    'editProfile.title': 'Edit Profile',
    'editProfile.changePhoto': 'Change Profile Picture',
    'editProfile.fullName': 'Full Name',
    'editProfile.emailAddress': 'Email Address',
    'editProfile.phoneNumber': 'Phone Number',
    'editProfile.emailNotice': 'Updating your email will require a verification link sent to your new address to confirm the change.',
    'editProfile.saveChanges': 'Save Changes',
    'editProfile.deactivateAccount': 'Deactivate Account',
    // Provider
    'provider.bookAppointment': 'Book Appointment',
    'provider.about': 'About',
    'provider.services': 'Services',
    'provider.location': 'Location',
    'provider.getDirections': 'Get Directions',
    'provider.patientReviews': 'patient reviews',
    // Booking Calendar
    'booking.selectDateTime': 'Select Date & Time',
    'booking.healthcareProvider': 'Healthcare Provider',
    'booking.availableSlots': 'Available Slots',
    'booking.confirmBooking': 'Confirm Booking',
    'booking.selected': 'Selected',
    'booking.available': 'Available',
    'booking.fullyBooked': 'Fully Booked',
    // Confirmation
    'confirmation.title': 'Confirmation',
    'confirmation.bookingConfirmed': 'Booking Confirmed!',
    'confirmation.successMessage': 'Your appointment has been successfully scheduled.',
    'confirmation.referenceNumber': 'Reference Number',
    'confirmation.dateTime': 'Date & Time',
    'confirmation.serviceFee': 'Service Fee',
    'confirmation.viewBookings': 'View My Bookings',
    'confirmation.goHome': 'Go to Home',
    // Auth
    'auth.createAccount': 'Create Account',
    'auth.enterPhone': 'Enter your phone number to continue',
    'auth.phoneNumber': 'Phone Number',
    'auth.agreeTerms': 'By continuing, I agree to the',
    'auth.termsOfService': 'Terms of Service',
    'auth.and': 'and',
    'auth.privacyPolicy': 'Privacy Policy',
    'auth.sendOtp': 'Send OTP',
    'auth.or': 'OR',
    'auth.signUpEmail': 'Sign up with Email',
    'auth.verifyPhone': 'Verify Phone Number',
    'auth.weSentCode': 'We sent a code to',
    'auth.verify': 'Verify',
    'auth.resendCode': 'Resend code in',
    // Welcome
    'welcome.signUp': 'Sign Up',
    'welcome.logIn': 'Log In',
    'welcome.skip': 'Skip for now',
    // Splash
    'splash.tagline': 'Book. Confirm. Done.',
    'splash.initializing': 'INITIALIZING',
  },
  fr: {
    // Bottom Nav
    'nav.home': 'Accueil',
    'nav.browse': 'Explorer',
    'nav.bookings': 'Rendez-vous',
    'nav.messages': 'Messages',
    'nav.profile': 'Profil',
    // Home
    'home.signIn': 'Connexion',
    'home.change': 'Changer',
    'home.searchPlaceholder': 'Rechercher des prestataires...',
    'home.search': 'Rechercher',
    'home.clinics': 'Cliniques',
    'home.salons': 'Salons',
    'home.tutors': 'Tuteurs',
    'home.upcomingBookings': 'Prochains rendez-vous',
    'home.noUpcoming': 'Aucun rendez-vous',
    'home.browseNow': 'Explorer',
    'home.featuredProviders': 'Prestataires en vedette',
    'home.viewAll': 'Voir tout',
    'home.bookNow': 'Reserver',
    'home.changeLocation': 'Changer de lieu',
    'home.selectLocation': 'Choisissez votre ville',
    'home.cancel': 'Annuler',
    'home.confirm': 'Confirmer',
    // Browse
    'browse.searchPlaceholder': 'Rechercher cliniques, salons, ou tuteurs...',
    'browse.advancedFilters': 'Filtres avances',
    'browse.availableNearYou': 'Disponible pres de vous',
    // Bookings
    'bookings.title': 'Mes rendez-vous',
    'bookings.upcoming': 'A venir',
    'bookings.past': 'Passes',
    'bookings.cancelled': 'Annules',
    'bookings.reschedule': 'Replanifier',
    'bookings.cancel': 'Annuler',
    'bookings.rateService': 'Evaluer le service',
    'bookings.recentlyCompleted': 'Recemment termines',
    'bookings.noPast': 'Aucun rendez-vous passe',
    'bookings.noPastDesc': "Vous n'avez termine aucun rendez-vous",
    'bookings.noCancelled': 'Aucun rendez-vous annule',
    'bookings.noCancelledDesc': "Vous n'avez annule aucun rendez-vous",
    'bookings.cancelConfirm': 'Etes-vous sur de vouloir annuler ce rendez-vous?',
    'bookings.cancelYes': 'Oui, annuler',
    'bookings.cancelNo': 'Garder',
    'bookings.rescheduleTitle': 'Replanifier le rendez-vous',
    'bookings.bookingCancelled': 'Rendez-vous annule',
    // Messages
    'messages.title': 'Messages',
    // Chat
    'chat.online': 'En ligne',
    'chat.typePlaceholder': 'Ecrire un message...',
    // Profile
    'profile.editProfile': 'Modifier le profil',
    'profile.myBookings': 'Mes rendez-vous',
    'profile.totalBookings': 'Total',
    'profile.upcoming': 'A venir',
    'profile.settings': 'Parametres',
    'profile.pushNotifications': 'Notifications push',
    'profile.language': 'Langue',
    'profile.account': 'Compte',
    'profile.paymentMethods': 'Moyens de paiement',
    'profile.savedAddresses': 'Adresses enregistrees',
    'profile.support': 'Assistance',
    'profile.helpFaq': 'Aide & FAQ',
    'profile.contactUs': 'Nous contacter',
    'profile.logOut': 'Deconnexion',
    'profile.version': 'BookApp v2.4.0 - Fait avec amour',
    'profile.selectLanguage': 'Choisir la langue',
    'profile.english': 'Anglais',
    'profile.french': 'Francais',
    'profile.arabic': 'Arabe',
    // Edit Profile
    'editProfile.title': 'Modifier le profil',
    'editProfile.changePhoto': 'Changer la photo de profil',
    'editProfile.fullName': 'Nom complet',
    'editProfile.emailAddress': 'Adresse e-mail',
    'editProfile.phoneNumber': 'Numero de telephone',
    'editProfile.emailNotice': "La mise a jour de votre e-mail necessitea un lien de verification envoye a votre nouvelle adresse.",
    'editProfile.saveChanges': 'Enregistrer',
    'editProfile.deactivateAccount': 'Desactiver le compte',
    // Provider
    'provider.bookAppointment': 'Prendre rendez-vous',
    'provider.about': 'A propos',
    'provider.services': 'Services',
    'provider.location': 'Emplacement',
    'provider.getDirections': 'Itineraire',
    'provider.patientReviews': 'avis patients',
    // Booking Calendar
    'booking.selectDateTime': 'Choisir date & heure',
    'booking.healthcareProvider': 'Prestataire de sante',
    'booking.availableSlots': 'Creneaux disponibles',
    'booking.confirmBooking': 'Confirmer le rendez-vous',
    'booking.selected': 'Selectionne',
    'booking.available': 'Disponible',
    'booking.fullyBooked': 'Complet',
    // Confirmation
    'confirmation.title': 'Confirmation',
    'confirmation.bookingConfirmed': 'Rendez-vous confirme!',
    'confirmation.successMessage': 'Votre rendez-vous a ete planifie avec succes.',
    'confirmation.referenceNumber': 'Numero de reference',
    'confirmation.dateTime': 'Date et heure',
    'confirmation.serviceFee': 'Frais de service',
    'confirmation.viewBookings': 'Voir mes rendez-vous',
    'confirmation.goHome': "Aller a l'accueil",
    // Auth
    'auth.createAccount': 'Creer un compte',
    'auth.enterPhone': 'Entrez votre numero de telephone pour continuer',
    'auth.phoneNumber': 'Numero de telephone',
    'auth.agreeTerms': 'En continuant, j\'accepte les',
    'auth.termsOfService': 'Conditions d\'utilisation',
    'auth.and': 'et',
    'auth.privacyPolicy': 'Politique de confidentialite',
    'auth.sendOtp': 'Envoyer OTP',
    'auth.or': 'OU',
    'auth.signUpEmail': 'S\'inscrire par e-mail',
    'auth.verifyPhone': 'Verifier le numero',
    'auth.weSentCode': 'Nous avons envoye un code a',
    'auth.verify': 'Verifier',
    'auth.resendCode': 'Renvoyer le code dans',
    // Welcome
    'welcome.signUp': 'S\'inscrire',
    'welcome.logIn': 'Se connecter',
    'welcome.skip': 'Passer pour le moment',
    // Splash
    'splash.tagline': 'Reservez. Confirmez. Termine.',
    'splash.initializing': 'INITIALISATION',
  },
  ar: {
    // Bottom Nav
    'nav.home': '\u0627\u0644\u0631\u0626\u064a\u0633\u064a\u0629',
    'nav.browse': '\u062a\u0635\u0641\u062d',
    'nav.bookings': '\u062d\u062c\u0648\u0632\u0627\u062a\u064a',
    'nav.messages': '\u0627\u0644\u0631\u0633\u0627\u0626\u0644',
    'nav.profile': '\u0627\u0644\u0645\u0644\u0641 \u0627\u0644\u0634\u062e\u0635\u064a',
    // Home
    'home.signIn': '\u062a\u0633\u062c\u064a\u0644 \u0627\u0644\u062f\u062e\u0648\u0644',
    'home.change': '\u062a\u063a\u064a\u064a\u0631',
    'home.searchPlaceholder': '\u0627\u0628\u062d\u062b \u0639\u0646 \u0645\u0642\u062f\u0645\u064a \u0627\u0644\u062e\u062f\u0645\u0627\u062a...',
    'home.search': '\u0628\u062d\u062b',
    'home.clinics': '\u0639\u064a\u0627\u062f\u0627\u062a',
    'home.salons': '\u0635\u0627\u0644\u0648\u0646\u0627\u062a',
    'home.tutors': '\u0645\u062f\u0631\u0633\u0648\u0646',
    'home.upcomingBookings': '\u0627\u0644\u062d\u062c\u0648\u0632\u0627\u062a \u0627\u0644\u0642\u0627\u062f\u0645\u0629',
    'home.noUpcoming': '\u0644\u0627 \u062a\u0648\u062c\u062f \u062d\u062c\u0648\u0632\u0627\u062a \u0642\u0627\u062f\u0645\u0629',
    'home.browseNow': '\u062a\u0635\u0641\u062d \u0627\u0644\u0622\u0646',
    'home.featuredProviders': '\u0645\u0642\u062f\u0645\u0648 \u062e\u062f\u0645\u0627\u062a \u0645\u0645\u064a\u0632\u0648\u0646',
    'home.viewAll': '\u0639\u0631\u0636 \u0627\u0644\u0643\u0644',
    'home.bookNow': '\u0627\u062d\u062c\u0632 \u0627\u0644\u0622\u0646',
    'home.changeLocation': '\u062a\u063a\u064a\u064a\u0631 \u0627\u0644\u0645\u0648\u0642\u0639',
    'home.selectLocation': '\u0627\u062e\u062a\u0631 \u0645\u0648\u0642\u0639\u0643',
    'home.cancel': '\u0625\u0644\u063a\u0627\u0621',
    'home.confirm': '\u062a\u0623\u0643\u064a\u062f',
    // Browse
    'browse.searchPlaceholder': '\u0627\u0628\u062d\u062b \u0639\u0646 \u0639\u064a\u0627\u062f\u0627\u062a\u060c \u0635\u0627\u0644\u0648\u0646\u0627\u062a\u060c \u0623\u0648 \u0645\u062f\u0631\u0633\u064a\u0646...',
    'browse.advancedFilters': '\u0641\u0644\u0627\u062a\u0631 \u0645\u062a\u0642\u062f\u0645\u0629',
    'browse.availableNearYou': '\u0645\u062a\u0627\u062d \u0628\u0627\u0644\u0642\u0631\u0628 \u0645\u0646\u0643',
    // Bookings
    'bookings.title': '\u062d\u062c\u0648\u0632\u0627\u062a\u064a',
    'bookings.upcoming': '\u0627\u0644\u0642\u0627\u062f\u0645\u0629',
    'bookings.past': '\u0627\u0644\u0633\u0627\u0628\u0642\u0629',
    'bookings.cancelled': '\u0627\u0644\u0645\u0644\u063a\u0627\u0629',
    'bookings.reschedule': '\u0625\u0639\u0627\u062f\u0629 \u062c\u062f\u0648\u0644\u0629',
    'bookings.cancel': '\u0625\u0644\u063a\u0627\u0621',
    'bookings.rateService': '\u062a\u0642\u064a\u064a\u0645 \u0627\u0644\u062e\u062f\u0645\u0629',
    'bookings.recentlyCompleted': '\u0645\u0643\u062a\u0645\u0644\u0629 \u0645\u0624\u062e\u0631\u0627',
    'bookings.noPast': '\u0644\u0627 \u062a\u0648\u062c\u062f \u062d\u062c\u0648\u0632\u0627\u062a \u0633\u0627\u0628\u0642\u0629',
    'bookings.noPastDesc': '\u0644\u0645 \u062a\u0643\u0645\u0644 \u0623\u064a \u0645\u0648\u0639\u062f \u0628\u0639\u062f',
    'bookings.noCancelled': '\u0644\u0627 \u062a\u0648\u062c\u062f \u062d\u062c\u0648\u0632\u0627\u062a \u0645\u0644\u063a\u0627\u0629',
    'bookings.noCancelledDesc': '\u0644\u0645 \u062a\u0644\u063a\u0650 \u0623\u064a \u062d\u062c\u0632',
    'bookings.cancelConfirm': '\u0647\u0644 \u0623\u0646\u062a \u0645\u062a\u0623\u0643\u062f \u0645\u0646 \u0625\u0644\u063a\u0627\u0621 \u0647\u0630\u0627 \u0627\u0644\u062d\u062c\u0632\u061f',
    'bookings.cancelYes': '\u0646\u0639\u0645\u060c \u0625\u0644\u063a\u0627\u0621',
    'bookings.cancelNo': '\u0627\u0644\u0627\u062d\u062a\u0641\u0627\u0638 \u0628\u0627\u0644\u062d\u062c\u0632',
    'bookings.rescheduleTitle': '\u0625\u0639\u0627\u062f\u0629 \u062c\u062f\u0648\u0644\u0629 \u0627\u0644\u062d\u062c\u0632',
    'bookings.bookingCancelled': '\u062a\u0645 \u0625\u0644\u063a\u0627\u0621 \u0627\u0644\u062d\u062c\u0632',
    // Messages
    'messages.title': '\u0627\u0644\u0631\u0633\u0627\u0626\u0644',
    // Chat
    'chat.online': '\u0645\u062a\u0635\u0644',
    'chat.typePlaceholder': '\u0627\u0643\u062a\u0628 \u0631\u0633\u0627\u0644\u0629...',
    // Profile
    'profile.editProfile': '\u062a\u0639\u062f\u064a\u0644 \u0627\u0644\u0645\u0644\u0641 \u0627\u0644\u0634\u062e\u0635\u064a',
    'profile.myBookings': '\u062d\u062c\u0648\u0632\u0627\u062a\u064a',
    'profile.totalBookings': '\u0625\u062c\u0645\u0627\u0644\u064a',
    'profile.upcoming': '\u0627\u0644\u0642\u0627\u062f\u0645\u0629',
    'profile.settings': '\u0627\u0644\u0625\u0639\u062f\u0627\u062f\u0627\u062a',
    'profile.pushNotifications': '\u0627\u0644\u0625\u0634\u0639\u0627\u0631\u0627\u062a',
    'profile.language': '\u0627\u0644\u0644\u063a\u0629',
    'profile.account': '\u0627\u0644\u062d\u0633\u0627\u0628',
    'profile.paymentMethods': '\u0637\u0631\u0642 \u0627\u0644\u062f\u0641\u0639',
    'profile.savedAddresses': '\u0627\u0644\u0639\u0646\u0627\u0648\u064a\u0646 \u0627\u0644\u0645\u062d\u0641\u0648\u0638\u0629',
    'profile.support': '\u0627\u0644\u062f\u0639\u0645',
    'profile.helpFaq': '\u0627\u0644\u0645\u0633\u0627\u0639\u062f\u0629 \u0648\u0627\u0644\u0623\u0633\u0626\u0644\u0629',
    'profile.contactUs': '\u0627\u062a\u0635\u0644 \u0628\u0646\u0627',
    'profile.logOut': '\u062a\u0633\u062c\u064a\u0644 \u0627\u0644\u062e\u0631\u0648\u062c',
    'profile.version': 'BookApp v2.4.0 - \u0635\u0646\u0639 \u0628\u062d\u0628',
    'profile.selectLanguage': '\u0627\u062e\u062a\u064a\u0627\u0631 \u0627\u0644\u0644\u063a\u0629',
    'profile.english': '\u0627\u0644\u0625\u0646\u062c\u0644\u064a\u0632\u064a\u0629',
    'profile.french': '\u0627\u0644\u0641\u0631\u0646\u0633\u064a\u0629',
    'profile.arabic': '\u0627\u0644\u0639\u0631\u0628\u064a\u0629',
    // Edit Profile
    'editProfile.title': '\u062a\u0639\u062f\u064a\u0644 \u0627\u0644\u0645\u0644\u0641 \u0627\u0644\u0634\u062e\u0635\u064a',
    'editProfile.changePhoto': '\u062a\u063a\u064a\u064a\u0631 \u0635\u0648\u0631\u0629 \u0627\u0644\u0645\u0644\u0641',
    'editProfile.fullName': '\u0627\u0644\u0627\u0633\u0645 \u0627\u0644\u0643\u0627\u0645\u0644',
    'editProfile.emailAddress': '\u0627\u0644\u0628\u0631\u064a\u062f \u0627\u0644\u0625\u0644\u0643\u062a\u0631\u0648\u0646\u064a',
    'editProfile.phoneNumber': '\u0631\u0642\u0645 \u0627\u0644\u0647\u0627\u062a\u0641',
    'editProfile.emailNotice': '\u062a\u062d\u062f\u064a\u062b \u0628\u0631\u064a\u062f\u0643 \u0627\u0644\u0625\u0644\u0643\u062a\u0631\u0648\u0646\u064a \u064a\u062a\u0637\u0644\u0628 \u0631\u0627\u0628\u0637 \u062a\u062d\u0642\u0642 \u064a\u0631\u0633\u0644 \u0625\u0644\u0649 \u0639\u0646\u0648\u0627\u0646\u0643 \u0627\u0644\u062c\u062f\u064a\u062f.',
    'editProfile.saveChanges': '\u062d\u0641\u0638 \u0627\u0644\u062a\u063a\u064a\u064a\u0631\u0627\u062a',
    'editProfile.deactivateAccount': '\u062a\u0639\u0637\u064a\u0644 \u0627\u0644\u062d\u0633\u0627\u0628',
    // Provider
    'provider.bookAppointment': '\u062d\u062c\u0632 \u0645\u0648\u0639\u062f',
    'provider.about': '\u062d\u0648\u0644',
    'provider.services': '\u0627\u0644\u062e\u062f\u0645\u0627\u062a',
    'provider.location': '\u0627\u0644\u0645\u0648\u0642\u0639',
    'provider.getDirections': '\u0627\u0644\u0627\u062a\u062c\u0627\u0647\u0627\u062a',
    'provider.patientReviews': '\u062a\u0642\u064a\u064a\u0645\u0627\u062a',
    // Booking Calendar
    'booking.selectDateTime': '\u0627\u062e\u062a\u0631 \u0627\u0644\u062a\u0627\u0631\u064a\u062e \u0648\u0627\u0644\u0648\u0642\u062a',
    'booking.healthcareProvider': '\u0645\u0642\u062f\u0645 \u0627\u0644\u0631\u0639\u0627\u064a\u0629 \u0627\u0644\u0635\u062d\u064a\u0629',
    'booking.availableSlots': '\u0627\u0644\u0623\u0648\u0642\u0627\u062a \u0627\u0644\u0645\u062a\u0627\u062d\u0629',
    'booking.confirmBooking': '\u062a\u0623\u0643\u064a\u062f \u0627\u0644\u062d\u062c\u0632',
    'booking.selected': '\u0645\u062e\u062a\u0627\u0631',
    'booking.available': '\u0645\u062a\u0627\u062d',
    'booking.fullyBooked': '\u0645\u0643\u062a\u0645\u0644',
    // Confirmation
    'confirmation.title': '\u0627\u0644\u062a\u0623\u0643\u064a\u062f',
    'confirmation.bookingConfirmed': '\u062a\u0645 \u062a\u0623\u0643\u064a\u062f \u0627\u0644\u062d\u062c\u0632!',
    'confirmation.successMessage': '\u062a\u0645 \u062c\u062f\u0648\u0644\u0629 \u0645\u0648\u0639\u062f\u0643 \u0628\u0646\u062c\u0627\u062d.',
    'confirmation.referenceNumber': '\u0631\u0642\u0645 \u0627\u0644\u0645\u0631\u062c\u0639',
    'confirmation.dateTime': '\u0627\u0644\u062a\u0627\u0631\u064a\u062e \u0648\u0627\u0644\u0648\u0642\u062a',
    'confirmation.serviceFee': '\u0631\u0633\u0648\u0645 \u0627\u0644\u062e\u062f\u0645\u0629',
    'confirmation.viewBookings': '\u0639\u0631\u0636 \u062d\u062c\u0648\u0632\u0627\u062a\u064a',
    'confirmation.goHome': '\u0627\u0644\u0630\u0647\u0627\u0628 \u0644\u0644\u0631\u0626\u064a\u0633\u064a\u0629',
    // Auth
    'auth.createAccount': '\u0625\u0646\u0634\u0627\u0621 \u062d\u0633\u0627\u0628',
    'auth.enterPhone': '\u0623\u062f\u062e\u0644 \u0631\u0642\u0645 \u0647\u0627\u062a\u0641\u0643 \u0644\u0644\u0645\u062a\u0627\u0628\u0639\u0629',
    'auth.phoneNumber': '\u0631\u0642\u0645 \u0627\u0644\u0647\u0627\u062a\u0641',
    'auth.agreeTerms': '\u0628\u0627\u0644\u0645\u062a\u0627\u0628\u0639\u0629\u060c \u0623\u0648\u0627\u0641\u0642 \u0639\u0644\u0649',
    'auth.termsOfService': '\u0634\u0631\u0648\u0637 \u0627\u0644\u062e\u062f\u0645\u0629',
    'auth.and': '\u0648',
    'auth.privacyPolicy': '\u0633\u064a\u0627\u0633\u0629 \u0627\u0644\u062e\u0635\u0648\u0635\u064a\u0629',
    'auth.sendOtp': '\u0625\u0631\u0633\u0627\u0644 \u0631\u0645\u0632 \u0627\u0644\u062a\u062d\u0642\u0642',
    'auth.or': '\u0623\u0648',
    'auth.signUpEmail': '\u0627\u0644\u062a\u0633\u062c\u064a\u0644 \u0628\u0627\u0644\u0628\u0631\u064a\u062f',
    'auth.verifyPhone': '\u062a\u062d\u0642\u0642 \u0645\u0646 \u0631\u0642\u0645 \u0627\u0644\u0647\u0627\u062a\u0641',
    'auth.weSentCode': '\u0623\u0631\u0633\u0644\u0646\u0627 \u0631\u0645\u0632\u0627 \u0625\u0644\u0649',
    'auth.verify': '\u062a\u062d\u0642\u0642',
    'auth.resendCode': '\u0625\u0639\u0627\u062f\u0629 \u0627\u0644\u0625\u0631\u0633\u0627\u0644 \u062e\u0644\u0627\u0644',
    // Welcome
    'welcome.signUp': '\u0625\u0646\u0634\u0627\u0621 \u062d\u0633\u0627\u0628',
    'welcome.logIn': '\u062a\u0633\u062c\u064a\u0644 \u0627\u0644\u062f\u062e\u0648\u0644',
    'welcome.skip': '\u062a\u062e\u0637\u064a \u0627\u0644\u0622\u0646',
    // Splash
    'splash.tagline': '\u0627\u062d\u062c\u0632. \u0623\u0643\u062f. \u0627\u0646\u062a\u0647\u064a.',
    'splash.initializing': '\u062c\u0627\u0631\u064a \u0627\u0644\u062a\u0634\u063a\u064a\u0644',
  },
}

const languageLabels: Record<Language, string> = {
  en: 'English',
  fr: 'Fran\u00e7ais',
  ar: '\u0627\u0644\u0639\u0631\u0628\u064a\u0629',
}

interface I18nContextType {
  language: Language
  setLanguage: (lang: Language) => void
  t: (key: string) => string
  dir: 'ltr' | 'rtl'
  languageLabels: Record<Language, string>
}

const I18nContext = createContext<I18nContextType>({
  language: 'en',
  setLanguage: () => {},
  t: (key: string) => key,
  dir: 'ltr',
  languageLabels,
})

export function I18nProvider({ children }: { children: React.ReactNode }) {
  const [language, setLanguageState] = useState<Language>('en')

  useEffect(() => {
    const saved = localStorage.getItem('bookapp-language') as Language | null
    if (saved && translations[saved]) {
      setLanguageState(saved)
    }
  }, [])

  const setLanguage = useCallback((lang: Language) => {
    setLanguageState(lang)
    localStorage.setItem('bookapp-language', lang)
  }, [])

  const t = useCallback(
    (key: string) => translations[language]?.[key] || translations.en[key] || key,
    [language]
  )

  const dir = language === 'ar' ? 'rtl' : 'ltr'

  return (
    <I18nContext.Provider value={{ language, setLanguage, t, dir, languageLabels }}>
      {children}
    </I18nContext.Provider>
  )
}

export function useI18n() {
  return useContext(I18nContext)
}
