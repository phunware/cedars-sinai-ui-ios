#!/bin/bash --login

# ****
# **** UTILITY ****
# ****

export LANG="en_US.UTF-8"
export LC_COLLATE="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
export LC_MESSAGES="en_US.UTF-8"
export LC_MONETARY="en_US.UTF-8"
export LC_NUMERIC="en_US.UTF-8"
export LC_TIME="en_US.UTF-8"

# Build Params

export WORKSPACE="cedars-sinai.xcworkspace"
export SCHEME="CedarsSinai"
export CURRENT_DIR=$(pwd)
export BUILD_DIR
export FRAMEWORK_NAME="${SCHEME}.framework"
export FRAMEWORK_PATH="Framework/${FRAMEWORK_NAME}"

function xcode_build {
	local sdk
	local cflags
	local config=$1
	local merge=$2
	local archs
	local flags

	if [ $config == "Release" ]; then
		sdk="iphoneos"
		archs="arm64 armv7"
		flags="-fembed-bitcode -Qunused-arguments"
	else
		sdk="iphonesimulator"
		archs="i386 x86_64"
	fi

	BUILD_DIR=$(xcodebuild -showBuildSettings \
		-workspace ${WORKSPACE} -scheme ${SCHEME} -configuration ${config} -sdk ${sdk} | grep "BUILD_ROOT" | sed 's/[ ]*BUILD_ROOT = //')

    xcodebuild BITCODE_GENERATION_MODE=bitcode ONLY_ACTIVE_ARCH=NO ARCHS="${archs}" OTHER_CFLAGS="${flags}" \
		-workspace ${WORKSPACE} -scheme ${SCHEME} -configuration ${config} -sdk ${sdk} \
		clean build || exit 1

	mkdir -p "Framework/${config}-${sdk}"

	cp -RL "${BUILD_DIR}/${config}-${sdk}/${FRAMEWORK_NAME}" "Framework/${config}-${sdk}/${FRAMEWORK_NAME}" || exit 1

	if [ "$merge" == true ]; then
		echo "Merging Archs"

		cp -RL Framework/${config}-${sdk}/${FRAMEWORK_NAME}/Headers/* $FRAMEWORK_PATH/Headers/
		cp -RL Framework/${config}-${sdk}/${FRAMEWORK_NAME}/Modules/*/* $FRAMEWORK_PATH/Modules/*/

		lipo -create "$FRAMEWORK_PATH/${SCHEME}" "Framework/${config}-${sdk}/${FRAMEWORK_NAME}/${SCHEME}" -output "$FRAMEWORK_PATH/${SCHEME}"
		echo $(lipo -info "$FRAMEWORK_PATH/${SCHEME}")
	else
		echo "Copying Framework"

		cp -RL Framework/${config}-${sdk}/${FRAMEWORK_NAME}/* $FRAMEWORK_PATH/
		echo $(lipo -info "$FRAMEWORK_PATH/${SCHEME}")
	fi
}

function build_frameworks {
	rm -fr Framework/*/
	mkdir -p "${FRAMEWORK_PATH}"

	xcode_build "Release"
	xcode_build "Debug" true
}

build_frameworks
