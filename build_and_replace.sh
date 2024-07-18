#!/bin/bash

# Définir les chemins
FLUTTER_DIR="client"
APK_BUILD_DIR="$FLUTTER_DIR/build/app/outputs/flutter-apk"
WEB_BUILD_DIR="$FLUTTER_DIR/build/web"
APK_DEST_DIR="~/FlashEvent/apk"
WEB_DEST_DIR="~/FlashEvent/web"

# Construire l'APK et le client web
echo "Building Flutter APK..."
cd $FLUTTER_DIR && flutter pub get && flutter build apk --release
if [ $? -ne 0 ]; then
  echo "Failed to build APK"
  exit 1
fi

echo "Building Flutter web..."
flutter build web
cp -r client/build/web/* web/

# Copier et remplacer les fichiers existants
echo "Copying APK to destination..."
cp -f $APK_BUILD_DIR/app-release.apk $APK_DEST_DIR/

echo "Copying web build to destination..."
rm -rf $WEB_DEST_DIR/*
cp -r $WEB_BUILD_DIR/* $WEB_DEST_DIR/

echo "Build and replace completed successfully."
