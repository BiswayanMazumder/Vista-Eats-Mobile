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
    apiKey: 'AIzaSyDbvSTnxYTfPEPQ4HpHAjYQ3Gobas7MZY0',
    appId: '1:931029105010:web:c1b851904598e90be045eb',
    messagingSenderId: '931029105010',
    projectId: 'vistaeats',
    authDomain: 'vistaeats.firebaseapp.com',
    storageBucket: 'vistaeats.firebasestorage.app',
    measurementId: 'G-0C8M4W6GXJ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAVEGLKgg0g5MKylbNaiZYs2kcb_2NRzec',
    appId: '1:931029105010:android:e18bb5b021af516fe045eb',
    messagingSenderId: '931029105010',
    projectId: 'vistaeats',
    storageBucket: 'vistaeats.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyATfKrvv24l_Yuic4ykcO_JmhQ_AhWm7yc',
    appId: '1:931029105010:ios:4c1562b656bd6ae5e045eb',
    messagingSenderId: '931029105010',
    projectId: 'vistaeats',
    storageBucket: 'vistaeats.firebasestorage.app',
    iosBundleId: 'com.example.vistaeats',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyATfKrvv24l_Yuic4ykcO_JmhQ_AhWm7yc',
    appId: '1:931029105010:ios:4c1562b656bd6ae5e045eb',
    messagingSenderId: '931029105010',
    projectId: 'vistaeats',
    storageBucket: 'vistaeats.firebasestorage.app',
    iosBundleId: 'com.example.vistaeats',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDbvSTnxYTfPEPQ4HpHAjYQ3Gobas7MZY0',
    appId: '1:931029105010:web:0bc5e85053d29ba8e045eb',
    messagingSenderId: '931029105010',
    projectId: 'vistaeats',
    authDomain: 'vistaeats.firebaseapp.com',
    storageBucket: 'vistaeats.firebasestorage.app',
    measurementId: 'G-0JGQNKES4H',
  );
}
