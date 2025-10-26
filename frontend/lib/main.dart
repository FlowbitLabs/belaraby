import 'package:belaraby/app/app.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://hmgwrovvqeezkyfiqula.supabase.co',
    anonKey: 'sb_publishable_CCl-SQTxVV2Soi0cYDSpkg_nSQHlhuw',
  );

  runApp(const BelArabyApp());
}
