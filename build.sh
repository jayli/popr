
cd ./event-bridge/
echo "building eventbridge"
clang -fobjc-arc \
      -framework Foundation \
      -framework AppKit \
      -framework ApplicationServices \
      -shared \
      -o libeventbridge.dylib \
      EventBridge.m

echo "eventbridge build finish"

cargo build

cp ./event-bridge/libeventbridge.dylib ./target/debug/
