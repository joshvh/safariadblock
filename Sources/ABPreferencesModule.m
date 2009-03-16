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

#import "ABPreferencesModule.h"
#import "ABValueTransformers.h"
#import "Constants.h"
#import "ABController.h"
#import "ABHelper.h"
#import <RegexKit/RegexKit.h>

@implementation ABPreferencesModule
@synthesize versionLabel, URLTesterResults;

#pragma mark -
#pragma mark NSPreferencesModule

- (NSString *)preferencesNibName {
	return @"ABPreferences";
}
 
- (NSView*)viewForPreferenceNamed:(NSString *)aName
{
#pragma unused(aName)
	if (!_preferencesView)
		[NSBundle loadNibNamed:[self preferencesNibName] owner:self];
	return _preferencesView;
}

- (BOOL)isResizable;
{
	return NO;
}

- (void)willBeDisplayed
{
	[subscriptionsTable unbind:@"sortDescriptors"];
}

- (void)saveChanges
{
	[sharedController saveSubscriptions];
	[sharedController saveCustomFilters];
	[sharedController updateFilters];
}

- (void)moduleWasInstalled
{
	filterBeingEdited = nil;
	subscriptionBeingEdited = nil;
	
	[NSValueTransformer setValueTransformer:[[[ABBooleanToStateValueTransformer alloc] init] autorelease]
									forName:@"ABBooleanToStateValueTransformer"];
	
	[NSValueTransformer setValueTransformer:[[[ABBooleanToInverseStateValueTransformer alloc] init] autorelease]
									forName:@"ABBooleanToInverseStateValueTransformer"];
	
	[self setVersionLabel:[NSString stringWithFormat:NSLocalizedString(@"Current Version: %@",@"Preferences -> General tab -> current version label"),[ABController version]]];
	[self setURLTesterResults:[NSArray array]];
	
	[customFiltersTable setDoubleAction:@selector(showFilterEditor:)];
	[customFiltersTable setTarget:self];
	
	[subscriptionsTable setDoubleAction:@selector(showSubscriptionEditor:)];
	[subscriptionsTable setTarget:self];
}

#pragma mark -
#pragma mark Misc

- (ABController *)sharedController
{
	if (!sharedController)
		sharedController = [ABController sharedController];
	return sharedController;
}

- (IBAction)enabledOrDisable:(id)sender
{
	[[self sharedController] enabledOrDisable:sender];
}

- (IBAction)uninstall:(id)sender
{
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert addButtonWithTitle:@"Cancel"];
	[alert addButtonWithTitle:@"Uninstall"];
	[alert setMessageText:NSLocalizedString(@"Are you sure you want to uninstall Safari AdBlock?",@"Uninstall Safari AdBlock confirmation dialog -> message text; put non breakable space for 'Safari AdBlock'")];
	[alert setInformativeText:NSLocalizedString(@"You will be asked for an administrator password.",@"Uninstall Safari AdBlock confirmation dialog -> informative text")];
	[alert setAlertStyle:NSWarningAlertStyle];
	[alert beginSheetModalForWindow:[_preferencesView window]
					  modalDelegate:self
					 didEndSelector:@selector(uninstallAlertDidEnd:returnCode:contextInfo:)
						contextInfo:nil];
}

- (void)uninstallAlertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if (returnCode == NSAlertSecondButtonReturn) {
		NSAlert *alert = [[[NSAlert alloc] init] autorelease];
		[alert addButtonWithTitle:@"OK"];
		[alert setAlertStyle:NSWarningAlertStyle];
		if (rmSafariAdBlock() == noErr) {
			[alert setMessageText:NSLocalizedString(@"Safari AdBlock has been successfully uninstalled.",@"Safari AdBlock successfully uninstalled alert -> message text")];
			[alert setInformativeText:NSLocalizedString(@"You need to restart Safari for changes to be effective.",@"Safari AdBlock successfully uninstalled alert -> informative text")];
		} else {
			[alert setMessageText:NSLocalizedString(@"Safari AdBlock could not be uninstalled.",@"Safari AdBlock failed to be uninstalled alert -> message text")];
			[alert setInformativeText:NSLocalizedString(@"Get support at http://safariadblock.sf.net to solve this issue.",@"Safari AdBlock failed to be uninstalled alert -> informative text")];
		}
		[alert runModal];
	}
}

#pragma mark -
#pragma mark Filters

- (IBAction)showFilterEditor:(id)sender
{
	NSString *filter = nil;
	if ([sender isKindOfClass:[NSTableView class]]) {
		filterBeingEdited = [[customFiltersController arrangedObjects] objectAtIndex:[sender clickedRow]];
		filter = [filterBeingEdited objectForKey:@"filter"];
	}
	[ruleEditorDelegate prepareFilterEditorWithFilter:filter];
	[NSApp beginSheet:filterEditor
	   modalForWindow:[_preferencesView window]
		modalDelegate:self
	   didEndSelector:@selector(addFilterSheetDidEndSheet:returnCode:contextInfo:)
		  contextInfo:nil];
}

- (void)addFilterSheetDidEndSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    [sheet orderOut:self];
}

- (IBAction)hideFilterEditor:(id)sender
{
    [NSApp endSheet:filterEditor];
}

- (IBAction)saveFilter:(id)sender
{
	if (filterBeingEdited) {
		[customFiltersController removeObject:filterBeingEdited];
		filterBeingEdited = nil;
	}
	[customFiltersController addObject:[NSDictionary dictionaryWithObject:[ruleEditorDelegate filter] forKey:@"filter"]];
	[self hideFilterEditor:self];
}

#pragma mark -
#pragma mark Subscriptions

- (IBAction)showSubscriptionEditor:(id)sender
{
	if ([sender isKindOfClass:[NSTableView class]]) {
		subscriptionBeingEdited = [[subscriptionsController selectedObjects] objectAtIndex:0];
		if (![[subscriptionBeingEdited objectForKey:SubscriptionIsCustomKey] boolValue])
			return;
		[subscriptionNameTextField setObjectValue:[subscriptionBeingEdited objectForKey:SubscriptionNameKey]];
		[subscriptionURLTextField setObjectValue:[[subscriptionBeingEdited objectForKey:SubscriptionURLsKey] objectAtIndex:0]];
		[[subscriptionURLTextField delegate] controlTextDidChange:[NSNotification notificationWithName:NSControlTextDidChangeNotification object:subscriptionURLTextField]];
	} else {
		subscriptionBeingEdited = nil;
		[subscriptionNameTextField setObjectValue:@""];
		[subscriptionURLTextField setObjectValue:@""];
	}
	[[subscriptionURLTextField delegate] reset];
	[NSApp beginSheet:subscriptionEditor
	   modalForWindow:[_preferencesView window]
		modalDelegate:self
	   didEndSelector:@selector(subscriptionEditorSheetDidEndSheet:returnCode:contextInfo:)
		  contextInfo:nil];
}

- (void)subscriptionEditorSheetDidEndSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    [sheet orderOut:self];
}

- (IBAction)hideSubscriptionEditor:(id)sender
{
    [NSApp endSheet:subscriptionEditor];
}

- (void)saveSubscription:(id)sender
{
	NSMutableDictionary *newSubscription;
	NSString *URL = [subscriptionURLTextField objectValue];
	NSString *name = [subscriptionNameTextField objectValue];
	if ([name length] == 0)
		name = URL;
	
	// We either edit an already existing entry
	if (subscriptionBeingEdited) {
		newSubscription = [NSMutableDictionary dictionaryWithDictionary:subscriptionBeingEdited];
		[newSubscription setValue:[NSArray arrayWithObject:URL] forKey:SubscriptionURLsKey];
		[newSubscription setValue:name forKey:SubscriptionNameKey];
		[subscriptionsController removeObject:subscriptionBeingEdited];
		[subscriptionsController addObject:newSubscription];
		
	// Or we add a new one
	} else {
		int maxOrder = 0, maxLanguageKey = 0;
		for (NSDictionary *subscription in [[ABController sharedController] subscriptions]) {
			if ([[subscription objectForKey:SubscriptionsOrderKey] intValue] > maxOrder)
				maxOrder = [[subscription objectForKey:SubscriptionsOrderKey] intValue];
			if ([[subscription objectForKey:SubscriptionsLanguageKey] intValue] > maxLanguageKey)
				maxLanguageKey = [[subscription objectForKey:SubscriptionsLanguageKey] intValue];
		}
		newSubscription = [NSMutableDictionary dictionaryWithObjectsAndKeys:
						   [NSArray arrayWithObject:URL], SubscriptionURLsKey,
						   name, SubscriptionNameKey,
						   [NSNumber numberWithInt:maxOrder+1], SubscriptionsOrderKey,
						   [NSString stringWithFormat:@"%d",maxLanguageKey+1], SubscriptionsLanguageKey,
						   [NSNumber numberWithBool:YES], SubscriptionIsCustomKey,
						   [NSNumber numberWithBool:YES], SubscriptionIsSubscribedKey,
						   nil];
		[subscriptionsController addObject:newSubscription];
	}
	
	
	subscriptionBeingEdited = nil;
	[subscriptionsController setSelectedObjects:[NSArray arrayWithObject:newSubscription]];
	[self hideSubscriptionEditor:self];
}

#pragma mark -
#pragma mark URL Tester

- (IBAction)showURLTester:(id)sender
{
	[NSApp beginSheet:URLTester
	   modalForWindow:[_preferencesView window]
		modalDelegate:self
	   didEndSelector:@selector(URLTesterSheetDidEndSheet:returnCode:contextInfo:)
		  contextInfo:nil];
}

- (void)URLTesterSheetDidEndSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    [sheet orderOut:self];
}

- (IBAction)hideURLTester:(id)sender
{
    [NSApp endSheet:URLTester];
}

- (IBAction)testURL:(id)sender
{
	NSString *URL = [URLToTestTextField objectValue];
	NSArray *whiteList = [[[ABController sharedController] filters] objectForKey:WhiteListFiltersKey];
	NSArray *blockList = [[[ABController sharedController] filters] objectForKey:BlockListFiltersKey];
	NSMutableArray *results = [NSMutableArray array];
	
	if (whiteList)
		for (NSString *regex in whiteList)
			if ([URL isMatchedByRegex:[RKRegex regexWithRegexString:regex options:RegexKitDefaultOptions]])
				[results addObject:[NSDictionary dictionaryWithObjectsAndKeys:
									@"Whitelisted", @"Status",
									regex, @"Filter",
									nil]];
	
	if (blockList)
		for (NSString *regex in blockList)
			if ([URL isMatchedByRegex:[RKRegex regexWithRegexString:regex options:RegexKitDefaultOptions]])
				[results addObject:[NSDictionary dictionaryWithObjectsAndKeys:
									@"Blocked", @"Status",
									regex, @"Filter",
									nil]];
	
	[self setURLTesterResults:results];
}

@end