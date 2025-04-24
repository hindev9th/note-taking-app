#!/bin/bash

# === THÔNG TIN APP ===
APP_NAME="notetake"
VERSION="1.0.0"
MAINTAINER="Your Name <hindev9th@gmail.com>"
ICON_PATH="./notetake.png"  # Icon PNG 128x128
EXECUTABLE_NAME="note"      # Tên file chạy chính

# === THƯ MỤC LÀM VIỆC ===
BUILD_DIR="notetake_deb"
APP_DIR="$BUILD_DIR/usr/local/bin/$APP_NAME"
ICON_DST="$BUILD_DIR/usr/share/icons/hicolor/128x128/apps"
DESKTOP_DST="$BUILD_DIR/usr/share/applications"
DEBIAN_DIR="$BUILD_DIR/DEBIAN"

# === DỌN DẸP VÀ TẠO THƯ MỤC ===
rm -rf $BUILD_DIR
mkdir -p "$APP_DIR" "$ICON_DST" "$DESKTOP_DST" "$DEBIAN_DIR"

# === COPY BUILD FLUTTER ===
cp -r build/linux/x64/release/bundle/* "$APP_DIR/"
chmod +x "$APP_DIR/$EXECUTABLE_NAME"

# === COPY ICON ===
cp "$ICON_PATH" "$ICON_DST/$APP_NAME.png"

# === TẠO FILE .desktop ===
cat <<EOF > "$DESKTOP_DST/${APP_NAME}.desktop"
[Desktop Entry]
Name=NoteTake
Comment=A simple note-taking app
Exec=/usr/local/bin/$APP_NAME/$EXECUTABLE_NAME
Icon=$APP_NAME
Terminal=false
Type=Application
Categories=Utility;GTK;
StartupWMClass=com.example.note
EOF

# === TẠO FILE control ===
cat <<EOF > "$DEBIAN_DIR/control"
Package: $APP_NAME
Version: $VERSION
Section: utils
Priority: optional
Architecture: amd64
Depends: libgtk-3-0
Maintainer: $MAINTAINER
Description: A simple note-taking app
 A local-only Flutter-based note-taking app with text and drawing support.
EOF

# === ĐÓNG GÓI ===
dpkg-deb --build "$BUILD_DIR"

echo ""
echo "✅ DONE! File .deb đã được tạo: ${BUILD_DIR}.deb"

