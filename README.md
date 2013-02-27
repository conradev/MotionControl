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
xcodebuild -project MotionControl.xcodeproj -target MotionControlHelper -configuration Release
```

### Installing

Installing and running is currently manual. I have plans to include the helper bundle with an application to both install and inject MotionControl upon launch, but until then, you'll have to do install it manually.

First, you need to copy the helper bundle to `/Library/ScriptingAdditions`:

``` sh
sudo cp -r build/Release/MotionControlHelper.osax /Library/ScriptingAdditions/
```

To inject MotionControl into Dock.app, you can run the following command:

``` sh
osascript -e 'tell application "Dock"' -e '«event MCTLLoad»' -e 'end tell'
```

Now, to get MotionControl to initialize itself, you have to swipe from space to space once using the trackpad. I hope to rid of this requirement in the future as well.
Once that has been done, Dock.app will now be polling the Leap Motion for swipe events. Enjoy!
