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
#import "NSPreferences.h"
#import "ABController.h"
#import "ABRuleEditorDelegate.h"

@interface ABPreferencesModule : NSPreferencesModule <NSPreferencesModule> {
	ABController *sharedController;
	IBOutlet NSArrayController *subscriptionsController, *customFiltersController;
	IBOutlet NSTableView *subscriptionsTable, *customFiltersTable;
	IBOutlet NSWindow *filterEditor, *subscriptionEditor, *URLTester;
	IBOutlet ABRuleEditorDelegate *ruleEditorDelegate;
	IBOutlet NSTextField *subscriptionURLTextField, *subscriptionNameTextField, *URLToTestTextField;
	NSString *versionLabel;
	NSDictionary *filterBeingEdited, *subscriptionBeingEdited;
	NSArray *URLTesterResults;
}
@property(copy, readwrite) NSString *versionLabel;
@property(retain, readwrite) NSArray *URLTesterResults;

- (IBAction)enabledOrDisable:(id)sender;
- (IBAction)showFilterEditor:(id)sender;
- (IBAction)hideFilterEditor:(id)sender;
- (IBAction)saveFilter:(id)sender;
- (IBAction)showSubscriptionEditor:(id)sender;
- (IBAction)uninstall:(id)sender;
- (void)uninstallAlertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo;
- (void)subscriptionEditorSheetDidEndSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;
- (IBAction)hideSubscriptionEditor:(id)sender;
- (void)saveSubscription:(id)sender;
- (IBAction)showURLTester:(id)sender;
- (IBAction)hideURLTester:(id)sender;
- (IBAction)testURL:(id)sender;
@end

