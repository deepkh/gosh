#!/bin/bash
DEBIAN_RCS_BIN_PATH=/opt/rcs/bin
AOSP_HELPER_PATH=$DEBIAN_RCS_BIN_PATH/aosp_helper.sh
AOSP_TARGET_FILE=.target
ADB=$DEBIAN_RCS_BIN_PATH/adb
#ADB=/home/${WHOAMI}/workspace/aosp_cm-14.1_5422/out/host/linux-x86/bin/adb
#ADB=/opt/workspace/aosp_8.1_poplar/out/soong/host/linux-x86/bin/adb
FASTBOOT=/opt/rcs/bin/fastboot

_set_aosp_target() {
  if [ ! -f "$AOSP_TARGET_FILE" ]; then
    echo "Do you wish to install this program?"
    select yn in "generic_x86_64" "poplar" "scorpion_windy" "generic"; do
      case $yn in
        "generic_x86_64" ) RET=generic_x86_64; break;;
        "poplar" ) RET=poplar; break;;
        "scorpion_windy" ) RET=scorpion_windy; break;;
        "generic" ) RET=generic; break;;
      esac
    done
    echo $RET > $AOSP_TARGET_FILE
  fi
  AOSP_TARGET=`cat $AOSP_TARGET_FILE`
}

_get_aosp_target() {
  _set_aosp_target

  if [ "$AOSP_TARGET" = "generic_x86_64" ]; then
    ADB_ADDR=
    AOSP_LUNCH=6    # aosp8.0 x86_64 emulator
  elif [ "$AOSP_TARGET" = "poplar" ]; then
    ADB_ADDR=192.168.9.2:5555
    #ADB_ADDR=192.168.4.157:5555
    #ADB_ADDR=192.168.4.222:5555
    #ADB_ADDR=
    AOSP_LUNCH=34   # aosp8.1 34. poplar-eng 
  elif [ "$AOSP_TARGET" = "scorpion_windy" ]; then
    ADB_ADDR=192.168.4.44:5555
    AOSP_LUNCH=36   # aosp6.0.1 36. aosp_sgp611-userdebug
  elif [ "$AOSP_TARGET" = "generic" ]; then
    ADB_ADDR=192.168.9.2:5555
    AOSP_LUNCH=1    # aosp8.0.0_r17_poplar armv7
  fi
}

repo_log_forall() {
  repo forall -c 'pwd ; git log --pretty=format:"%ci%x09%s" | head -5 ; echo '   ''
}


#### repo checkout by a date
#### 0
# first to get default.xml from .repo/manifest at 180720
# and then repo sync to this 180720's manfiest to obtains the same git module structures
#
# cp defaul_180720.xml .repo/manifests
# repo init -m defaul_180720.xml
# repo sync



## repo sync for a clean tree
## repo forall -c 'git reset --hard; git clean -f -d -x'; time repo sync; date
#
#### 1 checkout sub-modules to master
repo_checkout_master_forall() {
  repo forall -c 'git checkout -b master'
}

#### 2 checkout sub-modules by a date 
repo_checkout_before_180720() {
  repo forall -c 'git checkout `git rev-list -n 1 --before="2018-07-20 00:00" master`'
}

repo_checkout_before_180627() {
  repo forall -c 'git checkout `git rev-list -n 1 --before="2018-05-27 00:00" HEAD`'
}

repo_checkout_before_180508() {
  repo forall -c 'git checkout `git rev-list -n 1 --before="2018-05-08 00:00" HEAD`'
}

adb_logcat_clear() {
  $ADB logcat -G 64M
  $ADB logcat -c
  $ADB logcat -c
  $ADB logcat -c
}

adb_logcat_filter() {
  adb_logcat_clear
  $ADB logcat | grep -E $1
}

adb_logcat() {
  adb_logcat_clear
  $ADB logcat 
}

adb_logcat_ms() {
  echo 123
# adb_logcat_filter "NuPlayer|PlaylistFetcher
}

adb_logcat_ali() {
  adb_logcat_filter "ALIALI"
}

adb_logcat_exo() {
  adb_logcat_filter "EXOEXO"
}

adb_logcat_avpath() {
  adb_logcat_filter "AVPATH"
}

adb_shell() {
  $ADB shell $@
}

adb_push() {
  $ADB push $@
}

adb_pull() {
  $ADB pull $@
}

adb_install() {
  $ADB pull $@
}

adb_connect() {
  _get_aosp_target
  sudo $ADB start-server
  if [ "$ADB_ADDR" != "" ]; then
    sudo $ADB connect $ADB_ADDR
  fi
  sudo $ADB root
  sudo $ADB shell setenforce 0
  sudo $ADB remount
  _aosp_get_wm_size
}

adb_disconnect() {
  sudo $ADB kill-server
}

_aosp_emulator() {
  _get_aosp_target
  source build/envsetup.sh && lunch $AOSP_LUNCH && emulator -writable-system  &
}

_aosp_source() {
  _get_aosp_target
  source build/envsetup.sh
  lunch $AOSP_LUNCH
}

_aosp_makems() {
  _get_aosp_target
  make -f ~/bin/aosp_media_server.mk TARGET=$AOSP_TARGET $@
}

_aosp_makeall() {
  _get_aosp_target
  echo $AOSP_LUNCH
  source build/envsetup.sh && lunch $AOSP_LUNCH && time make all -j8
}

_aosp_get_wm_size() {
  $ADB shell dumpsys SurfaceFlinger
  $ADB shell wm size

  echo " "
  echo "getprop sys.display-size"
  $ADB shell getprop sys.display-size
}

_aosp_set_wm_size() {
  #only twice size of physical ?!
  $ADB shell wm size 3840x2160

  #fore youtube app driving on 4k ?!
# $ADB shell setprop sys.display-size 3840x2160

  _aosp_get_wm_size
}

_aosp_restore_x86() {
  APK_PATH="/home/${WHOAMI}/workspace/apk"
  MICROG_PATH="$APK_PATH/microg"
  $ADB install "$MICROG_PATH/com.google.android.gms-9258259.apk"
  $ADB install "$MICROG_PATH/com.google.android.gsf-8.apk"
  $ADB install "$MICROG_PATH/com.android.vending-16.apk"
  #$ADB install "$MICROG_PATH/org.microg.gms.droidguard-4.apk"
  $ADB install "$MICROG_PATH/UnifiedNlp.apk"
  $ADB install "$APK_PATH/com.google.android.youtube.tv_2.03.04-20304360_minAPI21(x86)(nodpi)_apkmirror.com.apk"
  _aosp_set_wm_size
}

_aosp_restore() {
  APK_PATH="/home/${WHOAMI}/workspace/apk"
  $ADB install "$APK_PATH/com.google.android.youtube.tv_2.02.08-20208320_minAPI21(armeabi-v7a)(nodpi)_apkmirror.com.apk"
  $ADB install "$APK_PATH/VLC for Android_v3.0.13_apkpure.com.apk"
  $ADB install "$APK_PATH/ALiMediaPlayer__v1.0_20180521.apk"
  $ADB install "$APK_PATH/iqiyi_tv_7.11.apk"
  $ADB install "$APK_PATH/com.primatelabs.geekbench_3.4.1-1047_minAPI14(arm64-v8a,armeabi-v7a,mips,x86,x86_64)(nodpi).apk"
  $ADB install "$APK_PATH/cpu-z-1-26.apk"
  $ADB install "$APK_PATH/com.androidfung.drminfo_1.0.9.170318-45_minAPI18(nodpi)_apkmirror.com.apk"
  $ADB install "$APK_PATH/MediaPlayerDemo.0.7.5.apk"
  $ADB install "$APK_PATH/QTStreamPlayer__v1.1.0_20180402.apk"
}

_aosp_install() {
  $ADB install $@
}

_copy_apk() {
  cp /home/${WHOAMI}/workspace/ExoPlayer/demos/main/buildout/outputs/apk/noExtensions/debug/demo-noExtensions-debug.apk /opt/workspace/apk/
}

_aliexo_copy() {
  sudo cp /opt/workspace/ExoPlayer-ALi/demos/main/buildout/outputs/apk/noExtensions/debug/demo-noExtensions-debug.apk /opt/netsync_v1.3.3/web/demo.apk
}

_aliexo_install() {
# cp /home/${WHOAMI}/workspace/ExoPlayer/demos/main/buildout/outputs/apk/noExtensions/debug/demo-noExtensions-debug.apk /opt/workspace/apk/
  $ADB uninstall com.google.android.exoplayer2.demo 2> /dev/null
  $ADB install /opt/workspace/ExoPlayer-ALi/demos/main/buildout/outputs/apk/noExtensions/debug/demo-noExtensions-debug.apk
  #$ADB install /opt/workspace/ExoPlayer-ALi.0827/demos/main/buildout/outputs/apk/noExtensions/debug/demo-noExtensions-debug.apk
  #$ADB install /opt/workspace/ExoPlayer/demos/main/buildout/outputs/apk/noExtensions/debug/demo-noExtensions-debug.apk
  #$ADB install /opt/workspace/ExoPlayer-ALi.0823/demos/main/buildout/outputs/apk/noExtensions/debug/demo-noExtensions-debug.apk
  echo YO
}

_otgdemo_install() {
# cp /home/${WHOAMI}/workspace/ExoPlayer/demos/main/buildout/outputs/apk/noExtensions/debug/demo-noExtensions-debug.apk /opt/workspace/apk/
  $ADB uninstall com.developerhaoz.androidotgdemo 2> /dev/null
  $ADB install /opt/workspace/AndroidOtgDemo/app/build/outputs/apk/app-debug.apk
}
_exo_apk_install() {
  #adb shell pm list packages
  $ADB uninstall com.google.android.exoplayer2.demo 2> /dev/null
  $ADB install /opt/workspace/ExoPlayer/demos/main/buildout/outputs/apk/noExtensions/debug/demo-noExtensions-debug.apk
}

_aosp_hot_reboot() {
  $ADB shell setprop ctl.restart zygote

}

_aosp_soft_reboot() {
  $ADB shell setprop persist.sys.safemode 1
  _aosp_hot_reboot
}

_aosp_shutdown() {
  $ADB shell reboot -p
}

_aosp_enter_wifi_pass() {
  $ADB shell input text 'opoa5aj4qwer'
  $ADB shell input keyevent 66
}

_aosp_enter_hls() {
  $ADB shell input text 'http://deb.netsync.tv/vod/test/efd3521f/5f1f053b/6846_fhd.m3u8?s=d1brAQDhB6kOwZYzhnfhwqclaFWp5BxrR5e4DAewHPp229sJnzS6rLAImNIevNACtP2xBn1PEXheON-sshx0vQK-wdDR8us6juYEYCROO422pNEVT8n22bjSxMxyR.2YWkvtBMQzfUA_'
  $ADB shell input keyevent 66
}

_make_traverse_condition2() {
  f="${3}"
  if [ "${f}" = "${1}/." ]; then
    return
  elif [ "${f}" = "${1}/.." ]; then
    return
  else
    #index dir
    if  [[ -d "${f}" ]] ; then
      if _make_is_target_dir "${f}" "${1}" "${2}" && [ "${_index_dir}" = "1" ]; then
        echo "found dir ${f}"; 
      else 
        _make_traverse ${f} ${2}; 
      fi
    fi

    #index file
    if [[ -f "${f}" && "${_index_file}" = "1" ]]; then
      if _make_is_target_file "${f}" "${1}" "${2}"; then 
        echo "found file ${f}"; 
      fi
    fi
  fi
}

_aosp_helper_edit() {
  sudo gvim $AOSP_HELPER_PATH
}

_aosp_dpi_240() {
  $ADB shell wm density 240
}

_poplar_usb2_host() {
  $ADB shell echo host > /sys/kernel/debug/hisi_inno_phy/role
}

_poplar_usb2_otg() {
  $ADB shell echo otg > /sys/kernel/debug/hisi_inno_phy/role
}

_poplar_burn() {
  sudo $FASTBOOT flash mmcsda2 boot.img
  sudo $FASTBOOT flash mmcsda3 system.img
  sudo $FASTBOOT flash mmcsda5 vendor.img
  sudo $FASTBOOT flash mmcsda6 cache.img
  sudo $FASTBOOT flash mmcsda7 userdata.img
}

_poplar_burn_boot() {
  sudo $FASTBOOT flash mmcsda2 boot.img
}

_poplar_kernel_copy() {
  POPLAR_PREBUILT_KERNEL=../aosp_8.1_poplar/device/linaro/poplar-kernel
  cp ./arch/arm64/boot/Image ${POPLAR_PREBUILT_KERNEL}/Image
  cp ./arch/arm64/boot/dts/hisilicon/hi3798cv200-poplar.dtb ${POPLAR_PREBUILT_KERNEL}/hi3798cv200-poplar.dtb
}

_poplar_kernel_make() {
  CROSS_64=/opt/toolchain/gcc-linaro-7.1.1-2017.08-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-
  #make ARCH=arm64 poplar_defconfig
  #make ARCH=arm64 menuconfig
  make ARCH=arm64 CROSS_COMPILE=${CROSS_64} -j8
  _poplar_kernel_copy
}

_poplar_push_blobs() {
  #Graphics
  $ADB push libGLES_mali.so /system/vendor/lib/egl/libGLES_mali.so
  $ADB push hwcomposer.poplar.so /system/vendor/lib/hw/hwcomposer.poplar.so
  $ADB push libhi_gfx2d.so /system/vendor/lib/libhi_gfx2d.so
  $ADB push liboverlay.so /system/vendor/lib/liboverlay.so
  $ADB push gralloc.poplar.so /system/vendor/lib/hw/gralloc.poplar.so
  $ADB push libion_ext.so /system/vendor/lib/libion_ext.so

  #Device
  $ADB push libhi_common.so /system/vendor/lib/libhi_common.so
  $ADB push libhi_msp.so /system/vendor/lib/libhi_msp.so
  $ADB push libhi_vfmw.so /system/vendor/lib/libhi_vfmw.so
  $ADB push libOMX_Core.so /system/vendor/lib/libOMX_Core.so
  $ADB push libOMX.hisi.video.decoder.so /system/vendor/lib/libOMX.hisi.video.decoder.so
  $ADB push libstagefrighthw.so /system/vendor/lib/libstagefrighthw.so
  $ADB push libhiavplayer.so /system/vendor/lib/libhiavplayer.so
  $ADB push libhiavplayer_adp.so /system/vendor/lib/libhiavplayer_adp.so
  $ADB push libhiavplayerservice.so /system/vendor/lib/libhiavplayerservice.so
  $ADB push hiavplayer /system/vendor/bin/hiavplayer
  
  #MD5 Graphics
  $ADB shell md5sum /system/vendor/lib/egl/libGLES_mali.so
  $ADB shell md5sum /system/vendor/lib/hw/hwcomposer.poplar.so
  $ADB shell md5sum /system/vendor/lib/libhi_gfx2d.so
  $ADB shell md5sum /system/vendor/lib/liboverlay.so
  $ADB shell md5sum /system/vendor/lib/hw/gralloc.poplar.so
  $ADB shell md5sum /system/vendor/lib/libion_ext.so

  #MMD5 Device
  $ADB shell md5sum /system/vendor/lib/libhi_common.so
  $ADB shell md5sum /system/vendor/lib/libhi_msp.so
  $ADB shell md5sum /system/vendor/lib/libhi_vfmw.so
  $ADB shell md5sum /system/vendor/lib/libOMX_Core.so
  $ADB shell md5sum /system/vendor/lib/libOMX.hisi.video.decoder.so
  $ADB shell md5sum /system/vendor/lib/libstagefrighthw.so
  $ADB shell md5sum /system/vendor/lib/libhiavplayer.so
  $ADB shell md5sum /system/vendor/lib/libhiavplayer_adp.so
  $ADB shell md5sum /system/vendor/lib/libhiavplayerservice.so
  $ADB shell md5sum /system/vendor/bin/hiavplayer
}

_alias() {
  export PATH=$DEBIAN_RCS_BIN_PATH:$PATH
  alias aosphelperedit="$AOSP_HELPER_PATH _aosp_helper_edit"
  alias aospsource="$AOSP_HELPER_PATH _aosp_source"
  alias aospalias="source $AOSP_HELPER_PATH _alias"
  alias aospemulator="source $AOSP_HELPER_PATH _aosp_emulator"
  alias push="$AOSP_HELPER_PATH adb_push"
  alias pull="$AOSP_HELPER_PATH adb_pull"
  alias adbinstall="$AOSP_HELPER_PATH adb_install"
  alias connect="$AOSP_HELPER_PATH adb_connect"
  alias disconnect="$AOSP_HELPER_PATH adb_disconnect"
  alias shell="$AOSP_HELPER_PATH adb_shell"
  alias logcat="$AOSP_HELPER_PATH adb_logcat"
  alias logcatexo="$AOSP_HELPER_PATH adb_logcat_exo"
  alias logcatavpath="$AOSP_HELPER_PATH adb_logcat_avpath"
  alias logcatali="$AOSP_HELPER_PATH adb_logcat_ali"
  alias makems="$AOSP_HELPER_PATH _aosp_makems"
  alias aospmakeall="$AOSP_HELPER_PATH _aosp_makeall"
  alias repologforall="$AOSP_HELPER_PATH repo_log_forall"
  alias repocheckoutmaster="$AOSP_HELPER_PATH repo_checkout_master_forall"
  alias repocheckout180720="$AOSP_HELPER_PATH repo_checkout_before_180720"
  alias repocheckout180627="$AOSP_HELPER_PATH repo_checkout_before_180627"
  alias repocheckout180508="$AOSP_HELPER_PATH repo_checkout_before_180508"
  
  alias aospgetwmsize="$AOSP_HELPER_PATH _aosp_get_wm_size"
  alias aospsetwmsize="$AOSP_HELPER_PATH _aosp_set_wm_size"
  alias aosprestorex86="$AOSP_HELPER_PATH _aosp_restore_x86"
  alias aosprestore="$AOSP_HELPER_PATH _aosp_restore"
  alias aospinstall="$AOSP_HELPER_PATH _aosp_install"
  alias aosphotreboot="$AOSP_HELPER_PATH _aosp_hot_reboot"
  alias aospsoftreboot="$AOSP_HELPER_PATH _aosp_soft_reboot"
  alias aospshutdown="$AOSP_HELPER_PATH _aosp_shutdown"
  
  alias poplarusbhost="$AOSP_HELPER_PATH _poplar_usb2_host"
  alias poplarusbotg="$AOSP_HELPER_PATH _poplar_usb2_otg"
  alias poplarburn="$AOSP_HELPER_PATH _poplar_burn"
  alias poplarburnboot="$AOSP_HELPER_PATH _poplar_burn_boot"
  alias poplarkernelcopy="$AOSP_HELPER_PATH _poplar_kernel_copy"
  alias poplarkernelmake="$AOSP_HELPER_PATH _poplar_kernel_make"
  alias poplarpushblobs="$AOSP_HELPER_PATH _poplar_push_blobs"
  
  alias copyapk="$AOSP_HELPER_PATH _copy_apk"
  alias aliexoinstall="$AOSP_HELPER_PATH _aliexo_install"
  alias aliexocopy="$AOSP_HELPER_PATH _aliexo_copy"
  alias otgdemoinstall="$AOSP_HELPER_PATH _otgdemo_install"
  alias enterwifipass="$AOSP_HELPER_PATH _aosp_enter_wifi_pass"
  alias enterhls="$AOSP_HELPER_PATH _aosp_enter_hls"
  alias dpi240="$AOSP_HELPER_PATH _aosp_dpi_240"
}

$@

