import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "marcotty.apps.flutter_memo_cards"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "marcotty.apps.flutter_memo_cards"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    val keystoreProperties = Properties()
    val keystorePropertiesFile = project.rootProject.file("key.properties")
    if (keystorePropertiesFile.exists()) {
        keystoreProperties.load(FileInputStream(keystorePropertiesFile))
    }
    // 2. Define your signing configurations
    signingConfigs {
        create("release") {
            // Specifies the path to your keystore file.
            // It's recommended to place your .jks file inside the 'android' directory
            // or provide a full absolute path.
            storeFile = project.file(keystoreProperties.getProperty("storeFile") ?: "")
            // Specifies the password for your keystore.
            storePassword = keystoreProperties.getProperty("storePassword")
            // Specifies the identifying name for your key.
            keyAlias = keystoreProperties.getProperty("keyAlias")
            // Specifies the password for your key.
            keyPassword = keystoreProperties.getProperty("keyPassword")
        }
    }

    buildTypes {
        release {
            // Add the "release" signing configuration to the release build type.
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true // Typically enabled for release builds
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            // ... other release build type configurations            
            // Signing with the debug keys for now, so `flutter run --release` works.
            //signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
