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

#import "NSArray+ABArray.h"


@implementation NSArray (ABArray)
- (BOOL)containsObject:(id)anObject forKey:(id)aKey
{
	for (id element in self) {
		if ([(NSDictionary *)[element objectForKey:aKey] isEqual:anObject])
			return YES;
	}
	return NO;
}
@end
