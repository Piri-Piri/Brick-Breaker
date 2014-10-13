//
//  Brick.swift
//  Brick Breaker
//
//  Created by David Pirih on 12.10.14.
//  Copyright (c) 2014 Piri-Piri. All rights reserved.
//

import UIKit
import SpriteKit

enum BrickType: Int {
    case Green = 1
    case Blue
    case Grey
    case Yellow
}

class Brick: SKSpriteNode {
    
    let kBrickCategory:UInt32   = 0x1 << 3
    var brickType: BrickType = BrickType.Green
    var isIndestructable: Bool = false
    var spawnExtraBall: Bool = false
    
    var brickSmashSound: SKAction!
    
    convenience init(type: BrickType) {
        switch type {
        case BrickType.Green:
            self.init(imageNamed: "BrickGreen")
        case BrickType.Blue:
            self.init(imageNamed: "BrickBlue")
        case BrickType.Grey:
            self.init(imageNamed: "BrickGrey")
        case BrickType.Yellow:
            self.init(imageNamed: "BrickYellow")
        default:
            println("Error")
        }
        self.brickType = type
        self.isIndestructable = (type == BrickType.Grey)
        self.spawnExtraBall = (type == BrickType.Yellow)
        
        self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)
        self.physicsBody?.categoryBitMask = kBrickCategory
        self.physicsBody?.dynamic = false;
        
        brickSmashSound = SKAction.playSoundFileNamed("BrickSmash.caf", waitForCompletion: false)
    }
    
    func hit() {
        switch self.brickType {
        case BrickType.Green:
            self.createExplosion()
            self.removeFromParent()
        
        case BrickType.Blue:
            self.texture = SKTexture(imageNamed: "BrickGreen")
            self.brickType = BrickType.Green
        
        case BrickType.Grey:
            println("Block is indestructable!")
            
        case BrickType.Yellow:
            self.createExplosion()
            self.removeFromParent()

        default:
            println("Error")
        }
    }
    
    func createExplosion(){
        let brickExplosionPath = NSBundle.mainBundle().pathForResource("BrickExplosion", ofType: "sks")
        var brickExplosion = NSKeyedUnarchiver.unarchiveObjectWithFile(brickExplosionPath!) as SKEmitterNode
        brickExplosion.position = self.position
        self.parent?.addChild(brickExplosion)
        self.parent?.runAction(brickSmashSound)
        
        // garbage collection for actions
        let brickExplosionLifeTime = Double(brickExplosion.particleLifetime) + Double(brickExplosion.particleLifetimeRange)
        let removeExplosion = SKAction.sequence([SKAction.waitForDuration(brickExplosionLifeTime), SKAction.removeFromParent()])
        brickExplosion.runAction(removeExplosion)
    }
    
}
