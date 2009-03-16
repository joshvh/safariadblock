#!/bin/sh

if [ $CONFIGURATION = "Release" ]; then
	
	# Clean up RegexKit
	rm -f "$BUILT_PRODUCTS_DIR/$FULL_PRODUCT_NAME/Contents/Frameworks/RegexKit.framework/Headers"
	rm -rf "$BUILT_PRODUCTS_DIR/$FULL_PRODUCT_NAME/Contents/Frameworks/RegexKit.framework/Versions/A/Headers"
		
	# Create the InputManager-like folder with the Info file
	mkdir "$CONFIGURATION_BUILD_DIR/Safari AdBlock"
	rm -f "$CONFIGURATION_BUILD_DIR/Safari AdBlock/Info"
	cp "$PROJECT_DIR/Info" "$CONFIGURATION_BUILD_DIR/Safari AdBlock"

	# Trim the .bundle and put it in the folder
	# sh trim-app.sh -d -n -t -r "$CONFIGURATION_BUILD_DIR/Safari AdBlock"
	rm -rf "$CONFIGURATION_BUILD_DIR/Safari AdBlock/$FULL_PRODUCT_NAME"
	mv "$BUILT_PRODUCTS_DIR/$FULL_PRODUCT_NAME" "$CONFIGURATION_BUILD_DIR/Safari AdBlock"
	
	# Create the installer
	rm -f "$CONFIGURATION_BUILD_DIR/Install Safari AdBlock.pkg"
	#mkdir "$CONFIGURATION_BUILD_DIR/Installer.pmdoc"
	#for xml in "$PROJECT_DIR/Installer.pmdoc/"*
	#do
	#	sed -e "s/%%CURRENT_PROJECT_VERSION%%/$CURRENT_PROJECT_VERSION/" < "$xml" > "$CONFIGURATION_BUILD_DIR/Installer.pmdoc/`basename "$xml"`"
	#done
	#/Developer/usr/bin/packagemaker --doc "$CONFIGURATION_BUILD_DIR/Installer.pmdoc" --version "$CURRENT_PROJECT_VERSION" --out "$CONFIGURATION_BUILD_DIR/Install Safari AdBlock.pkg"
	#rm -rf "$CONFIGURATION_BUILD_DIR/Installer.pmdoc"
	echo "/Developer/usr/bin/packagemaker --doc \"$PROJECT_DIR/Installer.pmdoc\" --version \"$CURRENT_PROJECT_VERSION\" --out \"$CONFIGURATION_BUILD_DIR/Install Safari AdBlock.pkg\""
	/Developer/usr/bin/packagemaker --doc "$PROJECT_DIR/Installer.pmdoc" --version "$CURRENT_PROJECT_VERSION" --out "$CONFIGURATION_BUILD_DIR/Install Safari AdBlock.pkg"
	
	# Create the dmg
	rm -f "$CONFIGURATION_BUILD_DIR/Safari_AdBlock_$CURRENT_PROJECT_VERSION.dmg"
	cp "$PROJECT_DIR/Safari AdBlock.dmg" "$CONFIGURATION_BUILD_DIR/Safari AdBlock.temp.dmg"
	hdiutil attach "$CONFIGURATION_BUILD_DIR/Safari AdBlock.temp.dmg"
	cp "$CONFIGURATION_BUILD_DIR/Install Safari AdBlock.pkg" "/Volumes/Safari AdBlock/Install Safari AdBlock.pkg"
	rm -f "$CONFIGURATION_BUILD_DIR/Install Safari AdBlock.pkg"
	hdiutil detach "/Volumes/Safari AdBlock"
	hdiutil resize -sectors min "$CONFIGURATION_BUILD_DIR/Safari AdBlock.temp.dmg"
	hdiutil convert "$CONFIGURATION_BUILD_DIR/Safari AdBlock.temp.dmg" -format UDBZ -o "$CONFIGURATION_BUILD_DIR/Safari_AdBlock_$CURRENT_PROJECT_VERSION.dmg"
	rm -f "$CONFIGURATION_BUILD_DIR/Safari AdBlock.temp.dmg"
	
	# Create the tar (because of the Safari+SourceForge bug)
	pushd "$CONFIGURATION_BUILD_DIR" && tar cvf "Safari_AdBlock_$CURRENT_PROJECT_VERSION.dmg.tar" "Safari_AdBlock_$CURRENT_PROJECT_VERSION.dmg" && popd
fi


