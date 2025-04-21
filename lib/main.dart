import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:photographers/config/firebase_options.dart';
import 'package:photographers/themes/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp());
}
