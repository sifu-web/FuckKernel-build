#!/data/data/com.termux/files/usr/bin/bash
# FINAL — চালাও এভাবে: bash final_build.sh
# অবশ্যই এই পাথ থেকে চালাবে: ~/FuckKernel/FuckKernel/jni
set -e

EGL_BASE="https://raw.githubusercontent.com/KhronosGroup/EGL-Registry/main/api"
GL_BASE="https://raw.githubusercontent.com/KhronosGroup/OpenGL-Registry/main/api"
DEST="include/khronos"

echo "====================================="
echo " ধাপ ১: হেডার ডাউনলোড"
echo "====================================="
mkdir -p "$DEST/EGL" "$DEST/GLES" "$DEST/GLES2" "$DEST/GLES3" "$DEST/KHR"

fetch() {
  url="$1"; out="$2"
  if [ -s "$out" ]; then
    echo " [skip, exists] $out"
    return
  fi
  echo " -> $out"
  wget -q -O "$out" "$url" || echo "    FAILED: $url"
  [ -s "$out" ] || echo "    EMPTY/404: $url"
}

fetch "$EGL_BASE/EGL/egl.h"          "$DEST/EGL/egl.h"
fetch "$EGL_BASE/EGL/eglext.h"       "$DEST/EGL/eglext.h"
fetch "$EGL_BASE/EGL/eglplatform.h"  "$DEST/EGL/eglplatform.h"
fetch "$EGL_BASE/KHR/khrplatform.h"  "$DEST/KHR/khrplatform.h"
fetch "$GL_BASE/GLES/gl.h"           "$DEST/GLES/gl.h"
fetch "$GL_BASE/GLES/glext.h"        "$DEST/GLES/glext.h"
fetch "$GL_BASE/GLES/glplatform.h"   "$DEST/GLES/glplatform.h"
fetch "$GL_BASE/GLES2/gl2.h"         "$DEST/GLES2/gl2.h"
fetch "$GL_BASE/GLES2/gl2ext.h"      "$DEST/GLES2/gl2ext.h"
fetch "$GL_BASE/GLES2/gl2platform.h" "$DEST/GLES2/gl2platform.h"
fetch "$GL_BASE/GLES3/gl3.h"         "$DEST/GLES3/gl3.h"
fetch "$GL_BASE/GLES3/gl31.h"        "$DEST/GLES3/gl31.h"
fetch "$GL_BASE/GLES3/gl32.h"        "$DEST/GLES3/gl32.h"
fetch "$GL_BASE/GLES3/gl3platform.h" "$DEST/GLES3/gl3platform.h"

echo ""
echo "====================================="
echo " ধাপ ২: কম্পাইল"
echo "====================================="

ARCH=arm64-v8a
OUT=../out
mkdir -p "$OUT" obj

CXX="clang++"

INCLUDES="-I. -Isrc -Iinclude -Iinclude/Android_vulkan -Iinclude/ImGui -Iinclude/ImGui/backends \
-Iinclude/khronos \
-Iinclude/external/curl-android-$ARCH/include \
-Iinclude/external/openssl-android-$ARCH/include \
-Iinclude/external/nlohmann"

CXXFLAGS="-std=c++17 -fvisibility=hidden -DVK_USE_PLATFORM_ANDROID_KHR \
-w -Wno-error=format-security -Wno-error=c++11-narrowing -fpermissive -fexceptions \
-DUSE_OPENGL -O2 $INCLUDES"

SRCS="
src/main.cpp
src/Android_draw/draw.cpp
src/Android_touch/TouchHelperA.cpp
src/ImGui/imgui.cpp
src/ImGui/imgui_demo.cpp
src/ImGui/imgui_draw.cpp
src/ImGui/imgui_tables.cpp
src/ImGui/imgui_widgets.cpp
src/ImGui/backends/imgui_impl_android.cpp
src/ImGui/backends/imgui_impl_opengl3.cpp
src/ENC/oxorany.cpp
"

OBJS=""
for f in $SRCS; do
  obj="obj/$(basename "$f").o"
  echo " -> কম্পাইল: $f"
  $CXX $CXXFLAGS -c "$f" -o "$obj"
  OBJS="$OBJS $obj"
done

echo ""
echo "====================================="
echo " ধাপ ৩: লিংক"
echo "====================================="
$CXX $CXXFLAGS $OBJS \
  include/external/curl-android-$ARCH/lib/libcurl.a \
  include/external/openssl-android-$ARCH/lib/libssl.a \
  include/external/openssl-android-$ARCH/lib/libcrypto.a \
  -llog -landroid -lEGL -lGLESv3 -lz \
  -o "$OUT/stranger.sh"

echo ""
echo "✅✅✅ বিল্ড সফল: $OUT/stranger.sh"
ls -la "$OUT/stranger.sh"
