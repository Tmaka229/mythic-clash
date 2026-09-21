#!/usr/bin/env bash
set -e
mkdir -p www && cp index.html www/index.html
npm install
[ -d android ] || npx cap add android
MANIFEST=android/app/src/main/AndroidManifest.xml
grep -q screenOrientation $MANIFEST || \
  sed -i 's/<activity/<activity android:screenOrientation="sensorLandscape"/' $MANIFEST
npx cap sync android
(cd android && ./gradlew assembleDebug)
