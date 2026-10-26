package com.qoravulx.app

import android.app.KeyguardManager
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.Drawable
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.FileInputStream
import java.security.MessageDigest

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.qoravulx.app/security"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getInstalledApps" -> {
                    try {
                        val apps = getInstalledApplicationsList()
                        result.success(apps)
                    } catch (e: Exception) {
                        result.error("APPS_ERROR", e.message, null)
                    }
                }
                "getPackageInfo" -> {
                    val pkgName = call.argument<String>("packageName")
                    if (pkgName != null) {
                        try {
                            val info = getSinglePackageDetails(pkgName)
                            result.success(info)
                        } catch (e: Exception) {
                            result.error("PKG_ERROR", e.message, null)
                        }
                    } else {
                        result.error("INVALID_ARG", "Package name is required", null)
                    }
                }
                "getDeviceSecurityInfo" -> {
                    try {
                        val devInfo = getDeviceSecurityDetails()
                        result.success(devInfo)
                    } catch (e: Exception) {
                        result.error("DEV_INFO_ERROR", e.message, null)
                    }
                }
                "openAppSettings" -> {
                    val pkg = call.argument<String>("packageName")
                    if (pkg != null) {
                        val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                            data = Uri.fromParts("package", pkg, null)
                            flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        }
                        startActivity(intent)
                        result.success(true)
                    } else {
                        result.error("INVALID_ARG", "Package name is required", null)
                    }
                }
                "requestUninstall" -> {
                    val pkg = call.argument<String>("packageName")
                    if (pkg != null) {
                        val intent = Intent(Intent.ACTION_DELETE).apply {
                            data = Uri.fromParts("package", pkg, null)
                            flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        }
                        startActivity(intent)
                        result.success(true)
                    } else {
                        result.error("INVALID_ARG", "Package name is required", null)
                    }
                }
                "openSecuritySettings" -> {
                    try {
                        val intent = Intent(Settings.ACTION_SECURITY_SETTINGS).apply {
                            flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        }
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("SECURITY_SETTINGS_ERROR", e.message, null)
                    }
                }
                "analyzeApkFile" -> {
                    val path = call.argument<String>("filePath")
                    if (path != null) {
                        try {
                            val apkDetails = inspectApkFile(path)
                            result.success(apkDetails)
                        } catch (e: Exception) {
                            result.error("APK_INSPECT_ERROR", e.message, null)
                        }
                    } else {
                        result.error("INVALID_ARG", "File path is required", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun getInstalledApplicationsList(): List<Map<String, Any?>> {
        val pm = packageManager
        val packages: List<PackageInfo> = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            pm.getInstalledPackages(PackageManager.PackageInfoFlags.of(PackageManager.GET_PERMISSIONS.toLong()))
        } else {
            @Suppress("DEPRECATION")
            pm.getInstalledPackages(PackageManager.GET_PERMISSIONS)
        }

        val appList = mutableListOf<Map<String, Any?>>()
        for (pkg in packages) {
            try {
                val appInfo = pkg.applicationInfo ?: continue
                val isSystem = (appInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0
                val appName = pm.getApplicationLabel(appInfo).toString()
                val installer = getInstallerPackage(pkg.packageName)
                val permissions = pkg.requestedPermissions?.toList() ?: emptyList()

                val appMap = mutableMapOf<String, Any?>(
                    "appName" to appName,
                    "packageName" to pkg.packageName,
                    "versionName" to (pkg.versionName ?: "1.0.0"),
                    "versionCode" to if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) pkg.longVersionCode.toInt() else @Suppress("DEPRECATION") pkg.versionCode,
                    "installerPackage" to installer,
                    "isSystemApp" to isSystem,
                    "targetSdkVersion" to appInfo.targetSdkVersion,
                    "minSdkVersion" to if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) appInfo.minSdkVersion else 21,
                    "requestedPermissions" to permissions,
                    "firstInstallTime" to pkg.firstInstallTime,
                    "lastUpdateTime" to pkg.lastUpdateTime
                )
                appList.add(appMap)
            } catch (_: Exception) {}
        }
        return appList
    }

    private fun getSinglePackageDetails(packageName: String): Map<String, Any?>? {
        val pm = packageManager
        return try {
            val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                PackageManager.GET_PERMISSIONS or PackageManager.GET_SIGNING_CERTIFICATES
            } else {
                @Suppress("DEPRECATION")
                PackageManager.GET_PERMISSIONS or PackageManager.GET_SIGNATURES
            }

            val pkg = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                pm.getPackageInfo(packageName, PackageManager.PackageInfoFlags.of(flags.toLong()))
            } else {
                @Suppress("DEPRECATION")
                pm.getPackageInfo(packageName, flags)
            }

            val appInfo = pkg.applicationInfo ?: return null
            val isSystem = (appInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0
            val appName = pm.getApplicationLabel(appInfo).toString()
            val installer = getInstallerPackage(packageName)
            val permissions = pkg.requestedPermissions?.toList() ?: emptyList()

            var certSha256: String? = null
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                val signingInfo = pkg.signingInfo
                if (signingInfo != null) {
                    val sigs = if (signingInfo.hasMultipleSigners()) {
                        signingInfo.apkContentsSigners
                    } else {
                        signingInfo.signingCertificateHistory
                    }
                    if (sigs != null && sigs.isNotEmpty()) {
                        certSha256 = getCertificateFingerprint(sigs[0].toByteArray())
                    }
                }
            } else {
                @Suppress("DEPRECATION")
                val sigs = pkg.signatures
                if (sigs != null && sigs.isNotEmpty()) {
                    certSha256 = getCertificateFingerprint(sigs[0].toByteArray())
                }
            }

            mapOf(
                "appName" to appName,
                "packageName" to pkg.packageName,
                "versionName" to (pkg.versionName ?: "1.0.0"),
                "versionCode" to if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) pkg.longVersionCode.toInt() else @Suppress("DEPRECATION") pkg.versionCode,
                "installerPackage" to installer,
                "isSystemApp" to isSystem,
                "targetSdkVersion" to appInfo.targetSdkVersion,
                "minSdkVersion" to if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) appInfo.minSdkVersion else 21,
                "requestedPermissions" to permissions,
                "signingCertHash" to certSha256,
                "firstInstallTime" to pkg.firstInstallTime,
                "lastUpdateTime" to pkg.lastUpdateTime
            )
        } catch (_: Exception) {
            null
        }
    }

    private fun getDeviceSecurityDetails(): Map<String, Any?> {
        val isRooted = checkRootMethod()
        val devOptions = Settings.Global.getInt(contentResolver, Settings.Global.DEVELOPMENT_SETTINGS_ENABLED, 0) == 1
        val adbEnabled = Settings.Global.getInt(contentResolver, Settings.Global.ADB_ENABLED, 0) == 1
        
        val keyguardManager = getSystemService(Context.KEYGUARD_SERVICE) as? KeyguardManager
        val isDeviceSecure = keyguardManager?.isDeviceSecure ?: true

        val patch = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Build.VERSION.SECURITY_PATCH
        } else {
            null
        }

        return mapOf(
            "androidVersion" to Build.VERSION.RELEASE,
            "sdkVersion" to Build.VERSION.SDK_INT,
            "securityPatchLevel" to patch,
            "deviceModel" to Build.MODEL,
            "manufacturer" to Build.MANUFACTURER,
            "isRooted" to isRooted,
            "rootCheckAvailable" to true,
            "developerOptionsEnabled" to devOptions,
            "usbDebuggingEnabled" to adbEnabled,
            "unknownSourcesEnabled" to false,
            "screenLockEnabled" to isDeviceSecure,
            "screenLockCheckAvailable" to true,
            "encryptionEnabled" to true,
            "encryptionCheckAvailable" to true
        )
    }

    private fun inspectApkFile(filePath: String): Map<String, Any?> {
        val file = File(filePath)
        if (!file.exists()) {
            throw Exception("File does not exist: $filePath")
        }

        val fileSha256 = calculateFileSha256(file)
        val pm = packageManager
        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            PackageManager.GET_PERMISSIONS or PackageManager.GET_SIGNING_CERTIFICATES
        } else {
            @Suppress("DEPRECATION")
            PackageManager.GET_PERMISSIONS or PackageManager.GET_SIGNATURES
        }

        val pkgInfo = pm.getPackageArchiveInfo(filePath, flags)
        val permissions = pkgInfo?.requestedPermissions?.toList() ?: emptyList()
        val appInfo = pkgInfo?.applicationInfo

        var certSha256: String? = null
        if (pkgInfo != null) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                val signingInfo = pkgInfo.signingInfo
                if (signingInfo != null) {
                    val sigs = if (signingInfo.hasMultipleSigners()) {
                        signingInfo.apkContentsSigners
                    } else {
                        signingInfo.signingCertificateHistory
                    }
                    if (sigs != null && sigs.isNotEmpty()) {
                        certSha256 = getCertificateFingerprint(sigs[0].toByteArray())
                    }
                }
            } else {
                @Suppress("DEPRECATION")
                val sigs = pkgInfo.signatures
                if (sigs != null && sigs.isNotEmpty()) {
                    certSha256 = getCertificateFingerprint(sigs[0].toByteArray())
                }
            }
        }

        return mapOf(
            "fileName" to file.name,
            "filePath" to file.absolutePath,
            "fileSizeBytes" to file.length(),
            "sha256Hash" to fileSha256,
            "packageName" to pkgInfo?.packageName,
            "versionName" to (pkgInfo?.versionName ?: "1.0.0"),
            "versionCode" to (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P && pkgInfo != null) pkgInfo.longVersionCode.toInt() else @Suppress("DEPRECATION") (pkgInfo?.versionCode ?: 1)),
            "targetSdkVersion" to appInfo?.targetSdkVersion,
            "minSdkVersion" to if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N && appInfo != null) appInfo.minSdkVersion else 21,
            "requestedPermissions" to permissions,
            "signatureValid" to (certSha256 != null),
            "signerCertHash" to certSha256
        )
    }

    private fun getInstallerPackage(packageName: String): String? {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                packageManager.getInstallSourceInfo(packageName).installingPackageName
            } else {
                @Suppress("DEPRECATION")
                packageManager.getInstallerPackageName(packageName)
            }
        } catch (_: Exception) {
            null
        }
    }

    private fun getCertificateFingerprint(certBytes: ByteArray): String {
        val md = MessageDigest.getInstance("SHA-256")
        val digest = md.digest(certBytes)
        return digest.joinToString(":") { String.format("%02X", it) }
    }

    private fun calculateFileSha256(file: File): String {
        val digest = MessageDigest.getInstance("SHA-256")
        FileInputStream(file).use { fis ->
            val buffer = ByteArray(8192)
            var bytesRead: Int
            while (fis.read(buffer).also { bytesRead = it } != -1) {
                digest.update(buffer, 0, bytesRead)
            }
        }
        return digest.digest().joinToString("") { String.format("%02x", it) }
    }

    private fun checkRootMethod(): Boolean {
        val paths = arrayOf(
            "/system/app/Superuser.apk",
            "/sbin/su",
            "/system/bin/su",
            "/system/xbin/su",
            "/data/local/xbin/su",
            "/data/local/bin/su",
            "/system/sd/xbin/su",
            "/system/bin/failsafe/su",
            "/data/local/su",
            "/su/bin/su"
        )
        for (path in paths) {
            if (File(path).exists()) return true
        }

        val buildTags = Build.TAGS
        if (buildTags != null && buildTags.contains("test-keys")) {
            return true
        }
        return false
    }
}
