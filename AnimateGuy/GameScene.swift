//
//  GameScene.swift
//  AnimateGuy
//
//  Created by Jacob Mensch on 4/7/15.
//  Copyright (c) 2015 uB. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, AnalogControlPositionChange {
  
  // loop timing
  var lastUpdateTime: NSTimeInterval = 0
  var dt: NSTimeInterval = 0
  
  // character
  let man = SKSpriteNode(imageNamed: "man1.png")
  
  // animation
  var manAnimation: SKAction!
  var manTextures: [SKTexture] = []
  var manScale = CGFloat(0.5)
  var velocity = CGPointZero
  let manRotateRadiansPerSec: CGFloat = 4.0 * CGFloat(M_PI)

  // area bounds
  let playableRect: CGRect
  
  // debugging
  let debugOn = false
  
  ////////////////// INITIALIZATION ////////////////
  
  override init(size: CGSize) {
    
    // set up playableRect
    let maxAspectRatio: CGFloat = 16.0 / 9.0
    let playableHeight = size.width / maxAspectRatio
    let playableMargin = (size.height - playableHeight) / 2.0
    playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)
    
    // set up animation
    for i in 1...3 {
      manTextures.append(SKTexture(imageNamed: "man\(i)"))
    }
    
    super.init(size: size)
    
    manAnimation = getAnimation(10)
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  //////////////// DID MOVE TO VIEW /////////////////
  
  override func didMoveToView(view: SKView) {
    
    // set up edge loop
//    let rect = CGRect(x: playableRect.origin.x,
//      y: playableRect.origin.y + 0.1 * playableRect.height,
//      width: playableRect.size.width,
//      height: playableRect.size.height * 3)
    physicsBody = SKPhysicsBody(edgeLoopFromRect: playableRect)
    
    backgroundColor = SKColor.whiteColor()
    
    // set up background
    let background = SKSpriteNode(imageNamed: "background1")
    background.size = size
    background.anchorPoint = CGPointZero
    background.position = CGPointZero
    addChild(background)
    
    man.setScale(manScale)
    man.position = CGPoint(x: 400, y: 240)
    man.zPosition = 100
    addChild(man)
    man.physicsBody = SKPhysicsBody(rectangleOfSize: man.size)
    man.physicsBody?.restitution = 0.0
    
    if debugOn { debugDrawPlayableArea(view) }
  }
  
  //////////////////// UPDATE ///////////////////////
  
  override func update(currentTime: CFTimeInterval) {
    
    // update the time interval
    dt = lastUpdateTime > 0 ? currentTime - lastUpdateTime : dt
    lastUpdateTime = currentTime
    
    if man.actionForKey("jumping") == nil {
      if velocity.x < 0 {
        man.xScale = -1 * manScale
      } else if velocity.x > 0 {
        man.xScale = manScale
      }
    }
    
    moveSprite(man, velocity: velocity)
  }
  
  ///////////////// TOUCH HANDLING ///////////////////
  
  override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
//    let touch = touches.anyObject() as UITouch
//    let touchLocation = touch.locationInNode(self)
//    sceneTouched(touchLocation)
    //jump()
  }
  
  func sceneTouched(touchLocation: CGPoint) {
    moveToward(touchLocation)
  }
  
  //////////////////////////// GENERAL SPRITE MOVEMENT ////////////////////////////
  
  func moveSprite(sprite: SKSpriteNode, velocity: CGPoint) {
    let amountToMove = velocity * CGFloat(dt)
    sprite.position += amountToMove
  }
  
  //////////////////////////// MAN ////////////////////////////
  
  func moveToward(location: CGPoint) {
    let direction = location.x - man.position.x
    velocity = CGPoint(x: direction, y: 0)
    
    startAnimation()
  }
  
  func startAnimation() {
    if man.actionForKey("animation") == nil {
      man.runAction(
        SKAction.repeatActionForever(manAnimation),
        withKey: "animation")
    }
  }
  
  func stopAnimation() {
    man.removeActionForKey("animation")
    man.texture = SKTexture(imageNamed: "man1")
  }
  
  func getAnimation(speed: NSTimeInterval) -> SKAction {
    let time = 0.2
    return SKAction.repeatActionForever(
      SKAction.animateWithTextures(manTextures, timePerFrame: time))
  }
  
  func jump() {
    man.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 1200))
    
    let rotationDirection = man.xScale > 0 ? CGFloat(-4 * M_PI) : CGFloat(4 * M_PI)
    let duration = 1.0
    let rotate = SKAction.rotateByAngle(rotationDirection, duration: duration)
    let shrink = SKAction.sequence([
      SKAction.scaleBy(0.5, duration: duration / 2),
      SKAction.scaleBy(2.0, duration: duration / 2)])
    
    let rotateAndShrink = SKAction.group([rotate, shrink])
    
    man.runAction(rotateAndShrink, withKey: "jumping")
  }
  
  ///////////////// CONTROLS ///////////////////
  
  func analogControlPositionChanged(analogControl: AnalogControl, position: CGPoint) {
  //  println("The point is \(position)")
  
      if position.x == 0 {
        velocity.x = 0
        stopAnimation()
      } else {
        velocity.x = 500 * position.x
        startAnimation()
      }
    
      if man.actionForKey("jumping") == nil {
        if position.y < -0.5 {
          jump()
        }
      }
  }
  
  ////////////////// DEBUGGING //////////////////
  
  func debugDrawPlayableArea(view: SKView) {
    
    println("scene.frame = \(self.frame)")
    
    // playableRect in red
    let shape = SKShapeNode()
    let path = CGPathCreateMutable()
    CGPathAddRect(path, nil, playableRect)
    shape.path = path
    shape.strokeColor = SKColor.redColor()
    shape.lineWidth = 4.0
    shape.zPosition = 1000
    addChild(shape)
    println("playableRect = \(playableRect)")
    
    println("view.frame = \(view.frame)")
    
    println("-------------------------------------")
    
  }
}
