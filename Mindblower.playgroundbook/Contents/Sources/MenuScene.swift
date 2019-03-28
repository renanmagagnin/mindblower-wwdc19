//
//  MenuScene.swift
//  VectorFields
//
//  Created by Renan Magagnin on 20/03/19.
//  Copyright © 2019 Renan Magagnin. All rights reserved.
//

import SpriteKit

public class MenuScene: SKScene {

    var logo: SKSpriteNode!
    var tapToPlay: SKSpriteNode!
    
    // Whether taps make the game start or not
    var isReady = false
    
    var gameScene: GameScene!
    
    public override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        self.backgroundColor = .black
        
        setup()
        
        // Animate in and schedule tap readiness
        animateIn {
            self.isReady = true
            print("is ready")
        }
        
        gameScene = GameScene(size: UIScreen.main.bounds.size)
    }
    
}

// MARK: Touch
extension MenuScene {
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isReady {
            
            // Play select sound
            if action(forKey: "menuSelect") == nil {
                let playMenuSelectAction = SKAction.playSoundFileNamed("MenuSelect", waitForCompletion: false)
                self.run(.sequence([playMenuSelectAction, .wait(forDuration: 20)]), withKey: "menuSelect")
            }
            
            animateOut {
                self.startGame()
            }
        }
    }
}


// MARK: Setup
extension MenuScene {
    func setup() {
        setupTapToPlay()
        setupLogo()
    }
    
    func setupLogo() {
        let logoSize = CGSize(width: size.width * 0.9, height: size.height * 0.55) // 923x421 in 1024x768
        logo = SKSpriteNode(imageNamed: "Logo")
        logo.size = logoSize
        logo.position.y = size.height * 0.052
        logo.alpha = 0
        addChild(logo)
    }
    
    func setupTapToPlay() {
        let tapToPlaySize = CGSize.init(width: size.width * 0.35, height: size.height * 0.25) // 355x196 in 1024x768
        tapToPlay = SKSpriteNode(imageNamed: "TapToPlay")
        tapToPlay.size = tapToPlaySize
        tapToPlay.position.y = -size.height * 0.143
        tapToPlay.alpha = 0
        addChild(tapToPlay)
    }
    
}

// MARK: Animation
extension MenuScene {
    func animateIn(completion block: @escaping () -> Void) {
        let duration: TimeInterval = 5
        
        // Logo actions
//        let actions = [
//            SKAction.fadeAlpha(to: 1, duration: duration/40),
//            SKAction.fadeAlpha(to: 0, duration: duration/40),
//            SKAction.fadeAlpha(to: 1, duration: duration/40),
//            SKAction.fadeAlpha(to: 0, duration: duration/40),
//
//            SKAction.fadeAlpha(to: 1, duration: duration/40),
//            SKAction.fadeAlpha(to: 0, duration: duration/40),
//            SKAction.fadeAlpha(to: 1, duration: duration/40),
//            SKAction.fadeAlpha(to: 0.5, duration: duration/40),
//
//            SKAction.fadeAlpha(to: 1, duration: duration/20),
//            SKAction.fadeAlpha(to: 0.5, duration: duration/20),
//            SKAction.fadeAlpha(to: 1, duration: duration/20),
//            SKAction.fadeAlpha(to: 0, duration: duration/20),
//
//            SKAction.fadeAlpha(to: 1, duration: duration/40),
//            SKAction.fadeAlpha(to: 0, duration: duration/40),
//            SKAction.fadeAlpha(to: 1, duration: duration/40),
//            SKAction.fadeAlpha(to: 0.5, duration: duration/40),
//
//            SKAction.fadeAlpha(to: 1, duration: 0.5),
//
//            SKAction.wait(forDuration: 0.5)
//        ]
        
        // Logo actions
        let actions = [
            SKAction.fadeAlpha(to: 0.5, duration: duration/30),
            
            SKAction.fadeAlpha(to: 0, duration: duration/50),
            SKAction.fadeAlpha(to: 1, duration: duration/50),
            SKAction.fadeAlpha(to: 0, duration: duration/50),
            SKAction.fadeAlpha(to: 0.5, duration: duration/50),
            
            .wait(forDuration: 0.2),
            
            SKAction.fadeAlpha(to: 0, duration: duration/50),
            SKAction.fadeAlpha(to: 0.5, duration: duration/50),
            SKAction.fadeAlpha(to: 0, duration: duration/50),
            SKAction.fadeAlpha(to: 1, duration: duration/50),
            
            .wait(forDuration: 0.2),
            
            SKAction.fadeAlpha(to: 1, duration: duration/20),
            SKAction.fadeAlpha(to: 0.5, duration: duration/20),
            SKAction.fadeAlpha(to: 1, duration: duration/20),
            SKAction.fadeAlpha(to: 0, duration: duration/20),
            
            .wait(forDuration: 0.1),
            
            SKAction.fadeAlpha(to: 1, duration: duration/40),
            SKAction.fadeAlpha(to: 0, duration: duration/40),
            SKAction.fadeAlpha(to: 1, duration: duration/40),
            SKAction.fadeAlpha(to: 0.5, duration: duration/40),
            
            SKAction.fadeAlpha(to: 1, duration: 0.5),
            
            SKAction.wait(forDuration: 0.5)
        ]
        
        for action in actions {
            action.timingMode = .easeInEaseOut
        }
        
        
        // Tap to play actions
        let blinkInAction = SKAction.fadeIn(withDuration: 0.4)
        blinkInAction.timingMode = .easeInEaseOut
        let blinkOutAction = SKAction.fadeOut(withDuration: 1.2)
        blinkOutAction.timingMode = .easeInEaseOut
        let blinkAction = SKAction.repeatForever(.sequence([blinkInAction, blinkOutAction]))
        
        // Play logo actions and at the end, play tap to play actions
        logo.run(.sequence(actions)) {
            self.tapToPlay.run(blinkAction)
            block()
        }
        
        // Play static sound
        let playStaticAction = SKAction.playSoundFileNamed("NeonStatic", waitForCompletion: true)
        run(playStaticAction, withKey: "neonStatic")
    }
    
    func animateOut(completion block: @escaping () -> Void) {
        tapToPlay.removeAllActions()
        
        let duration: TimeInterval = 0.3
        
        let fadeOutAction = SKAction.fadeOut(withDuration: duration)
        fadeOutAction.timingMode = .easeInEaseOut
        
        
        let turnOffTapToPlayAction = SKAction.run {
            self.tapToPlay.run(fadeOutAction)
        }
        
        let turnOffLogoAction = SKAction.run {
            self.logo.run(fadeOutAction)
        }
        
        let turnOffLogoSound = SKAction.run {
            self.removeAction(forKey: "neonStatic")
        }
        
        let actions: [SKAction] = [
            turnOffTapToPlayAction,
            turnOffLogoSound,
            .wait(forDuration: 0.3),
            turnOffLogoAction,
            
            // Wait for a while before proceeding to game
            .wait(forDuration: 1),
            .run {
                block()
            }
        ]
        
        run(.sequence(actions))
    }
}

// MARK: Navigation
extension MenuScene {
    
    func startGame() {
        guard let view = view else { return }
        
        gameScene.scaleMode = .aspectFit
        gameScene.anchorPoint = .init(x: 0.5, y: 0.5)
        view.presentScene(gameScene)
        
        view.ignoresSiblingOrder = true
        
//        view.showsPhysics = true
//        view.showsFPS = true
//        view.showsNodeCount = true
    }
}
