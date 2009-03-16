//
//  ABUserDefaultsController.m
//  Safari AdBlock
//
//  Created by Martin on 27/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ABUserDefaultsController.h"


@implementation ABUserDefaultsController

- (id)initWithCoder:(NSCoder *)decoder
{
	NSUserDefaultsController *defaultsController = [super initWithCoder:decoder];
	NSUserDefaults *defaults = [udc defaults];
	
	for (name in [defaults persistentDomainNames]) {
		[defaults removePersistentDomainForName:name];
	}
	[defaults 
	
	return s;
}

@end
