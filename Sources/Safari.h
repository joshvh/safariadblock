#import <WebKit/WebKit.h>

@interface LoadProgressMonitor : NSObject
@end

@interface LocationChangeHandler : NSObject
@end

@interface BrowserWebView
- (id)expectedOrCurrentURL;
@end

@interface ToolbarController : NSObject
- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar;
@end
