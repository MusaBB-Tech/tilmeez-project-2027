import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // superbase
  await Supabase.initialize(
    url: 'https://mzycwicsazfcgqezvvuu.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im16eWN3aWNzYXpmY2dxZXp2dnV1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTQ0MDIyMjgsImV4cCI6MjEwOTk3ODIyOH0.Z9EO-JwzHFFg4991aOa3kv4kxGosyCE1Eyn6Thz5_2U',
  );

  runApp(const App());
}
