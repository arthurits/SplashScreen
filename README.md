# Splash screen
A stand-alone splash screen used to launch other exe applications under Windows OS.

The main idea is totally  based on [Bradley Grainger's blog entry](https://faithlife.codes/blog/2008/09/displaying_a_splash_screen_with_c_introduction/ "Bradley's blog entry") posted back on September 22, 2008.
Shortly after, Stefan Olson built Bradley’s code (incorporating a few improvements) into a new Visual C++ application and shared it in a blog post on November 27. Unfortunately, his post is no longer available, although it can be retrieved using WayBackMachine [here](https://web.archive.org/web/20081212164733/http://olsonsoft.com/blogs/stefanolson/post/A-better-WPF-splash-screen.aspx "Archived Stefan's blog entry").

This project continues Bradley's and Stefan's efforts incorporating some minor tweaks:
* Splash image, application to be launched and fadeout time are all retrieved from an external plain text file. It could be easily adapted to JSON files if a JSON parser (such as [rapidJSON](https://github.com/Tencent/rapidjson "rapidJSON GitHub")) is included. 
* The splash screen is closed during the fadeout whenever the launched application is closed (the WM_QUIT message posted from the launched application is handled by the splash screen).
* The C++ version is ported to assembly (for the smallest and fastest possible executable) and some basic OOP is implemented.

## Instructions
1. Set the splash screen application icon in the corresponding resources.rc file and then compile any of the 3 versions.
2. Create a text file named *settings.txt* and place it in the same folder as the splash screen application. Write three text lines:
   * Path (either absolute or relative) of the splash image. The resulting absolute path should be less than 260 characters long.
   * Path (either absolute or relative) of the application to be launched. The resulting absolute path should be less than 260 characters long.
   * Time in miliseconds for the fading out of the splash screen (typically 500 or less).
3. Use this code in the form's shown event to signal the fading out of the splash screen:
```csharp
private void Form1_Shown(Object sender, EventArgs e)
{
    // signal the native process (that launched us) to close the splash screen
    using (var closeSplashEvent = new EventWaitHandle(false, EventResetMode.ManualReset, "CloseSplashScreenEvent"))
    {
        closeSplashEvent.Set();
    }
}
```

## MASM x86 version
Compiling requirements: masm32 SDK.

Execution requirements: Windows 2000 and above.

Developement status: currently functional, minor adjustments needed.

## MASM x64 version
Compiling requirements: Windows SDK.

Execution requirements: Windows 2000 and above.

Developement status: currently functional, minor adjustments needed.

## C++ version
Minor tweaks to Bradley's and Stefan's original.

Compiling requirements: C++ and Windows SDK.

Execution requirements: Visual C++ redistributable under Windows 2000 and above.

Developement status: currently functional. Minor adjustments needed.


## License
Free for personal use.
No commercial use allowed.
