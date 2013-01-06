//
//  Created by Alex Shapovalov on 1/30/11
//  Copyright 2011 http://www.yaplex.com/ All rights reserved.
//


#import <UIKit/UIKit.h>

@class RootViewController;

@interface AliensAttackAppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
