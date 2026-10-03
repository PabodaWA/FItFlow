# R8 rules for the Flutter Android embedding. Dart code is obfuscated separately
# with `flutter build --obfuscate`.

-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
