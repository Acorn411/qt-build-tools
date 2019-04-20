#!/bin/bash

# requirements:
# 1. brew
# 2. brew install llvm (https://bugreports.qt.io/browse/QTBUG-66353)

export PATH=$PATH:/usr/local/Qt-5.12.3/bin

cd qtbase

if [[ $1 == openssl ]]; then
    
	# download openssl
	curl -O https://www.openssl.org/source/openssl-1.1.1a.tar.gz
	tar -xvzf openssl-1.1.1a.tar.gz

	# compile openssl
	cd openssl-1.1.1a
	./Configure darwin64-x86_64-cc --prefix=$PWD/dist
	make
	# print arch info (optional)
	lipo -info libssl.a 
	lipo -info libcrypto.a
	make install
	cd ..

	# continue

	OPENSSL_LIBS='-L$PWD/openssl-1.1.1a/dist/lib -lssl -lcrypto' ./configure -opensource -confirm-license -no-securetransport -nomake examples -nomake tests -openssl-linked -I $PWD/openssl-1.1.1a/dist/include -L $PWD/openssl-1.1.1a/dist/lib

elif [[ $1 == securetransport ]]; then

	./configure -opensource -confirm-license -nomake examples -nomake tests -no-openssl -securetransport

else

	echo "Error: please specify which SSL layer to use (openssl or securetransport)"
    exit 1

fi

make -j 12
echo maki | sudo -S sudo make install

cd ../qttools
qmake
make -j 12
echo maki | sudo -S sudo make install

cd ../qtmacextras
qmake
make -j 12
echo maki | sudo -S sudo make install

cd ../qtdeclarative/src
qmake
make -j 12 sub-qmldevtools
echo maki | sudo -S sudo make install

# make docs - currently doesnt work

#cd ../qtbase
#make  -j 12 docs
#cd ../qttools
#make  -j 12 docs
#cd ../qtmacextras
#make  -j 12 docs

#echo maki | sudo -S cp -f -r ../qtbase/doc /usr/local/Qt-5.12.3/

cd /usr/local
zip -r ~/Desktop/qt5.12.3_mac.zip Qt-5.12.3/*