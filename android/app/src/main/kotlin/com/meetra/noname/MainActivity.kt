package com.meetra.noname

import com.meetra.noname.channel.OverlayChannelHandler
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {

    private var overlayChannelHandler:
        OverlayChannelHandler? = null

    override fun configureFlutterEngine(
        flutterEngine: FlutterEngine
    ) {
        super.configureFlutterEngine(
            flutterEngine
        )

        overlayChannelHandler =
            OverlayChannelHandler(
                activity = this,
                messenger =
                    flutterEngine
                        .dartExecutor
                        .binaryMessenger
            )

        overlayChannelHandler?.register()
    }

    override fun cleanUpFlutterEngine(
        flutterEngine: FlutterEngine
    ) {
        overlayChannelHandler?.dispose()
        overlayChannelHandler = null

        super.cleanUpFlutterEngine(
            flutterEngine
        )
    }
}