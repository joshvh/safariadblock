/*
 This file is part of Safari AdBlock.
 
 Safari AdBlock is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 any later version.
 
 Safari AdBlock is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with Safari AdBlock.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "ABHelper.h"
#import "Constants.h"
#import "ABController.h"
#import "NSString+ABString.h"
#import <Security/Security.h>
#import <RegexKit/RegexKit.h>
#import <objc/objc-class.h>

#pragma mark -
#pragma mark RegexKitAdditionsHack

@implementation NSObject (RegexKitAdditionsHack)

- (BOOL)_isMatchedByAnyRegexInArray:(NSArray *)regexArray
{
	if (!regexArray)
		return NO;
	return [self isMatchedByAnyRegexInArray:regexArray
									library:RKRegexPCRELibrary
									options:RegexKitDefaultOptions
									  error:nil];
}

@end


#pragma mark -
#pragma mark ABPaths

@implementation ABPaths

+ (NSString *)applicationSupportFolderPath
{
	return [ShortApplicationSupportFolderPath stringByExpandingTildeInPath];
}

+ (NSString *)filtersPlistPath
{
	return [[ABPaths applicationSupportFolderPath] stringByAppendingPathComponent:FiltersPlistFullName];
}

+ (NSString *)subscriptionsPlistPath
{
	return [[ABPaths applicationSupportFolderPath] stringByAppendingPathComponent:SubscriptionsPlistFullName];
}

+ (NSString *)customFiltersFilePath
{
	return [[ABPaths applicationSupportFolderPath] stringByAppendingPathComponent:CustomFiltersFileFullName];
}

+ (NSString *)cacheFilePathForURL:(NSString *)url
{
	return [[ABPaths applicationSupportFolderPath] stringByAppendingPathComponent:[url sha1]];
}

@end



#pragma mark -
#pragma mark Uninstall

// Thanks, http://boinc.berkeley.edu/

static AuthorizationRef gOurAuthRef = NULL;
static char shPath[] = "/bin/sh";

static OSStatus getAuthorization() {
	static Boolean  			sIsAuthorized = false;
	AuthorizationRights 		ourAuthRights;
	AuthorizationFlags  		ourAuthFlags;
	AuthorizationItem   		ourAuthRightsItem[1];
	AuthorizationEnvironment	ourAuthEnvironment;
	AuthorizationItem   		ourAuthEnvItem[1];
	char						*prompt = "";
	OSStatus					err = noErr;
	
	if (sIsAuthorized)
		return noErr;
	
	ourAuthRights.count = 0;
	ourAuthRights.items = NULL;
	
	err = AuthorizationCreate (&ourAuthRights, kAuthorizationEmptyEnvironment, kAuthorizationFlagDefaults, &gOurAuthRef);
	if (err != noErr) {
		return err;
	}
	
	ourAuthRightsItem[0].name = kAuthorizationRightExecute;
	ourAuthRightsItem[0].value = shPath;
	ourAuthRightsItem[0].valueLength = strlen(shPath);
	ourAuthRightsItem[0].flags = 0;
	
	ourAuthRights.count = 1;
	ourAuthRights.items = ourAuthRightsItem;
	
	ourAuthEnvItem[0].name = kAuthorizationEnvironmentPrompt;
	ourAuthEnvItem[0].value = prompt;
	ourAuthEnvItem[0].valueLength = strlen(prompt);
	ourAuthEnvItem[0].flags = 0;
	
	ourAuthEnvironment.count = 1;
	ourAuthEnvironment.items = ourAuthEnvItem;
	
	ourAuthFlags = kAuthorizationFlagInteractionAllowed | kAuthorizationFlagExtendRights;
	
	err = AuthorizationCopyRights (gOurAuthRef, &ourAuthRights, &ourAuthEnvironment, ourAuthFlags, NULL);
	
	if (err == noErr)
		sIsAuthorized = true;
	
	return err;
}

OSStatus rmSafariAdBlock() {
	
	short   			i;
	char				*args[2];
	OSStatus			err;
	FILE				*ioPipe;
	char				*p, junk[256];
	
	err = getAuthorization();
	if (err != noErr) {
		return err;
	} else {
		for (i=0; i<5; i++) {   	// Retry 5 times if error
			args[0] = (char *) [[[NSBundle bundleWithIdentifier:BundleIdentifier] pathForResource:@"uninstall" ofType:@"sh"] UTF8String];
			args[1] = NULL;
			err = AuthorizationExecuteWithPrivileges(gOurAuthRef, shPath, 0, args, &ioPipe);
			// We use the pipe to signal us when the command has completed
			do {
				p = fgets(junk, sizeof(junk), ioPipe);
			} while (p);
			fclose (ioPipe);
			if (err == noErr)
				break;
		}
	}
	
	return err;
}

#pragma mark -
#pragma mark Swizzle

@implementation NSObject (Swizzle)

+ (BOOL)swizzleMethod:(SEL)old withMethod:(SEL)new
{
	Method oldMethod = class_getInstanceMethod(self, old);
	if (!oldMethod)
		return NO;
	
	Method newMethod = class_getInstanceMethod(self, new);
	if (!newMethod)
		return NO;
	
	method_exchangeImplementations(oldMethod, newMethod);
	return YES;
}

+ (BOOL)overrideMethod:(NSString *)methodName
{
	return [self swizzleMethod:NSSelectorFromString(methodName)
					withMethod:NSSelectorFromString([@"_" stringByAppendingString:methodName])];
}

+ (BOOL)overrideMethods:(NSArray *)methods
{
	for (NSString *method in methods)
		if (![self overrideMethod:method])
			return NO;
	return YES;
}

@end


void swizzle(Class originalClass, SEL originalName, Class newClass, SEL newName)
{
	/*
	(IMP) method_setImplementation(
								   class_getInstanceMethod([LocationChangeHandler class], @selector(webView:didFinishLoadForFrame:)),
								   (IMP) webView_didFinishLoadForFrame_override));
	
	method_setImplementation(class_getInstanceMethod(cls, name), <#IMP imp#>)*/
	
	method_exchangeImplementations(class_getInstanceMethod(originalClass, originalName), class_getInstanceMethod(newClass, newName));
}