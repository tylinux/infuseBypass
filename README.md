# Infuse(tvOS) bypass

> Only tested on Infuse 8.1.9 version


## Installation

1. Clone and build this project with xcodebuild
2. copy `build/Release-appletvos/InfuseBypass.framework` to `Payload/Infuse.app/Frameworks`
3. insert dylib load command into `Payload/Infuse.app/Infuse` with [https://github.com/tyilo/insert_dylib](https://github.com/tyilo/insert_dylib):
  ```bash
  insert_dylib @executable_path/Frameworks/InfuseBypass.framework/InfuseBypass infuse
  mv infuse_patched infuse
  ```
4. execute `zip -qr Infuse_patched_unsigned.ipa Payload` to create new ipa file.
5. Sideload the ipa file using `Sideloadly` or any other method.

or you can use `Sideloadly` to finish all steps like this: 
![https://imgur.com/a/FmXRI8K](https://i.imgur.com/XGjO1XU.png)
