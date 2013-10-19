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
  
  // Check if there's multiple phototheque connected
  BOOL isMultiplePhotothequeConnected = [urls containsObject:[NSURL URLWithString:@"file://localhost/Volumes/Phototheque-1/"]];
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
  
  
  //
  BOOL isPhotothequeConnected = [urls containsObject:[NSURL URLWithString:@"file://localhost/Volumes/Phototheque/"]];
  
  if (isPhotothequeConnected) {
    NSLog(@"Phototheque connected...");
    NSError *error;
    NSString *volumeFormat;
    NSInteger indexOfphototheque = [urls indexOfObject:[NSURL URLWithString:@"file://localhost/Volumes/Phototheque/"]];
    NSURL *volume = [urls objectAtIndex:indexOfphototheque];
    [displayLogs setStringValue:[NSString stringWithFormat:@"Phototheque connected at index %ld.", (long)indexOfphototheque]];
    [volume getResourceValue:&volumeFormat forKey:NSURLVolumeLocalizedFormatDescriptionKey error:&error];
    NSLog(@"Type of Volume: %@", volumeFormat);
    [displayLogs setStringValue:[NSString stringWithFormat:@"%@\nType of Server: %@", [displayLogs stringValue], volumeFormat]];
    
    
    if ([volumeFormat isEqualToString:@"AppleShare"]) {
      NSLog(@"High Resolution Server mounted.");
      [[[NSApplication sharedApplication] dockTile] setBadgeLabel:[NSString stringWithFormat:@"High"]];
      [_highResolutionButton setEnabled:NO];
      [_lowResolutionButton highlight:YES];

    } else if ([volumeFormat isEqualToString:@"SMB (NTFS)"]) {
      NSLog(@"Low Resolution Server.");
      [[[NSApplication sharedApplication] dockTile] setBadgeLabel:[NSString stringWithFormat:@"Low"]];
      [_lowResolutionButton setEnabled:NO];
      [_highResolutionButton highlight:YES];
    } else {
      NSLog(@"Unknown connected Server.");
      [[[NSApplication sharedApplication] dockTile] setBadgeLabel:[NSString stringWithFormat:@"Unknown"]];
    }
    
  } else {
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
    NSLog(@"Connect to High Res");
    
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
//    [_highResolutionButton setEnabled:NO];
//    [_lowResolutionButton highlight:YES];
  }
  
  if (resultCode == NSAlertOtherReturn) {
    NSLog(@"Connect to Low Res");
    
    NSDictionary *mountDict;
    mountDict = [NSDictionary dictionaryWithObjectsAndKeys:
                 @"layout-macdata", @"kServerNameKey",
                 @"Phototheque", @"kVolumeNameKey",
                 @"smb", @"kTransportNameKey",
                 @"", @"kMountDirectoryKey",
                 @"Layout", @"kUserNameKey",
                 @"layout", @"kPasswordKey",
                 [NSNumber numberWithBool:YES],
                 @"kAsyncKey", NULL];
    [phototheque mountServer:mountDict];
    NSLog(@"Unmount multiple server and mount Low Res");
    [[[NSApplication sharedApplication] dockTile] setBadgeLabel:[NSString stringWithFormat:@"Low"]];
//    [_lowResolutionButton setEnabled:NO];
//    [_highResolutionButton highlight:YES];
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
    
  NSArray *volumes = [ServerPipe listMountedVolume];
//  NSLog(@"%@", volumes);
  [displayLogs setStringValue:[volumes componentsJoinedByString:@"\n"]];
    
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
               @"smb", @"kTransportNameKey",
               @"", @"kMountDirectoryKey",
               @"Layout", @"kUserNameKey",
               @"layout", @"kPasswordKey",
               [NSNumber numberWithBool:YES],
               @"kAsyncKey", NULL];
    
  [lowRes mountServer:mountDict];
    
  [[[NSApplication sharedApplication] dockTile] setBadgeLabel:[NSString stringWithFormat:@"Low"]];
  [_lowResolutionButton setEnabled:NO];
  [_highResolutionButton setEnabled:YES];
  [_highResolutionButton highlight:YES];
}

@end
