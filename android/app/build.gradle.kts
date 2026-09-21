import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Llaves de firma del equipo.
//
// Android solo deja instalar una APK encima de otra si **las dos están
// firmadas con la misma llave**. Con las llaves de depuración eso no se
// cumple: cada computador tiene la suya, así que la APK que compila uno no se
// puede instalar encima de la que compiló otro —hay que desinstalar, y al
// desinstalar se pierden los datos del productor—.
//
// El archivo `android/key.properties` **no está en el repositorio** (ver
// .gitignore). Cada quien lo copia junto con el `.jks` que comparta el equipo.
// Si no existe, se firma con las de depuración y todo sigue funcionando para
// desarrollar; lo que no sirve es para repartir.
val propiedadesDeFirma = Properties()
val archivoDeFirma = rootProject.file("key.properties")
val hayLlavePropia = archivoDeFirma.exists()
if (hayLlavePropia) {
    archivoDeFirma.inputStream().use { propiedadesDeFirma.load(it) }
}

android {
    namespace = "com.redcacao.cacao_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.redcacao.cacao_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Sale de `version:` en pubspec.yaml. El número de después del `+` es
        // el versionCode, y **tiene que subir en cada APK que repartan**:
        // Android se niega a instalar encima una versión igual o menor.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hayLlavePropia) {
            create("equipo") {
                keyAlias = propiedadesDeFirma.getProperty("keyAlias")
                keyPassword = propiedadesDeFirma.getProperty("keyPassword")
                storeFile = propiedadesDeFirma.getProperty("storeFile")?.let { file(it) }
                storePassword = propiedadesDeFirma.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hayLlavePropia) {
                signingConfigs.getByName("equipo")
            } else {
                // Sirve para probar en el propio computador, no para repartir.
                signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
