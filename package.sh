#!/bin/sh

#取版本号
version=`awk '{if($0~"s.version"){print $3;exit}}' VideoOS.podspec`

#删除版本号中的引号
version=`echo $version | sed 's/\"//g' `

function fixDynamicPackage() {
    echo "fixDynamicPackage"

    cd VideoOS-"$version"/ios
    cp VideoOS.framework/Headers/VideoOS-umbrella.h VideoOS-umbrella.h

    sed '/VPLua/'d VideoOS-umbrella.h > VideoOS-umbrella1.h
    sed '/VPUPSVGAPlayer.h/'d VideoOS-umbrella1.h > VideoOS-umbrella2.h
    sed '/VPUPSVGAParser.h/'d VideoOS-umbrella2.h > VideoOS-umbrella3.h
    sed '/VideoPlsLuaViewSDK/'d VideoOS-umbrella3.h > VideoOS-umbrella4.h

    rm VideoOS.framework/Headers/VideoOS-umbrella.h
    cp VideoOS-umbrella4.h VideoOS.framework/Headers/VideoOS-umbrella.h

    rm VideoOS-umbrella*.h

    rm VideoOS.framework/Headers/VPLua*.h
    rm VideoOS.framework/Headers/VideoPlsLuaViewSDK.h
    rm VideoOS.framework/Headers/VPUPSVGAPlayer.h
    rm VideoOS.framework/Headers/VPUPSVGAParser.h

    echo "resource"
    cp -r VideoOS.framework/VideoPlsResources.bundle VideoPlsResources.bundle
    cd ../..
}

echo $version

mkdir VideoOS-$version-Release

function fixStaticPackage() {
    echo "fixStaticPackage"

    mkdir Framework

    cp VideoOS-"$version"/ios/VideoOS.framework/Versions/A/VideoOS Framework/VideoOS
    
    sh arch.sh

    rm VideoOS-"$version"/ios/VideoOS.framework/Versions/A/VideoOS

    cp Framework/output/VideoOS VideoOS-"$version"/ios/VideoOS.framework/Versions/A/VideoOS

    cp -r VideoOS-"$version"/ios/VideoOS.framework/Versions/A/Resources/VideoPlsResources.bundle VideoOS-"$version"/ios/VideoPlsResources.bundle

    rm -r Framework
}

echo "package dynamic"

pod package ./VideoOS.podspec --spec-sources=https://git.coding.net/Zard1096/VideoPlsPodsRepo.git,https://github.com/CocoaPods/Specs.git --no-mangle --force --verbose --dynamic

if [ $? -eq 0 ]; then
    fixDynamicPackage
    cp -r VideoOS-"$version"/ios VideoOS-"$version"-Release/dynamic 
else
    exit 1
fi

exit 1
echo "package static"

pod package ./VideoOS.podspec --spec-sources=https://git.coding.net/Zard1096/VideoPlsPodsRepo.git,https://github.com/CocoaPods/Specs.git --no-mangle --force --verbose 

if [ $? -eq 0 ]; then
    fixStaticPackage
    cp -r VideoOS-"$version"/ios VideoOS-"$version"-Release/static 
else
    exit 1
fi

zip -r -y -q VideoOS-"$version"-Release.zip VideoOS-"$version"-Release

