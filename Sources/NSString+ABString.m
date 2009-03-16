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

#import "NSString+ABString.h"
#import <RegexKit/RegexKit.h>
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (ABString)

- (NSDictionary *)parseAsFilter
{	
	NSMutableDictionary *filter = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								   [NSNumber numberWithBool:NO],@"IsWhitelist",
								   nil,@"RegularExpression",
								   nil];
	
	NSString *current = [NSString stringWithString:self];
	NSString *filterEditorString = current;

	if ([current length] == 0)
		return nil;
	
	// For now, we ignore special-adblock-filters
	//current = [current stringByMatching:@"\\$(~?[\\w\\-]+(?:,~?[\\w\\-]+)*)$"
	//							replace:1
	//				withReferenceString:@""];
	
	if ([self isMatchedByRegex:@"#"])
		return nil;
	if ([self isMatchedByRegex:@"\\$"])
		return nil;
	
	// Comment?
	if ([current length] >= 1 && [current characterAtIndex:0] == '!')
		return nil;
	
	// Whitelist?
	if ([current length] >= 2 && [current characterAtIndex:0] == '@' && [current characterAtIndex:1] == '@') {
		current = [current substringFromIndex:2];
		filterEditorString = current;
		if ([current isMatchedByRegex:@"^\\|?https?://"]) {
			[filter setObject:[NSNumber numberWithBool:YES] forKey:@"IsPageWhitelist"];
			filterEditorString = [filterEditorString stringByMatching:@"^\\|?https?://" replaceWithEmptyString:1];
		} else {
			[filter setObject:[NSNumber numberWithBool:YES] forKey:@"IsWhitelist"];
			filterEditorString = current;
		}
	}
	
	// Regular expression?
	if ([current length] >= 2 && [current characterAtIndex:0] == '/' && [current characterAtIndex:[current length]-1] == '/') {
		[filter setObject:[NSNumber numberWithBool:YES] forKey:@"IsAlreadyRegularExpression"];
		current = [current substringWithRange:NSMakeRange(1, [current length]-2)];
		filterEditorString = current;
	
	} else {
		NSString *anchorParsed;
		
		// Next few lines inspired by AdBlock Plus
		// http://adblockplus.org
		// Prefs.js, line 924 of CVS version 1.64 (Mon Sep 24 09:22:37 2007)
		
		// Escape special symbols
		current = [current stringByMatching:@"(\\W)"
									replace:RKReplaceAll
						withReferenceString:@"\\$1"];
		
		// Replace "\*" by ".*"
		current = [current stringByMatching:@"\\\\\\*"
									replace:RKReplaceAll
						withReferenceString:@".*"];
		
		// Anchor at beginning
		anchorParsed = [current stringByMatching:@"^\\\\\\|"
										 replace:1
							 withReferenceString:@"^"];
		if (![current isEqualToString:anchorParsed]) {
			[filter setObject:[NSNumber numberWithBool:YES] forKey:@"HasBeginningAnchor"];
			current = anchorParsed;
			filterEditorString = [filterEditorString stringByMatching:@"^\\|" replace:1 withReferenceString:@""];
		}
		
		// Anchor at end
		anchorParsed = [current stringByMatching:@"\\\\\\|$"
										 replace:1
							 withReferenceString:@"$$"];
		if (![current isEqualToString:anchorParsed]) {
			[filter setObject:[NSNumber numberWithBool:YES] forKey:@"HasEndAnchor"];
			current = anchorParsed;
			filterEditorString = [filterEditorString stringByMatching:@"\\|$" replace:1 withReferenceString:@""];
			
		}
		
		// Remove leading and trailing wildcards
		current = [current stringByMatching:@"^(\\.\\*)"
									replace:1
						withReferenceString:@""];
		current = [current stringByMatching:@"(\\.\\*)$"
									replace:1
						withReferenceString:@""];
				   
	}
	
	[filter setObject:current forKey:@"RegularExpression"];
	[filter setObject:filterEditorString forKey:@"FilterEditorString"];
	return filter;
}

// FIXME: RegexKit bug?
- (NSString *)stringByMatching:(id)aRegex replaceWithEmptyString:(const NSUInteger)count
{
	NSMutableString *temp = [NSMutableString stringWithString:[self stringByMatching:aRegex replace:count withReferenceString:@"FIX_THIS_BUG"]];
	[temp replaceOccurrencesOfString:@"FIX_THIS_BUG" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	return temp;
}

// Thanks, http://projects.stoneship.org/hg/shared/cocoa_crypto_hashing/file/de6f737ef575
- (NSString *)sha1
{
	unsigned char digest[CC_SHA1_DIGEST_LENGTH];
	char finaldigest[2*CC_SHA1_DIGEST_LENGTH];
	int i;
	
	NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
	CC_SHA1([data bytes],[data length],digest);
	for(i=0;i<CC_SHA1_DIGEST_LENGTH;i++) sprintf(finaldigest+i*2,"%02x",digest[i]);
	
	return [NSString stringWithCString:finaldigest length:2*CC_SHA1_DIGEST_LENGTH];
}

@end
