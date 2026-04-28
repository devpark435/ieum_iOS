#!/bin/sh
set -e

REPO="$CI_PRIMARY_REPOSITORY_PATH"
mkdir -p "$REPO/Configs"

# SLASH trick: xcconfig treats // as comment, so split https://
cat > "$REPO/Debug.xcconfig" <<EOF
KAKAO_APP_KEY = $KAKAO_APP_KEY
BASE_URL = https:\$(SLASH)/$BASE_URL_HOST/
SLASH = /
EOF

cp "$REPO/Debug.xcconfig" "$REPO/Release.xcconfig"
cp "$REPO/Debug.xcconfig" "$REPO/Configs/Debug.xcconfig"
cp "$REPO/Debug.xcconfig" "$REPO/Configs/Release.xcconfig"

echo "✅ xcconfig generated"
