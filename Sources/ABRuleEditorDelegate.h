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

@interface ABRuleEditorDelegate : NSObject {
	IBOutlet NSRuleEditor *ruleEditor;
	IBOutlet id ruleEditorRootItem;
	IBOutlet NSPopUpButton *ruleItem1, *ruleItem2, *ruleItem3, *ruleItem4;
	IBOutlet NSTextField *ruleItem5, *ruleItem5Label;
	NSString *filter;
	NSRect ruleItem5Frame;
}
@property(retain, readwrite) NSString *filter;
+ (ABRuleEditorDelegate *)defaultRuleEditorDelegate;
- (void)buildRuleControls;
- (void)buildRuleFilter;
- (void)prepareFilterEditorWithFilter:(NSString *)aFilter;
@end

@interface NSObject (ABRuleEditorChildItem)
- (void)ruleEditorChildItem:sender;
@end
