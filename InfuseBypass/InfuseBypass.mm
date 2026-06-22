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
#include "dobby.h"

@interface InfuseBypass : NSObject
@end

static int return_true(void) {
    return 1;
}

static int return_false(void) {
    return 0;
}

static void patchAtAddr(size_t offset, void *fakeFn) {

    uint32_t target_idx = 0;

    const char *suffix = "infuse";
    size_t slen = strlen(suffix);
    uint32_t img_count = _dyld_image_count();
    for (uint32_t i = 0; i < img_count; i++) {
        const char *n = _dyld_get_image_name(i);
        if (!n) continue;
        size_t nlen = strlen(n);
        if (nlen >= slen && strcasecmp(n + nlen - slen, suffix) == 0) {
            target_idx = i;
            break;
        }
    }

    const struct mach_header_64 *hdr = (const struct mach_header_64 *)_dyld_get_image_header(target_idx);
    void *hookAddr = (void *)((uintptr_t)hdr + offset);
    DobbyHook(hookAddr, (void *)fakeFn, NULL);
}

// hook for version 8.4.7
static void applyPatches_8_4_7(void) {
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    if (![version isEqualToString:@"8.4.7"]) {
        return;
    }
    // patch IAP status
    patchAtAddr(0x7BDA84, (void *)return_true);
    // patch pro features unlock check
    patchAtAddr(0x5A1180, (void *)return_false);
}

@implementation InfuseBypass

+ (void)load {
    Class HookClass = InfuseBypass.class;
    // Hook -[FCInAppPurchaseServiceFreemium iapVersionStatus]
    Class iapClass = objc_getClass("FCInAppPurchaseServiceFreemium");
    Method originalIapMethod = class_getInstanceMethod(iapClass, NSSelectorFromString(@"iapVersionStatus"));
    Method swizzledIapMethod = class_getInstanceMethod(HookClass, @selector(returnTrue));

    if (originalIapMethod && swizzledIapMethod) {
        method_exchangeImplementations(originalIapMethod, swizzledIapMethod);
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

    // patches for 8.4.7
    applyPatches_8_4_7();
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
