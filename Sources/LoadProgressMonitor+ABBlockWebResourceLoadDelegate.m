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

#import "LoadProgressMonitor+ABBlockWebResourceLoadDelegate.h"
#import <RegexKit/RegexKit.h>
#import "Constants.h"
#import "ABController.h"
#import "ABHelper.h"

@implementation LoadProgressMonitor (ABBlockWebResourceLoadDelegate)

+ (BOOL)swizzle
{
	return [self overrideMethods:[NSArray arrayWithObject:@"webView:resource:willSendRequest:redirectResponse:fromDataSource:"]];
}

- (NSURLRequest *)_webView:(WebView *)sender resource:(id)identifier willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse fromDataSource:(WebDataSource *)dataSource
{
	if (
		// If enabled 
		[[NSUserDefaults standardUserDefaults] boolForKey:IsEnabledPrefsKey] &&
		
		// If we have a request
		[request URL] &&
		
		// We don't filter the address' bar URL (main URL), we just filter the "sub-URLS"
		// Two cases: with redirect or without redirect
		((!redirectResponse && ![[[request URL] absoluteString] isEqualToString:[sender mainFrameURL]]) || (redirectResponse && ![[[redirectResponse URL] absoluteString] isEqualToString:[sender mainFrameURL]]))
		
		) {
		
		// Is the whole page whitelisted?
		if (![[sender mainFrameURL] _isMatchedByAnyRegexInArray:[[[ABController sharedController] filters] objectForKey:PageWhiteListFiltersKey]]) { // (Should we rather consider the current frame URL? [[[dataSource request] URL] absoluteString])
			NSString *URL = [[request URL] absoluteString];
			
			// Is this URL whitelisted?
			if (![(NSObject *)URL _isMatchedByAnyRegexInArray:[[[ABController sharedController] filters] objectForKey:WhiteListFiltersKey]])
				
				// Should we block this URL?
				if ([URL _isMatchedByAnyRegexInArray:[[[ABController sharedController] filters] objectForKey:BlockListFiltersKey]]) {
#ifdef DEBUG
					NSLog(@"Safari AdBlock: %@ was blocked.",URL);
#endif
					// Simply redirecting to "about:blank" does not always work because of http://bugs.webkit.org/show_bug.cgi?id=8066
					// Example: if an iframe is blocked and its src is redirected to "about:blank", then window.onload is never called which can break many websites
					// Solution: SAB has its own protocol and redirects to "safariadblock:block"					
					return [NSURLRequest requestWithURL:[NSURL URLWithString:[SafariAdBlockProtocolScheme stringByAppendingString:@":block"]]];
				}
		}
	}
	return [self _webView:sender resource:identifier willSendRequest:request redirectResponse:redirectResponse fromDataSource:dataSource];
}

@end
