package com.vn2.phim

import android.content.Intent
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import android.os.Bundle
import android.view.WindowManager
import android.app.Activity
import fl.pip.FlPiPActivity


class MainActivity : FlPiPActivity() {

    private val channel = "webviewChannel"
    private val method = "webview"
    private val pipChannel = "pip_channel"

    private val code = 100


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor, channel).setMethodCallHandler { call, result ->
            if (call.method == method) {
                val url: String = call.argument("url")!!
                val username: String = call.argument("username")!!
                val password: String = call.argument("password")!!
                val isLoggedIn: Boolean = call.argument("isLoggedIn")!!

                Log.d("url", call.arguments.toString())

                val intent = Intent(this, WebViewActivity::class.java)
                intent.putExtra("url", url)
                intent.putExtra("username", username)
                intent.putExtra("password", password)
                intent.putExtra("isLoggedIn", isLoggedIn)

                this.startActivity(intent)

                result.success("")
            } else {
                result.notImplemented()
            }
        }

         MethodChannel(flutterEngine.dartExecutor, pipChannel).setMethodCallHandler { call, result ->
            if (call.method == "enterPiP") {
                if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                    val aspectRatio = android.util.Rational(16, 9)
                    val params = android.app.PictureInPictureParams.Builder()
                        .setAspectRatio(aspectRatio)
                        .build()
                    enterPictureInPictureMode(params)
                    result.success(true)
                } else {
                    result.success(false)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (resultCode == Activity.RESULT_OK && requestCode == code) {
            //
        }
    }
}
