
cd ./event-bridge/
clang -fobjc-arc \
      -framework Foundation \
      -framework AppKit \
      -framework ApplicationServices \
      -shared \
      -o libeventbridge.dylib \
      EventBridge.m

cargo build

cp ./event-bridge/libeventbridge.dylib ./target/debug/
