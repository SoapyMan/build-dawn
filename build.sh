#!/bin/bash

# Clone dawn

if [ ! -d "dawn" ]; then
  git clone --depth=1 --no-tags --single-branch --branch all-fixes-merged https://github.com/SoapyMan/dawn.git
else
  cd dawn
  git restore src/dawn/native/CMakeLists.txt
  git pull --force --no-tags
  cd ..
fi

cmake                                         \
  -S dawn                                     \
  -B dawn.build                               \
  -D CMAKE_BUILD_TYPE=Release                 \
  -D CMAKE_POLICY_DEFAULT_CMP0091=NEW         \
  -D CMAKE_POLICY_DEFAULT_CMP0092=NEW         \
  -D CMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded \
  -D ABSL_MSVC_STATIC_RUNTIME=ON              \
  -D DAWN_BUILD_SAMPLES=OFF                   \
  -D DAWN_BUILD_TESTS=OFF                     \
  -D DAWN_ENABLE_VULKAN=ON                    \
  -D DAWN_ENABLE_D3D12=OFF                    \
  -D DAWN_ENABLE_D3D11=OFF                    \
  -D DAWN_ENABLE_NULL=OFF                     \
  -D DAWN_ENABLE_DESKTOP_GL=OFF               \
  -D DAWN_ENABLE_OPENGLES=OFF                 \
  -D DAWN_USE_GLFW=OFF                        \
  -D DAWN_ENABLE_SPIRV_VALIDATION=OFF         \
  -D DAWN_DXC_ENABLE_ASSERTS_IN_NDEBUG=OFF    \
  -D DAWN_FETCH_DEPENDENCIES=ON               \
  -D DAWN_BUILD_MONOLITHIC_LIBRARY=ON         \
  -D TINT_BUILD_SAMPLES=OFF                   \
  -D TINT_BUILD_DOCS=OFF                      \
  -D TINT_BUILD_TESTS=OFF                     \
  -D TINT_BUILD_GLSL_VALIDATOR=OFF            \
  -D TINT_BUILD_GLSL_WRITER=OFF               \
  -D TINT_BUILD_SPV_READER=ON                 \
  -D TINT_BUILD_SPV_WRITER=ON                 \
  -D ENABLE_HLSL=OFF

# NOTE: webgpu target is in extra.cmake
cmake --build dawn.build --config Release --target webgpu_dawn --parallel 4

cp dawn.build/gen/include/dawn/webgpu.h .
cp dawn.build/src/dawn/native/libwebgpu_dawn.so .

if [ -n "$GITHUB_WORKFLOW" ]; then

  DAWN_COMMIT=$(<dawn/.git/refs/heads/main)
  echo "$DAWN_COMMIT" > dawn_commit.txt

  LDATE=$(date +"%Y%m%d%H%M%S")
  BUILD_DATE="${LDATE:0:4}-${LDATE:4:2}-${LDATE:6:2}"

  tar -czvf webgpu-"$BUILD_DATE".zip libwebgpu_dawn.so webgpu.h dawn_commit.txt

  echo "DAWN_COMMIT=$DAWN_COMMIT" >> $GITHUB_ENV
  echo "BUILD_DATE=$BUILD_DATE" >> $GITHUB_ENV

fi
