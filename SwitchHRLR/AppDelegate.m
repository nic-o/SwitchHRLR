//
//  AppDelegate.m
//  SwitchHRLR
//
//  Created by Nicolas Georget on 9/22/12.
//  Copyright (c) 2012 Nicolas Georget. All rights reserved.
//

#import "AppDelegate.h"
#import "ServerPipe.h"

@implementation AppDelegate

@synthesize displayLogs;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  
  NSArray *keys = [NSArray arrayWithObjects:NSURLVolumeNameKey, NSURLVolumeIsRemovableKey, nil];
  NSArray *urls = [[NSFileManager defaultManager]
                   mountedVolumeURLsIncludingResourceValuesForKeys:keys
                   options:NSVolumeEnumerationSkipHiddenVolumes]; 
  NSLog(@"%@", urls);
  
  // Apple change the way to urls the paths of Mounted servers:
  // Version <= 10.8 : file://localhost/Volumes/.....
  // Version >= 10.9 : file:///Volumes/.....
  // i.e. http://cocoadev.com/DeterminingOSVersion
  NSString *versionOS = [[NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"] objectForKey:@"ProductVersion"];
  NSString *protocole;
  if ([versionOS isEqualToString:@"10.9"]) {
    protocole = @"file:///Volumes/";
  } else {
    protocole = @"file://localhost/Volumes/";
  }
  NSLog(@"Protocole used for OS %@: %@", versionOS, protocole);

  // Check if there's multiple phototheque connected
  BOOL isMultiplePhotothequeConnected = [urls containsObject:[NSURL URLWithString:[NSString stringWithFormat:@"%@Phototheque-1/", protocole]]];
  
  NSLog(@"Multiple servers connected: %s", isMultiplePhotothequeConnected ? "true" : "false");
  if (isMultiplePhotothequeConnected) {
    
    // Voir si la method utilise dans Lynda.com/Cocoa/02.08 est meilleure
    NSBeginCriticalAlertSheet(@"Multiple Phototheque",
                              @"High Resolution", // == NSAlertDefaultReturn
                              nil,                // == NSAlertAlternateReturn
                              @"Low Resolution",  // == NSAlertOtherReturn
                              [[NSApp delegate] window],
                              self,
                              @selector(sheetDidEnd:resultCode:contextInfo:),
                              NULL,
                              NULL,
                              @"It seems that you are connected to more than one Phototheque. Choose one!");
    [[[NSApplication sharedApplication] dockTile] setBadgeLabel:[NSString stringWithFormat:@"Both !!"]];
  }
  
  
  BOOL isPhotothequeConnected = [urls containsObject:[NSURL URLWithString:[NSString stringWithFormat:@"%@Phototheque/", protocole]]];
  NSLog(@"isPhotothequeConnected: %s", isPhotothequeConnected ? "true" : "false");
  
  if (isPhotothequeConnected) {
    NSLog(@"Phototheque connected...");
    NSError *error;
    NSString *volumeFormat;
    NSInteger indexOfphototheque = [urls indexOfObject:[NSURL URLWithString:[NSString stringWithFormat:@"%@Phototheque/", protocole]]];
    NSURL *volume = [urls objectAtIndex:indexOfphototheque];
    [volume getResourceValue:&volumeFormat forKey:NSURLVolumeLocalizedFormatDescriptionKey error:&error];
    NSLog(@"Protocole Network for Phototheque used: %@", volumeFormat);
    
    if ([volumeFormat isEqualToString:@"AppleShare"]) {
      NSLog(@"High Resolution Server mounted with protocole %@.", volumeFormat);
      // [displayLogs setStringValue:[NSString stringWithFormat:@"%@\nYou are connected to the High Resolution Phototheque", [displayLogs stringValue]]];
      [displayLogs setStringValue:@"You are connected to the High Resolution Phototheque\n"];
      [[[NSApplication sharedApplication] dockTile] setBadgeLabel:[NSString stringWithFormat:@"High"]];
      [_highResolutionButton setEnabled:NO];
      [_lowResolutionButton highlight:YES];

    } else if ([volumeFormat isEqualToString:@"SMB (NTFS)"]) {
      NSLog(@"Low Resolution Server mounted with protocole %@.", volumeFormat);
      // [displayLogs setStringValue:[NSString stringWithFormat:@"%@\nYou are connected to the Low Resolution Phototheque", [displayLogs stringValue]]];
      [displayLogs setStringValue:@"You are connected to the Low Resolution Phototheque\n"];
      [[[NSApplication sharedApplication] dockTile] setBadgeLabel:[NSString stringWithFormat:@"Low"]];
      [_lowResolutionButton setEnabled:NO];
      [_highResolutionButton highlight:YES];
    } else {
      NSLog(@"Unknown connected Server.");
      [[[NSApplication sharedApplication] dockTile] setBadgeLabel:[NSString stringWithFormat:@"Unknown"]];
    }
    
  } else {
    NSLog(@"No server connected....");
    [displayLogs setStringValue:@"There's no phototheque connected."];
    [[[NSApplication sharedApplication] dockTile] setBadgeLabel:[NSString stringWithFormat:@"None"]];
    [_highResolutionButton highlight:YES];
  }
  

  
}

// function if 2 phototheque connected
- (void)sheetDidEnd:(NSWindow *)sheet resultCode:(NSInteger)resultCode contextInfo:(void *)contextInfo {
  
  ServerPipe *phototheque = [[ServerPipe alloc] init];
  [phototheque unmountServer:@"/Volumes/Phototheque"];
  [phototheque unmountServer:@"/Volumes/Phototheque-1"];
  
  
  if (resultCode == NSAlertDefaultReturn) {
    // Button connect to HR
    NSLog(@"Connect to High Resolution Server");
    
    NSDictionary *mountDict;
    mountDict = [NSDictionary dictionaryWithObjectsAndKeys:
                 @"layout.sophieparis.com", @"kServerNameKey",
                 @"Phototheque", @"kVolumeNameKey",
                 @"afp", @"kTransportNameKey",
                 @"", @"kMountDirectoryKey",
                 nil, @"kUserNameKey",
                 nil, @"kPasswordKey",
                 [NSNumber numberWithBool:YES],
                 @"kAsyncKey", NULL];
    [phototheque mountServer:mountDict];
    NSLog(@"Unmount multiple server and mount High Res");
    [[[NSApplication sharedApplication] dockTile] setBadgeLabel:[NSString stringWithFormat:@"High"]];
  }
  
  if (resultCode == NSAlertOtherReturn) {
    NSLog(@"Connect to Low Resolution Server");
    
    NSDictionary *mountDict;
    mountDict = [NSDictionary dictionaryWithObjectsAndKeys:
                 @"layout-macdata", @"kServerNameKey",
                 @"Phototheque", @"kVolumeNameKey",
                 @"cifs", @"kTransportNameKey",
                 @"", @"kMountDirectoryKey",
                 @"Layout", @"kUserNameKey",
                 @"layout", @"kPasswordKey",
                 [NSNumber numberWithBool:YES],
                 @"kAsyncKey", NULL];
    [phototheque mountServer:mountDict];
    NSLog(@"Unmount multiple server and mount Low Res");
    [[[NSApplication sharedApplication] dockTile] setBadgeLabel:[NSString stringWithFormat:@"Low"]];
  }
}

////////////////////////////////////////////////////////////////////////////////

- (IBAction)highResolution:(id)sender {
    
  ServerPipe *highRes = [[ServerPipe alloc] init];
  
  [highRes unmountServer:@"/Volumes/Phototheque"];
    
  NSDictionary *mountDict;
  mountDict = [NSDictionary dictionaryWithObjectsAndKeys:
               @"layout.sophieparis.com", @"kServerNameKey",
               @"Phototheque", @"kVolumeNameKey",
               @"afp", @"kTransportNameKey",
               @"", @"kMountDirectoryKey",
               nil, @"kUserNameKey",
               nil, @"kPasswordKey",
               [NSNumber numberWithBool:YES],
               @"kAsyncKey", NULL];
    
  [highRes mountServer:mountDict];
  
  NSLog(@"Connect to High Resolution Server");
  [displayLogs setStringValue:[NSString stringWithFormat:@"%@• Switched to High Resolution\n", [displayLogs stringValue]]];
    
  [[[NSApplication sharedApplication] dockTile] setBadgeLabel:[NSString stringWithFormat:@"High"]];
  [_highResolutionButton setEnabled:NO];
  [_lowResolutionButton setEnabled:YES];
  [_lowResolutionButton highlight:YES];

}

////////////////////////////////////////////////////////////////////////////////

- (IBAction)lowResolution:(id)sender {
    
  ServerPipe *lowRes = [[ServerPipe alloc] init];
  
  [lowRes unmountServer:@"/Volumes/Phototheque"];
    
  NSDictionary *mountDict;
  mountDict = [NSDictionary dictionaryWithObjectsAndKeys:
               @"layout-macdata", @"kServerNameKey",
               @"Phototheque", @"kVolumeNameKey",
               @"cifs", @"kTransportNameKey",
               @"", @"kMountDirectoryKey",
               @"Layout", @"kUserNameKey",
               @"layout", @"kPasswordKey",
               [NSNumber numberWithBool:YES],
               @"kAsyncKey", NULL];
    
  [lowRes mountServer:mountDict];
  
  NSLog(@"Connect to Low Resolution Server");
  [displayLogs setStringValue:[NSString stringWithFormat:@"%@• Switched to Low Resolution\n", [displayLogs stringValue]]];
  
  [[[NSApplication sharedApplication] dockTile] setBadgeLabel:[NSString stringWithFormat:@"Low"]];
  [_lowResolutionButton setEnabled:NO];
  [_highResolutionButton setEnabled:YES];
  [_highResolutionButton highlight:YES];
}

@end
