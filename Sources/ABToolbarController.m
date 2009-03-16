#import "ABToolbarController.h"
#import "Constants.h"
#import "ABHelper.h"
#import "ABController.h"

@implementation ToolbarController (ABToolbarController)

+ (BOOL)swizzle
{
	NSArray *selectors = [NSArray arrayWithObjects:
						  @"toolbarAllowedItemIdentifiers:", 
						  @"toolbar:itemForItemIdentifier:willBeInsertedIntoToolbar:",
						  nil];
	
	for (NSString *selector in selectors)
		if (![ToolbarController overrideMethod:selector])
			return NO;
			
	return YES;	
}

- (NSArray *)_toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
	return [[self _toolbarAllowedItemIdentifiers:toolbar] arrayByAddingObject:SafariAdBlockToolbarIdentifier];
}

- (NSToolbarItem *)_toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
{
	if (![itemIdentifier isEqualToString:SafariAdBlockToolbarIdentifier])
		return [self _toolbar:toolbar itemForItemIdentifier:itemIdentifier willBeInsertedIntoToolbar:flag];
	
	NSButton *button = [[[NSButton alloc] initWithFrame:NSMakeRect(0.0, 0.0, 28.0, 22.0)] autorelease];
	[button setButtonType:NSToggleButton];
	[button setBezelStyle:NSTexturedRoundedBezelStyle];
	NSImage *on = [[[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleWithIdentifier:BundleIdentifier] pathForImageResource:@"ToolbarOn"]] autorelease];
	NSImage *off = [[[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleWithIdentifier:BundleIdentifier] pathForImageResource:@"ToolbarOff"]] autorelease];
	[button setImage:on];
	[button setAlternateImage:off];
	[button setTitle:nil];
	//[button setTarget:[ABController sharedController]];
	//[button setAction:@selector(enabledOrDisable:)];
	[button bind:@"value" toObject:[NSUserDefaults standardUserDefaults] withKeyPath:IsEnabledPrefsKey options:[NSDictionary dictionaryWithObject:NSNegateBooleanTransformerName forKey:NSValueTransformerNameBindingOption]];
	
	NSToolbarItem *toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier] autorelease];
	[toolbarItem setLabel:@"Safari AdBlock"];
	[toolbarItem setPaletteLabel:@"Enable/Disable Safari AdBlock"];
	[toolbarItem setToolTip:@"Enable/Disable Safari AdBlock"];
	[toolbarItem setView:button];	
	
    return toolbarItem;
}

@end
