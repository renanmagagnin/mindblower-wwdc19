//
//  See LICENSE folder for this template’s licensing information.
//
//  Abstract:
//  Instantiates a live view and passes it to the PlaygroundSupport framework.
//


import SpriteKit
import PlaygroundSupport
import AVFoundation

let width = UIScreen.main.bounds.size.width
let height = UIScreen.main.bounds.size.height

let spriteView = SKView(frame: UIScreen.main.bounds)

//Debugging commands
//spriteView.showsDrawCount = true
//spriteView.showsNodeCount = true
//spriteView.showsFPS = true

let path = Bundle.main.path(forResource: "BackgroundMusic", ofType: "mp3")!
let url = URL(fileURLWithPath: path)
let backgroundMusicPlayer = try! AVAudioPlayer(contentsOf: url)
backgroundMusicPlayer.numberOfLoops = -1
backgroundMusicPlayer.volume = 0.07
backgroundMusicPlayer.play()

// Adding game to playground so that we all can play
let scene = MenuScene(size: UIScreen.main.bounds.size)
scene.scaleMode = .aspectFit
scene.anchorPoint = .init(x: 0.5, y: 0.5)
spriteView.presentScene(scene)

// Show in Playground live view
PlaygroundPage.current.liveView = spriteView
