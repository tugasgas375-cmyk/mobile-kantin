import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => const FirebaseOptions(
        apiKey: 'YOUR_API_KEY',
        appId: 'YOUR_APP_ID',
        messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
        projectId: 'mobile-kantin-demo',
        authDomain: 'mobile-kantin-demo.firebaseapp.com',
        storageBucket: 'mobile-kantin-demo.firebasestorage.app',
      );
}
