//
//  Menu.swift
//  Brick Breaker
//
//  Created by David Pirih on 13.10.14.
//  Copyright (c) 2014 Piri-Piri. All rights reserved.
//

import UIKit
import SpriteKit

class Menu: SKNode {
    let menuPanel: SKSpriteNode!
    let levelLabel: SKLabelNode!
    let playButton: SKSpriteNode!
    let playLabel: SKLabelNode!
    
    var levelNumber: Int = 1 {
        didSet {
           levelLabel.text = "Level \(levelNumber)"
        }
    }
    
    //var isTouchable: Bool = false
    
    
    override init() {
        super.init()
        menuPanel = SKSpriteNode(imageNamed: "MenuPanel")
        menuPanel.position = CGPointZero
        self.addChild(menuPanel)
        
        levelLabel = SKLabelNode(fontNamed: "Futura")
        levelLabel.text = "Level 1"
        levelLabel.fontColor = UIColor.grayColor()
        levelLabel.fontSize = 15.0
        levelLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        menuPanel.addChild(levelLabel)
        
        
        playButton = SKSpriteNode(imageNamed: "Button")
        playButton.name = "Play Button"
        playButton.position = CGPointMake(0, -((menuPanel.size.height * 0.5) + (playButton.size.height * 0.5) + 10.0))
        self.addChild(playButton)
        
        playLabel = SKLabelNode(fontNamed: "Futura")
        playLabel.name = "Play Button"
        playLabel.text = "Play"
        playLabel.position = CGPointMake(0, 2)
        playLabel.fontColor = UIColor.grayColor()
        playLabel.fontSize = 15.0
        playLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        playButton.addChild(playLabel)
        
        //isTouchable = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show() {
        // Animate MenuPanel
        menuPanel.position = CGPointMake(260, menuPanel.position.y)
        let slideLeft = SKAction.moveByX(-260.0, y:0.0, duration: 0.5)
        /* slow down the aminateion by getting near to the end */
        slideLeft.timingMode = SKActionTimingMode.EaseOut
        menuPanel.runAction(slideLeft)
        
        
        // Animate PlayButton
        playButton.position = CGPointMake(-260, playButton.position.y)
        let slideRight = SKAction.moveByX(260.0, y:0.0, duration: 0.5)
        /* slow down the aminateion by getting near to the end */
        slideRight.timingMode = SKActionTimingMode.EaseOut
        //playButton.runAction(SKAction.sequence([slideRight, SKAction.runBlock( { self.isTouchable = true } ) ]))
        playButton.runAction(slideRight)
        
        self.hidden = false
    }
    
    func hide() {
        //isTouchable = false
        
        // Animate MenuPanel
        menuPanel.position = CGPointMake(0, menuPanel.position.y)
        let slideLeft = SKAction.moveByX(-260.0, y: 0.0, duration: 0.5)
        /* slow down the aminateion by getting near to the end */
        slideLeft.timingMode = SKActionTimingMode.EaseIn
        menuPanel.runAction(slideLeft)
        
        
        // Animate PlayButton
        playButton.position = CGPointMake(0, playButton.position.y)
        let slideRight = SKAction.moveByX(260.0, y: 0.0, duration: 0.5)
        /* slow down the aminateion by getting near to the end */
        slideRight.timingMode = SKActionTimingMode.EaseIn
        playButton.runAction(SKAction.sequence([slideRight, SKAction.runBlock( {
            self.hidden = true
        } ) ]))
    }
}
