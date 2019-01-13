//
//  ViewController.h
//  GuidedMeditationTreksV1
//
//  Created by Mr Russell on 1/12/15.
//  Copyright (c) 2015 Guided Meditation Treks. All rights reserved.
//

#import <UIKit/UIKit.h>
@import AVFoundation;

@interface ViewController : UIViewController <UIAlertViewDelegate, AVAudioPlayerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *playButton;

@property (weak, nonatomic) IBOutlet UIButton *track1Button;
@property (weak, nonatomic) IBOutlet UIButton *track2Button;
@property (weak, nonatomic) IBOutlet UIButton *track3Button;
@property (weak, nonatomic) IBOutlet UIButton *track4Button;

@property (weak, nonatomic) IBOutlet UISwitch *binauralSwitch;

@property (weak, nonatomic) IBOutlet UISlider *binauralSliderOutlet;
@property (weak, nonatomic) IBOutlet UISlider *natureSliderOutlet;
@property (weak, nonatomic) IBOutlet UISlider *pinknoiseSliderOutlet;
@property (weak, nonatomic) IBOutlet UISlider *voiceSliderOutlet;


- (IBAction)playButtonPressed:(id)sender;

- (IBAction)track1ButtonPressed:(id)sender;
- (IBAction)track2ButtonPressed:(id)sender;
- (IBAction)track3ButtonPressed:(id)sender;
- (IBAction)track4ButtonPressed:(id)sender;

- (IBAction)binauralSwitchChanged:(id)sender;
- (IBAction)binauralVolumeSeek:(id)sender;
- (IBAction)natureVolumeSeek:(id)sender;
- (IBAction)pinknoiseVolumeSeek:(id)sender;
- (IBAction)voiceVolumeSeek:(id)sender;

- (IBAction)linkToWeb:(UIButton *)selectedButton;

@end

