## AAPT & APKName for Android

**AAPT** - Android Asset Packaging Tool. This tool is part of the SDK (and build system) and allows you to view, create, and update Zip-compatible archives (zip, jar, apk). The original one is only built for host i.e. Linux, Mac and Windows. This repo has been modified to use with Android System & Recovery.

**APKName** - Trimmed version of AAPT that only dumps the package name and application label of given APK.

**Building :**

1. Sync any android ROM. This repo is splited from [OmniROM](https://github.com/omnirom)

2. Remove old aapt folder from frameworks/base

	`rm -rf frameworks/base/tools/aapt`

3. Clone this repo to aapt path

	`git clone https://github.com/Devil7DK/aapt-android -b master frameworks/base/tools/aapt`

4. Run following commands to build

	`. build/envsetup.sh && lunch <generic> && make aapt
-j$(($(nproc)*2))` - for building AAPT

	`. build/envsetup.sh && lunch < generic > && make apkname
-j$(($(nproc)*2))` - for building APKName
