# MotionControl

This tweak integrates [Leap Motion](https://www.leapmotion.com) into Mission Control. It allows you to (physically) swipe between spaces seamlessly!

It works by injecting itself into Dock.app in the form of a [ScriptingAddition](http://developer.apple.com/library/mac/#technotes/tn1164/_index.html).

## Getting Started

### Prequisites

- [Xcode 4.6](https://itunes.apple.com/us/app/xcode/id497799835), which includes the OS X 10.8 SDK
- [Leap SDK](https://developer.leapmotion.com/downloads/leap-motion/sdk)
- Leap Motion device

### Building

The first step to build the project is to clone the repository:

``` sh
git clone git://github.com/conradev/MotionControl.git
cd MotionControl
```

Next, you need to place the Leap SDK in the project folder. Assuming the Leap SDK disk image is mounted on your machine, run:

``` sh
cp -r /Volumes/Leap/LeapSDK ./
```

Now you are ready to build the project! To build it, simply run the `xcodebuild` command:

``` sh
xcodebuild -project MotionControl.xcodeproj -target MotionControlLauncher -configuration Release
```

### Installing

Installing is as simple as copying the launcher to your applications folder

``` sh
sudo cp -r build/Release/MotionControl.app /Applications/
```

Simply run the application, it will prompt you for your password once, and MotionControl will be loaded.
It is recommended to add the Application as a Login Item, so it loads every time you log in.

To get MotionControl to initialize itself, you have to swipe from space to space once using the trackpad. I hope to rid of this requirement in the future.
Once that has been done, Dock.app will now be waiting for Leap Motion swipe gestures. Enjoy!

### Uninstalling

To uninstall MotionControl, you have to remove the following files:

- `/Applications/MotionControl.app`
- `/Library/ScriptingAdditions/MotionControlHelper.osax`
