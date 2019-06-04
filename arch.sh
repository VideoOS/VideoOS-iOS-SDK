#!/bin/sh
#Remove arch

cd Framework

clean="$1"

echo "$clean"

function removeAFN() {
	echo "remove AFN"
	rm AF*.o
	rm *+AF*.o
}

function removeSD() {
	echo "remove SD"
	rm SD*.o
	rm NSData+ImageContentType.o
	rm UIImage+GIF.o
	rm UIImage+MultiFormat.o
	rm UIView+WebCacheOperation.o
	rm -rf UIImage+WebP.o
    rm -rf UIImage+ForceDecode.o
	rm -rf NSImage+WebCache.o
	rm -rf MKAnnotationView+WebCache.o
	rm -rf UIButton+WebCache.o
	rm -rf UIImageView+HighlightedWebCache.o
	rm -rf UIImageView+WebCache.o
	rm -rf UIView+WebCache.o
	rm -rf FLAnimatedImageView+WebCache.o
}

function removeLuaView {
	echo "remove LuaView"
	rm -rf JUFL*.o
	rm -rf l*.o
	rm -rf Layout.o
	rm -rf LuaView.o
	rm -rf LuaViewCore.o
	rm -rf *+LuaView.o
	rm -rf print.o
	rm -rf UIScrollView+LVRefresh.o
	rm -rf UIView+JUFLXNode.o
    rm -rf LV*.o
    rm -rf VPLuaViewSDK-dummy.o
}

function removeZipArchive {
	echo "remove ZipArchive"
	rm -rf aes_ni.o
    rm -rf aescrypt.o
    rm -rf aeskey.o
    rm -rf aestab.o
    rm -rf entropy.o
    rm -rf crypt.o
    rm -rf fileenc.o
    rm -rf hmac.o
    rm -rf ioapi_buf.o
    rm -rf ioapi_mem.o
    rm -rf ioapi.o
    rm -rf mztools.o
    rm -rf minishared.o
    rm -rf prng.o
    rm -rf pwd2key.o
    rm -rf sha1.o
    rm -rf SSZipArchive-dummy.o
    rm -rf SSZipArchive.o
    rm -rf unzip.o
    rm -rf zip.o
}

function removeLuaScriptManager {
	echo "remove VPUPLuaScriptManager"
	rm -rf VPUPLuaScriptManager.o	
}

if [ "$clean" != "" ]; then
	rm -rf i386
	rm -rf x86_64
	rm -rf armv7
	rm -rf arm64
	rm -rf output
	exit
fi

archs=("i386" "x86_64" "armv7" "arm64")

for i in {0..3}
do
	echo "${archs["$i"]} processing"

	arch=${archs["$i"]}

	mkdir "$arch"

	echo "lipo thin"

	lipo VideoOS -thin "$arch" -output "$arch"/VideoOS

	mkdir "$arch"/archieve

	cd "$arch"/archieve

	echo "ar -x .a"

	ar -x ../VideoOS


	removeAFN

	removeSD

	# removeLuaView

    # removeZipArchive

	echo "libtool build"

	libtool -static *.o -o ../VideoOS

	cd ../../
done

mkdir output

lipo -create i386/VideoOS x86_64/VideoOS armv7/VideoOS arm64/VideoOS -output output/VideoOS

cd ..

exit
