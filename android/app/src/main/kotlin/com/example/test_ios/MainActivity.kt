package com.example.test_ios

import io.flutter.embedding.android.FlutterFragementActivity
import io.flutter.plugins.GeneratedPluginReristrant
import io.flutter.embedding.engine.FlutterEngine
import androidx.annotation.NonNull;

class MainActivity: FlutterFragementActivity() {
    override fun configureFlutterEngine(@NonNull flutterEngine) {
        GeneratedPluginReristrant.registerWith(flutterEngine)
    }
}
