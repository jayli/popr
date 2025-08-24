//
//  EventBridge.h
//  EventBridge
//
//  Created by bachi on 2025/8/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EventBridge : NSObject

/// 获取当前激活应用中光标所在位置的选中文本
/// @return 选中的文本，如果没有选中内容则返回 nil
+ (nullable NSString *)getSelectedText;

@end

#ifdef __cplusplus
extern "C" {
#endif

/// C 接口函数，供 Rust 或其他语言调用
/// @return 返回 UTF-8 编码的 C 字符串（需手动释放内存，或由调用方管理）
const char* _Nullable get_selected_text_from_oc(void);
const char* _Nullable get_hello_from_oc(void);

/// 释放由 get_selected_text 返回的字符串内存（可选）
void free_selected_text_from_oc(const char* str);

#ifdef __cplusplus
}
#endif

NS_ASSUME_NONNULL_END

