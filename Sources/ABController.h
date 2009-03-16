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
#import <WebKit/WebKit.h>

@class SUUpdater;

@interface ABController : NSObject {
	NSMutableDictionary *filters;
	NSMutableArray *subscriptions;
	NSMutableDictionary *listsToLoad;
	NSMutableData *currentListData;
	NSString *currentListURL;
	NSMutableArray *customFilters;
	SUUpdater *updater;
}
@property(retain, readwrite) NSMutableDictionary *filters;
@property(retain, readwrite) NSMutableArray *customFilters;
@property(retain, readwrite) NSMutableArray *subscriptions;

+ (ABController*)sharedController;
+ (id)allocWithZone:(NSZone *)zone;
- (id)copyWithZone:(NSZone *)zone;
- (id)retain;
- (unsigned)retainCount;
- (void)release;
- (id)autorelease;
- (BOOL)loadFilters;
- (void)loadCustomFilters;
- (BOOL)loadSubscriptions;
- (void)saveSubscriptions;
- (void)parseLists;
- (void)downloadNextList;
- (void)downloadListWithURL:(NSString *)URL;
- (void)updateFilters;
- (void)saveFilters;
- (void)saveCustomFilters;
- (IBAction)enabledOrDisable:(id)sender;
+ (NSString *)version;
+ (NSString *)userAgent;
@end
