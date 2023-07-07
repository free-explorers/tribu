package com.tribu.mobile

import io.flutter.embedding.android.FlutterActivity
import android.util.Log
import android.os.Bundle

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d("TAG", "message")
    }
}
