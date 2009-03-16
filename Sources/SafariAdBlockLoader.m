#import "SafariAdBlockLoader.h"


@implementation SafariAdBlockLoader

+ (void)load
{
	if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.Safari"]) {
		NSString *path = [[[NSBundle bundleWithIdentifier:@"net.sourceforge.SafariAdBlockLoader"] builtInPlugInsPath] stringByAppendingPathComponent:@"Safari AdBlock.bundle"];
		NSError *error;
		if (![[NSBundle bundleWithPath:path] loadAndReturnError:&error])
			NSLog(@"Safari AdBlock could not be loaded: %@", error);
	}
}

@end
