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

#import <RegexKit/RegexKit.h>
#import "ABRuleEditorDelegate.h"
#import "NSString+ABString.h"


@implementation ABRuleEditorDelegate
@synthesize filter;

static ABRuleEditorDelegate *defaultRuleEditorDelegate = nil;

+ (ABRuleEditorDelegate *)defaultRuleEditorDelegate
{
	return defaultRuleEditorDelegate;
}

- (void)awakeFromNib
{	
	defaultRuleEditorDelegate = self;
	
	ruleItem5Frame = [ruleItem5 frame];
	
	[self buildRuleControls];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(buildRuleFilter)
												 name:NSControlTextDidChangeNotification
											   object:ruleItem5];

}

- (void)buildRuleControls
{
	[ruleItem1 setMenu:[ruleEditorRootItem menu]];
	[ruleItem2 setMenu:[[[ruleItem1 selectedItem] target] menu]];
	[ruleItem3 setMenu:[[[ruleItem2 selectedItem] target] menu]];
	if ([[[ruleItem3 selectedItem] target] isKindOfClass:[NSPopUpButton class]]) {
		[ruleItem4 setMenu:[[[ruleItem3 selectedItem] target] menu]];
		[ruleItem5 setFrame:ruleItem5Frame];
		[ruleItem4 setHidden:NO];
	} else {
		[ruleItem4 setHidden:YES];
		[ruleItem5 setFrame:NSMakeRect([ruleItem4 frame].origin.x, [ruleItem5 frame].origin.y, [ruleItem5 frame].size.width + [ruleItem5 frame].origin.x - [ruleItem4 frame].origin.x, [ruleItem5 frame].size.height)];
	}
	if ([[[ruleItem3 selectedItem] title] isEqualToString:@"is matched by"]) {
		[ruleItem5Label setObjectValue:@""];
	} else {
		[ruleItem5Label setObjectValue:@"Use * as the wildcard character"];
	}
	[ruleItem5Label setFrame:NSMakeRect([ruleItem5 frame].origin.x, [ruleItem5 frame].origin.y - 26, [ruleItem5 frame].size.width, [ruleItem5 frame].size.height)];
	[self buildRuleFilter];
}

- (void)buildRuleFilter
{
	NSMutableString *aFilter = [NSMutableString string];
	if ([[[ruleItem1 selectedItem] title] isEqualToString:@"Don't block"])
		[aFilter appendString:@"@@"];
	if ([[[ruleItem3 selectedItem] title] isEqualToString:@"is matched by"]) {
		if ([RKRegex isValidRegexString:[ruleItem5 objectValue] options:RKCompileNoOptions]) {
			[ruleItem5Label setObjectValue:@"The regular expression is valid."];
		} else {
			[ruleItem5Label setObjectValue:@"The regular expression is not valid!"];
		}
		[aFilter appendFormat:@"/%@/",[ruleItem5 objectValue]];
	} else {	
		if ([[[ruleItem3 selectedItem] title] isEqualToString:@"starts with"])
			[aFilter appendString:@"|"];
		if (![ruleItem4 isHidden])
			[aFilter appendString:[[ruleItem4 selectedItem] title]];
		[aFilter appendString:[ruleItem5 objectValue]];
		if ([[[ruleItem3 selectedItem] title] isEqualToString:@"ends with"])
			[aFilter appendString:@"|"];
	}
	[self setFilter:aFilter];
}

- (void)prepareFilterEditorWithFilter:(NSString *)aFilter
{
	if (!aFilter) {
		[ruleItem1 selectItemWithTitle:@"Block"];
		[self buildRuleControls];
		[ruleItem3 selectItemWithTitle:@"contains"];
		[self buildRuleControls];
		[ruleItem5 setObjectValue:@""];
	} else {
		NSDictionary *parsedFilter = [aFilter parseAsFilter];
		if ([[parsedFilter objectForKey:@"IsPageWhitelist"] boolValue]) {
			[ruleItem1 selectItemWithTitle:@"Don't block"];
			[self buildRuleControls];
			[ruleItem2 selectItemWithTitle:@"anything on pages"];
			[self buildRuleControls];
			if ([aFilter rangeOfString:@"https://"].location == NSNotFound) {
				[ruleItem4 selectItemWithTitle:@"http://"];
			} else {
				[ruleItem4 selectItemWithTitle:@"https://"];
			}
			[self buildRuleControls];
		} else {
			if ([[parsedFilter objectForKey:@"IsWhitelist"] boolValue]) {
				[ruleItem1 selectItemWithTitle:@"Don't block"];
			} else {
				[ruleItem1 selectItemWithTitle:@"Block"];
			}
			[self buildRuleControls];
			[ruleItem2 selectItemWithTitle:@"elements"];
			[self buildRuleControls];
			if ([[parsedFilter objectForKey:@"HasBeginningAnchor"] boolValue])
				[ruleItem3 selectItemWithTitle:@"starts with"];
			else if ([[parsedFilter objectForKey:@"HasEndAnchor"] boolValue])
				[ruleItem3 selectItemWithTitle:@"ends with"];
			else if ([[parsedFilter objectForKey:@"IsAlreadyRegularExpression"] boolValue])
				[ruleItem3 selectItemWithTitle:@"is matched by"];
			else
				[ruleItem3 selectItemWithTitle:@"contains"];
			[self buildRuleControls];
		}
		[ruleItem5 setObjectValue:[parsedFilter objectForKey:@"FilterEditorString"]];
	}
	[self buildRuleFilter];
}

@end

@implementation NSObject (ABRuleEditorChildItem)
- (void)ruleEditorChildItem:sender
{
	[[ABRuleEditorDelegate defaultRuleEditorDelegate] buildRuleControls];
	return;
}
@end