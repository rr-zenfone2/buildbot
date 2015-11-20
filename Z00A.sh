#!/usr/bin/env bash

export BUILD_WITH_COLORS=0
export WORKSPACE=~/RR
export PATH=~/bin:$PATH
export USE_CCACHE=1
prebuilts/misc/linux-x86/ccache/ccache -M 30G

git config --global user.name knone1
git config --global user.email knone.null@gmail.com
git config --global core.excludesfile ~/.gitignore

DEVICE=Z00A

WORKSPACE=~/RR

cd $WORKSPACE

sleep 1
cd $WORKSPACE
cd hardware/intel/img/hwcomposer
sleep 1
# Update HWC interface
git fetch http://review.cyanogenmod.org/CyanogenMod/android_hardware_intel_img_hwcomposer refs/changes/86/117186/1 && git cherry-pick FETCH_HEAD

sleep 1
# hwc: Enabling ION
git fetch http://review.cyanogenmod.org/CyanogenMod/android_hardware_intel_img_hwcomposer refs/changes/87/117187/1 && git cherry-pick FETCH_HEAD

sleep 1
# hwc: merrifield_plus: Add legacy LP blob support
git fetch http://review.cyanogenmod.org/CyanogenMod/android_hardware_intel_img_hwcomposer refs/changes/89/117189/1 && git cherry-pick FETCH_HEAD

sleep 1
# Fix compiliation without WIDI support
git fetch http://review.cyanogenmod.org/CyanogenMod/android_hardware_intel_img_hwcomposer refs/changes/85/117185/1 && git cherry-pick FETCH_HEAD

sleep 1
# Update #define syntax for string concatenation
git fetch http://review.cyanogenmod.org/CyanogenMod/android_hardware_intel_img_hwcomposer refs/changes/84/117184/1 && git cherry-pick FETCH_HEAD

sleep 1
# hwc: Use the proper define for the primary display
git fetch http://review.cyanogenmod.org/CyanogenMod/android_hardware_intel_img_hwcomposer refs/changes/88/117188/1 && git cherry-pick FETCH_HEAD

sleep 2
cd $WORKSPACE
# intel: videdecoder: Allow INTEL_VIDEO_XPROC_SHARING to be defined
cd hardware/intel/common/libmix
git fetch http://review.cyanogenmod.org/CyanogenMod/android_hardware_intel_common_libmix refs/changes/92/117192/1 && git cherry-pick FETCH_HEAD

sleep 2
cd $WORKSPACE
cd system/core
# Turn a shutdown request into reboot when charger is connected.
git fetch http://review.cyanogenmod.org/CyanogenMod/android_system_core refs/changes/32/114532/1 && git cherry-pick FETCH_HEAD

sleep 2
cd $WORKSPACE
cd external/tinyalsa
# tinyalsa: Use kernel headers when available
git fetch http://review.cyanogenmod.org/CyanogenMod/android_external_tinyalsa refs/changes/30/114530/2 && git cherry-pick FETCH_HEAD

sleep 2
cd $WORKSPACE

source build/envsetup.sh && time brunch cm_$DEVICE-userdebug -j4
