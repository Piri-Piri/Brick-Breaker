//
//  GameScene.swift
//  Brick Breaker
//
//  Created by David Pirih on 12.10.14.
//  Copyright (c) 2014 Piri-Piri. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var menu: Menu!
    
    var brickLayer: SKNode!
    var level: [[Int]] = [[]]
    var currentLevel:Int = 1 {
        didSet {
            levelDisplay.text = "Level: \(currentLevel)"
            menu.levelNumber = currentLevel
        }
    }
    let kFinalLevel:Int = 9
    
    var paddle: SKSpriteNode!
    
    let ballSpeed: CGFloat = 350.0
    var isBallReleased: Bool = false
    var isBallOnPaddle: Bool = false
    
    var levelDisplay: SKLabelNode!
    var hearts: NSMutableArray!
    var lives: Int = 2 {
        didSet {
            for var i = 0; i < hearts.count; i++ {
                let heart = (hearts.objectAtIndex(i) as SKSpriteNode)
                
                if lives > i {
                    heart.texture = SKTexture(imageNamed: "HeartFull")
                } else {
                    heart.texture = SKTexture(imageNamed: "HeartEmpty")
                }
            }
        }
    }
    
    let kBallCategory:UInt32    = 0x1 << 0
    let kPaddleCategory:UInt32  = 0x1 << 1
    let kEdgeCategory:UInt32    = 0x1 << 2
    /* Category for Brick also defined in its class */
    let kBrickCategory:UInt32   = 0x1 << 3
    
    var ballBounceSound: SKAction!
    var paddleBounceSound: SKAction!
    var levelUpSound: SKAction!
    var loseLifeSound: SKAction!
    
    var previousPosition:CGPoint = CGPointZero
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        // Setup background
        self.backgroundColor = UIColor.whiteColor()
        
        // Setup PhysicsWorld
        self.physicsWorld.gravity = CGVectorMake(0.0, 0.0)
        self.physicsWorld.contactDelegate = self
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRectMake(0, -128, view.frame.size.width, view.frame.size.height + 100))
        self.physicsBody?.categoryBitMask = kEdgeCategory
        
        // Setup Paddle
        paddle = SKSpriteNode(imageNamed: "Paddle")
        paddle.position = CGPointMake(view.frame.size.width * 0.5, 90)
        paddle.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(paddle.size.width, paddle.size.height))
        paddle.physicsBody?.dynamic = false
        paddle.physicsBody?.categoryBitMask = kPaddleCategory
        self.addChild(paddle)
        
        // Seup HUD Bar
        let hudBar = SKSpriteNode(color: UIColor(red: 0.831, green: 0.831, blue: 0.831, alpha: 1.0), size: CGSizeMake(view.frame.size.width, 28))
        hudBar.position = CGPointMake(0, view.frame.size.height)
        hudBar.anchorPoint = CGPointMake(0, 1)
        self.addChild(hudBar)
        
        // Setup level label
        levelDisplay = SKLabelNode(fontNamed: "Futura")
        levelDisplay.text = "Level: 1"
        levelDisplay.fontColor = SKColor.grayColor()
        levelDisplay.fontSize = 15.0
        levelDisplay.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        levelDisplay.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Top
        levelDisplay.position = CGPointMake(10, -10)
        hudBar.addChild(levelDisplay)
        
        
        // Setup HUD with hearts (26x22)
        hearts = [SKSpriteNode(imageNamed: "HeartFull"),SKSpriteNode(imageNamed: "HeartFull")]
        for var i = 0; i < hearts.count; i++ {
            let heart = (hearts.objectAtIndex(i) as SKSpriteNode)
            
            heart.position = CGPointMake(view.frame.size.width - (16.0 + (29.0 * CGFloat(i))), view.frame.size.height - 14)
            self.addChild(heart)
        }
        
        // Setup Sounds
        ballBounceSound = SKAction.playSoundFileNamed("BallBounce.caf", waitForCompletion: false)
        paddleBounceSound = SKAction.playSoundFileNamed("PaddleBounce.caf", waitForCompletion: false)
        levelUpSound = SKAction.playSoundFileNamed("LevelUp.caf", waitForCompletion: false)
        loseLifeSound = SKAction.playSoundFileNamed("LoseLife.caf", waitForCompletion: false)
        
        // Setup Bricks
        brickLayer = SKNode()
        brickLayer.position = CGPointMake(0.0, view.frame.size.height - 28)
        self.addChild(brickLayer)
        
        // Add Mneu
        menu = Menu()
        menu.position = CGPointMake(view.frame.size.width * 0.5, view.frame.size.height * 0.5)
        self.addChild(menu)
        
        // Start Gameplay (first level)
        loadLevel(currentLevel)
        newBall()
    }
    
    func newBall() {
        // remove existing ball(s)
        self.enumerateChildNodesWithName("ball", usingBlock: { (node, stop) -> Void in
            node.removeFromParent()
        })
        
        // Setup Ball: spawn at paddle
        let ball = SKSpriteNode(imageNamed: "BallBlue")
        ball.position = CGPointMake(0.0, paddle.size.height)
        paddle.addChild(ball)
        
        self.isBallReleased = false

        // Reset paddle position
        paddle.position = CGPointMake(self.view!.frame.size.width * 0.5, 90)
    }
    
    func loadLevel(levelNumber: Int) {
        brickLayer.removeAllChildren()
        switch levelNumber {
        case 1:
            level = [[1,2,3,3,2,1],[0,1,2,2,1,0],[1,1,0,0,1,1],[0,1,1,1,1,0],[0,2,1,1,2,0]]
  
        case 2:
            level = [[1,2,1,1,2,1],[0,1,3,3,1,0],[1,3,0,0,3,1],[0,1,1,1,1,0],[0,2,1,1,2,0]]
            
        case 3:
            level = [[1,2,1,1,2,1],[0,1,2,2,1,0],[1,1,0,0,1,1],[0,1,1,1,1,0],[0,2,1,1,2,0]]
            
        case 4:
            level = [[1,2,1,1,2,1],[0,1,2,2,1,0],[1,1,0,0,1,1],[0,1,1,1,1,0],[0,2,1,1,2,0]]
            
        case 5:
            level = [[1,2,1,1,2,1],[0,1,2,2,1,0],[1,1,0,0,1,1],[0,1,1,1,1,0],[0,2,1,1,2,0]]
            
        case 6:
            level = [[1,2,1,1,2,1],[0,1,2,2,1,0],[1,1,0,0,1,1],[0,1,1,1,1,0],[0,2,4,4,2,0]]
            
        case 7:
            level = [[1,2,1,1,2,1],[0,1,2,2,1,0],[1,1,0,0,1,1],[0,1,1,1,1,0],[0,2,1,1,2,0]]
            
        case 8:
            level = [[1,2,1,1,2,1],[0,1,2,2,1,0],[1,1,0,0,1,1],[0,1,1,1,1,0],[0,2,1,1,2,0]]
            
        case 9:
            level = [[1,2,1,1,2,1],[0,1,2,2,1,0],[1,1,0,0,1,1],[0,1,1,1,1,0],[0,2,1,1,2,0]]
            
        default:
            println("Error")
        }
        
        var row = 0;
        var col = 0;
        for rowBricks:Array in level {
            col = 0;
            for brickType in rowBricks {
                if brickType > 0 {
                    let brick = Brick(type: BrickType(rawValue: brickType)!)
                    brick.position = CGPointMake(2 + (brick.size.width * 0.5) + ((brick.size.width + 3) * CGFloat(col)), -(2 + (brick.size.height * 0.5) + ((brick.size.height + 3) * CGFloat(row))));
                    brickLayer.addChild(brick)
                }
                col++;
            }
            row++;
        }
        
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
            if menu.hidden {
                if !isBallReleased {
                    isBallOnPaddle = true
                }
            }
            previousPosition = touch.locationInNode(self)
        }
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        if menu.hidden {
            for touch: AnyObject in touches {
                let location = touch.locationInNode(self)
                // Calc move distance (x axis) from touch
                let moveDistanceX = location.x - previousPosition.x
                // set new position
                paddle.position = CGPointMake(paddle.position.x + moveDistanceX, paddle.position.y)
                
                /*
                Set min and max x (1/4) based on center anchor point of the paddle
                */
                var minPaddleX = -paddle.size.width * 0.25
                var maxPaddleX = self.frame.size.width + (paddle.size.width * 0.25)
                
                // limit with ball on the paddle
                if isBallOnPaddle {
                    minPaddleX = paddle.size.width * 0.5
                    maxPaddleX = self.frame.size.width - (paddle.size.width * 0.5)
                }
                
                if paddle.position.x < minPaddleX {
                    paddle.position = CGPointMake(minPaddleX, paddle.position.y)
                }
                if paddle.position.x > maxPaddleX {
                    paddle.position = CGPointMake(maxPaddleX, paddle.position.y)
                }
                // saved current position for next move
                previousPosition = location
            }
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        if menu.hidden {
            if isBallOnPaddle {
                isBallOnPaddle = false
                isBallReleased = true
                paddle.removeAllChildren()
                spawnBallWithLocation(CGPointMake(paddle.position.x, paddle.position.y + paddle.size.height) , withVelocity: CGVectorMake(0.0, ballSpeed))
            }
        }
        else {
            for touch: AnyObject in touches {
                let touchedNode = menu.nodeAtPoint(touch.locationInNode(menu))
                if touchedNode.name == "Play Button" {
                    menu.hide()
                }
            }
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        if isLevelCompleted() {
            // Start next level
            self.runAction(levelUpSound)
            currentLevel++
            
            // reset due game end
            if currentLevel > kFinalLevel {
                lives = 2
                currentLevel = 1
            }
            
            loadLevel(currentLevel)
            newBall()
            menu.show()
        }
        else if isBallReleased && !isBallOnPaddle && self.childNodeWithName("ball") == nil {
            self.runAction(loseLifeSound)
            lives--
            
            // reset due gome over
            if lives < 0 {
                lives = 2
                currentLevel = 1
                loadLevel(currentLevel)
                menu.show()
            }
            newBall()
        }
    }
    
    override func didSimulatePhysics() {
        self.enumerateChildNodesWithName("ball", usingBlock: { (node, stop) -> Void in
            // ball leaves the screen
            if node.position.y + node.frame.size.height < 0 {
                node.removeFromParent()
            }
        })
    }
    
    func spawnExtraBall(location:CGPoint) {
        var dx:CGFloat
        var dy:CGFloat
        var direction:CGVector
        
        // random chance 1:2
        if arc4random_uniform(UInt32(2)) == 0 {
            // 45 degress to the right
            dx = CGFloat(cos(M_PI_4))
            dy = CGFloat(sin(M_PI_4))
            direction = CGVectorMake(dx, dy)
        }
        else {
            // 45 degress to the left (135 degress)
            dx = CGFloat(cos(M_PI * 0.75))
            dy = CGFloat(sin(M_PI * 0.75))
            direction = CGVectorMake(dx, dy)
        }
        spawnBallWithLocation(location, withVelocity: CGVectorMake(direction.dx * ballSpeed, direction.dy * ballSpeed))
    }
    
    func spawnBallWithLocation(location:CGPoint, withVelocity: CGVector) {
        let ball = SKSpriteNode(imageNamed: "BallBlue")
        ball.name = "ball"
        ball.position = CGPointMake(location.x, location.y)
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width * 0.5)
        ball.physicsBody?.velocity = withVelocity
        ball.physicsBody?.restitution = 1.0
        ball.physicsBody?.linearDamping = 0.0
        ball.physicsBody?.friction = 0.0
        
        ball.physicsBody?.categoryBitMask = kBallCategory
        /* ignore the other ball*/
        ball.physicsBody?.collisionBitMask = kEdgeCategory | kPaddleCategory | kBrickCategory
        ball.physicsBody?.contactTestBitMask = kEdgeCategory | kPaddleCategory | kBrickCategory
        self.addChild(ball)
    }
    
    func isLevelCompleted() -> Bool {
        for node in brickLayer.children {
            if node.isKindOfClass(Brick) {
                if !(node as Brick).isIndestructable {
                    return false
                }
            }
        }
        return true
    }
    
    // MARK: SKPhysicsContactDelegate
    
    func didBeginContact(contact: SKPhysicsContact) {
        var firstBody:SKPhysicsBody
        var secondBody:SKPhysicsBody
        
        /* Ensure that the halo is the firstBody */
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }
        else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if firstBody.categoryBitMask == kBallCategory && secondBody.categoryBitMask == kPaddleCategory {
            // Collision between Ball and Paddle: calc bounce angle
            if firstBody.node?.position.y > secondBody.node?.position.y {
                // Get contact point in paddle coordinates
                let pointInPaddle = secondBody.node?.convertPoint(contact.contactPoint, fromNode: self)
                // Get contact position as a percentage of the paddle's width to determine the angle of bounce
                let x = (pointInPaddle!.x + secondBody.node!.frame.size.width * 0.5) / secondBody.node!.frame.size.width
                
                // Cap percantage and flip it
                let multiplier = 1.0 - fmax(fmin(x, 1.0), 0.0)
                // Calc angle on ball position in paddle
                /*
                Range from 0 - 90 degress with an offet of 45 degress (counterclockwise)
                */
                let angle = (CGFloat(M_PI_2) * multiplier) + CGFloat(M_PI_4)
                // Convert radians to vector
                let direction = radiansToVector(angle)
                // bounce ball with calced angle (vector)
                firstBody.velocity = CGVectorMake(direction.dx * ballSpeed, direction.dy * ballSpeed)
            }
            self.runAction(paddleBounceSound)
        }
        
        if firstBody.categoryBitMask == kBallCategory && secondBody.categoryBitMask == kBrickCategory {
            // Collision between Ball and Brick: break brick in a explosion
            if secondBody.node?.respondsToSelector(Selector("hit")) == true {
                if (secondBody.node as Brick).spawnExtraBall {
                    // convert Brick (part of the bricklayer to coordinates of the scene)
                    spawnExtraBall(brickLayer.convertPoint(secondBody.node!.position, toNode: self))
                }
                (secondBody.node as Brick).hit()
            }
            self.runAction(ballBounceSound)
        }
        
        if firstBody.categoryBitMask == kBallCategory && secondBody.categoryBitMask == kEdgeCategory {
            self.runAction(ballBounceSound)
        }
    }
    
    // MARK: Helper Functions
    
    private func radiansToVector(radians : CGFloat) -> CGVector
    {
        let vector : CGVector = CGVectorMake(cos(radians), sin(radians))
        return vector
    }
    
    private func randomInRange(low : CGFloat, high : CGFloat) -> CGFloat
    {
        let value = CGFloat(arc4random_uniform(UINT32_MAX)) / CGFloat(UINT32_MAX)
        return value * (high - low) + low
    }
}
