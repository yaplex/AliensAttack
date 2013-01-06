//
//  Created by Alex Shapovalov on 1/30/11
//  Copyright 2011 http://www.yaplex.com/ All rights reserved.
//

#import "cocos2d.h"
#import "GLES-Render.h"

@interface MainGameScene : CCLayer {

}

+(id) scene;
-(void) initBackground: (CGSize)screenSize;
-(void) initScoreLabel: (CGSize) screenSize;
-(void) initShieldLabel: (CGSize) screenSize;



-(void) initCannons: (CGSize) screenSize;
-(void) createNewAlien : (ccTime) dt;
-(void) addNewAlien: (CGPoint) p;
-(bool) checkIfBodyReachedGround: (CCSprite*)body;
-(void) createNewBulletAndMoveToLocation: (CGPoint) location;
-(void) makeExplosion: (CGPoint) location;
-(void) removeExplosionCallback: (id) sender;
-(void) substractLivePointsAlienHitTheGround;
-(bool) checkIfBodyWasKilled: (CCSprite*) body;
-(void) addPointsForKillingAlien;


@end
