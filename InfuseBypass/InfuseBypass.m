//
//  InfuseBypass.m
//  InfuseBypass
//
//  Created by tylinux on 2025/12/27.
//
#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface InfuseBypass : NSObject

@end

@implementation InfuseBypass

+ (void)load {
    Class HookClass = InfuseBypass.class;
    // 1. Hook FCInAppPurchaseServiceFreemium iapVersionStatus
    Class iapClass = objc_getClass("FCInAppPurchaseServiceFreemium");
    Method originalIapMethod = class_getInstanceMethod(iapClass, NSSelectorFromString(@"iapVersionStatus"));
    Method swizzledIapMethod = class_getInstanceMethod(HookClass, @selector(returnTrue));

    if (originalIapMethod && swizzledIapMethod) {
        method_exchangeImplementations(originalIapMethod, swizzledIapMethod);
    }
    // 2. Hook NSFileManager 的 containerURLForSecurityApplicationGroupIdentifier:
    Class fileManagerClass = objc_getClass("NSFileManager");
    Method originalFMMethod = class_getInstanceMethod(fileManagerClass, @selector(containerURLForSecurityApplicationGroupIdentifier:));
    Method swizzledFMMethod = class_getInstanceMethod(HookClass, @selector(containerURLForSecurityApplicationGroupIdentifier:));
    
    if (originalFMMethod && swizzledFMMethod) {
        method_exchangeImplementations(originalFMMethod, swizzledFMMethod);
    }
    // 3. Hook CKContainer 的 defaultContainer
    Class cloudKitClass = objc_getClass("CKContainer");
    Method originalDefaultMethod = class_getClassMethod(cloudKitClass, @selector(defaultContainer));
    Method swizzledDefaultMethod = class_getClassMethod(HookClass, @selector(defaultContainer));
    
    if (originalDefaultMethod && swizzledDefaultMethod) {
        method_exchangeImplementations(originalDefaultMethod, swizzledDefaultMethod);
    }
    // 4. Hook CKContainer 的 containerWithIdentifier:
    Method originalIdentifierMethod = class_getClassMethod(cloudKitClass, @selector(containerWithIdentifier:));
    Method swizzledIdentifierMethod = class_getClassMethod(HookClass, @selector(containerWithIdentifier:));
    
    if (originalIdentifierMethod && swizzledIdentifierMethod) {
        method_exchangeImplementations(originalIdentifierMethod, swizzledIdentifierMethod);
    }
}

- (BOOL)returnTrue {
    return YES;
}
- (NSURL *)containerURLForSecurityApplicationGroupIdentifier:(NSString *)groupIdentifier {
    NSString *homeDirectory = NSHomeDirectory();
    NSString *containerBasePath = [homeDirectory stringByAppendingPathComponent:@"Documents/ApplicationGroupContainers"];
    NSURL *baseURL = [NSURL fileURLWithPath:containerBasePath isDirectory:YES];
    NSURL *containerURL = [baseURL URLByAppendingPathComponent:groupIdentifier];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *containerPath = [containerURL path];
    BOOL containerExists = [fileManager fileExistsAtPath:containerPath];
    
    if (!containerExists) {
        NSError *error = nil;
        
        [fileManager createDirectoryAtURL:containerURL
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:&error];

        NSURL *appSupportURL = [containerURL URLByAppendingPathComponent:@"Library/Application Support"];
        [fileManager createDirectoryAtURL:appSupportURL
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:&error];

        NSURL *cachesURL = [containerURL URLByAppendingPathComponent:@"Library/Caches"];
        [fileManager createDirectoryAtURL:cachesURL
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:&error];

        NSURL *preferencesURL = [containerURL URLByAppendingPathComponent:@"Library/Preferences"];
        [fileManager createDirectoryAtURL:preferencesURL
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:&error];
    }

    return containerURL;
}
+ (id)defaultContainer {
    return nil;
}
+ (id)containerWithIdentifier:(NSString *)identifier {
    return nil;
}

@end
