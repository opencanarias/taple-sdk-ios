#!/bin/bash

# script based on https://github.com/opencanarias/uniffi-rs-fullstack-examples/blob/main/hello/Makefile

GREEN='\033[1;32m'
NC='\033[0;0m'

# Compilation mode: release/debug
mode=release

LIB_NAME=taple
UDL_NAME=taple_ffi

scripts_dir=$(pwd)
ffi_dir=$scripts_dir/../../taple-ffi
sdk_dir=$scripts_dir/../sdk

architectures=()
# architectures+=("ios_target nightly_required unstable_required")
architectures+=("x86_64-apple-ios false false")
architectures+=("aarch64-apple-ios false false")
architectures+=("aarch64-apple-ios-sim true false")
architectures+=("aarch64-apple-ios-macabi true true")
architectures+=("x86_64-apple-ios-macabi true true")

echo -e "${GREEN}Generating swift binding ...${NC}"
cd $ffi_dir
cargo run --features=uniffi/cli --bin uniffi-bindgen generate  $ffi_dir/src/taple_uniffi.udl --out-dir $ffi_dir/target/ --language swift 

#This has the porpuse of binding the .h file to 
sed -i '' 's/module/framework module/' $ffi_dir/target/${LIB_NAME}FFI.modulemap

for key in ${!architectures[@]}
do
    read -a elements <<< "${architectures[$key]}"
    
    ios_target=${elements[0]}
    nightly=$([ ${elements[1]} = true ] && echo "+nightly" || echo "")
    unstable=$([ ${elements[2]} = true ] && echo "-Z build-std" || echo "")

    cd $ffi_dir
    echo -e "${GREEN}Compiling architecture: $ios_target ${NC}"
    cargo $nightly build $unstable --features ios --lib --target $ios_target --$mode


    echo -e "${GREEN}Copying resources: $ios_target ${NC}"
    cd $ffi_dir/target/${ios_target}/release 
    rm -rf ${LIB_NAME}FFI.framework || echo "skip removing"
    mkdir -p ${LIB_NAME}FFI.framework
    cd ${LIB_NAME}FFI.framework
    mkdir Headers Modules Resources
    cp $ffi_dir/target/${LIB_NAME}FFI.h ./Headers
    cp $ffi_dir/target/${LIB_NAME}FFI.modulemap ./Modules/module.modulemap
    cp $scripts_dir/resources/Info.plist ./Resources
    cp $ffi_dir/target/${ios_target}/release/lib${UDL_NAME}.a ./${LIB_NAME}FFI
done

echo -e "${GREEN}Target creation ...${NC}"
cd $ffi_dir

#Universal library for MacOS IOS simulators
lipo -create target/x86_64-apple-ios/release/${LIB_NAME}FFI.framework/${LIB_NAME}FFI \
    target/aarch64-apple-ios-sim/release/${LIB_NAME}FFI.framework/${LIB_NAME}FFI \
    -output target/aarch64-apple-ios-sim/release/${LIB_NAME}FFI.framework/${LIB_NAME}FFI

#Universal library for MacCatalyst
lipo -create target/x86_64-apple-ios-macabi/release/${LIB_NAME}FFI.framework/${LIB_NAME}FFI \
    target/aarch64-apple-ios-macabi/release/${LIB_NAME}FFI.framework/${LIB_NAME}FFI \
    -output target/aarch64-apple-ios-macabi/release/${LIB_NAME}FFI.framework/${LIB_NAME}FFI
	
rm -rf target/${LIB_NAME}FFI.xcframework || echo "skip removing"
	
xcodebuild -create-xcframework \
    -framework target/aarch64-apple-ios/release/${LIB_NAME}FFI.framework \
    -framework target/aarch64-apple-ios-sim/release/${LIB_NAME}FFI.framework \
    -framework target/aarch64-apple-ios-macabi/release/${LIB_NAME}FFI.framework \
    -output target/${LIB_NAME}FFI.xcframework


echo -e "${GREEN}Copying swift binding into the ios lib ...${NC}"

mkdir $sdk_dir
mkdir $sdk_dir/Sources

cp $scripts_dir/resources/Package.swift $sdk_dir
cp -r $scripts_dir/resources/Tests $sdk_dir
cp -r $ffi_dir/target/${LIB_NAME}FFI.xcframework $sdk_dir/Sources
cp $ffi_dir/target/${LIB_NAME}FFI.swift $sdk_dir/Sources/taple_sdk

echo -e "${GREEN}Finish !${NC}"