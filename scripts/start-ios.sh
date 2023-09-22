#!/bin/bash

LIB_NAME=taple
UDL_NAME=taple_ffi
GREEN='\033[1;32m'
NC='\033[0;0m'

architectures=(x86_64-apple-ios aarch64-apple-ios aarch64-apple-ios-sim aarch64-apple-ios-macabi x86_64-apple-ios-macabi)

scripts_dir=$(pwd)
ffi_dir=$scripts_dir/../../taple-ffi
sdk_dir=$scripts_dir/../taple_sdk

echo -e "${GREEN}Compiling sources ..."
cd $ffi_dir
cargo build --features ios --lib --release --target x86_64-apple-ios
cargo build --features ios --lib --release --target aarch64-apple-ios
cargo +nightly build --features ios --lib --release --target aarch64-apple-ios-sim
cargo +nightly build -Z build-std --features ios --lib --release --target aarch64-apple-ios-macabi
cargo +nightly build -Z build-std --features ios --lib --release --target x86_64-apple-ios-macabi

echo -e "${GREEN}Generating swift binding ..."
cargo run --features=uniffi/cli --bin uniffi-bindgen generate  $ffi_dir/src/taple_uniffi.udl --out-dir $ffi_dir/target/ --language swift 

mv $ffi_dir/target/${UDL_NAME}FFI.modulemap $ffi_dir/target/${LIB_NAME}FFI.modulemap 
mv $ffi_dir/target/${UDL_NAME}FFI.h $ffi_dir/target/${LIB_NAME}FFI.h
sed -i '' 's/module\ ${LIB_NAME}FFI/framework\ module\ ${LIB_NAME}FFI/' $ffi_dir/target/${LIB_NAME}FFI.modulemap
sed -i '' '3i\
\'$'\nframework'$'\n ' $ffi_dir/target/${LIB_NAME}FFI.modulemap
sed -i '' 's/taple_ffiFFI/tapleFFI/g' $ffi_dir/target/${UDL_NAME}.swift
sed -i '' 's/taple_ffiFFI/tapleFFI/g' $ffi_dir/target/${LIB_NAME}FFI.modulemap

echo -e "${GREEN}Copying resources...${NC}"

for ((i=0;i<5;i++))
do
    cd $ffi_dir/target/${architectures[i]}/release 
    rm -rf ${LIB_NAME}FFI.framework || echo "skip removing"
    mkdir -p ${LIB_NAME}FFI.framework && cd ${LIB_NAME}FFI.framework
    mkdir Headers Modules Resources
    cp ../../../${LIB_NAME}FFI.modulemap ./Modules/module.modulemap
    cp ../../../${LIB_NAME}FFI.h ./Headers
    cp ../lib${UDL_NAME}.a ./${LIB_NAME}FFI
    cp $scripts_dir/resources/Info.plist ./Resources
done

#Creacion de targets
echo -e "${GREEN}Target creation ...${NC}"
cd $ffi_dir

lipo -create target/x86_64-apple-ios/release/${LIB_NAME}FFI.framework/${LIB_NAME}FFI \
    target/aarch64-apple-ios-sim/release/${LIB_NAME}FFI.framework/${LIB_NAME}FFI \
    -output target/aarch64-apple-ios-sim/release/${LIB_NAME}FFI.framework/${LIB_NAME}FFI

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
cp $ffi_dir/target/${UDL_NAME}.swift $sdk_dir/Sources/taple_sdk

echo -e "${GREEN}Finish !"