import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
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
          'you can reconfigure this by running the FlutterFire CLI.',
        );
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAsTystbKYRaVc_4i3Qp1Ek_EhGGps2CGU',
    appId: '1:33301875925:web:cbcc0473fe2a6dd15c665c',
    messagingSenderId: '33301875925',
    projectId: 'mini-project-flutter-59761',
    authDomain: 'mini-project-flutter-59761.firebaseapp.com',
    storageBucket: 'mini-project-flutter-59761.firebasestorage.app',
    measurementId: 'G-S3LFFF0Y0N',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAsTystbKYRaVc_4i3Qp1Ek_EhGGps2CGU',
    appId: '1:33301875925:web:cbcc0473fe2a6dd15c665c',
    messagingSenderId: '33301875925',
    projectId: 'mini-project-flutter-59761',
    storageBucket: 'mini-project-flutter-59761.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAsTystbKYRaVc_4i3Qp1Ek_EhGGps2CGU',
    appId: '1:33301875925:web:cbcc0473fe2a6dd15c665c',
    messagingSenderId: '33301875925',
    projectId: 'mini-project-flutter-59761',
    storageBucket: 'mini-project-flutter-59761.firebasestorage.app',
    iosBundleId: 'com.example.taskManagementSystem',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAsTystbKYRaVc_4i3Qp1Ek_EhGGps2CGU',
    appId: '1:33301875925:web:cbcc0473fe2a6dd15c665c',
    messagingSenderId: '33301875925',
    projectId: 'mini-project-flutter-59761',
    storageBucket: 'mini-project-flutter-59761.firebasestorage.app',
    iosBundleId: 'com.example.taskManagementSystem',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAsTystbKYRaVc_4i3Qp1Ek_EhGGps2CGU',
    appId: '1:33301875925:web:cbcc0473fe2a6dd15c665c',
    messagingSenderId: '33301875925',
    projectId: 'mini-project-flutter-59761',
    authDomain: 'mini-project-flutter-59761.firebaseapp.com',
    storageBucket: 'mini-project-flutter-59761.firebasestorage.app',
    measurementId: 'G-S3LFFF0Y0N',
  );
}
