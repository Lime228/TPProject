# ZadachOk App (Frontend)

Это фронтенд Flutter-приложения **ZadachOk**. Ниже приведена инструкция по первичному запуску проекта.

## 🚀 Как запустить проект

1. **Откройте папку `frontend` в Android Studio.**

2. **Запустите Android эмулятор.**  
   Убедитесь, что устройство доступно в Android Studio.

3. **Попробуйте запустить проект (Run > Run 'main.dart').**  
   При первом запуске может появиться сообщение о необходимости создать структуру Flutter-проекта.

4. **Откройте терминал и выполните:**

   ```bash
   flutter create .
   ```

   Эта команда создаст необходимые системные папки, такие как `.idea`, `android/`, `ios/` и другие.

5. **Настройте файл `android/app/build.gradle.kts`.**  
   Замените его содержимое следующим кодом:

   ```kotlin
   plugins {
       id("com.android.application")
       id("kotlin-android")
       id("dev.flutter.flutter-gradle-plugin")
   }

   dependencies {
       coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
       implementation("androidx.window:window:1.2.0")
       implementation("androidx.window:window-java:1.2.0")
       implementation("androidx.core:core-ktx:1.12.0")
   }

   android {
       namespace = "com.example.zadachok"
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
           applicationId = "com.example.zadachok"
           minSdk = flutter.minSdkVersion
           targetSdk = flutter.targetSdkVersion
           versionCode = flutter.versionCode
           versionName = flutter.versionName
       }

       buildTypes {
           release {
               signingConfig = signingConfigs.getByName("debug")
           }
       }
   }

   buildscript {
       repositories {
           google()
           mavenCentral()
       }
   }

   allprojects {
       repositories {
           google()
           mavenCentral()
       }
   }

   flutter {
       source = "../.."
   }
   ```

6. **Добавьте разрешения и структуру в файл `android/app/src/main/AndroidManifest.xml`:**

   ```xml
   <manifest xmlns:android="http://schemas.android.com/apk/res/android">
       <uses-permission android:name="android.permission.INTERNET"/>
       <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
       <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
       <uses-permission android:name="android.permission.VIBRATE"/>
       <uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT"/>

       <application android:label="ZadachOk" android:name="${applicationName}" android:icon="@mipmap/ic_launcher">
           <activity
               android:name=".MainActivity"
               android:exported="true"
               android:launchMode="singleTop"
               android:taskAffinity=""
               android:theme="@style/LaunchTheme"
               android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
               android:hardwareAccelerated="true"
               android:windowSoftInputMode="adjustResize">
               <meta-data android:name="io.flutter.embedding.android.NormalTheme" android:resource="@style/NormalTheme"/>
               <intent-filter>
                   <action android:name="android.intent.action.MAIN"/>
                   <category android:name="android.intent.category.LAUNCHER"/>
               </intent-filter>
           </activity>
           <meta-data android:name="flutterEmbedding" android:value="2"/>
       </application>

       <queries>
           <intent>
               <action android:name="android.intent.action.PROCESS_TEXT"/>
               <data android:mimeType="text/plain"/>
           </intent>
           <intent>
               <action android:name="android.intent.action.VIEW"/>
               <category android:name="android.intent.category.BROWSABLE"/>
               <data android:scheme="https"/>
           </intent>
           <intent>
               <action android:name="android.intent.action.VIEW"/>
               <category android:name="android.intent.category.BROWSABLE"/>
               <data android:scheme="http"/>
           </intent>
       </queries>
   </manifest>
   ```

7. **Добавьте разрешения в файл `android/app/src/debug/AndroidManifest.xml`:**

   ```xml
   <manifest xmlns:android="http://schemas.android.com/apk/res/android">
       <uses-permission android:name="android.permission.INTERNET"/>
       <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
       <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
       <uses-permission android:name="android.permission.VIBRATE"/>
       <uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT"/>
   </manifest>
   ```

8. **Подтяните зависимости.**  
   Откройте файл `pubspec.yaml` и нажмите `Pub get` (или выполните в терминале):

   ```bash
   flutter pub get
   ```

9. **Повторно запустите проект.**

---

Если возникнут ошибки при сборке или запуске, убедитесь, что у вас установлены все зависимости Flutter и Android SDK, а также актуальная версия NDK (`27.0.12077973`).