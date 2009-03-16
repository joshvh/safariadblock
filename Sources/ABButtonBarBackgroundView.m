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

#import "ABButtonBarBackgroundView.h"
#import "Constants.h"

@implementation ABButtonBarBackgroundView

- (void)drawRect:(NSRect)rect
{
    [[NSColor colorWithDeviceWhite:0.7 alpha:1.0] set];
    [NSBezierPath fillRect:rect];	
	NSImage *img = [[NSImage alloc] initWithContentsOfFile:
					[[NSBundle bundleWithIdentifier:BundleIdentifier]
					 pathForImageResource:@"ButtonBarBackground"]];
	[img drawInRect:NSMakeRect(1, 1, rect.size.width-2, rect.size.height-1)
		   fromRect:NSZeroRect
		  operation:NSCompositeSourceOver
		   fraction:1.0];
	[img setFlipped:YES];
	[img release];
}

@end
