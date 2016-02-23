To compile a C project that makes use of the OSULogger facilities on darwin try:

```gcc -L /swift-nightly-install/Applications/Xcode.app/Contents/Developer/Toolchains/swift-SNAPSHOT-2016-02-21-a.xctoolchain/usr/lib/swift -Wl,-rpath,/swift-nightly-install/Applications/Xcode.app/Contents/Developer/Toolchains/swift-SNAPSHOT-2016-02-21-a.xctoolchain/usr/lib/swift -o clog ../test.c -I Headers/ -L .build/debug/ -lOSULogger -Wl,-rpath,`pwd`/.build/debug```
