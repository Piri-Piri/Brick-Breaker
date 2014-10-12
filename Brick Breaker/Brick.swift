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
    
    let explosionSound = SKAction.playSoundFileNamed("Explosion.caf", waitForCompletion: false)
    
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
        
        self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)
        self.physicsBody?.categoryBitMask = kBrickCategory
        self.physicsBody?.dynamic = false;
    }
    
    func hit() {
        switch self.brickType {
        case BrickType.Blue:
            self.texture = SKTexture(imageNamed: "BrickGreen")
            self.brickType = BrickType.Green
        case BrickType.Green:
            let brickExplosionPath = NSBundle.mainBundle().pathForResource("BrickExplosion", ofType: "sks")
            var brickExplosion = NSKeyedUnarchiver.unarchiveObjectWithFile(brickExplosionPath!) as SKEmitterNode
            brickExplosion.position = self.position
            self.parent?.addChild(brickExplosion)
            self.parent?.runAction(explosionSound)
            
            self.removeFromParent()
        default:
            println("Error")
        }
    }
    
}
