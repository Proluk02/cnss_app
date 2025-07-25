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
    apiKey: 'AIzaSyDCOo9m35I0qrt0jGXE1201IpMyNTXgV8M',
    appId: '1:439563567935:web:62fc6813e258e39177098a',
    messagingSenderId: '439563567935',
    projectId: 'cnssapp-d0758',
    authDomain: 'cnssapp-d0758.firebaseapp.com',
    storageBucket: 'cnssapp-d0758.firebasestorage.app',
    measurementId: 'G-FT7H7D6ZPC',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBzitKan4CfLHgaw7wU1mRTg6bVMD5-5Sk',
    appId: '1:439563567935:android:ac3a7b32b672ebf977098a',
    messagingSenderId: '439563567935',
    projectId: 'cnssapp-d0758',
    storageBucket: 'cnssapp-d0758.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAytotYFChptZHV3rmm5eGeKt4HK_nfDSU',
    appId: '1:439563567935:ios:cd2308d41027979477098a',
    messagingSenderId: '439563567935',
    projectId: 'cnssapp-d0758',
    storageBucket: 'cnssapp-d0758.firebasestorage.app',
    iosBundleId: 'com.example.cnssApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAytotYFChptZHV3rmm5eGeKt4HK_nfDSU',
    appId: '1:439563567935:ios:cd2308d41027979477098a',
    messagingSenderId: '439563567935',
    projectId: 'cnssapp-d0758',
    storageBucket: 'cnssapp-d0758.firebasestorage.app',
    iosBundleId: 'com.example.cnssApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDCOo9m35I0qrt0jGXE1201IpMyNTXgV8M',
    appId: '1:439563567935:web:74276d1169e6daf977098a',
    messagingSenderId: '439563567935',
    projectId: 'cnssapp-d0758',
    authDomain: 'cnssapp-d0758.firebaseapp.com',
    storageBucket: 'cnssapp-d0758.firebasestorage.app',
    measurementId: 'G-CCW47HM14L',
  );
}
