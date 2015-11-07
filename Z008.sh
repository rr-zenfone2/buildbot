#!/usr/bin/env bash

# Lets all build in the same time zone
export TZ="usr/share/zoneinfo/UTC"
export BUILD_WITH_COLORS=0
export WORKSPACE=~/RR

git config --global user.name knone1
git config --global user.email knone.null@gmail.com
git config --global core.excludesfile ~/.gitignore

DEVICE=Z008

if [ -z "$HOME" ]
then
  echo HOME not in environment, guessing...
  export HOME=$(awk -F: -v v="$USER" '{if ($1==v) print $6}' /etc/passwd)
fi

function check_result {
  if [ "0" -ne "$?" ]
  then
    (repo forall -c "git reset --hard") >/dev/null
    echo $1
    exit 1
  fi
}

WORKSPACE=~/RR

cd $WORKSPACE

# Jenkins logs in with "bash -c ..." which does not read any profile or rc
# files (that is, it's not a login or interactive shell).  Source the system
# profile here to pull in system settings such as ccache variables, etc.
if [ -d /etc/profile.d ]; then
  for i in /etc/profile.d/*.sh; do
    if [ -r $i ]; then
      . $i
    fi
  done
  unset i
fi

REPO=$(which repo)
if [ -z "$REPO" ]
then
  mkdir -p ~/bin
  curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
  chmod a+x ~/bin/repo
fi

export PATH=~/bin:$PATH
export USE_CCACHE=1

CCACHE_BIN=$(which ccache)
if [ -z "$CCACHE_BIN" ]
then
  CCACHE_BIN="prebuilts/misc/linux-x86/ccache/ccache"
fi

if [ -z "$CCACHE_DIR" ]
then
  #export CCACHE_DIR="$HOME/.ccache-$device"
  export CCACHE_DIR=$WORKSPACE/.ccache
  if [ ! -d "$CCACHE_DIR" -a -x "$CCACHE_BIN" ]
  then
    mkdir -p "$CCACHE_DIR"
    #$CCACHE_BIN -M 20G
    $CCACHE_BIN -M 30G
  fi
fi

rm -Rf $WORKSPACE/cache/*

rm -Rf $WORKSPACE/kernel/*

#to ensure the right arch is clean..
#source build/envsetup.sh && time breakfast cm_$DEVICE-userdebug

make clean

sleep 2
make clobber

sleep 3
rm -Rf $WORKSPACE/out/*

 repo sync --force-sync -d -f -c
  check_result "repo sync failed."

#cp -Rv ~/backup/* ~/RR/device/asus

rm -Rv $WORKSPACE/frameworks/testing/*

cp -Rv ~/buildbot/patch/charger-ui-3.patch ~/RR/frameworks/base/

cd $WORKSPACE/frameworks/base/

git am charger-ui-3.patch
#patch -p1 < fb.patch 1>&2

sleep 1
cd $WORKSPACE
git fetch http://review.cyanogenmod.org/CyanogenMod/android_device_asus_mofd-common refs/changes/37/117837/1 && git cherry-pick FETCH_HEAD

sleep 1
cd $WORKSPACE
cd hardware/intel/img/hwcomposer && git fetch http://review.cyanogenmod.org/CyanogenMod/android_hardware_intel_img_hwcomposer refs/changes/82/117182/1 && git cherry-pick FETCH_HEAD

git fetch http://review.cyanogenmod.org/CyanogenMod/android_hardware_intel_img_hwcomposer refs/changes/83/117183/1 && git cherry-pick FETCH_HEAD

sleep 1
cd $WORKSPACE
git fetch http://review.cyanogenmod.org/CyanogenMod/android_device_asus_mofd-common refs/changes/37/117837/1 && git cherry-pick FETCH_HEAD

sleep 1
cd $WORKSPACE
cd hardware/intel/img/libdrm && git fetch http://review.cyanogenmod.org/CyanogenMod/android_hardware_intel_img_libdrm refs/changes/01/117201/1 && git cherry-pick FETCH_HEAD


sleep 1
cd $WORKSPACE
cd hardware/intel/common/libmix && git fetch http://review.cyanogenmod.org/CyanogenMod/android_hardware_intel_common_libmix refs/changes/91/117191/1 && git cherry-pick FETCH_HEAD

sleep 1
cd $WORKSPACE

cd frameworks/native && git fetch http://review.cyanogenmod.org/CyanogenMod/android_frameworks_native refs/changes/64/109364/3 && git cherry-pick FETCH_HEAD


cd $WORKSPACE

cd system/core && git fetch http://review.cyanogenmod.org/CyanogenMod/android_system_core refs/changes/65/109365/6 && git cherry-pick FETCH_HEAD

cd $WORKSPACE
cd external/tinyalsa && git fetch http://review.cyanogenmod.org/CyanogenMod/android_external_tinyalsa refs/changes/43/103343/1 && git cherry-pick FETCH_HEAD && cd ../.. && cd bootable/recovery && git fetch http://review.cyanogenmod.org/CyanogenMod/android_bootable_recovery refs/changes/26/102426/1 && git cherry-pick FETCH_HEAD && cd ../.. && cd system/core && git fetch http://review.cyanogenmod.org/CyanogenMod/android_system_core refs/changes/28/103928/1 && git cherry-pick FETCH_HEAD && cd ../.. && cd hardware/ril && git fetch http://review.cyanogenmod.org/CyanogenMod/android_hardware_ril refs/changes/25/102725/2 && git cherry-pick FETCH_HEAD && cd ../.. && cd system/core && git fetch http://review.cyanogenmod.org/CyanogenMod/android_system_core refs/changes/70/101970/2 && git cherry-pick FETCH_HEAD && git fetch http://review.cyanogenmod.org/CyanogenMod/android_system_core refs/changes/86/110686/1 && git cherry-pick FETCH_HEAD

cd $WORKSPACE

source build/envsetup.sh && time brunch cm_$DEVICE-userdebug -j3



#LAST_CLEAN=0
#if [ -f .clean ]
#then
#  LAST_CLEAN=$(date -r .clean +%s)
#fi
#TIME_SINCE_LAST_CLEAN=$(expr $(date +%s) - $LAST_CLEAN)
# convert this to hours
#TIME_SINCE_LAST_CLEAN=$(expr $TIME_SINCE_LAST_CLEAN / 60 / 60)
#if [ $TIME_SINCE_LAST_CLEAN -gt "72" ]
#then
#  echo "Cleaning!"
#  touch .clean
#  make clobber
#else
#echo "Skipping clean: $TIME_SINCE_LAST_CLEAN hours since last clean."
#i

$CCACHE_BIN -s

