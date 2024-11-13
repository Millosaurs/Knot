// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCsqSuG7P2Cc-IYXLK_lneTIYSNkV2UJtE',
    appId: '1:544573848624:web:49c5862cd8daf0a16ec1f5',
    messagingSenderId: '544573848624',
    projectId: 'knot-0',
    authDomain: 'knot-0.firebaseapp.com',
    storageBucket: 'knot-0.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAtVGu3fXs_DBMStTmZClDjWPxiLfWnNCA',
    appId: '1:544573848624:android:b10fc663638421ff6ec1f5',
    messagingSenderId: '544573848624',
    projectId: 'knot-0',
    storageBucket: 'knot-0.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCys57_ueOYGtCxN2HXLw51EEPXpnRLQPE',
    appId: '1:544573848624:ios:338d33315e5d4a356ec1f5',
    messagingSenderId: '544573848624',
    projectId: 'knot-0',
    storageBucket: 'knot-0.firebasestorage.app',
    iosBundleId: 'com.shrivatsav.knot',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCys57_ueOYGtCxN2HXLw51EEPXpnRLQPE',
    appId: '1:544573848624:ios:338d33315e5d4a356ec1f5',
    messagingSenderId: '544573848624',
    projectId: 'knot-0',
    storageBucket: 'knot-0.firebasestorage.app',
    iosBundleId: 'com.example.knot',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCsqSuG7P2Cc-IYXLK_lneTIYSNkV2UJtE',
    appId: '1:544573848624:web:6c1367534ae742706ec1f5',
    messagingSenderId: '544573848624',
    projectId: 'knot-0',
    authDomain: 'knot-0.firebaseapp.com',
    storageBucket: 'knot-0.firebasestorage.app',
  );
}
