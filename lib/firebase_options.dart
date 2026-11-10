import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../models.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return const FirebaseOptions(
        apiKey: 'demo-api-key',
        appId: 'demo-app-id',
        messagingSenderId: 'demo-messaging-sender-id',
        projectId: 'mobile-kantin-demo',
        authDomain: 'mobile-kantin-demo.firebaseapp.com',
        storageBucket: 'mobile-kantin-demo.firebasestorage.app',
      );
    }

    return const FirebaseOptions(
      apiKey: 'demo-api-key',
      appId: 'demo-app-id',
      messagingSenderId: 'demo-messaging-sender-id',
      projectId: 'mobile-kantin-demo',
      authDomain: 'mobile-kantin-demo.firebaseapp.com',
      storageBucket: 'mobile-kantin-demo.firebasestorage.app',
    );
  }
}
