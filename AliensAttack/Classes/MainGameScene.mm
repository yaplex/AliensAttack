//
//  Created by Alex Shapovalov on 1/30/11
//  Copyright 2011 http://www.yaplex.com All rights reserved.
//

#import "MainGameScene.h"
#import <CCActionInterval.h>
#import "GameOverScene.h"
#import <SimpleAudioEngine.h>

#define PTM_RATIO 32

// enums that will be used as tags
enum {
	kAlienBatchNodeTag = 1,
	kBulletNodeTag = 2,	
};
CCSprite *_rightCannon;
CCSprite *_rightCannonBase;
CCSprite *_background;
NSMutableArray *_explosionsArray;
NSMutableArray *_aliens;
int _userScore;
int _shieldScore;

float _alienMoveSpeed;
float _cannonAngle = 30.0f;
CCLabelTTF *_scoreLabel;
CCLabelTTF *_shieldLabel;
@implementation MainGameScene
+(id) scene
{
	CCScene *scene = [CCScene node];
	MainGameScene *layer = [MainGameScene node];
	[scene addChild: layer];
	
	return scene;
}

-(id) init
{
		if ((self=[super init])) {
			self.isTouchEnabled = YES;
			self.isAccelerometerEnabled = YES;
			
			_userScore = 15;
			_shieldScore = 100;
			_alienMoveSpeed = 6.0f;
			CGSize screenSize = [CCDirector sharedDirector].winSize;
			
			_explosionsArray = [[NSMutableArray alloc] init];
			_aliens = [[NSMutableArray alloc] init];
					
			[self initScoreLabel: screenSize];
			[self initShieldLabel: screenSize];
			[self initBackground: screenSize];

			[self initCannons:screenSize];
			
			[self schedule: @selector(tick:)];
			[self schedule:@selector(createNewAlien:) interval:1.0f];
            
       
                SimpleAudioEngine* sharedAudioEngine = [SimpleAudioEngine sharedEngine];
                [sharedAudioEngine playBackgroundMusic:@"background.mp3" loop:YES];
    
		
        }
	return self;
}

-(void) initCannons: (CGSize) screenSize
{
	_rightCannonBase = [CCSprite spriteWithFile:@"cannon-base.png"];
	CGSize baseBoxSize = [[_rightCannonBase texture] contentSize];
	_rightCannonBase.position = ccp(screenSize.width - baseBoxSize.width/2, baseBoxSize.height/2);
	[self addChild:_rightCannonBase z:1];
	
	_rightCannon = [CCSprite spriteWithFile:@"cannon-main.png"];
	_rightCannon.anchorPoint = ccp(1,0);
	CGSize rightCannonSize = [[_rightCannon texture] contentSize];
	_rightCannon.position = ccp(screenSize.width -baseBoxSize.width/2-5, baseBoxSize.height/2-5);
	_rightCannon.rotation = _cannonAngle;
	
	[self addChild:_rightCannon z:1];
}

-(void) createNewAlien : (ccTime) dt
{
	CGSize screenSize = [CCDirector sharedDirector].winSize;
	int randomX = (arc4random() % ((int)screenSize.width - 64)) + 64;// 20 pixels from both sides should not contain sprites
	float randomY = (float)screenSize.height - 5.0f;
	CGPoint location = ccp(randomX, randomY);
	[self addNewAlien:location];
}


-(void) draw
{
	//world->DrawDebugData();
}

-(void) initScoreLabel: (CGSize) screenSize
{
	_scoreLabel = [CCLabelTTF labelWithString:@"Score: 0" 
										   fontName:@"Marker Felt" 
										   fontSize:24];
	[self addChild:_scoreLabel z:100000];
	[_scoreLabel setColor:ccc3(0,0,255)];
	_scoreLabel.anchorPoint = CGPointMake(1.0f, 1.0f);
	_scoreLabel.position = CGPointMake(screenSize.width, screenSize.height);
}

-(void) initShieldLabel: (CGSize) screenSize
{
	_shieldLabel = [CCLabelTTF labelWithString:@"Shield: 100%" 
										   fontName:@"Marker Felt" 
										   fontSize:24];
	[self addChild:_shieldLabel z:100000];
	[_shieldLabel setColor:ccc3(0,0,255)];
	_shieldLabel.position = ccp( screenSize.width - 275, screenSize.height-15);
}

-(void) addNewAlien: (CGPoint) p
{
	CCSprite *alien = [CCSprite spriteWithFile:@"alien.png"];
	alien.position = ccp(p.x, p.y);
	alien.scale = 0.6f;
	id shake = [CCShaky3D actionWithRange:2 shakeZ:NO grid:ccg(5, 7) duration:5];
	[alien runAction:[CCRepeatForever actionWithAction:shake]];	
	CGPoint newPosition = ccp(alien.position.x, -10);
	id moveAlienAction = [CCMoveTo actionWithDuration:_alienMoveSpeed position:newPosition];
	[alien runAction:moveAlienAction];
	
	[self addChild:alien z:1];	
	[_aliens addObject:alien];
}

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{	
	static float prevX=0, prevY=0;
	
	//#define kFilterFactor 0.05f
#define kFilterFactor 1.0f	// don't use filter. the code is here just as an example
	
	float accelX = (float) acceleration.x * kFilterFactor + (1- kFilterFactor)*prevX;
	float accelY = (float) acceleration.y * kFilterFactor + (1- kFilterFactor)*prevY;
	
	prevX = accelX;
	prevY = accelY;

}


-(void) initBackground: (CGSize)screenSize
{
	_background = [CCSprite spriteWithFile:@"background.png" ];
	_background.position = ccp(screenSize.width/2, screenSize.height/2);
	
	CGSize backSize = _background.contentSize;
	 
	_background.scaleY = screenSize.height / backSize.height; 
	//_background.scaleX = screenSize.width / backSize.width;  
	
	float canMoveTo = (backSize.width - screenSize.width)/2;
	ccTime moveSpeed = 15;
	id moveRight = [CCMoveBy actionWithDuration:moveSpeed position:ccp(canMoveTo,0)];
	id moveLeft = [CCMoveBy actionWithDuration:moveSpeed * 2 position:ccp(-canMoveTo * 2, 0)];
	id moveToStart = [CCMoveBy actionWithDuration:moveSpeed position:ccp(canMoveTo,0)];
	id repeatForewer = [CCRepeatForever actionWithAction:
						[CCSequence actions:moveRight, moveLeft, moveToStart, nil]];
	
	[_background runAction:repeatForewer];
	
	[self addChild:_background z:0 tag:1];
	
	CCSprite *ground = [CCSprite spriteWithFile:@"ground.png"];
	CGSize groundBoxSize = [[ground texture] contentSize];
	ground.position = ccp(screenSize.width/2, groundBoxSize.height/2);
	[self addChild:ground z:0];
}

-(void) tick: (ccTime) dt
{

	NSEnumerator *aliensEnumerator = [_aliens objectEnumerator];
	id alienObject;
	while (alienObject = [aliensEnumerator nextObject]) {
		CCSprite *myActor = (CCSprite*)alienObject;
		bool isReached = [self checkIfBodyReachedGround: myActor];
		if (isReached) {
			[self substractLivePointsAlienHitTheGround];
		}		
		else {
			bool isKilled = [self checkIfBodyWasKilled:myActor];
			if (isKilled) {
				[self addPointsForKillingAlien];
			}
		}
		
	}
}

-(void) gameOver
{
	// show new scene with game over text and two buttons: 
	// play again and go to menu
	[[CCDirector sharedDirector] replaceScene:[CCTransitionFlipAngular 
											   transitionWithDuration:0.5f 
											   scene:[GameOverScene scene]]];
}
-(void) addPointsForKillingAlien
{
	_userScore += 10;
	[_scoreLabel setString:[NSString stringWithFormat:@"Money: $%d", _userScore]];
	
	if(_alienMoveSpeed> 2.3) _alienMoveSpeed -= 0.05f;
}

-(void) substractLivePointsAlienHitTheGround
{
	_shieldScore -= 10;
	if (_shieldScore <=0) {
		[self gameOver];
	}
	[_shieldLabel setString:[NSString stringWithFormat:@"Shield: %d%s", _shieldScore, "%"]];
}

-(bool) checkIfBodyReachedGround: (CCSprite*)body
{
	CCSprite *myActor = body;
	CGRect boundingBox = [myActor boundingBox];
	CGPoint spritePosition = [myActor position];
	if (spritePosition.y <= 18.0f) {
		[_aliens removeObject:myActor];
		[myActor removeFromParentAndCleanup:YES];
		return YES;
	}
	
	return NO;
}

-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{	UITouch	*touch = [touches anyObject];
	CGPoint location = [touch locationInView: [touch view]];
	location = [[CCDirector sharedDirector] convertToGL:location];
	
	[self createNewBulletAndMoveToLocation:location];
}

-(void) createNewBulletAndMoveToLocation: (CGPoint) location
{
	CCSprite *bullet = [CCSprite spriteWithFile:@"bullet.png"];
	bullet.position = ccp(_rightCannon.position.x, _rightCannon.position.y + 10);
	
	// bullet rotation
	float angelRadians = atanf(
							   ((float)_rightCannon.position.y - (float)location.y)
							   /
							   ((float)_rightCannon.position.x - (float)location.x)
							   );
	float angelDegrees = CC_RADIANS_TO_DEGREES(angelRadians);
	float cocosAngel = -1 * angelDegrees;
	
	bullet.rotation = cocosAngel;
	
	if (cocosAngel >=70) {
		_cannonAngle = 70;
		
	}
	else {
		if (cocosAngel < 0) {
			_cannonAngle = -1*cocosAngel;
		}
		else {
			_cannonAngle = cocosAngel;
		}		
	}
	
	_rightCannon.rotation = _cannonAngle;
	//	CGPoint	startLocation = ccp(_rightCannon.position.x - 73 * sin(_cannonAngle), _rightCannon.position.y -73 * cos(_cannonAngle));
	//bullet.position = startLocation;

    SimpleAudioEngine* sharedAudioEngine = [SimpleAudioEngine sharedEngine];
    [sharedAudioEngine playEffect:@"laser.caf"];
    
	id shootAction = [CCMoveTo actionWithDuration:0.3f position:location];	
	id shootDone = [CCCallFuncN actionWithTarget:self selector:@selector(bulletMoveFinished:)];
	[bullet runAction:[CCSequence actions: shootAction, shootDone, nil]];
	
	[self addChild:bullet z:10 tag:kBulletNodeTag];
	_userScore -= 5;
	[_scoreLabel setString:[NSString stringWithFormat:@"Money: $%d", _userScore]];
}

	 -(void)bulletMoveFinished: (id) sender
	 {
		 CCSprite *bullet = (CCSprite *)sender;
		 CGPoint explosionPosition = ccp(bullet.position.x, bullet.position.y);
		 [self makeExplosion: explosionPosition];
		 [self removeChild:bullet cleanup:YES];
	 }
	 
-(void) makeExplosion: (CGPoint) location
{
	CCSprite *explosion = [CCSprite spriteWithFile:@"explosion.png"];	
	[_explosionsArray addObject:explosion];
	[self addChild:explosion z:11];
	explosion.scale = 0.01f;
	explosion.position = ccp(location.x, location.y);
	id scaleAction = [CCScaleTo actionWithDuration:1.2f scale:0.9f];
	id fadeOut = [CCFadeOut actionWithDuration:0.7f];
	id removeExplosion = [CCCallFuncN actionWithTarget:self selector:@selector(removeExplosionCallback:)];
    
    SimpleAudioEngine* sharedAudioEngine = [SimpleAudioEngine sharedEngine];
    [sharedAudioEngine playEffect:@"explosion.caf"];

    
	[explosion runAction:[CCSequence actions:scaleAction, fadeOut, removeExplosion, nil]];
}

-(bool) checkIfBodyWasKilled: (CCSprite*) body
{
	CCSprite *myActor = body;
	CGRect boundingBox = [myActor boundingBox];	
	
	id explosion;
	NSEnumerator *explosionEnumerator = [_explosionsArray objectEnumerator];
	while (explosion = [explosionEnumerator nextObject]) {
		CCSprite *exp = (CCSprite *)explosion;
			CGRect exRect = [exp boundingBox];
			if (CGRectIntersectsRect(exRect, boundingBox)) {
				CCLOG(@"intercection");
				 
				[_aliens removeObject:myActor];
				[myActor removeFromParentAndCleanup:YES];
				return YES;
		}
	}
	
	return NO;
}

-(void) removeExplosionCallback: (id) sender
{
	CCSprite *explosion = (CCSprite *)sender;
	[_explosionsArray removeObject:explosion];
	[explosion removeFromParentAndCleanup:YES];
}
	 
- (void) dealloc
{

	
	// don't forget to call "super dealloc"
	[super dealloc];
}

@end
