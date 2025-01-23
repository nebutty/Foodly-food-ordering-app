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
    apiKey: 'AIzaSyD1wQN9WGmePlu0BOSsIjKrvjB_59lTWlg',
    appId: '1:850637311125:web:f17bd23068260d2ee19f9c',
    messagingSenderId: '850637311125',
    projectId: 'fooddelivery-b4928',
    authDomain: 'fooddelivery-b4928.firebaseapp.com',
    storageBucket: 'fooddelivery-b4928.firebasestorage.app',
    measurementId: 'G-1B8WD1EZ1H',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBgFmJMdoG6ezW8FfYg870ptet3leqROuM',
    appId: '1:850637311125:android:19d7415ac936784de19f9c',
    messagingSenderId: '850637311125',
    projectId: 'fooddelivery-b4928',
    storageBucket: 'fooddelivery-b4928.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDRekfstaDYmyxcOfuE6zweOFlwAMOwuz8',
    appId: '1:850637311125:ios:9ae053b8bb3de996e19f9c',
    messagingSenderId: '850637311125',
    projectId: 'fooddelivery-b4928',
    storageBucket: 'fooddelivery-b4928.firebasestorage.app',
    iosBundleId: 'com.example.fooddelivery',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDRekfstaDYmyxcOfuE6zweOFlwAMOwuz8',
    appId: '1:850637311125:ios:9ae053b8bb3de996e19f9c',
    messagingSenderId: '850637311125',
    projectId: 'fooddelivery-b4928',
    storageBucket: 'fooddelivery-b4928.firebasestorage.app',
    iosBundleId: 'com.example.fooddelivery',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD1wQN9WGmePlu0BOSsIjKrvjB_59lTWlg',
    appId: '1:850637311125:web:3236c7a8669a19cee19f9c',
    messagingSenderId: '850637311125',
    projectId: 'fooddelivery-b4928',
    authDomain: 'fooddelivery-b4928.firebaseapp.com',
    storageBucket: 'fooddelivery-b4928.firebasestorage.app',
    measurementId: 'G-TFXK2C8DND',
  );
}
