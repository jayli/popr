//
//  EventBridge.m
//  EventBridge
//
//  Created by bachi on 2025/8/24.
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
    @autoreleasepool {
        // 1. 获取当前最前面的应用
        NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
        NSRunningApplication *frontApp = [workspace frontmostApplication];
        if (!frontApp || !frontApp.processIdentifier) {
            return nil;
        }

        // 2. 创建 AXUIElement 引用
        AXUIElementRef appRef = AXUIElementCreateApplication(frontApp.processIdentifier);
        if (!appRef) {
            return nil;
        }

        // 3. 获取当前焦点元素（光标所在控件）
        AXUIElementRef focusedElement = NULL;
        AXError error = AXUIElementCopyAttributeValue(appRef, kAXFocusedUIElementAttribute, (CFTypeRef *)&focusedElement);
        if (error != kAXErrorSuccess || !focusedElement) {
            CFRelease(appRef);
            return nil;
        }

        // 4. 获取选中的文本
        CFTypeRef selectedTextRef = NULL;
        error = AXUIElementCopyAttributeValue(focusedElement, kAXSelectedTextAttribute, &selectedTextRef);
        
        NSString *selectedText = nil;
        if (error == kAXErrorSuccess && selectedTextRef) {
            if (CFGetTypeID(selectedTextRef) == CFStringGetTypeID()) {
                selectedText = CFBridgingRelease(selectedTextRef); // 自动释放
                selectedTextRef = NULL; // 避免重复释放
            } else {
                CFRelease(selectedTextRef);
            }
        }

        // 5. 清理资源
        if (selectedTextRef) CFRelease(selectedTextRef);
        CFRelease(focusedElement);
        CFRelease(appRef);

        return selectedText;
    }
}

@end

// 返回 UTF-8 C 字符串（注意：静态存储 or malloc）
const char* get_hello(void) {
    return "Hello world!!!";
}

// C 接口实现
const char* _Nullable get_selected_text(void) {
    @autoreleasepool {
        // 先释放旧内存
        if (g_lastSelectedText) {
            free(g_lastSelectedText);
            g_lastSelectedText = NULL;
        }
        NSString *text = [EventBridge getSelectedText];

        NSString *tt = @"sdf";
        NSLog(@"loging-------------------- %@", text);

        if (!text) {
            return NULL;
        }
        
        // 转为 UTF-8 并复制到堆内存
        const char *utf8 = [text UTF8String];
        size_t len = strlen(utf8) + 1;
        char *copied = (char *)malloc(len);
        strcpy(copied, utf8);

        g_lastSelectedText = copied;
        
        return g_lastSelectedText;
    }
}

void free_selected_text(const char* str) {
    if (str == g_lastSelectedText) {
        // 我们只允许释放内部字符串
        if (g_lastSelectedText) {
            free((void *)g_lastSelectedText);
            g_lastSelectedText = NULL;
        }
    }
}


