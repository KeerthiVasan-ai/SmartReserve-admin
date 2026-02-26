pluginManagement {

    val flutterSdkPath: String by lazy {
        val properties = java.util.Properties()
        val localPropertiesFile = file("local.properties")

        require(localPropertiesFile.exists()) {
            "local.properties file not found. Please set flutter.sdk"
        }

        localPropertiesFile.inputStream().use {
            properties.load(it)
        }

        properties.getProperty("flutter.sdk")
                ?: error("flutter.sdk not set in local.properties")
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.9.1" apply false
    id("org.jetbrains.kotlin.android") version "2.2.21" apply false
    id("com.google.gms.google-services") version "4.4.0" apply false
    // id("com.google.firebase.crashlytics") version "2.9.9" apply false
}

include(":app")
