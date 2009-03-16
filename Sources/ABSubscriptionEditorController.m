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

#import "ABSubscriptionEditorController.h"


@implementation ABSubscriptionEditorController
@synthesize isLoading, isValid, hasFailed;

- (void)awakeFromNib
{
	[self reset];
}

- (void)reset
{
	currentConnection = nil;
	currentStatusCode = 0;
	[self setIsLoading:[NSNumber numberWithBool:NO]];
	[self setIsValid:[NSNumber numberWithBool:NO]];
	[self setHasFailed:[NSNumber numberWithInt:NO]];
	[loadingProgressIndicator startAnimation:nil];
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
	if (currentConnection) {
		[currentConnection cancel];
		[self clean];
	}
	
	[self setIsValid:[NSNumber numberWithBool:NO]];
	[self setHasFailed:[NSNumber numberWithInt:NO]];
	
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[(NSTextField *)[aNotification object] objectValue]]
											 cachePolicy:NSURLRequestUseProtocolCachePolicy
										  timeoutInterval:60.0];
	currentConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	
	if (currentConnection)
		[self setIsLoading:[NSNumber numberWithBool:YES]];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	if ([response isKindOfClass:[NSHTTPURLResponse class]])
		currentStatusCode = [(NSHTTPURLResponse *)response statusCode];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[self setIsLoading:[NSNumber numberWithBool:NO]];
	[self setIsValid:[NSNumber numberWithBool:NO]];
	[self setHasFailed:[NSNumber numberWithInt:YES]];
	[self clean];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	[self setIsLoading:[NSNumber numberWithBool:NO]];
	if (200 <= currentStatusCode && currentStatusCode < 300) {
		[self setIsValid:[NSNumber numberWithBool:YES]];
		[self setHasFailed:[NSNumber numberWithInt:NO]];
	} else {
		[self setIsValid:[NSNumber numberWithBool:NO]];
		[self setHasFailed:[NSNumber numberWithInt:YES]];
	}
	[self clean];
}

- (void)clean
{
	[currentConnection release];
	currentConnection = nil;
	currentStatusCode = 0;
}

@end
