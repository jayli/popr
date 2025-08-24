// bindgen 可生成更完整的绑定，这里手动声明
unsafe extern "C" {
    fn get_selected_text() -> *const std::os::raw::c_char;
    fn free_selected_text_string(str: *const std::os::raw::c_char);
}

fn main() {
    unsafe {
        let c_str = get_selected_text();
        if !c_str.is_null() {
            let rust_str = std::ffi::CStr::from_ptr(c_str).to_string_lossy().into_owned();
            println!("✅ 选中文本: {}", rust_str);

            // 可选：释放内存（如果需要）
            // free_selected_text_string(c_str);
        } else {
            println!("❌ 无选中文本或权限不足");
        }
    }
}
