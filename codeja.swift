//
//  ViewController.swift
//  Muse
//
//  Created by Peter Cupples on 5/27/16.
//  Copyright © 2016 Peter Cupples. All rights reserved.
//

import Cocoa
import AVFoundation

protocol CommonProperties {
    unowned var player: AVAudioPlayer { get set }
    var total: NSTimeInterval { get }
    mutating func convert()
    init(total: NSTimeInterval, player: AVAudioPlayer)
}

extension CommonProperties {
    var total: NSTimeInterval { return player.duration }
    init(total: NSTimeInterval, player: AVAudioPlayer) {
        self.total = total
        self.player = player
    }
    enum InputError: ErrorType {
        case InputMissing
        case WeirdPath
    }
    
    mutating func convert() throws -> AVAudioPlayer {
        guard let myFilePath = NSBundle.mainBundle().pathForResource((tuneList[tune]), ofType: "m4a")
            else { throw InputError.InputMissing }
        guard let myFilePathURL = NSURL(fileURLWithPath: myFilePath!)
            else { throw InputError.WeirdPath }
        return AVAudioPlayer(contentsOfURL: myFilePathURL, delegate: AutoStopTimerANDErasePlayer())
        //total = player.duration)
    }
    //delegate: AutoStopTimerANDErasePlayer)
    //self.musicSlider.minValue = 0.0
    // self.musicSlider.maxValue = player.duration
}

class ViewController: NSViewController, CommonProperties {
    @IBOutlet weak var songSelector: NSPopUpButton!
    @IBOutlet weak var musicSlider: NSSlider!
    @IBOutlet weak var musicTimer: NSTextField!
    
    var tuneList = [String]()
    var tune: Int
    var startTime = NSTimeInterval()
    unowned var player = AVAudioPlayer()
    var total: NSTimeInterval
    var delegate: AVAudioPlayerDelegate
    
    init(total: NSTimeInterval, player: AVAudioPlayer, tune: Int = 0, delegate: AVAudioPlayerDelegate) {
        self.total = total
        self.player = player
        self.tune = tune
        self.delegate = delegate
    }
    var timer = NSTimer()
    @IBAction func handleClick(sender: NSButton) {
        musicSlider.hidden = false
        tune = songSelector.indexOfSelectedItem
        do {
            player = try CommonProperties.convert()
            print("Yay")
            print("the end time is \(total)")
            player.prepareToPlay()
        } catch CommonProperties.InputError.InputMissing {
            print("Input is Missing")
            player.delegate.audioPlayerDecodeErrorDidOccur()
        } catch CommonProperties.InputError.WeirdPath {
            print("Decode Error")
            player.delegate.audioPlayerDecodeErrorDidOccur()
        } catch {
            print("sugar")
        }
        self.musicSlider.minValue = 0.0
        self.musicSlider.maxValue = player.duration
        total = player.duration
        player.play()
        
        if !timer.valid {
            startTime = NSDate.timeIntervalSinceReferenceDate()
            let aSelector : Selector = #selector(self.updateMusicSliderANDMusicTimer(total))
            timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: aSelector, userInfo: nil, repeats: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        songSelector.itemAtIndex(0)
        musicSlider.hidden = true
        tuneList = ["02 Honey Honey", "16 S.O.S.", "06 Chiquitita"]
        
        // Do any additional setup after loading the view.
    }
    
    private func updateMusicSliderANDMusicTimer(total: NSTimeInterval) {
        let currentTime = NSDate.timeIntervalSinceReferenceDate()
        
        //Find the difference between current time and start time.
        
        var elapsedTime: NSTimeInterval = currentTime - startTime
        
        //calculate the minutes in elapsed time.
        
        let minutes = UInt8(elapsedTime / 60.0)
        
        elapsedTime -= (NSTimeInterval(minutes) * 60)
        
        //calculate the seconds in elapsed time.
        
        let seconds = UInt8(elapsedTime)
        
        elapsedTime -= NSTimeInterval(seconds)
        
        self.musicSlider.floatValue = Float(seconds)
        
        //add the leading zero for minutes, seconds and store them as string constants
        
        let strMinutes = String(minutes)
        let strSeconds = String(seconds)
        
        //concatenate minuets, seconds and assign it to the UILabel
        
        self.musicTimer.stringValue = "\(strMinutes):\(strSeconds)"
        
        if elapsedTime > total {
            elapsedTime = total
            player.delegate!.audioPlayerDidFinishPlaying(self)
            //(player: AVAudioPlayer,)
        }
    }
}

class AutoStopTimerANDErasePlayer : CommonProperties, AVAudioPlayerDelegate {
    unowned var player: AVAudioPlayer
    var total: NSTimeInterval
    
    init(total: NSTimeInterval, player: AVAudioPlayer) {
        self.total = total
        self.player = AVAudioPlayer()
    }
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            timer.invalidate()
            player.stop()
        }
    }
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer) {
        print("balls!")
        player = nil
    }
}
