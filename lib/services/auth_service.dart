import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Store ConfirmationResult for web OTP verification
  ConfirmationResult? _webConfirmationResult;

  /// Send OTP to the given phone number.
  /// On web, uses signInWithPhoneNumber (handles reCAPTCHA automatically).
  /// On mobile, uses verifyPhoneNumber (native SMS auto-retrieval).
  Future<void> sendOTP({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String errorMessage) onError,
  }) async {
    try {
      if (kIsWeb) {
        // Web: use signInWithPhoneNumber which handles reCAPTCHA internally
        _webConfirmationResult = await _auth.signInWithPhoneNumber(phoneNumber);
        onCodeSent('web-confirmation');
      } else {
        // Mobile: use verifyPhoneNumber for native SMS
        await _auth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (PhoneAuthCredential _) {},
          verificationFailed: (FirebaseAuthException e) {
            onError(e.message ?? 'Verification failed');
          },
          codeSent: (String verificationId, int? resendToken) {
            onCodeSent(verificationId);
          },
          codeAutoRetrievalTimeout: (_) {},
        );
      }
    } catch (e) {
      onError(e.toString());
    }
  }

  /// Verify the OTP code entered by the user.
  /// On web, uses the stored ConfirmationResult.
  /// On mobile, uses PhoneAuthProvider.credential.
  Future<UserCredential> verifyOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    if (kIsWeb && _webConfirmationResult != null) {
      // Web: confirm with the stored ConfirmationResult
      return await _webConfirmationResult!.confirm(smsCode);
    } else {
      // Mobile: use credential-based sign in
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return await _auth.signInWithCredential(credential);
    }
  }
}
