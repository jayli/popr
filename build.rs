// build.rs
use std::env;
use std::path::PathBuf;

fn main() {
    // 获取当前项目目录
    let project_dir = env::var("CARGO_MANIFEST_DIR").expect("CARGO_MANIFEST_DIR not set");
    
    // 假设 libeventbridge.dylib 放在项目根目录的 `event-bridge/` 文件夹
    let dylib_dir = PathBuf::from(project_dir).join("event-bridge");
    
    // 告诉 rustc 去这个目录找动态库
    println!("cargo:rustc-link-search=native={}", dylib_dir.display());
    
    // 告诉 rustc 链接 libeventbridge（会自动找 libeventbridge.dylib）
    println!("cargo:rustc-link-lib=dylib=eventbridge");
    
    // 可选：如果 dylib 依赖其他框架，也要链接
    println!("cargo:rustc-link-lib=framework=Foundation");
    println!("cargo:rustc-link-lib=framework=AppKit");
    println!("cargo:rustc-link-lib=framework=ApplicationServices");
}
