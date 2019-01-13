//
//  ViewController.m
//  GuidedMeditationTreksV1
//
//  Created by Mr Russell on 1/12/15.
//  Copyright (c) 2015 Guided Meditation Treks. All rights reserved.
//

#import "ViewController.h"
#import "IAPHelper.h"
@import AVFoundation;


@interface ViewController ()

@end

@implementation ViewController

NSMutableArray *soundsArray;
bool isPlaying;
NSString * playingTrack;
NSString * queuedTrack;

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    isPlaying = false;
    self.playButton.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    //Set Defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults boolForKey:@"defaultsSaved"])
    {
        [defaults setBool:YES forKey:@"defaultsSaved"];
        [defaults setBool:NO forKey:@"useIsochronic"];
        [defaults setFloat:.5 forKey:@"binauralVolume"];
        [defaults setFloat:.5 forKey:@"natureVolume"];
        [defaults setFloat:.5 forKey:@"pinknoiseVolume"];
        [defaults setFloat:.5 forKey:@"voiceVolume"];
        [defaults synchronize];
    }
        
    [self.binauralSliderOutlet setValue:[defaults floatForKey:@"binauralVolume"]];
    [self.natureSliderOutlet setValue:[defaults floatForKey:@"natureVolume"]];
    [self.pinknoiseSliderOutlet setValue:[defaults floatForKey:@"pinknoiseVolume"]];
    [self.voiceSliderOutlet setValue:[defaults floatForKey:@"voiceVolume"]];
    self.binauralSwitch.on = [defaults boolForKey:@"useIsochronic"];
    [self setIsochronic];

    self.playButton.hidden = YES;

    //Make sliders vertical
    CGAffineTransform trans = CGAffineTransformMakeRotation(M_PI*1.5);
    self.binauralSliderOutlet.transform = trans;
    self.natureSliderOutlet.transform = trans;
    self.pinknoiseSliderOutlet.transform = trans;
    self.voiceSliderOutlet.transform = trans;
    
    //buttons multiline
    self.track1Button.titleLabel.numberOfLines = 0;
    self.track2Button.titleLabel.numberOfLines = 0;
    self.track3Button.titleLabel.numberOfLines = 0;
    self.track4Button.titleLabel.numberOfLines = 0;

    self.track1Button.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.track2Button.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.track3Button.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.track4Button.titleLabel.textAlignment = NSTextAlignmentCenter;

    
    isPlaying = NO;
    queuedTrack = @"01";
    [self initSoundsArray];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)initSoundsArray
{
    soundsArray = [NSMutableArray new];
    
    NSMutableArray *audioFilenames = [NSMutableArray new];
    
    [audioFilenames addObject:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@%@%@", @"audio/", queuedTrack, @"binaural"] ofType:@"m4a"]];
    [audioFilenames addObject:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@%@%@", @"audio/", queuedTrack, @"nature"] ofType:@"m4a"]];
    [audioFilenames addObject:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@%@%@", @"audio/", queuedTrack, @"pinknoise"] ofType:@"m4a"]];
    [audioFilenames addObject:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@%@%@", @"audio/", queuedTrack, @"voice"] ofType:@"m4a"]];
    [audioFilenames addObject:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@%@%@", @"audio/", queuedTrack, @"isochronic"] ofType:@"m4a"]];


    NSString *binauralFile = [audioFilenames objectAtIndex:0];
    NSString *natureFile = [audioFilenames objectAtIndex:1];
    NSString *pinknoiseFile = [audioFilenames objectAtIndex:2];
    NSString *voiceFile = [audioFilenames objectAtIndex:3];
    NSString *isochronicFile = [audioFilenames objectAtIndex:4];
    
    AVAudioPlayer *binauralPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:binauralFile] error:nil];
    [soundsArray addObject:binauralPlayer];
    AVAudioPlayer *isochronicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:isochronicFile] error:nil];
    [soundsArray addObject:isochronicPlayer];

    if (self.binauralSwitch.isOn)
    {
        [binauralPlayer setVolume:0];
        [isochronicPlayer setVolume:self.binauralSliderOutlet.value];
    }
    else
    {
        [isochronicPlayer setVolume:0];
        [binauralPlayer setVolume:self.binauralSliderOutlet.value];
    }
    
    AVAudioPlayer *naturePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:natureFile] error:nil];
    [soundsArray addObject:naturePlayer];
    [naturePlayer setVolume:self.natureSliderOutlet.value];

    AVAudioPlayer *pinknoisePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:pinknoiseFile] error:nil];
    [soundsArray addObject:pinknoisePlayer];
    [pinknoisePlayer setVolume:self.pinknoiseSliderOutlet.value];

    AVAudioPlayer *voicePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:voiceFile] error:nil];
    voicePlayer.delegate = self;
    [soundsArray addObject:voicePlayer];
    [voicePlayer setVolume:self.voiceSliderOutlet.value];
    
    playingTrack = queuedTrack;
}

- (void)setPartVolume:(NSUInteger*) item : (float) volumeValue
{
    AVAudioPlayer *a = [soundsArray objectAtIndex:*item];
    [a setVolume:volumeValue];
}

-(IBAction)playButtonPressed:(id)sender {
    
    if(isPlaying)
    {
        for (AVAudioPlayer *a in soundsArray) [a pause];
        [self.playButton setTitle:@"Play" forState:UIControlStateNormal];
        UIImage *btnImage = [UIImage imageNamed:@"play.png"];
        [self.playButton setImage:btnImage forState:UIControlStateNormal];
        isPlaying = NO;
    }
    else
    {
        for (AVAudioPlayer *a in soundsArray) [a play];
        [self.playButton setTitle:@"Pause" forState:UIControlStateNormal];
        UIImage *btnImage = [UIImage imageNamed:@"pause.png"];
        [self.playButton setImage:btnImage forState:UIControlStateNormal];
        isPlaying = YES;
    }
}

- (IBAction)binauralVolumeSeek:(id)sender
{
    NSUInteger i;
    if (self.binauralSwitch.isOn)
    {
        i = 1;
    }
    else
    {
        i = 0;
    }
    
    [self setPartVolume:&i :self.binauralSliderOutlet.value];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setFloat:self.binauralSliderOutlet.value forKey:@"binauralVolume"];
    [defaults synchronize];
}
- (IBAction)natureVolumeSeek:(id)sender
{
    NSUInteger i = 2;
    [self setPartVolume:&i :self.natureSliderOutlet.value];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setFloat:self.natureSliderOutlet.value forKey:@"natureVolume"];
    [defaults synchronize];
}
- (IBAction)pinknoiseVolumeSeek:(id)sender
{
    NSUInteger i = 3;
    [self setPartVolume:&i :self.pinknoiseSliderOutlet.value];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setFloat:self.pinknoiseSliderOutlet.value forKey:@"pinknoiseVolume"];
    [defaults synchronize];
}
- (IBAction)voiceVolumeSeek:(id)sender
{
    NSUInteger i = 4;
    [self setPartVolume:&i :self.voiceSliderOutlet.value];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setFloat:self.voiceSliderOutlet.value forKey:@"voiceVolume"];
    [defaults synchronize];
}
- (IBAction)binauralSwitchChanged:(id)sender
{
    [self setIsochronic];
}

- (void)setIsochronic
{
    AVAudioPlayer *binaural = [soundsArray objectAtIndex:0];
    AVAudioPlayer *isochronic = [soundsArray objectAtIndex:1];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (self.binauralSwitch.isOn)
    {
        [binaural setVolume:0];
        [isochronic setVolume:self.binauralSliderOutlet.value];
        [defaults setBool:YES forKey:@"useIsochronic"];
    }
    else
    {
        [isochronic setVolume:0];
        [binaural setVolume:self.binauralSliderOutlet.value];
        [defaults setBool:NO forKey:@"useIsochronic"];
    }
    [defaults synchronize];
    
}

- (IBAction)track1ButtonPressed:(id)sender
{
    queuedTrack = @"01";
    [self changeToQueuedTrack];
}
- (IBAction)track2ButtonPressed:(id)sender
{
    queuedTrack = @"02";
    [self changeToQueuedTrack];
}
- (IBAction)track3ButtonPressed:(id)sender
{
    queuedTrack = @"03";
    [self changeToQueuedTrack];
}
- (IBAction)track4ButtonPressed:(id)sender
{
    queuedTrack = @"04";
    [self changeToQueuedTrack];
}

- (void)changeToQueuedTrack
{
    if (isPlaying)
    {
        [self confirmTrackChange : [playingTrack isEqualToString:queuedTrack]];
    }
    else
    {
        [self playQueuedTrack];
    }
}

- (void)confirmTrackChange:(bool) same
{
    NSString * msg;
    if (same)
    {
        msg = @"Are you sure you want to restart the program?";
    }
    else
    {
        msg = @"Are you sure you want to change programs?";
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm"
                                    message:msg
                                    delegate:self
                                    cancelButtonTitle:@"Cancel"
                                    otherButtonTitles:@"OK", nil];
    [alert show];
    //[alert release];
}

- (void)playQueuedTrack
{
    UIImage *btnImage;
    if (isPlaying)
    {
        for (AVAudioPlayer *a in soundsArray) [a stop];
        [self.playButton setTitle:@"Play" forState:UIControlStateNormal];
        btnImage = [UIImage imageNamed:@"play.png"];
        [self.playButton setImage:btnImage forState:UIControlStateNormal];
        isPlaying = NO;
    }
    
    self.playButton.hidden = NO;
    [self initSoundsArray];
    for (AVAudioPlayer *a in soundsArray) [a play];
    [self.playButton setTitle:@"Pause" forState:UIControlStateNormal];
    btnImage = [UIImage imageNamed:@"pause.png"];
    [self.playButton setImage:btnImage forState:UIControlStateNormal];
    isPlaying = YES;
}


- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) [self playQueuedTrack];
}

- (IBAction)linkToWeb:(UIButton *)selectedButton
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.guidedmeditationtreks.com/v1.html"]];
}

@end
