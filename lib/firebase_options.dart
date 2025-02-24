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
    apiKey: 'AIzaSyB-lDFnzKq7cJNX5YLq-qINfMipBA0iF2A',
    appId: '1:487724389222:web:13e57e49d38d705e336ea7',
    messagingSenderId: '487724389222',
    projectId: 'chatapp-4b630',
    authDomain: 'chatapp-4b630.firebaseapp.com',
    storageBucket: 'chatapp-4b630.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDfYOcO9Z4pgcdPHse7TeyuG41Jp1vmYoQ',
    appId: '1:487724389222:android:8f112d8bf12be548336ea7',
    messagingSenderId: '487724389222',
    projectId: 'chatapp-4b630',
    storageBucket: 'chatapp-4b630.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDN6aJTPvno-bod7xtlUTDHPCX0OIItECI',
    appId: '1:487724389222:ios:4bc0817b2db701a8336ea7',
    messagingSenderId: '487724389222',
    projectId: 'chatapp-4b630',
    storageBucket: 'chatapp-4b630.firebasestorage.app',
    iosBundleId: 'com.example.chatApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDN6aJTPvno-bod7xtlUTDHPCX0OIItECI',
    appId: '1:487724389222:ios:4bc0817b2db701a8336ea7',
    messagingSenderId: '487724389222',
    projectId: 'chatapp-4b630',
    storageBucket: 'chatapp-4b630.firebasestorage.app',
    iosBundleId: 'com.example.chatApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB-lDFnzKq7cJNX5YLq-qINfMipBA0iF2A',
    appId: '1:487724389222:web:3633778fbac6dfb1336ea7',
    messagingSenderId: '487724389222',
    projectId: 'chatapp-4b630',
    authDomain: 'chatapp-4b630.firebaseapp.com',
    storageBucket: 'chatapp-4b630.firebasestorage.app',
  );
}
