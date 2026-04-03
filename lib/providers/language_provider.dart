import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  String _locale = 'en'; // default English
  bool _isLoaded = false;

  String get locale => _locale;
  bool get isLoaded => _isLoaded;
  bool get isHindi => _locale == 'hi';

  LanguageProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _locale = prefs.getString('app_locale') ?? '';
    _isLoaded = true;
    notifyListeners();
  }

  /// Returns true if language has been previously selected
  bool get hasSelectedLanguage => _locale.isNotEmpty;

  Future<void> setLanguage(String locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_locale', locale);
    notifyListeners();
  }

  /// Get translated string
  String t(String key) {
    final map = _locale == 'hi' ? _hiStrings : _enStrings;
    return map[key] ?? _enStrings[key] ?? key;
  }

  // ─── English Strings ───
  static const _enStrings = <String, String>{
    // Home Screen
    'kids_workshop': 'Kids Workshop',
    'location': 'Sant Nirankari Satsang Bhawan, Inderlok',
    'what_to_do': 'What would you like to do?',
    'register_child': 'Register Child',
    'register_subtitle': 'Sign up your child for the workshop',
    'find_qr': "Find My Child's QR",
    'find_qr_subtitle': "Retrieve your child's QR code",
    'volunteer_login': 'Volunteer Login',
    'volunteer_subtitle': 'For workshop staff only',

    // Registration Screen
    'register_title': 'Register Child',
    'register_header': "Fill in your child's details to get a unique QR code for workshop entry.",
    'child_info': 'Child Information',
    'child_name': "Child's Full Name",
    'child_name_hint': 'e.g. Rahul Sharma',
    'age': 'Age',
    'age_hint': 'e.g. 10',
    'gender': 'Gender',
    'male': 'Male',
    'female': 'Female',
    'branch_name': 'Branch Name',
    'select_branch': 'Select Branch',
    'branch_Inderlok': 'Inderlok',
    'branch_Tri Nagar': 'Tri Nagar',
    'branch_Ashok Vihar': 'Ashok Vihar',
    'branch_Lawrence Road': 'Lawrence Road',
    'branch_Nehru Nagar': 'Nehru Nagar',
    'branch_Azad Colony': 'Azad Colony',
    'parent_guardian': 'Parent / Guardian',
    'parent_name': "Parent's Name",
    'parent_name_hint': 'e.g. Amit Kumar',
    'phone': 'Phone Number',
    'phone_hint': 'e.g. 9876543210',
    'address': 'Address',
    'address_hint': 'e.g. Delhi',
    'register_btn': 'Register Child',
    'required': 'Required',
    'valid_age': 'Enter a valid age (5–25)',
    'age_limit_note': 'Age should be between 5-25',
    'valid_phone': 'Enter a valid phone number',

    // Registration Success
    'reg_success_title': 'Registration Successful',
    'reg_success': 'Registration Successful!',
    'reg_complete': 'Registration Complete!',
    'show_qr': 'Show this QR code at workshop entry',
    'child_name_label': 'Child Name',
    'workshop_id': 'Workshop ID',
    'age_label': 'Age',
    'parent_label': 'Parent',
    'save_gallery': 'Save to Gallery',
    'share_qr': 'Share QR Code',
    'back_home': 'Back to Home',

    // Parent Access
    'find_your_qr': "Find Your Child's QR",
    'find_registration': 'Find Your Registration',
    'find_desc': 'Enter the phone number you used when registering your child.',
    'find_btn': "Find My Child's QR",
    'no_registration': 'No registrations found for this phone number.',

    // Children List
    'my_children': 'My Children',
    'tap_child': 'Tap on your child to view their QR code.',
    'already_entered': 'Already Entered',
    'not_entered': 'Not Yet Entered',

    // Admin Login
    'login_title': 'Volunteer Login',
    'vol_login': 'Volunteer Login',
    'vol_login_desc': 'Login to manage kids at the workshop',
    'login_restricted': 'This area is restricted to authorised workshop volunteers only.',
    'workshop_password': 'Workshop Password',
    'login_btn': 'Login',
    'login': 'Login',
    'no_account': "Don't have an account? ",
    'signup_volunteer': 'Sign up as volunteer',
    'vol_signup': 'Sign up',
    'login_failed': 'Login failed. Please check your credentials.',

    // Entry Success
    'entry_success': 'Entry Successful!',
    'entered_workshop': 'has entered the workshop 🎉',
    'scan_next': 'Scan Next',

    // Child Verification
    'child_details': 'Child Details',
    'entered_at': 'Entered at:',
    'camp_id': 'Workshop ID',
    'gender_label': 'Gender',
    'parent_info': 'Parent',
    'phone_label': 'Phone',
    'not_specified': 'Not specified',
    'allow_entry': 'Allow Entry',
    'no_reentry': '⚠️  This child has already been admitted. Do not allow re-entry.',
    'years': 'years',

    // Volunteer Signup
    'volunteer_signup': 'Volunteer Signup',
    'volunteer_header': 'Join our team! Fill in your details to register as a workshop volunteer. Note that password will be generated automatically.',
    'personal_info': 'Personal Information',
    'full_name': 'Full Name',
    'full_name_hint': 'e.g. Rahul Sharma',
    'age_16': 'Must be 16+',
    'email': 'Email',
    'email_hint': 'e.g. rahul@email.com',
    'invalid_email': 'Invalid email',
    'residential_address': 'Residential Address',
    'residential_hint': 'e.g. Block A, Rohini, Delhi',
    'phone_verification': 'Phone Verification',
    'signup_btn': 'Sign Up',

    // QR Scanner
    'scan_qr': 'Scan QR Code',
    'align_qr': 'Align the QR code within the frame',
    'child_not_found': '❌ Child not found. Invalid QR code.',

    // OTP
    'verify_phone': 'Verify Phone',
    'enter_otp': 'Enter OTP',
    'otp_sent': 'We sent a 6-digit code to',
    'otp_label': '6-digit Code',
    'otp_hint': '123456',
    'enter_6_digits': 'Enter 6 digits',
    'verify_continue': 'Verify & Continue',

    // Admin Dashboard
    'volunteer_dashboard': 'Volunteer Dashboard',
    'welcome_back': 'Welcome back,',
    'what_today': 'What would you like to do today?',
    'scan_qr_title': 'Scan QR Code',
    'scan_qr_subtitle': "Scan a child's QR to mark their entry/exit",
    'logout': 'Logout',
    'logout_subtitle': 'End your session securely',
    'no_scans_yet': 'No entries marked yet.',

    // Language Selection
    'choose_language': 'Choose Language',
    'language_subtitle': 'Select your preferred language',
    'continue_btn': 'Continue',
  };

  // ─── Hindi Strings ───
  static const _hiStrings = <String, String>{
    // Home Screen
    'kids_workshop': 'बच्चों की कार्यशाला',
    'location': 'संत निरंकारी सत्संग भवन, इंद्रलोक',
    'what_to_do': 'आप क्या करना चाहेंगे?',
    'register_child': 'बच्चे का पंजीकरण',
    'register_subtitle': 'अपने बच्चे को कार्यशाला के लिए पंजीकृत करें',
    'find_qr': 'अपने बच्चे का QR खोजें',
    'find_qr_subtitle': 'अपने बच्चे का QR कोड प्राप्त करें',
    'volunteer_login': 'वॉलंटियर लॉगिन',
    'volunteer_subtitle': 'केवल कार्यशाला स्टाफ के लिए',

    // Registration Screen
    'register_title': 'बच्चे का पंजीकरण',
    'register_header': 'कार्यशाला प्रवेश के लिए एक अनूठा QR कोड प्राप्त करने हेतु अपने बच्चे का विवरण भरें।',
    'child_info': 'बच्चे की जानकारी',
    'child_name': 'बच्चे का पूरा नाम',
    'child_name_hint': 'जैसे: राहुल शर्मा',
    'age': 'उम्र',
    'age_hint': 'जैसे: 10',
    'gender': 'लिंग',
    'male': 'लड़का',
    'female': 'लड़की',
    'branch_name': 'ब्रांच का नाम',
    'select_branch': 'ब्रांच चुनें',
    'branch_Inderlok': 'इंद्रलोक',
    'branch_Tri Nagar': 'त्री नगर',
    'branch_Ashok Vihar': 'अशोक विहार',
    'branch_Lawrence Road': 'लॉरेंस रोड',
    'branch_Nehru Nagar': 'नेहरू नगर',
    'branch_Azad Colony': 'आज़ाद कॉलोनी',
    'parent_guardian': 'माता-पिता / अभिभावक',
    'parent_name': 'माता-पिता का नाम',
    'parent_name_hint': 'जैसे: अमित कुमार',
    'phone': 'फोन नंबर',
    'phone_hint': 'जैसे: 9876543210',
    'address': 'पता',
    'address_hint': 'जैसे: दिल्ली',
    'register_btn': 'बच्चे का पंजीकरण करें',
    'required': 'आवश्यक',
    'valid_age': 'सही उम्र दर्ज करें (5–25)',
    'age_limit_note': 'उम्र 5-25 वर्ष के बीच होनी चाहिए',
    'valid_phone': 'सही फोन नंबर दर्ज करें',

    // Registration Success
    'reg_success_title': 'पंजीकरण सफल',
    'reg_success': 'पंजीकरण सफल!',
    'reg_complete': 'पंजीकरण पूर्ण!',
    'show_qr': 'कार्यशाला प्रवेश पर यह QR कोड दिखाएं',
    'child_name_label': 'बच्चे का नाम',
    'workshop_id': 'कार्यशाला ID',
    'age_label': 'उम्र',
    'parent_label': 'माता-पिता',
    'save_gallery': 'गैलरी में सेव करें',
    'share_qr': 'QR कोड शेयर करें',
    'back_home': 'होम पर वापस जाएं',

    // Parent Access
    'find_your_qr': 'अपने बच्चे का QR खोजें',
    'find_registration': 'अपना पंजीकरण खोजें',
    'find_desc': 'बच्चे को पंजीकृत करते समय इस्तेमाल किया गया फोन नंबर दर्ज करें।',
    'find_btn': 'अपने बच्चे का QR खोजें',
    'no_registration': 'इस फोन नंबर के लिए कोई पंजीकरण नहीं मिला।',

    // Children List
    'my_children': 'मेरे बच्चे',
    'tap_child': 'QR कोड देखने के लिए अपने बच्चे पर टैप करें।',
    'already_entered': 'पहले से प्रवेश किया',
    'not_entered': 'अभी तक प्रवेश नहीं',

    // Admin Login
    'login_title': 'वॉलंटियर लॉगिन',
    'vol_login': 'वॉलंटियर लॉगिन',
    'vol_login_desc': 'कार्यशाला में बच्चों का प्रबंधन करने के लिए लॉगिन करें',
    'login_restricted': 'यह क्षेत्र केवल अधिकृत कार्यशाला वॉलंटियर्स के लिए है।',
    'workshop_password': 'कार्यशाला पासवर्ड',
    'login_btn': 'लॉगिन',
    'login': 'लॉगिन',
    'no_account': 'खाता नहीं है? ',
    'signup_volunteer': 'वॉलंटियर के रूप में साइन अप करें',
    'vol_signup': 'साइन अप करें',
    'login_failed': 'लॉगिन विफल रहा। कृपया अपने विवरण की जाँच करें।',

    // Entry Success
    'entry_success': 'प्रवेश सफल!',
    'entered_workshop': 'ने कार्यशाला में प्रवेश किया 🎉',
    'scan_next': 'अगला स्कैन करें',

    // Child Verification
    'child_details': 'बच्चे का विवरण',
    'entered_at': 'प्रवेश समय:',
    'camp_id': 'कार्यशाला ID',
    'gender_label': 'लिंग',
    'parent_info': 'माता-पिता',
    'phone_label': 'फोन',
    'not_specified': 'निर्दिष्ट नहीं',
    'allow_entry': 'प्रवेश की अनुमति दें',
    'no_reentry': '⚠️  इस बच्चे को पहले ही प्रवेश मिल चुका है। पुनः प्रवेश की अनुमति न दें।',
    'years': 'वर्ष',

    // Volunteer Signup
    'volunteer_signup': 'वॉलंटियर साइन अप',
    'volunteer_header': 'हमारी टीम से जुड़ें! वॉलंटियर के रूप में पंजीकरण के लिए अपना विवरण भरें। ध्यान दें कि पासवर्ड स्वचालित रूप से बनाया जाएगा।',
    'personal_info': 'व्यक्तिगत जानकारी',
    'full_name': 'पूरा नाम',
    'full_name_hint': 'जैसे: राहुल शर्मा',
    'age_16': '16+ होना चाहिए',
    'email': 'ईमेल',
    'email_hint': 'जैसे: rahul@email.com',
    'invalid_email': 'अमान्य ईमेल',
    'residential_address': 'आवासीय पता',
    'residential_hint': 'जैसे: ब्लॉक A, रोहिणी, दिल्ली',
    'phone_verification': 'फोन सत्यापन',
    'signup_btn': 'साइन अप',

    // QR Scanner
    'scan_qr': 'QR कोड स्कैन करें',
    'align_qr': 'QR कोड को फ्रेम में संरेखित करें',
    'child_not_found': '❌ बच्चा नहीं मिला। अमान्य QR कोड।',

    // OTP
    'verify_phone': 'फोन सत्यापित करें',
    'enter_otp': 'OTP दर्ज करें',
    'otp_sent': 'हमने 6 अंकों का कोड भेजा है',
    'otp_label': '6 अंकों का कोड',
    'otp_hint': '123456',
    'enter_6_digits': '6 अंक दर्ज करें',
    'verify_continue': 'सत्यापित करें और जारी रखें',

    // Admin Dashboard
    'volunteer_dashboard': 'वॉलंटियर डैशबोर्ड',
    'welcome_back': 'वापस स्वागत है,',
    'what_today': 'आज आप क्या करना चाहेंगे?',
    'scan_qr_title': 'QR कोड स्कैन करें',
    'scan_qr_subtitle': 'प्रवेश/निकास चिह्नित करने के लिए बच्चे का QR स्कैन करें',
    'logout': 'लॉग आउट',
    'logout_subtitle': 'अपना सत्र सुरक्षित रूप से समाप्त करें',
    'no_scans_yet': 'अभी तक कोई प्रविष्टि नहीं की गई है।',

    // Language Selection
    'choose_language': 'भाषा चुनें',
    'language_subtitle': 'अपनी पसंदीदा भाषा चुनें',
    'continue_btn': 'जारी रखें',
  };
}
