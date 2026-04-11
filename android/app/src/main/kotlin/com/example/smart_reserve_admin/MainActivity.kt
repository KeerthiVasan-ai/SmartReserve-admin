package com.example.smart_reserve_admin

import android.content.Intent
import android.os.Bundle
import com.google.android.play.core.appupdate.AppUpdateManager
import com.google.android.play.core.appupdate.AppUpdateManagerFactory
import com.google.android.play.core.install.model.AppUpdateType
import com.google.android.play.core.install.model.UpdateAvailability
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "smart_reserve_admin/in_app_update"
    private lateinit var appUpdateManager: AppUpdateManager
    private val REQUEST_CODE_UPDATE = 1729
    private var pendingResult: MethodChannel.Result? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        appUpdateManager = AppUpdateManagerFactory.create(this)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "checkForUpdate") {
                pendingResult = result
                checkAndTriggerUpdate()
            } else {
                result.notImplemented()
            }
        }
    }

    private fun checkAndTriggerUpdate() {
        val appUpdateInfoTask = appUpdateManager.appUpdateInfo

        appUpdateInfoTask.addOnSuccessListener { appUpdateInfo ->
            if (appUpdateInfo.updateAvailability() == UpdateAvailability.UPDATE_AVAILABLE
                && appUpdateInfo.isUpdateTypeAllowed(AppUpdateType.IMMEDIATE)
            ) {
                // Request the update
                appUpdateManager.startUpdateFlowForResult(
                    appUpdateInfo,
                    AppUpdateType.IMMEDIATE,
                    this,
                    REQUEST_CODE_UPDATE
                )
            } else {
                pendingResult?.success("No update available or immediate update not allowed")
                pendingResult = null
            }
        }

        appUpdateInfoTask.addOnFailureListener { e ->
            pendingResult?.error("UPDATE_ERROR", e.message, null)
            pendingResult = null
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_CODE_UPDATE) {
            when (resultCode) {
                RESULT_OK -> {
                    pendingResult?.success("Update Successful")
                }
                RESULT_CANCELED -> {
                    pendingResult?.error("UPDATE_CANCELED", "User canceled update", null)
                }
                else -> {
                    pendingResult?.error("UPDATE_FAILED", "Update failed with code: $resultCode", null)
                }
            }
            pendingResult = null
        }
    }

    override fun onResume() {
        super.onResume()
        // Resume immediate update if one was in progress
        appUpdateManager.appUpdateInfo.addOnSuccessListener { appUpdateInfo ->
            if (appUpdateInfo.updateAvailability() == UpdateAvailability.DEVELOPER_TRIGGERED_UPDATE_IN_PROGRESS) {
                appUpdateManager.startUpdateFlowForResult(
                    appUpdateInfo,
                    AppUpdateType.IMMEDIATE,
                    this,
                    REQUEST_CODE_UPDATE
                )
            }
        }
    }
}
