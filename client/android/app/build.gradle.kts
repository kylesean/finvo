plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

kotlin {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
    }
}

android {
    namespace = "com.finvo.app"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.finvo.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            // The env-var local names must NOT shadow the SigningConfig
            // properties (keyAlias/keyPassword), or `keyAlias = keyAlias`
            // would try to reassign the local val and fail to compile.
            //
            // NOTE: this block runs during Gradle CONFIGURATION for EVERY
            // variant (including `flutter run` -> assembleDebug), so it must
            // never throw here — the keystore check lives in the
            // `tasks.whenTaskAdded` guard below, which only fires for actual
            // release-variant tasks. Missing env vars yield a null storeFile,
            // which is only an error if a release task really runs.
            storeFile = System.getenv("ANDROID_KEYSTORE_PATH")?.let { file(it) }
            storePassword = System.getenv("ANDROID_KEYSTORE_PASSWORD")
            keyAlias = System.getenv("ANDROID_KEY_ALIAS")
            keyPassword = System.getenv("ANDROID_KEY_PASSWORD")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

// Refuse to build a RELEASE variant without the release keystore.
//
// Debug builds (`flutter run`, assembleDebug) are never affected: the guard
// only attaches to tasks whose name contains "Release". This is the
// "no debug-key fallback" safety net — debug keystores are public in the
// Flutter template, so signing a published APK with one would let anyone
// impersonate official releases.
// Refuse to build a RELEASE variant without the release keystore.
//
// Debug builds (`flutter run`, assembleDebug) are never affected: the check
// runs when the Gradle TASK GRAPH is ready, which only includes release
// tasks when a release variant is actually being built. This is the
// "no debug-key fallback" safety net — debug keystores are public in the
// Flutter template, so signing a published APK with one would let anyone
// impersonate official releases.
gradle.taskGraph.whenReady {
    if (allTasks.any { it.name.contains("Release") }) {
        val missing = listOf(
            "ANDROID_KEYSTORE_PATH" to System.getenv("ANDROID_KEYSTORE_PATH"),
            "ANDROID_KEYSTORE_PASSWORD" to System.getenv("ANDROID_KEYSTORE_PASSWORD"),
            "ANDROID_KEY_ALIAS" to System.getenv("ANDROID_KEY_ALIAS"),
            "ANDROID_KEY_PASSWORD" to System.getenv("ANDROID_KEY_PASSWORD"),
        ).filter { (_, value) -> value.isNullOrEmpty() }.map { it.first }

        if (missing.isNotEmpty()) {
            throw GradleException(
                "Release signing is not configured. Set " +
                    missing.joinToString(", ") +
                    " (via CI secrets or local environment) before building a release APK. " +
                    "Refusing to sign with the debug keystore: debug keys are public in the " +
                    "Flutter template and must never be used for published builds.",
            )
        }
    }
}

flutter {
    source = "../.."
}
