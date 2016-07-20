//
// ViewController.swift
// Muse //
// Created by Peter Cupples on 5/27/16.
// Copyright © 2016 Peter Cupples. All rights reserved. //
import Cocoa
import AVFoundation
protocol AVAudioPlayerInstance {
unowned inout var player: AVAudioPlayer { get set } var total: NSTimeInterval { get set }
init(total: NSTimeInterval, player: AVAudioPlayer)
}
extension AVAudioPlayerInstance {
var total: NSTimeInterval { return player.duration } init(total: NSTimeInterval, player: AVAudioPlayer) {
self.total = total
self.player = AVAudioPlayer() }
}
class ViewController: NSViewController, AVAudioPlayerInstance { @IBOutlet weak var songSelector: NSPopUpButton!
@IBOutlet weak var musicSlider: NSSlider!
@IBOutlet weak var musicTimer: NSTextField!
var tuneList = [String]()
var tune: Int
var startTime = NSTimeInterval() unowned inout var player: AVAudioPlayer var total: NSTimeInterval
init(total: NSTimeInterval, &player: AVAudioPlayer, tune: Int = 0) { self.total = total
self.player = AVAudioPlayer()
self.tune = tune
}
var timer = NSTimer()
@IBAction func handleClick(sender: NSButton) {
 musicSlider.hidden = false
tune = songSelector.indexOfSelectedItem convert(&total)
if !timer.valid {
startTime = NSDate.timeIntervalSinceReferenceDate()
let aSelector : Selector = #selector(self.updateMusicSliderANDMusicTimer(total))
timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: aSelector,
userInfo: nil, repeats: true)
}
}
func convert(&total: NSTimeInterval) {
do {
let myFilePath = NSBundle.mainBundle().pathForResource((tuneList[tune]), ofType: "m4a") let myFilePathURL = NSURL(fileURLWithPath: myFilePath!)
try player = AVAudioPlayer(contentsOfURL: myFilePathURL, delegate:
AutoStopTimerANDErasePlayer) self.musicSlider.minValue = 0.0 self.musicSlider.maxValue = player.duration total = player.duration player.prepareToPlay()
print("Yay!")
print("the end time is \(total)") } catch {
player.delegate?.audioPlayerDecodeErrorDidOccur(&player) }
}
override func viewDidLoad() {
super.viewDidLoad()
songSelector.itemAtIndex(0)
musicSlider.hidden = true
tuneList = ["02 Honey Honey", "16 S.O.S.", "06 Chiquitita"]
// Do any additional setup after loading the view. }
class Time: AVAudioPlayer, AVAudioPlayerInstance {
private func updateMusicSliderANDMusicTimer(total: NSTimeInterval) {
let currentTime = NSDate.timeIntervalSinceReferenceDate() //Find the difference between current time and start time.
var elapsedTime: NSTimeInterval = currentTime - startTime
 //calculate the minutes in elapsed time.
let minutes = UInt8(elapsedTime / 60.0)
elapsedTime -= (NSTimeInterval(minutes) * 60)
//calculate the seconds in elapsed time.
let seconds = UInt8(elapsedTime)
elapsedTime -= NSTimeInterval(seconds)
self.musicSlider.floatValue = Float(seconds)
//add the leading zero for minutes, seconds and store them as string constants
let strMinutes = String(minutes) let strSeconds = String(seconds)
//concatenate minuets, seconds and assign it to the UILabel
self.musicTimer.stringValue = "\(strMinutes):\(strSeconds)"
if elapsedTime > total { elapsedTime = total
delegate!.audioPlayerDidFinishPlaying(self)
//(player: AVAudioPlayer,) }
} }
class AutoStopTimerANDErasePlayer : ViewController, AVAudioPlayerDelegate { init() {
super.init(total: total, player: player, tune: tune) }
func audioPlayerDidFinishPlaying(&player, successfully flag: Bool) { if flag {
timer.invalidate() player.stop()
}
}
func audioPlayerDecodeErrorDidOccur(&player) {
print("balls!") player = nil
}
}
