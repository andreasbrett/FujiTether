# FujiTether
**Quickest** way of shooting tethered with your Fuji X-T1, X-T2 and GFX50s (**windows only**)

## Prerequisites:
- Windows 10
- Fujifilm X-Acquire (download: http://www.fujifilm.com/support/digital_cameras/software/x_acquire/win/)

## What about Lightroom's AutoImport Feature?
While there is a big point in simply using Lightroom with its builtin feature **AutoImport** the goal of FujiTether is to display your photos **as quickly as possible**. If timing is of utmost importance and you can live with doing all the cataloging stuff *after* the photoshoot this script is for you.

I analyzed the photo transfer of X-Acquire and it is really fast! What takes long when using Lightroom is all the processing that is done:

- importing to the catalog
- keywording the photo
- setting metadata
- rendering previews

This is what I roughly measured with a stopwatch:
- X-Acquire transfers a JPG in under ***3sec*** to your computer (not much slower when using USB 2.0)
- Lightroom takes ***4sec*** to finally display the image
- **FujiTether takes *0.3sec* to display the image**  

## How to use it
There's not much to do to get FujiTether running.

If you've downloaded and installed **X-Acquire** from the Fujifilm website, configure it once to your liking. Run **FujiTether** by right-clicking the main file (***FujiTether.ps1***) and choosing **Run with Powershell**. FujiTether will figure out where files are uploaded to and poll this folder 4 times a second (=250msec) for new photos. New files are moved to a subfolder **FujiTether** and the latest JPEG will be displayed in fullscreen using Windows' onboard Photo Viewer in fullsreen mode.

This is what makes FujiTether so fast and efficient: **high speed polling** and **instant display**.

## Best X-Acquire Settings
- I choose to transfer JPEG only if speed counts and/or I'm using a USB 2.0 cable
- I choose to transfer JPEG+RAW if I want to work with all images right away after the photo shoot and/or I'm using a USB 3.0 cable (transfer of JPEG+RAW is not much slower than JPEG only)
- I always save JPEG+RAW to my camera for backup reasons

## Other Benefits?
FujiTether is a 1-click solution setting up **Tethered Shooting** right away. If you run the tool everything else will run with it. No need to run X-Acquire and no need to setup anything else. Setting up a tethered photoshoot couldn't be quicker. 

## Are there really no configurable options?!
There are some variables that you can tweak within the source code.

- **$FujiXAcquire**: specify path to Fuji X-Acquire executable (if you installed to a different folder)
- **$watchIntervalInMsec**: specify the polling interval (250msec did not slow down my Surface Pro 4 ***at all***)
- **$storeFolder**: specify a different folder to store final images in