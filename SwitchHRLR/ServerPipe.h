//
//  ServerPipe.h
//  SwitchHRLR
//
//  Created by Nicolas Georget on 9/26/12.
//  Copyright (c) 2012 Nicolas Georget. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServerPipe : NSObject {
    NSString *kServerNameKey;
    NSString *kVolumeNameKey;
    NSString *kTransportNameKey;
    NSString *kMountDirectoryKey;
    NSString *kUserNameKey;
    NSString *kPasswordKey;
    NSString *kAsyncKey;
}

-(void)mountServer:(NSDictionary *)mountDictionary;
-(void)mountServers:(NSArray *)array;

-(void)unmountServer:(NSString *)path;
-(void)unmountServers:(NSArray *)array;

+(id)listMountedVolume;

@end
