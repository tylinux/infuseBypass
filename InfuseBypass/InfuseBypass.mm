//
//  InfuseBypass.m
//  InfuseBypass
//
//  Created by tylinux on 2025/12/27.
//
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <mach-o/dyld.h>
#import <strings.h>

@interface InfuseBypass : NSObject
@end

@implementation InfuseBypass

+ (void)load {
    NSLog(@"Infuse Bypass init");
    Class HookClass = InfuseBypass.class;
    // Hook -[FCInAppPurchaseServiceFreemium iapVersionStatus]
    Class iapClass = objc_getClass("FCInAppPurchaseServiceFreemium");
    Method originalIapMethod = class_getInstanceMethod(iapClass, NSSelectorFromString(@"iapVersionStatus"));
    Method swizzledIapMethod = class_getInstanceMethod(HookClass, @selector(returnTrue));

    if (originalIapMethod && swizzledIapMethod) {
        method_exchangeImplementations(originalIapMethod, swizzledIapMethod);
    }

    // Hook Swift -[Infuse.InAppPurchaseServiceFreemiumSK2 iapVersionStatus]
    Class swiftIapClass = objc_getClass("_TtC6infuse31InAppPurchaseServiceFreemiumSK2");
    Method originalSwiftIapMethod = class_getInstanceMethod(swiftIapClass, NSSelectorFromString(@"iapVersionStatus"));
    Method swizzledSwiftIapMethod = class_getInstanceMethod(HookClass, @selector(returnTrue));

    if (originalSwiftIapMethod && swizzledSwiftIapMethod) {
        method_exchangeImplementations(originalSwiftIapMethod, swizzledSwiftIapMethod);
    }

    // Hook -[Infuse.InAppPurchaseServiceFreemiumSK2 isFeaturePurchased:tillDate:]
    Method originalSK2PurchaseMethod = class_getInstanceMethod(swiftIapClass, @selector(isFeaturePurchased:tillDate:));
    Method swizzledSK2PurchaseMethod = class_getInstanceMethod(HookClass, @selector(isFeaturePurchased:tillDate:));

    if (originalSK2PurchaseMethod && swizzledSK2PurchaseMethod) {
        method_exchangeImplementations(originalSK2PurchaseMethod, swizzledSK2PurchaseMethod);
    }

    // Hook NSFileManager containerURLForSecurityApplicationGroupIdentifier:
    Class fileManagerClass = objc_getClass("NSFileManager");
    Method originalFMMethod = class_getInstanceMethod(fileManagerClass, @selector(containerURLForSecurityApplicationGroupIdentifier:));
    Method swizzledFMMethod = class_getInstanceMethod(HookClass, @selector(containerURLForSecurityApplicationGroupIdentifier:));

    if (originalFMMethod && swizzledFMMethod) {
        method_exchangeImplementations(originalFMMethod, swizzledFMMethod);
    }
    // Hook CKContainer defaultContainer
    Class cloudKitClass = objc_getClass("CKContainer");
    Method originalDefaultMethod = class_getClassMethod(cloudKitClass, @selector(defaultContainer));
    Method swizzledDefaultMethod = class_getClassMethod(HookClass, @selector(defaultContainer));

    if (originalDefaultMethod && swizzledDefaultMethod) {
        method_exchangeImplementations(originalDefaultMethod, swizzledDefaultMethod);
    }

    // Hook CKContainer containerWithIdentifier:
    Method originalIdentifierMethod = class_getClassMethod(cloudKitClass, @selector(containerWithIdentifier:));
    Method swizzledIdentifierMethod = class_getClassMethod(HookClass, @selector(containerWithIdentifier:));

    if (originalIdentifierMethod && swizzledIdentifierMethod) {
        method_exchangeImplementations(originalIdentifierMethod, swizzledIdentifierMethod);
    }
}

- (BOOL)returnTrue {
    return YES;
}
- (BOOL)isFeaturePurchased:(long long)purchased tillDate:(id *)date {
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
