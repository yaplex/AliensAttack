//
//  Created by Alex Shapovalov on 1/30/11
//  Copyright 2011 http://www.yaplex.com/ All rights reserved.
//


#import "GameOverScene.h"
#import "MainGameScene.h"
#import <SimpleAudioEngine.h>


@implementation GameOverScene

+(id) scene
{
	CCScene *scene = [CCScene node];
	GameOverScene *layer = [GameOverScene node];
	[scene addChild: layer];
	
	return scene;
}


-(id) init
{
	if ((self=[super init])) {
		self.isTouchEnabled = YES;
		self.isAccelerometerEnabled = YES;
		
		CGSize screenSize = [CCDirector sharedDirector].winSize;
		
		[self initBackground: screenSize];
		
	}
	return self;
}

-(void) initBackground: (CGSize) screenSize
{
	CCSprite *background = [CCSprite spriteWithFile:@"game-over-screen.png"];
	CGRect textureRect = [background textureRect];
	background.scaleX = screenSize.width/textureRect.size.width;
	background.scaleY = screenSize.height/textureRect.size.height;
	
	background.position = ccp(screenSize.width/2, screenSize.height/2);
	
	[self addChild:background];
	CCMenuItemImage *playAgainButton = [CCMenuItemImage itemFromNormalImage:@"play-again-button.png" 
													   selectedImage:@"play-again-button.png" 
													   target:self 
															selector:@selector(playAgain:)];
	playAgainButton.scale = 0.7f;
	CCMenu *gameOverMenu = [CCMenu menuWithItems:playAgainButton, nil];
	gameOverMenu.position = ccp(screenSize.width/2, screenSize.height/2);
	[gameOverMenu alignItemsVertically];
	[self addChild:gameOverMenu];
	
}

-(void) playAgain:(CCMenuItem *) menuItem
{
    SimpleAudioEngine* sharedAudioEngine = [SimpleAudioEngine sharedEngine];
    [sharedAudioEngine playEffect:@"button-click.caf"];
    
	[[CCDirector sharedDirector] replaceScene:[MainGameScene scene]];
}

-(void) goToMainMenu: (CCMenuItem *) menuItem
{
	//[[CCDirector sharedDirector] replaceScene:[MainMenuScene scene]];
}


@end
