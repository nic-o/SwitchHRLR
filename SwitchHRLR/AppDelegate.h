//
//  AppDelegate.h
//  SwitchHRLR
//
//  Created by Nicolas Georget on 9/22/12.
//  Copyright (c) 2012 Nicolas Georget. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (weak) IBOutlet NSTextField *displayLogs;

@property (weak) IBOutlet NSButton *highResolutionButton;

@property (weak) IBOutlet NSButton *lowResolutionButton;

- (IBAction)highResolution:(id)sender;

- (IBAction)lowResolution:(id)sender;

@end
