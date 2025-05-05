
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

5. **Откройте файл `android/app/build.gradle.kts`.**  
   Найдите блок `android { ... }` и убедитесь, что он содержит следующий код:

   ```kotlin
   android {
       namespace = "com.example.zadachok"
       compileSdk = flutter.compileSdkVersion
       ndkVersion = "27.0.12077973"

       compileOptions {
           sourceCompatibility = JavaVersion.VERSION_11
           targetCompatibility = JavaVersion.VERSION_11
       }

       kotlinOptions {
           jvmTarget = JavaVersion.VERSION_11.toString()
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
   ```

   📌 Если значение `ndkVersion` указано другое — замените его на:

   ```kotlin
   ndkVersion = "27.0.12077973"
   ```

6. **Подтяните зависимости.**  
   Откройте файл `pubspec.yaml` и нажмите `Pub get` (или выполните в терминале):

   ```bash
   flutter pub get
   ```

   Это установит все необходимые зависимости для проекта.


---

7. **Повторно запустите проект.**

## 🔐 Тестовые данные для входа

- **Логин:** `admin`  
- **Пароль:** `admin`

---

Если возникнут ошибки при сборке или запуске, убедитесь, что у вас установлены все зависимости Flutter и Android SDK, а также актуальная версия NDK.
