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
    apiKey: 'AIzaSyAKIhVAf5AKyQQJKYWQ-VEXj1Id8M2n-gc',
    appId: '1:501790631469:web:711a7f1d0515a8a9e07aa4',
    messagingSenderId: '501790631469',
    projectId: 'docstore1-b0f9f',
    authDomain: 'docstore1-b0f9f.firebaseapp.com',
    storageBucket: 'docstore1-b0f9f.appspot.com',
    measurementId: 'G-HLYQBN1QL1',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCqmGa2qnNzlLCkdJjJWvxCSvzjAIgtE3c',
    appId: '1:501790631469:android:d580f6a714664843e07aa4',
    messagingSenderId: '501790631469',
    projectId: 'docstore1-b0f9f',
    storageBucket: 'docstore1-b0f9f.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAF31Gvytj6M6b_lmj3z71HNM1tNwh21OQ',
    appId: '1:501790631469:ios:92040bb01f23a08ae07aa4',
    messagingSenderId: '501790631469',
    projectId: 'docstore1-b0f9f',
    storageBucket: 'docstore1-b0f9f.appspot.com',
    iosBundleId: 'com.example.billstore2',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAF31Gvytj6M6b_lmj3z71HNM1tNwh21OQ',
    appId: '1:501790631469:ios:92040bb01f23a08ae07aa4',
    messagingSenderId: '501790631469',
    projectId: 'docstore1-b0f9f',
    storageBucket: 'docstore1-b0f9f.appspot.com',
    iosBundleId: 'com.example.billstore2',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAKIhVAf5AKyQQJKYWQ-VEXj1Id8M2n-gc',
    appId: '1:501790631469:web:543222d8dd6b13a6e07aa4',
    messagingSenderId: '501790631469',
    projectId: 'docstore1-b0f9f',
    authDomain: 'docstore1-b0f9f.firebaseapp.com',
    storageBucket: 'docstore1-b0f9f.appspot.com',
    measurementId: 'G-H3W772RENC',
  );
}
