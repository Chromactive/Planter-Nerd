// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions android = FirebaseOptions(
      apiKey: 'AIzaSyBlCbNMjD0rUjluN6I3d0CWA2sBdObaVm0',
      appId: '1:988490490890:android:faa460fad48681d45aebf3',
      messagingSenderId: '988490490890',
      projectId: 'pepperoni-nipples',
      storageBucket: 'pepperoni-nipples.appspot.com',
      databaseURL: 'https://pepperoni-nipples-default-rtdb.europe-west1.firebasedatabase.app');

  static const FirebaseOptions ios = FirebaseOptions(
      apiKey: 'AIzaSyCHiuc-raES1oTd48eGRJat4JsFzPGpSO4',
      appId: '1:988490490890:ios:6c6d2adc54f52e5b5aebf3',
      messagingSenderId: '988490490890',
      projectId: 'pepperoni-nipples',
      storageBucket: 'pepperoni-nipples.appspot.com',
      iosClientId: '988490490890-66icivp5vijp0c50jr5tr1gkvhgajul5.apps.googleusercontent.com',
      iosBundleId: 'com.example.plantNerd',
      databaseURL: 'https://pepperoni-nipples-default-rtdb.europe-west1.firebasedatabase.app/');
}
