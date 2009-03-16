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

#import "ABValueTransformers.h"

@implementation ABBooleanToStateValueTransformer

+ (Class)transformedValueClass {
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;   
}

- (id)transformedValue:(id)value {
	if ([value boolValue])
		return NSLocalizedString(@"Safari AdBlock is enabled",@"Preferences pane -> status text");
	else
		return NSLocalizedString(@"Safari AdBlock is disabled",@"Preferences pane -> status text");
}

@end

@implementation ABBooleanToInverseStateValueTransformer

+ (Class)transformedValueClass {
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;   
}

- (id)transformedValue:(id)value {
	if ([value boolValue])
		return NSLocalizedString(@"Disable",@"Preferences pane -> enabled/disable button title");
	else
		return NSLocalizedString(@"Enable",@"Preferences pane -> enabled/disable button title");
}

@end
