# google_mlkit_text_recognition solo se usa con TextRecognitionScript.latin, pero el plugin
# referencia en su código los reconocedores de otros scripts (chino/japonés/coreano/devanagari)
# como dependencias opcionales que no se incluyen; sin esto R8 falla al no encontrar esas clases.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
-dontwarn com.google.mlkit.vision.text.devanagari.**

# ML Kit y Play Services localizan varias de sus clases internas por reflexión (nombre exacto de
# clase). Si R8 las renombra/recorta, esa búsqueda falla en tiempo de ejecución y provoca un
# NullPointerException al escanear ("Attempt to invoke virtual method ... on a null object
# reference"), aunque compile sin errores. Hay que mantenerlas intactas.
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.mlkit.**
-dontwarn com.google.android.gms.**
