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

#import <Cocoa/Cocoa.h>

@interface NSObject (RegexKitAdditionsHack)
- (BOOL)_isMatchedByAnyRegexInArray:(NSArray *)regexArray;
@end

@interface NSObject (Swizzle)
+ (BOOL)swizzleMethod:(SEL)old withMethod:(SEL)new;
+ (BOOL)overrideMethod:(NSString *)methodName;
+ (BOOL)overrideMethods:(NSArray *)methods;
@end

@interface ABPaths : NSObject {
}

+ (NSString *)applicationSupportFolderPath;
+ (NSString *)filtersPlistPath;
+ (NSString *)subscriptionsPlistPath;
+ (NSString *)customFiltersFilePath;
+ (NSString *)cacheFilePathForURL:(NSString *)url;

@end

void swizzle(Class originalClass, SEL originalName, Class newClass, SEL newName);
