//
//  EventBridge.m
//  EventBridge
//
//  Created by HFY on 2025/8/24.
//

// EventBridge.m

#import "EventBridge.h"
#import <ApplicationServices/ApplicationServices.h>
#import <AppKit/AppKit.h>
#import <objc/runtime.h>

// 静态字符串存储（用于 C 接口返回）
static char* g_lastSelectedText = NULL;

@implementation EventBridge

+ (NSString *)getSelectedText {
    // 获取当前最前面的应用
    NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
    NSArray<NSRunningApplication *> *runningApps = [workspace runningApplications];
    
    NSRunningApplication *frontApp = nil;
    for (NSRunningApplication *app in runningApps) {
        if (app.isActive) {
            frontApp = app;
            break;
        }
    }
    
    if (!frontApp || !frontApp.processIdentifier) {
        return nil;
    }
    
    // 创建 AXUIElement
    AXUIElementRef appRef = AXUIElementCreateApplication(frontApp.processIdentifier);
    if (!appRef) {
        return nil;
    }
    
    // 获取焦点元素
    AXUIElementRef focusedElement = NULL;
    AXError result = AXUIElementCopyAttributeValue(appRef, kAXFocusedUIElementAttribute, (CFTypeRef *)&focusedElement);
    if (result != kAXErrorSuccess || !focusedElement) {
        CFRelease(appRef);
        return nil;
    }
    
    // 获取选中文本
    CFStringRef selectedTextRef = NULL;
    result = AXUIElementCopyAttributeValue(focusedElement, kAXSelectedTextAttribute, (CFTypeRef *)&selectedTextRef);
    
    NSString *selectedText = nil;
    if (result == kAXErrorSuccess && selectedTextRef) {
        selectedText = (__bridge_transfer NSString *)selectedTextRef;
    } else {
        // 失败时清理
        if (selectedTextRef) CFRelease(selectedTextRef);
    }
    
    // 清理资源
    CFRelease(focusedElement);
    CFRelease(appRef);
    
    return selectedText;
}

@end

// 返回 UTF-8 C 字符串（注意：静态存储 or malloc）
const char* get_hello(void) {
    return "Hello world!!!";
}

// C 接口实现
const char* _Nullable get_selected_text(void) {
    @autoreleasepool {
        NSString *text = [EventBridge getSelectedText];
        if (!text) {
            // 释放旧内存
            if (g_lastSelectedText) {
                free(g_lastSelectedText);
                g_lastSelectedText = NULL;
            }
            return NULL;
        }
        
        // 转为 UTF-8 并复制到堆内存
        const char *utf8 = [text UTF8String];
        size_t len = strlen(utf8) + 1;
        char *copied = (char *)malloc(len);
        if (copied) {
            strcpy(copied, utf8);
        }
        
        // 释放旧内存
        if (g_lastSelectedText) {
            free(g_lastSelectedText);
        }
        g_lastSelectedText = copied;
        
        return g_lastSelectedText;
    }
}

void free_selected_text_string(const char* str) {
    if (str == g_lastSelectedText) {
        // 我们只允许释放内部字符串
        if (g_lastSelectedText) {
            free((void *)g_lastSelectedText);
            g_lastSelectedText = NULL;
        }
    }
    // 注意：不支持释放任意指针
}


