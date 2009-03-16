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

#import "ABController.h"
#import "Constants.h"
#import "ABPreferences.h"
#import "Safari.h"
#import "NSString+ABString.h"
#import "NSArray+ABArray.h"
#import <RegexKit/RegexKit.h>
#import "ABHelper.h"
#import "ABURLProtocol.h"
#import "ABToolbarController.h"
#import "LoadProgressMonitor+ABBlockWebResourceLoadDelegate.h"
#import "LocationChangeHandler+ABBlockWebFrameLoadDelegate.h"
#import <Sparkle/Sparkle.h>

@implementation ABController
@synthesize filters, customFilters, subscriptions;

+ (void)initialize
{
	// Force the creation of the singleton
	[ABController sharedController];
}

#pragma mark -
#pragma mark Singleton

static ABController *sharedController = nil;

+ (ABController*)sharedController
{
    @synchronized(self) {
        if (sharedController == nil) {
            [[self alloc] init];
        }
    }
    return sharedController;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedController == nil) {
            sharedController = [super allocWithZone:zone];
            return sharedController;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (unsigned)retainCount
{
    return UINT_MAX;
}

- (void)release
{
    // do nothing
}

- (id)autorelease
{
    return self;
}

#pragma mark -
#pragma mark Init/Load

- (id) init
{	
	self = [super init];
	if (self != nil) {
				
		// Safari?
		if (!([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.Safari"] ||
			  [[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"org.webkit.nightly.WebKit"]
			  ))
			return nil;
		
		NSFileManager *fm = [NSFileManager defaultManager];
		NSString *applicationSupportFolderPath = [ABPaths applicationSupportFolderPath];
		
		NSMutableDictionary *defaults = [NSMutableDictionary dictionaryWithContentsOfFile:
										 [[NSBundle bundleWithIdentifier:BundleIdentifier] pathForResource:@"Defaults" ofType:@"plist"]];
		NSString *preferredLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
		if (![preferredLanguage isEqualToString:@"en"]) {
			[(NSMutableArray *)[defaults objectForKey:SubscriptionsPrefsKey] addObject:preferredLanguage];
		}
		[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
		
		if (![fm fileExistsAtPath:applicationSupportFolderPath]) {
			if (![fm createDirectoryAtPath:applicationSupportFolderPath withIntermediateDirectories:YES attributes:nil error:nil])
				return nil;
		}
		
		if (![self loadSubscriptions])
			return nil;
		
		if (![self loadFilters])
			return nil;
		
		[self loadCustomFilters];
		
		
		if (![filters objectForKey:LastUpdatedFiltersKey] || [[[filters objectForKey:LastUpdatedFiltersKey] addTimeInterval:3600*24*30] compare:[NSDate date]] == NSOrderedAscending) {
			[self updateFilters];
		}
		
		updater = [SUUpdater updaterForBundle:[NSBundle bundleWithIdentifier:BundleIdentifier]];
		[updater setDelegate:self];
		[updater setSendsSystemProfile:YES];
		[updater setAutomaticallyChecksForUpdates:YES];
		
		[NSURLProtocol registerClass:[ABURLProtocol class]];
		
		// The magic happens here!
		[LoadProgressMonitor swizzle];
		[LocationChangeHandler swizzle];
		[ToolbarController swizzle];
		
		// poseAsClass is depreciated, but... who cares if it works here?
		[[ABPreferences class] poseAsClass:[NSPreferences class]];
		
		
	}
	return self;
}

#pragma mark -
#pragma mark Subscriptions

- (BOOL)loadSubscriptions
{
	NSArray *subscriptionsSubscribedTo = [[NSUserDefaults standardUserDefaults] arrayForKey:SubscriptionsPrefsKey];
	NSMutableArray *subscriptionsData = [NSMutableArray arrayWithContentsOfFile:[[NSBundle bundleWithIdentifier:BundleIdentifier] pathForResource:@"Subscriptions" ofType:@"plist"]];
	if (!subscriptionsData)
		return NO;
	
	NSString *customSubscriptionsFile = [[ABPaths applicationSupportFolderPath] stringByAppendingPathComponent:SubscriptionsPlistFullName];
	if ([[NSFileManager defaultManager] fileExistsAtPath:customSubscriptionsFile]) {
		NSMutableArray *customSubscriptionsData = [NSMutableArray arrayWithContentsOfFile:customSubscriptionsFile];
		if (customSubscriptionsData)
			[subscriptionsData addObjectsFromArray:customSubscriptionsData];
	}
	
	for (NSDictionary *subscriptionData in subscriptionsData) {
		if ([subscriptionsSubscribedTo containsObject:[subscriptionData objectForKey:SubscriptionsLanguageKey]]) {
			[subscriptionData setValue:[NSNumber numberWithBool:YES] forKey:SubscriptionIsSubscribedKey];
		} else {
			[subscriptionData setValue:[NSNumber numberWithBool:NO] forKey:SubscriptionIsSubscribedKey];
		}
	}
	[self setSubscriptions:subscriptionsData];
	
	return YES;
}

- (void)saveSubscriptions
{	
	NSMutableArray *subscriptionsSubscribedTo = [NSMutableArray array];
	NSMutableArray *customSubscriptionsData = [NSMutableArray array];
	
	for (NSDictionary *subscription in subscriptions) {
		if ([[subscription objectForKey:SubscriptionIsSubscribedKey] boolValue]) {
			[subscriptionsSubscribedTo addObject:[subscription objectForKey:SubscriptionsLanguageKey]];
		}
		if ([[subscription objectForKey:SubscriptionIsCustomKey] boolValue]) {
			[customSubscriptionsData addObject:subscription];
		}
	}
	
	[[NSUserDefaults standardUserDefaults] setObject:subscriptionsSubscribedTo forKey:SubscriptionsPrefsKey];
	[customSubscriptionsData writeToFile:[[ABPaths applicationSupportFolderPath] stringByAppendingPathComponent:SubscriptionsPlistFullName]
							  atomically:YES];
}

- (NSArray *)subscriptionsSortDescriptors
{
	return [NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:SubscriptionsOrderKey ascending:YES] autorelease]];
}


#pragma mark -
#pragma mark Filters

- (BOOL)loadFilters
{	
	NSString *filtersPlistPath = [ABPaths filtersPlistPath];
	if ([[NSFileManager defaultManager] fileExistsAtPath:filtersPlistPath]) {
		[self setFilters:[NSMutableDictionary dictionaryWithContentsOfFile:filtersPlistPath]];
		if (!filters)
			return NO;
		if ([[filters objectForKey:VersionFiltersKey] intValue] != FiltersVersion)
			[self updateFilters];
	} else {
		[self setFilters:[NSMutableDictionary dictionary]];
	}
	return YES;
}

- (void)loadCustomFilters
{
	NSString *customFiltersFilePath = [ABPaths customFiltersFilePath];
	if ([[NSFileManager defaultManager] fileExistsAtPath:customFiltersFilePath]) {
		NSArray *flatCustomFilters = [[NSString stringWithContentsOfFile:customFiltersFilePath] componentsSeparatedByString:@"\n"];
		flatCustomFilters = [flatCustomFilters subarrayWithRange:NSMakeRange(1, [flatCustomFilters count]-1)];
		NSMutableArray *someCustomFilters = [NSMutableArray array];
		for (NSString *flatCustomFilter in flatCustomFilters) {
			if ([flatCustomFilter length] > 0)
				[someCustomFilters addObject:[NSDictionary dictionaryWithObject:flatCustomFilter forKey:@"filter"]];
		}
		[self setCustomFilters:someCustomFilters];
	} else {
		[self setCustomFilters:[NSMutableArray array]];
	}
}

- (void)saveFilters
{
	NSString *applicationSupportFolder = [ShortApplicationSupportFolderPath stringByExpandingTildeInPath];
	NSString *filtersPlistPath = [applicationSupportFolder stringByAppendingPathComponent:FiltersPlistFullName];
	[filters writeToFile:filtersPlistPath atomically:YES];
}

- (void)saveCustomFilters
{
	NSMutableString *flatCustomFilters = [NSMutableString stringWithString:@"[Safari AdBlock Custom Filters]\n"];
	for (NSDictionary *filter in customFilters) {
		[flatCustomFilters appendString:[filter objectForKey:@"filter"]];
		[flatCustomFilters appendString:@"\n"];
	}
	[flatCustomFilters writeToFile:[ABPaths customFiltersFilePath] atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (void)updateFilters
{
	listsToLoad = [[NSMutableDictionary dictionary] retain];
	for (NSDictionary *subscription in subscriptions) {
		if ([[subscription objectForKey:SubscriptionIsSubscribedKey] boolValue]) {
			for (NSString *URL in [subscription objectForKey:SubscriptionURLsKey]) {
				[listsToLoad setObject:[NSMutableData data] forKey:URL];
			}
		}
	}
	[self downloadNextList];
}

#pragma mark -
#pragma mark Download and parse lists

- (void)downloadNextList
{
	for (NSString *URL in listsToLoad) {
		if ([(NSData *)[listsToLoad objectForKey:URL] length] == 0) {
			currentListURL = URL;
			[self downloadListWithURL:URL];
			return;
		}
	}
	[self parseLists];
}

- (void)downloadListWithURL:(NSString *)URL
{
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL]
														   cachePolicy:NSURLRequestUseProtocolCachePolicy
													   timeoutInterval:30.0];
	[request setValue:[ABController userAgent] forHTTPHeaderField:@"User-Agent"];
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	if (connection) {
		currentListData = [[NSMutableData data] retain];
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [currentListData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [currentListData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSString *cacheFile = [ABPaths cacheFilePathForURL:currentListURL];
	if ([[NSFileManager defaultManager] fileExistsAtPath:cacheFile]) {
		[listsToLoad setObject:[NSData dataWithContentsOfFile:cacheFile] forKey:currentListURL];
	} else {
		[listsToLoad removeObjectForKey:currentListURL];
	}
	
	[connection release];
    [currentListData release];
	[self downloadNextList];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSString *cacheFile = [ABPaths cacheFilePathForURL:currentListURL];
	
	if ([currentListData length] == 0) {
		if ([[NSFileManager defaultManager] fileExistsAtPath:cacheFile]) {
			[listsToLoad setObject:[NSData dataWithContentsOfFile:cacheFile] forKey:currentListURL];
		} else {
			[listsToLoad removeObjectForKey:currentListURL];
		}
	} else {
		[listsToLoad setObject:currentListData forKey:currentListURL];
		[currentListData writeToFile:cacheFile atomically:YES];
	}
	
    [connection release];
    [currentListData release];
	[self downloadNextList];
}

- (void)parseLists
{
	NSMutableSet *whiteList = [NSMutableSet set];
	NSMutableSet *pageWhiteList = [NSMutableSet set];
	NSMutableSet *blockList = [NSMutableSet set];
	
	NSData *d = [NSData dataWithContentsOfFile:[ABPaths customFiltersFilePath]];
	if (d)
		[listsToLoad setObject:d forKey:[ABPaths customFiltersFilePath]];
	
	for (NSString *URL in listsToLoad) {
		NSString *list = nil;
		if ((list = [[NSString alloc] initWithData:[listsToLoad objectForKey:URL] encoding:NSUTF8StringEncoding]) ||
			(list = [[NSString alloc] initWithData:[listsToLoad objectForKey:URL] encoding:NSISOLatin1StringEncoding]) ||
			(list = [[NSString alloc] initWithData:[listsToLoad objectForKey:URL] encoding:NSASCIIStringEncoding])) {
			NSArray *lines = [list componentsSeparatedByString:@"\n"];
			[list release];
			if (!lines)
				continue;
			lines = [lines subarrayWithRange:NSMakeRange(1, [lines count]-1)]; // Ignore first line
			NSString *line;
			for (line in lines) {
				NSDictionary *f;
				if (f = [line parseAsFilter]) {
					if ([[f objectForKey:@"IsWhitelist"] boolValue]) {
						[whiteList addObject:[f objectForKey:@"RegularExpression"]];
					} else if ([[f objectForKey:@"IsPageWhitelist"] boolValue]) {
						[pageWhiteList addObject:[f objectForKey:@"RegularExpression"]];
					} else {
						[blockList addObject:[f objectForKey:@"RegularExpression"]];
					}
				}
			}
		}
	}
	
	[filters setValue:[whiteList allObjects] forKey:WhiteListFiltersKey];
	[filters setValue:[pageWhiteList allObjects] forKey:PageWhiteListFiltersKey];
	[filters setValue:[blockList allObjects] forKey:BlockListFiltersKey];
	[filters setValue:[NSDate date] forKey:LastUpdatedFiltersKey];
	[filters setValue:[NSNumber numberWithInt:FiltersVersion] forKey:VersionFiltersKey];
	[listsToLoad release];
	[self saveFilters];
}

#pragma mark -
#pragma mark Misc

+ (NSString *)version
{
	return [[NSBundle bundleWithIdentifier:BundleIdentifier] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

+ (NSString *)userAgent
{
	return [NSString stringWithFormat:UserAgentFormat, [ABController version]];
}

- (IBAction)enabledOrDisable:(id)sender
{
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	[ud setBool:![ud boolForKey:IsEnabledPrefsKey]
		 forKey:IsEnabledPrefsKey];
}

- (NSString *)pathToRelaunchForUpdater:(SUUpdater *)updater
{
	return [[NSBundle mainBundle] bundlePath];
}

@end
