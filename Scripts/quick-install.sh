#!/bin/sh
# Do "sudo Scripts/quick-install.sh" from Safari AdBlock's root directory
# and after having built Safari AdBlock in Xcode

rm -rf /Library/InputManagers/Safari\ AdBlock/Safari\ AdBlock\ Loader.bundle
cp -r build/Debug/Safari\ AdBlock\ Loader.bundle /Library/InputManagers/Safari\ AdBlock/Safari\ AdBlock\ Loader.bundle
