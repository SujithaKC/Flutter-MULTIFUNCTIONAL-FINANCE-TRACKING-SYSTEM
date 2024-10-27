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
    apiKey: 'AIzaSyAbMrTxkaTpIaPy7AnjpsUJvwMIYS9cCtY',
    appId: '1:288629209069:web:00164ce420af47631cd9e4',
    messagingSenderId: '288629209069',
    projectId: 'expensetracker007-b6780',
    authDomain: 'expensetracker007-b6780.firebaseapp.com',
    storageBucket: 'expensetracker007-b6780.appspot.com',
    measurementId: 'G-W6LPN69YGZ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC95uvKpSj9F4F52nUMWxRjRgxpxxGGJ6A',
    appId: '1:288629209069:android:6eecfec4cc9473be1cd9e4',
    messagingSenderId: '288629209069',
    projectId: 'expensetracker007-b6780',
    storageBucket: 'expensetracker007-b6780.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAH_cJyAvdU7zE1FL1F91RtujgSjtDcHS0',
    appId: '1:288629209069:ios:b7c211682ce924391cd9e4',
    messagingSenderId: '288629209069',
    projectId: 'expensetracker007-b6780',
    storageBucket: 'expensetracker007-b6780.appspot.com',
    iosBundleId: 'com.example.financeTracker',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAH_cJyAvdU7zE1FL1F91RtujgSjtDcHS0',
    appId: '1:288629209069:ios:b7c211682ce924391cd9e4',
    messagingSenderId: '288629209069',
    projectId: 'expensetracker007-b6780',
    storageBucket: 'expensetracker007-b6780.appspot.com',
    iosBundleId: 'com.example.financeTracker',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAbMrTxkaTpIaPy7AnjpsUJvwMIYS9cCtY',
    appId: '1:288629209069:web:ae4db2eb7e572b971cd9e4',
    messagingSenderId: '288629209069',
    projectId: 'expensetracker007-b6780',
    authDomain: 'expensetracker007-b6780.firebaseapp.com',
    storageBucket: 'expensetracker007-b6780.appspot.com',
    measurementId: 'G-12PEZ13E36',
  );
}
