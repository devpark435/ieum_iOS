#!/bin/sh
set -e

CONFIGS_DIR="$CI_PRIMARY_REPOSITORY_PATH/Configs"
mkdir -p "$CONFIGS_DIR"

# SLASH trick: xcconfig treats // as comment, so split https://
cat > "$CONFIGS_DIR/Debug.xcconfig" <<EOF
KAKAO_APP_KEY = $KAKAO_APP_KEY
BASE_URL = https:\$(SLASH)/$BASE_URL_HOST/
SLASH = /
EOF

cp "$CONFIGS_DIR/Debug.xcconfig" "$CONFIGS_DIR/Release.xcconfig"

echo "✅ xcconfig generated"
