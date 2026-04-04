import 'package:flutter/material.dart';

// ── Usage in any widget ──────────────────────────────────────────
// final t = AppLocalizations.of(context);
// Text(t.home)
// ────────────────────────────────────────────────────────────────

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const delegate = _AppLocalizationsDelegate();

  bool get isArabic => locale.languageCode == 'ar';
  bool get isFrench  => locale.languageCode == 'fr';

  // ── All strings ────────────────────────────────────────────────
  String get appName => 'Mawidi';

  // ── Bottom Nav ─────────────────────────────────────────────────
  String get navHome      => _t('Home',       'Accueil',     'الرئيسية');
  String get navBrowse    => _t('Browse',     'Explorer',    'تصفح');
  String get navBookings  => _t('Bookings',   'Réservations','حجوزاتي');
  String get navMessages  => _t('Messages',   'Messages',    'الرسائل');
  String get navProfile   => _t('Profile',    'Profil',      'الملف');

  // ── Home Screen ────────────────────────────────────────────────
  String get greeting         => _t('Hello', 'Bonjour', 'مرحباً');
  String get searchHint       => _t('Search services, providers...', 'Rechercher...', 'ابحث عن خدمات...');
  String get upcomingBookings => _t('Upcoming Bookings', 'Réservations à venir', 'الحجوزات القادمة');
  String get seeAll           => _t('See all', 'Voir tout', 'عرض الكل');
  String get featuredProviders=> _t('Featured Providers', 'Prestataires vedettes', 'مزودون مميزون');
  String get categories       => _t('Categories', 'Catégories', 'التصنيفات');
  String get confirmed        => _t('Confirmed', 'Confirmé', 'مؤكد');
  String get noUpcoming       => _t('No upcoming bookings', 'Pas de réservations', 'لا توجد حجوزات قادمة');

  // ── Browse Screen ──────────────────────────────────────────────
  String get browse           => _t('Browse', 'Explorer', 'تصفح');
  String get allProviders     => _t('All Providers', 'Tous les prestataires', 'جميع المزودين');
  String get noResults        => _t('No results found', 'Aucun résultat', 'لا توجد نتائج');
  String get filters          => _t('Filters', 'Filtres', 'الفلاتر');
  String get sortBy           => _t('Sort by', 'Trier par', 'ترتيب حسب');

  // ── Provider Detail ────────────────────────────────────────────
  String get about            => _t('About', 'À propos', 'حول');
  String get services         => _t('Services', 'Services', 'الخدمات');
  String get location         => _t('Location', 'Localisation', 'الموقع');
  String get getDirections    => _t('GET DIRECTIONS', 'ITINÉRAIRE', 'احصل على الاتجاه');
  String get openInMaps       => _t('Open in Maps', 'Ouvrir dans Maps', 'فتح في الخرائط');
  String get bookAppointment  => _t('Book Appointment', 'Prendre rendez-vous', 'احجز موعداً');
  String get open             => _t('OPEN', 'OUVERT', 'مفتوح');
  String get seeAllReviews    => _t('See all Reviews', 'Voir les avis', 'عرض التقييمات');
  String get patientReviews   => _t('patient reviews', 'avis patients', 'تقييم المريض');
  String get duration         => _t('Duration', 'Durée', 'المدة');

  // ── Booking Screen ─────────────────────────────────────────────
  String get bookService      => _t('Book Service', 'Réserver', 'احجز الخدمة');
  String get selectDate       => _t('Select Date', 'Choisir une date', 'اختر التاريخ');
  String get selectTime       => _t('Select Time', 'Choisir l\'heure', 'اختر الوقت');
  String get confirmBooking   => _t('Confirm Booking', 'Confirmer', 'تأكيد الحجز');
  String get notes            => _t('Notes (optional)', 'Notes (optionnel)', 'ملاحظات (اختياري)');

  // ── Bookings Screen ────────────────────────────────────────────
  String get myBookings       => _t('My Bookings', 'Mes réservations', 'حجوزاتي');
  String get upcoming         => _t('Upcoming', 'À venir', 'القادمة');
  String get past             => _t('Past', 'Passées', 'السابقة');
  String get cancelled        => _t('Cancelled', 'Annulées', 'الملغاة');
  String get cancel           => _t('Cancel', 'Annuler', 'إلغاء');
  String get reschedule       => _t('Reschedule', 'Reporter', 'إعادة جدولة');
  String get noUpcomingMsg    => _t('No upcoming bookings', 'Aucune réservation à venir', 'لا توجد حجوزات قادمة');
  String get noPastMsg        => _t('No past bookings', 'Aucune réservation passée', 'لا توجد حجوزات سابقة');
  String get noCancelledMsg   => _t('No cancelled bookings', 'Aucune réservation annulée', 'لا توجد حجوزات ملغاة');
  String get confirmCancel    => _t('Cancel Booking?', 'Annuler la réservation?', 'إلغاء الحجز؟');
  String get confirmCancelMsg => _t('This action cannot be undone.', 'Cette action est irréversible.', 'لا يمكن التراجع عن هذا الإجراء.');
  String get keepBooking      => _t('Keep Booking', 'Garder', 'الاحتفاظ بالحجز');
  String get cancelledOn      => _t('Cancelled on', 'Annulé le', 'تم الإلغاء في');
  String get newDate          => _t('New Date', 'Nouvelle date', 'تاريخ جديد');
  String get confirm          => _t('Confirm', 'Confirmer', 'تأكيد');

  // ── Profile Screen ─────────────────────────────────────────────
  String get profile          => _t('Profile', 'Profil', 'الملف الشخصي');
  String get editProfile      => _t('Edit Profile', 'Modifier le profil', 'تعديل الملف');
  String get myBookingsLabel  => _t('MY BOOKINGS', 'MES RÉSERVATIONS', 'حجوزاتي');
  String get totalBookings    => _t('Total Bookings', 'Total réservations', 'إجمالي الحجوزات');
  String get upcomingLabel    => _t('Upcoming', 'À venir', 'القادمة');
  String get settingsLabel    => _t('SETTINGS', 'PARAMÈTRES', 'الإعدادات');
  String get pushNotifications=> _t('Push Notifications', 'Notifications push', 'الإشعارات');
  String get language         => _t('Language', 'Langue', 'اللغة');
  String get accountLabel     => _t('ACCOUNT', 'COMPTE', 'الحساب');
  String get paymentMethods   => _t('Payment Methods', 'Modes de paiement', 'طرق الدفع');
  String get myFavorites      => _t('My Favorites', 'Mes favoris', 'المفضلة');
  String get supportLabel     => _t('SUPPORT', 'ASSISTANCE', 'الدعم');
  String get helpFaq          => _t('Help & FAQ', 'Aide & FAQ', 'المساعدة والأسئلة الشائعة');
  String get contactUs        => _t('Contact Us', 'Contactez-nous', 'اتصل بنا');
  String get logOut           => _t('Log Out', 'Déconnexion', 'تسجيل الخروج');
  String get logOutConfirm    => _t('Are you sure you want to log out?', 'Voulez-vous vraiment vous déconnecter?', 'هل أنت متأكد أنك تريد تسجيل الخروج؟');
  String get version          => _t('HayaBook v1.0.0 · Made with ❤️', 'HayaBook v1.0.0 · Fait avec ❤️', 'HayaBook v1.0.0 · صنع بـ ❤️');
  String get selectLanguage   => _t('Select Language', 'Choisir la langue', 'اختر اللغة');

  // ── Edit Profile ───────────────────────────────────────────────
  String get personalInfo     => _t('Personal Information', 'Informations personnelles', 'المعلومات الشخصية');
  String get fullName         => _t('Full Name', 'Nom complet', 'الاسم الكامل');
  String get emailAddress     => _t('Email Address', 'Adresse e-mail', 'البريد الإلكتروني');
  String get phoneNumber      => _t('Phone Number', 'Numéro de téléphone', 'رقم الهاتف');
  String get aboutLabel       => _t('About', 'À propos', 'حول');
  String get bioHint          => _t('Tell us about yourself...', 'Parlez-nous de vous...', 'أخبرنا عنك...');
  String get saveChanges      => _t('Save Changes', 'Enregistrer', 'حفظ التغييرات');
  String get save             => _t('Save', 'Enregistrer', 'حفظ');

  // ── Notifications ──────────────────────────────────────────────
  String get notifications    => _t('Notifications', 'Notifications', 'الإشعارات');
  String get today            => _t('TODAY', 'AUJOURD\'HUI', 'اليوم');
  String get yesterday        => _t('YESTERDAY', 'HIER', 'أمس');
  String get markAllRead      => _t('Clear all', 'Tout effacer', 'مسح الكل');

  // ── Favorites ──────────────────────────────────────────────────
  String get favorites        => _t('Favorites', 'Favoris', 'المفضلة');
  String get noFavorites      => _t('No Favorites Yet', 'Pas encore de favoris', 'لا توجد مفضلة بعد');
  String get noFavoritesMsg   => _t('Tap ♥ on any provider to save', 'Appuyez sur ♥ pour sauvegarder', 'اضغط ♥ لحفظ مزود');
  String get bookNow          => _t('Book Now', 'Réserver', 'احجز الآن');
  String get all              => _t('All', 'Tous', 'الكل');
  String get clinics          => _t('Clinics', 'Cliniques', 'العيادات');
  String get salons           => _t('Salons', 'Salons', 'الصالونات');
  String get tutors           => _t('Tutors', 'Tuteurs', 'المدرسون');

  // ── Help & FAQ ─────────────────────────────────────────────────
  String get helpTitle        => _t('Help & FAQ', 'Aide & FAQ', 'المساعدة والأسئلة');
  String get howCanWeHelp     => _t('How can we help?', 'Comment pouvons-nous vous aider?', 'كيف يمكننا المساعدة؟');
  String get searchAnswers    => _t('Search for answers, topics...', 'Rechercher des réponses...', 'ابحث عن إجابات...');
  String get faqLabel         => _t('FREQUENTLY ASKED QUESTIONS', 'QUESTIONS FRÉQUENTES', 'الأسئلة الشائعة');
  String get needMoreHelp     => _t('Need more help?', 'Besoin d\'aide?', 'تحتاج مزيداً من المساعدة؟');
  String get supportAvailable => _t('Our support team is available 24/7', 'Notre équipe est disponible 24h/24', 'فريق الدعم متاح على مدار الساعة');

  // ── Contact Us ─────────────────────────────────────────────────
  String get contactTitle     => _t('Contact Us', 'Contactez-nous', 'اتصل بنا');
  String get contactHeadline  => _t('How can we help with\nyour booking?', 'Comment vous aider\navec votre réservation?', 'كيف يمكننا مساعدتك\nفي حجزك؟');
  String get contactSubtitle  => _t('Our support team is here to assist you.', 'Notre équipe est là pour vous aider.', 'فريق الدعم هنا لمساعدتك.');
  String get startLiveChat    => _t('Start Live Chat', 'Démarrer le chat', 'بدء الدردشة المباشرة');
  String get orEmailUs        => _t('OR EMAIL US', 'OU ENVOYEZ UN E-MAIL', 'أو راسلنا');
  String get subject          => _t('SUBJECT', 'SUJET', 'الموضوع');
  String get subjectHint      => _t('What\'s this about?', 'De quoi s\'agit-il?', 'ما هذا بشأن؟');
  String get message          => _t('MESSAGE', 'MESSAGE', 'الرسالة');
  String get messageHint      => _t('How can we assist you today?', 'Comment pouvons-nous vous aider?', 'كيف يمكننا مساعدتك اليوم؟');
  String get sendEmail        => _t('Send Email', 'Envoyer', 'إرسال البريد');
  String get followUs         => _t('FOLLOW US', 'SUIVEZ-NOUS', 'تابعنا');

  // ── Reviews ────────────────────────────────────────────────────
  String get reviews          => _t('Reviews', 'Avis', 'التقييمات');
  String get totalReviewsLabel=> _t('Total Reviews', 'Avis au total', 'إجمالي التقييمات');
  String get userTestimonials => _t('User Testimonials', 'Témoignages', 'آراء المستخدمين');
  String get recent           => _t('Recent', 'Récents', 'الأحدث');
  String get highest          => _t('Highest', 'Les mieux notés', 'الأعلى تقييماً');
  String get mostLiked        => _t('Most Liked', 'Les plus aimés', 'الأكثر إعجاباً');
  String get writeReview      => _t('Write a Review', 'Écrire un avis', 'كتابة تقييم');
  String get shareExperience  => _t('Share your experience with others', 'Partagez votre expérience', 'شارك تجربتك مع الآخرين');
  String get yourRating       => _t('Your Rating', 'Votre note', 'تقييمك');
  String get yourName         => _t('Your Name', 'Votre nom', 'اسمك');
  String get yourReview       => _t('Your Review', 'Votre avis', 'تقييمك');
  String get submitReview     => _t('Submit Review', 'Soumettre', 'إرسال التقييم');
  String get report           => _t('Report', 'Signaler', 'إبلاغ');

  // ── Location ───────────────────────────────────────────────────
  String get selectLocation    => _t('Select Location', 'Sélectionner', 'اختر الموقع');
  String get searchCity        => _t('Search city or area...', 'Rechercher une ville...', 'ابحث عن مدينة...');
  String get useCurrentLocation=> _t('Use Current Location', 'Utiliser ma position', 'استخدام موقعي الحالي');
  String get enableGps         => _t('Enable GPS for better accuracy', 'Activer le GPS', 'تفعيل GPS للدقة');
  String get detectingLocation => _t('Detecting location...', 'Détection...', 'جارٍ التحديد...');
  String get popularCities     => _t('POPULAR CITIES', 'VILLES POPULAIRES', 'المدن الشائعة');
  String get searchResults     => _t('SEARCH RESULTS', 'RÉSULTATS', 'نتائج البحث');
  String get cantFindCity      => _t("Can't find your city? ", "Votre ville introuvable? ", "لا تجد مدينتك؟ ");
  String get contactSupport    => _t('Contact support', 'Contacter le support', 'تواصل مع الدعم');

  // ── Auth screens ───────────────────────────────────────────────
  String get login            => _t('Login', 'Connexion', 'تسجيل الدخول');
  String get signup           => _t('Sign Up', 'S\'inscrire', 'إنشاء حساب');
  String get email            => _t('Email', 'E-mail', 'البريد الإلكتروني');
  String get password         => _t('Password', 'Mot de passe', 'كلمة المرور');
  String get forgotPassword   => _t('Forgot Password?', 'Mot de passe oublié?', 'نسيت كلمة المرور؟');
  String get dontHaveAccount  => _t('Don\'t have an account?', 'Pas de compte?', 'ليس لديك حساب؟');
  String get alreadyHaveAccount=>_t('Already have an account?', 'Déjà un compte?', 'لديك حساب بالفعل؟');
  String get signIn           => _t('Sign In', 'Se connecter', 'تسجيل الدخول');
  String get createAccount    => _t('Create Account', 'Créer un compte', 'إنشاء حساب');
  String get phone            => _t('Phone', 'Téléphone', 'الهاتف');
  String get name             => _t('Name', 'Nom', 'الاسم');
  String get verifyOtp        => _t('Verify OTP', 'Vérifier OTP', 'التحقق');
  String get enterOtp         => _t('Enter the code sent to your phone', 'Entrez le code envoyé', 'أدخل الرمز المرسل لهاتفك');
  String get resendCode       => _t('Resend Code', 'Renvoyer le code', 'إعادة الإرسال');
  String get verify           => _t('Verify', 'Vérifier', 'تحقق');

  // ── Messages ───────────────────────────────────────────────────
  String get messages         => _t('Messages', 'Messages', 'الرسائل');
  String get noMessages       => _t('No messages yet', 'Aucun message', 'لا توجد رسائل بعد');
  String get typeMessage      => _t('Type a message...', 'Écrire un message...', 'اكتب رسالة...');
  String get send             => _t('Send', 'Envoyer', 'إرسال');

  // ── Confirmation Screen ────────────────────────────────────────
  String get bookingConfirmed => _t('Booking Confirmed!', 'Réservation confirmée!', 'تم تأكيد الحجز!');
  String get bookingConfirmedMsg => _t('Your appointment has been booked successfully.', 'Votre rendez-vous a été réservé.', 'تم حجز موعدك بنجاح.');
  String get viewBookings     => _t('View Bookings', 'Voir mes réservations', 'عرض الحجوزات');
  String get backToHome       => _t('Back to Home', 'Retour à l\'accueil', 'العودة للرئيسية');

  // ── Common ─────────────────────────────────────────────────────
  String get loading          => _t('Loading...', 'Chargement...', 'جارٍ التحميل...');
  String get error            => _t('Something went wrong', 'Une erreur est survenue', 'حدث خطأ ما');
  String get retry            => _t('Retry', 'Réessayer', 'إعادة المحاولة');
  String get ok               => _t('OK', 'OK', 'حسناً');
  String get yes              => _t('Yes', 'Oui', 'نعم');
  String get no               => _t('No', 'Non', 'لا');
  String get close            => _t('Close', 'Fermer', 'إغلاق');
  String get back             => _t('Back', 'Retour', 'رجوع');
  String get next             => _t('Next', 'Suivant', 'التالي');
  String get done             => _t('Done', 'Terminé', 'تم');
  String get pleaseWait       => _t('Please wait...', 'Veuillez patienter...', 'يرجى الانتظار...');
  String get fillAllFields    => _t('Please fill in all fields', 'Veuillez remplir tous les champs', 'يرجى ملء جميع الحقول');
  String get successSaved     => _t('Saved successfully!', 'Enregistré avec succès!', 'تم الحفظ بنجاح!');

  // ── FAQ content ────────────────────────────────────────────────
  String get faqQ1 => _t(
      'How to book an appointment?',
      'Comment prendre rendez-vous?',
      'كيف أحجز موعداً؟');
  String get faqA1 => _t(
      "Browse providers, select a time slot and tap 'Confirm Booking'. You'll receive an instant confirmation via email and app notification.",
      "Parcourez les prestataires, sélectionnez un créneau et appuyez sur 'Confirmer'. Vous recevrez une confirmation instantanée.",
      "تصفح المزودين واختر وقتاً متاحاً واضغط 'تأكيد الحجز'. ستصلك رسالة تأكيد فورية.");
  String get faqQ2 => _t(
      'What is the cancellation policy?',
      'Quelle est la politique d\'annulation?',
      'ما هي سياسة الإلغاء؟');
  String get faqA2 => _t(
      'You can cancel up to 24 hours before the appointment for a full refund. Cancellations within 24 hours may incur a fee of up to 50%.',
      'Vous pouvez annuler jusqu\'à 24h avant le rendez-vous pour un remboursement complet. Les annulations tardives peuvent entraîner des frais.',
      'يمكنك الإلغاء قبل 24 ساعة للحصول على استرداد كامل. قد تستحق الإلغاءات المتأخرة رسوماً تصل إلى 50٪.');
  String get faqQ3 => _t(
      'Can I reschedule my booking?',
      'Puis-je reporter mon rendez-vous?',
      'هل يمكنني إعادة جدولة الحجز؟');
  String get faqA3 => _t(
      'Yes! Go to My Bookings, select the appointment and tap "Reschedule". Rescheduling is free up to 2 hours before the appointment.',
      'Oui! Allez dans Mes Réservations, sélectionnez le rendez-vous et appuyez sur "Reporter". Le report est gratuit jusqu\'à 2h avant.',
      'نعم! اذهب إلى حجوزاتي، اختر الموعد واضغط "إعادة جدولة". الإعادة مجانية حتى ساعتين قبل الموعد.');
  String get faqQ4 => _t(
      'How do I contact a provider?',
      'Comment contacter un prestataire?',
      'كيف أتواصل مع المزود؟');
  String get faqA4 => _t(
      "Message a provider through in-app messaging. Open their profile and tap the Message button, or use the contact option in your booking details.",
      "Envoyez un message via la messagerie intégrée. Ouvrez le profil du prestataire et appuyez sur Message, ou utilisez l'option de contact dans vos détails de réservation.",
      "راسل المزود عبر الرسائل الداخلية. افتح ملفه واضغط زر الرسالة، أو استخدم خيار الاتصال في تفاصيل حجزك.");

  // ── Helpers ────────────────────────────────────────────────────
  String _t(String en, String fr, String ar) {
    switch (locale.languageCode) {
      case 'fr': return fr;
      case 'ar': return ar;
      default:   return en;
    }
  }
}

// ── Delegate ──────────────────────────────────────────────────────
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'fr', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}