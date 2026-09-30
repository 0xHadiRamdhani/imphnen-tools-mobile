# IMPHNEN ONLINE TOOLS — Mobile

Flutter companion app for Android and iOS. It uses the IMPHNEN branding, pale
blue palette, tool categories, favorites, and recent tools from the web product.

## Run locally

From this directory:

```sh
flutter pub get
flutter run
```

Create an Android debug APK with `flutter build apk --debug`.

## Local processing

JSON formatting, JWT decoding, UUID and password generation, Base64, URL
encoding, SHA hashes, regex matching, text diff, timestamps, URL parsing, HTTP
status lookup, cron validation, basic SQL formatting, source minification,
Markdown text preview, and HEX color conversion run on the device.

JWT decoding only displays the header and payload; it never verifies a token's
signature. The basic source minifiers do not parse full language grammars.

Tools that require image/PDF codecs, multimedia processing, or AI providers are
identified in the UI. They are not presented as working processors until a
provider is integrated. Favorites, recent tools, theme, and language are stored
with local preferences.
