
# https://developer.apple.com/forums/thread/666335

COMMAND_LINE_TOOLS_PATH="$(xcode-select -p)"
TEMP="xcframework"
HEADERS="headers"
LIB_NAME="libpjproject.a"
XCFRAMEWORK="libpjproject.xcframework"
SIM_ARM64="ios-arm64-simulator"
SIM_X86_64="ios-x86_64-simulator"
SIM_ARM64_X86_64="ios-arm64_x86_64-simulator"
IOS_ARM64="ios-arm64"
# MACOS_ARM64="macos-arm64"
# MACOS_X86_64="macos-x86_64"
# MACOS_ARM64_X86_64="macos-arm64_x86_64"

# Create folders
rm -rf "$TEMP"
mkdir -p "$TEMP/$HEADERS"
mkdir -p "$TEMP/$SIM_ARM64"
mkdir -p "$TEMP/$SIM_X86_64"
mkdir -p "$TEMP/$SIM_ARM64_X86_64"
mkdir -p "$TEMP/$IOS_ARM64"
# mkdir -p "$TEMP/$MACOS_ARM64"
# mkdir -p "$TEMP/$MACOS_X86_64"
# mkdir -p "$TEMP/$MACOS_ARM64_X86_64"

# Functions

clean () {
	find . -not -path "./pjsip-apps/*" -not -path "./$TEMP/*" -name "*.a" -exec rm {} \;
}

compile () {
	./configure-iphone --enable-video=no
	make dep && make clean && make
}

create_lib () {
	libtool -static -o "$LIB_NAME" `find . -not -path "./pjsip-apps/*" -not -path "./$TEMP/*" -name "*.a"`
}

# SIMULATOR

# Simulator arm64
clean
export IPHONESDK="$COMMAND_LINE_TOOLS_PATH/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk"
export DEVPATH="$COMMAND_LINE_TOOLS_PATH/Platforms/iPhoneSimulator.platform/Developer"
export ARCH="-arch arm64"
export MIN_IOS="-mios-simulator-version-min=13"
compile
create_lib
mv "$LIB_NAME" "$TEMP/$SIM_ARM64"

# Simulator x86_64
clean
export IPHONESDK="$COMMAND_LINE_TOOLS_PATH/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk"
export DEVPATH="$COMMAND_LINE_TOOLS_PATH/Platforms/iPhoneSimulator.platform/Developer"
export ARCH="-arch x86_64"
export MIN_IOS="-mios-simulator-version-min=13"
compile
create_lib
mv "$LIB_NAME" "$TEMP/$SIM_X86_64"

# Create Simulators lipo
lipo -create "$TEMP/$SIM_ARM64/$LIB_NAME" "$TEMP/$SIM_X86_64/$LIB_NAME" -output "$TEMP/$SIM_ARM64_X86_64/$LIB_NAME"


# # MACOSX

# # macOS arm64
# clean
# export IPHONESDK="$COMMAND_LINE_TOOLS_PATH/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk"
# export DEVPATH="$COMMAND_LINE_TOOLS_PATH/Platforms/MacOSX.platform/Developer"
# export ARCH="-arch arm64"
# # export MIN_IOS="-mios-simulator-version-min=13"
# compile
# create_lib
# mv "$LIB_NAME" "$TEMP/$MACOS_ARM64"

# # macOS x86_64
# clean
# export IPHONESDK="$COMMAND_LINE_TOOLS_PATH/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk"
# export DEVPATH="$COMMAND_LINE_TOOLS_PATH/Platforms/MacOSX.platform/Developer"
# export ARCH="-arch x86_64"
# # export MIN_IOS="-mios-simulator-version-min=13"
# compile
# create_lib
# mv "$LIB_NAME" "$TEMP/$MACOS_X86_64"

# # Create Simulators lipo
# lipo -create "$TEMP/$MACOS_ARM64/$LIB_NAME" "$TEMP/$MACOS_X86_64/$LIB_NAME" -output "$TEMP/$MACOS_ARM64_X86_64/$LIB_NAME"


# IPHONE

# iOS arm64
clean
export IPHONESDK="$COMMAND_LINE_TOOLS_PATH/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk"
export DEVPATH="$COMMAND_LINE_TOOLS_PATH/Platforms/iPhoneOS.platform/Developer"
export ARCH="-arch arm64"
export MIN_IOS="-miphoneos-version-min=13"
compile
create_lib
mv "$LIB_NAME" "$TEMP/$IOS_ARM64"

# Headers
LIBS="pjlib pjlib-util pjmedia pjnath pjsip" # third_party"
OUT_HEADERS="$TEMP/$HEADERS"
for path in $LIBS; do
	mkdir -p $OUT_HEADERS/$path
	cp -a $path/include/* $OUT_HEADERS/$path
done

# XCFramework
rm -rf $XCFRAMEWORK
xcodebuild -create-xcframework \
-library "$TEMP/$SIM_ARM64_X86_64/$LIB_NAME" \
-headers "$TEMP/$HEADERS" \
-library "$TEMP/$IOS_ARM64/$LIB_NAME" \
-headers "$TEMP/$HEADERS" \
-output $XCFRAMEWORK


# -library "$TEMP/$MACOS_ARM64_X86_64/$LIB_NAME" \
# -headers "$TEMP/$HEADERS" \

# ZIP
zip -r "$XCFRAMEWORK.zip" $XCFRAMEWORK

# Checksum
swift package compute-checksum "$XCFRAMEWORK.zip"
