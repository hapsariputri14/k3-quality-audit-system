import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      // Konfigurasi untuk Web
      return const FirebaseOptions(
        apiKey: "AIzaSyDbTqVH7V81uXb_LivpZ8XpHJsJjwtA--0",
        authDomain: "productqualityaudit.firebaseapp.com",
        projectId: "productqualityaudit",
        storageBucket: "productqualityaudit.firebasestorage.app",
        messagingSenderId: "1016511478525",
        appId: "1:1016511478525:web:8170f82dd2afe27b4a9c94",
        measurementId: "G-1ZP0WHW48E",
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // Konfigurasi untuk Android (sudah sesuai google-services.json)
        return const FirebaseOptions(
          apiKey: "AIzaSyCMX5hKwJiD0z3lBdiTXoPKznd2_g9zsuw",
          appId: "1:1016511478525:android:52e8a1b7870d31604a9c94",
          messagingSenderId: "1016511478525",
          projectId: "productqualityaudit",
          storageBucket: "productqualityaudit.firebasestorage.app",
        );

      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }
}
