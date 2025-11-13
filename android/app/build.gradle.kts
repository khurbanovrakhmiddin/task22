plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.tak22_audio"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"




    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.tak22_audio"
        minSdk = 21
        targetSdk = 36
        versionCode = 1
        versionName = "1.0.1"
        ndkVersion = "27.0.12077973"
        multiDexEnabled = true


        ndk {
            abiFilters.addAll(listOf("armeabi-v7a", "arm64-v8a"))
        }
    }
    packaging {
        jniLibs {
            useLegacyPackaging = false
        }
    }
    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}
dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib:2.1.0")

    // Core library desugaring для flutter_local_notifications
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
flutter {
    source = "../.."
}
