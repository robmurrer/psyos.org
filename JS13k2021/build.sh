#!/bin/bash

# SIMPLE BUILD SCRIPT FOR JS13k by FRANK FORCE
# minifies and combines index.html and index.js and zips the result

name="OS13k"

# install closure and advzip globally if necessary
# npm install -g google-closure-compiler
# npm install -g terser
# npm install -g advzip-bin
# npm install -g roadroller

# remove old files
rm index.zip
rm index.min.html
rm -rf build

google-closure-compiler --js  index.js --externs externs.js --js_output_file build/index.js --compilation_level ADVANCED --language_out ECMASCRIPT_2019 --warning_level VERBOSE --jscomp_off *
if [ $? -ne 0 ]; then
    read -p "Press enter to continue"
    exit $?
fi

# get rid of strict mode by adding a 0 at the top
cp build/index.js build/indexStrict.js
rm build/index.js
echo 0 > build/index.js
cat build/indexStrict.js >> build/index.js

# more minification with terser
terser -o build/index.js --compress --mangle -- build/index.js
if [ $? -ne 0 ]; then
    read -p "Press enter to continue"
    exit $?
fi

# roadroaller compresses the code better then zip
roadroller build/index.js -o build/index.js
if [ $? -ne 0 ]; then
    read -p "Press enter to continue"
    exit $?
fi

# make the html
echo "<body><script>" >> build/index.html
cat build/index.js >> build/index.html
echo "</script>" >> build/index.html

# zip the result
cd build
advzip -a -4 -i 99 index.zip index.html
if [ $? -ne 0 ]; then
    read -p "Press enter to continue"
    exit $?
fi