#!/usr/bin/env bash
set -e
mkdir -p www && cp index.html www/index.html
npm install
[ -d android ] || npx cap add android

# --- app icon ---
RES=android/app/src/main/res
for spec in mdpi:48:108 hdpi:72:162 xhdpi:96:216 xxhdpi:144:324 xxxhdpi:192:432; do
  IFS=: read name legacy fg <<< "$spec"
  mkdir -p $RES/mipmap-$name
  convert icon.png -resize ${legacy}x${legacy} $RES/mipmap-$name/ic_launcher.png
  convert icon.png -resize ${legacy}x${legacy} $RES/mipmap-$name/ic_launcher_round.png
  inner=$(( fg * 74 / 100 ))
  convert -size ${fg}x${fg} xc:none \( icon.png -resize ${inner}x${inner} \) -gravity center -composite $RES/mipmap-$name/ic_launcher_foreground.png
done
mkdir -p $RES/values
cat > $RES/values/ic_launcher_background.xml <<'XML'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="ic_launcher_background">#05050F</color>
</resources>
XML
# --- end icon ---

MANIFEST=android/app/src/main/AndroidManifest.xml
grep -q screenOrientation $MANIFEST || \
  sed -i 's/<activity/<activity android:screenOrientation="sensorLandscape"/' $MANIFEST
npx cap sync android
(cd android && ./gradlew assembleDebug)
