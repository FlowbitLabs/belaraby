import 'package:belaraby/app/app.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://klxgaocpasaiqkpembxy.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtseGdhb2NwYXNhaXFrcGVtYnh5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDYyMjgwNzYsImV4cCI6MjA2MTgwNDA3Nn0.92F3zNVKmp-m5PQjXjhuc1UfQIjz36BVgfz7QOBQ25o',
  );

  runApp(const BelArabyApp());
}
