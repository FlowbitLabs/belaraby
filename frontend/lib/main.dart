import 'package:belaraby/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load();
  
  final String supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  final String supabaseKey = dotenv.env['SUPABASE_Key'] ?? '';

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );
  
  runApp(const BelArabyApp());
}
