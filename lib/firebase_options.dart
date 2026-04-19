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
    apiKey: 'AIzaSyAvlsvlB-HGJc-Ci8Z89RgqhJN_zrvdwp0',
    appId: '1:872186367302:web:e265243d3b9c1cf662a947',
    messagingSenderId: '872186367302',
    projectId: 'almozawed',
    authDomain: 'almozawed.firebaseapp.com',
    storageBucket: 'almozawed.firebasestorage.app',
  );

  // MOCK OPTIONS: The user needs to run `flutterfire configure` to generate real ones

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBsuXO02rPf3pJlXzBS3pkTfnKxybLjD8o',
    appId: '1:872186367302:android:be762e4b6270d81e62a947',
    messagingSenderId: '872186367302',
    projectId: 'almozawed',
    storageBucket: 'almozawed.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAx_tzZUIj3u5rDrDBjCpO42il3_iwk304',
    appId: '1:872186367302:ios:3332d77dcdcc8d2962a947',
    messagingSenderId: '872186367302',
    projectId: 'almozawed',
    storageBucket: 'almozawed.firebasestorage.app',
    iosBundleId: 'com.example.provisionsSystem',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAx_tzZUIj3u5rDrDBjCpO42il3_iwk304',
    appId: '1:872186367302:ios:3332d77dcdcc8d2962a947',
    messagingSenderId: '872186367302',
    projectId: 'almozawed',
    storageBucket: 'almozawed.firebasestorage.app',
    iosBundleId: 'com.example.provisionsSystem',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAvlsvlB-HGJc-Ci8Z89RgqhJN_zrvdwp0',
    appId: '1:872186367302:web:978c1ddf778bb7a362a947',
    messagingSenderId: '872186367302',
    projectId: 'almozawed',
    authDomain: 'almozawed.firebaseapp.com',
    storageBucket: 'almozawed.firebasestorage.app',
  );

}