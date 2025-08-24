use rdev::{listen, Event, EventType};

// bindgen 可生成更完整的绑定，这里手动声明
unsafe extern "C" {
    fn get_selected_text_from_oc() -> *const std::os::raw::c_char;
    fn get_hello_from_oc() -> *const std::os::raw::c_char;
    fn free_selected_text_from_oc(str: *const std::os::raw::c_char);
}

fn get_selected_text() -> String {
    unsafe {
        let hello_text = get_hello_from_oc();
        let hello_str = std::ffi::CStr::from_ptr(hello_text).to_string_lossy().into_owned();
        // return hello_str;
        free_selected_text_from_oc(hello_text);
        // println!("{}", hello_str);
        let c_str = get_selected_text_from_oc();
        if !c_str.is_null() {
            let rust_str = std::ffi::CStr::from_ptr(c_str).to_string_lossy().into_owned();
            free_selected_text_from_oc(c_str);
            return rust_str;
            // println!("✅ 选中文本: {}", rust_str);

            // 可选：释放内存（如果需要）
            // free_selected_text_from_oc(c_str);
        } else {
            return "".to_string();
        }
    }
}

fn main() {
    println!("================ main begin!==================");
    // unsafe {
    //     let hello_text = get_hello_from_oc();
    //     let hello_str = std::ffi::CStr::from_ptr(hello_text).to_string_lossy().into_owned();
    //     free_selected_text_from_oc(hello_text);
    //     println!("{}", hello_str);
    // }
    println!("开始监听键盘/鼠标事件...");

    listen(|event: Event| {
        match event.event_type {
            EventType::KeyPress(key) => {
                println!("⌨️ KeyPress: {:?}", key);
            }
            EventType::ButtonRelease(button) => {
                let tmp_text: String = get_selected_text();
                println!("🖱️ ButtonRelease: {:?}", button);
                println!(">>>: {:?}", tmp_text);
            }
            _ => {}
        }
    }).expect("无法启动监听");
}
