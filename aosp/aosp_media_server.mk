###################################################################
#
#       AOSP media server & media extractor build scripts
#      
#   by Guan-Da Huang 2018-03-22 
###################################################################
 
.DEFAULT_GOAL := all
all: ms

.PHONY: printvar
printvar:
ifeq ($(TARGET),generic_x86_64)
	@echo X1
else ifeq ($(TARGET),generic)
	@echo X2
else ifeq ($(TARGET),scorpion_windy)
	@echo X3
else ifeq ($(TARGET),poplar)
	@echo X4
endif
ifeq ($(TARGET),$(filter $(TARGET),generic_x86_64 poplar))
	@echo it was
endif


#-----------------------------------------------------------  
#                       mediaserver linked diagram
#-----------------------------------------------------------
#                                libmediaplayerservice.so
# mediaserver ->                 android.hardware.media.omx@1.0
#
#
# libmediaplayerservice.so ->    libstagefright.so
#                                libstagefright_foundation.so
#                                libstagefright_httplive.so
#                                libstagefright_mpegdash.so
#                                libstagefright_omx.so
#                                libstagefright_nuplayer.so
#                                libstagefright_rtsp
#                                android.hardware.media.omx@1.0
#
# libmedia_jni.so          ->    libstagefright.so
#                                libstagefright_foundation.so
#
# libstagefright_httplive.so ->  libstagefright.so
#                                libstagefright_foundation.so
#                                
# libstagefright.so ->           libstagefright_omx.so
#                                libstagefright_aacenc.so
#                                libstagefright_matroska.so
#                                libstagefright_mpeg2ts.a
#                                libstagefright_foundation.so
#                                android.hardware.media.omx@1.0
#                                
# libstagefright_mpeg2ts.a  ->  ?
#
# libstagefright_nuplayer.so ->   N/A
#
# libstagefright_omx.so       ->  android.hardware.media.omx@1.0
#
# libmedia.so                 ->  android.hardware.media.omx@1.0
#
# android.hardware.media.omx@1.0 -> E:\aosp_extractor\hardware\interfaces\media\omx\1.0
#-----------------------------------------------------------

.PHONY: img
img:
	rm -f out/target/product/$(TARGET)/*.img*
	make -j8
 
###################################################################
#               mediaserver
###################################################################
FRAMEWORK_AV_MEDIA=frameworks/av/media
LIBSTAGEFRIGHT_NUPLAYER=$(FRAMEWORK_AV_MEDIA)/libmediaplayerservice/nuplayer
LIBSTAGEFRIGHT_MPEG2TS=$(FRAMEWORK_AV_MEDIA)/libstagefright/mpeg2ts
LIBSTAGEFRIGHT=$(FRAMEWORK_AV_MEDIA)/libstagefright
LIBSTAGEFRIGHT_HTTPLIVE=$(FRAMEWORK_AV_MEDIA)/libstagefright/httplive
LIBMEDIAPLAYERSERVICE=$(FRAMEWORK_AV_MEDIA)/libmediaplayerservice
MEDIASERVER=$(FRAMEWORK_AV_MEDIA)/mediaserver
LIBSTAGEFRIGHT_OMX=$(FRAMEWORK_AV_MEDIA)/libstagefright/omx
LIBMEDIA_JNI=frameworks/base/media/jni
LIBMEDIA=$(FRAMEWORK_AV_MEDIA)/libmedia
MEDIACODE=frameworks/av/services/mediacodec
MS_MODULES=mediacodec libmediacodecservice libmedia mediaserver libstagefright libstagefright libstagefright_httplive libstagefright_foundation libstagefright_nuplayer libstagefright_omx libstagefright_mpeg2ts libmediaplayerservice libmedia_jni "android.hardware.media.omx@1.0-service"
# AOSP 6.0.1 no mediacode
 
.PHONY: ms 
ms_binary_idx:
	~/bin/aosp_make.sh _make_index out 0 1 $(MS_MODULES) > $@

clean_ms_binary: ms_binary_idx
	rm -rf `cat ms_binary_idx`

ms: 
	#@~/bin/aosp_make.sh _make_mmm $(LIBSTAGEFRIGHT_OMX) $(LIBSTAGEFRIGHT_MPEG2TS) $(LIBSTAGEFRIGHT_NUPLAYER) $(LIBSTAGEFRIGHT) $(LIBMEDIA_JNI) $(LIBSTAGEFRIGHT_HTTPLIVE) $(LIBMEDIAPLAYERSERVICE) $(MEDIASERVER)
	#@~/bin/aosp_make.sh _make_mmm $(LIBMEDIA) $(LIBSTAGEFRIGHT_OMX) $(LIBSTAGEFRIGHT_MPEG2TS) $(LIBSTAGEFRIGHT_NUPLAYER) $(LIBSTAGEFRIGHT) $(LIBMEDIA_JNI) $(LIBSTAGEFRIGHT_HTTPLIVE) $(LIBMEDIAPLAYERSERVICE) $(MEDIASERVER) $(MEDIACODE)
	### only ACodec, MediaCodec
	@~/bin/aosp_make.sh _make_mmm $(LIBSTAGEFRIGHT) $(LIBMEDIA_JNI) $(LIBMEDIAPLAYERSERVICE) $(MEDIACODE)
 
###################################################################
#               remove mediaserver
###################################################################
.PHONY: ms_clean
ms_dir_idx:
	~/bin/aosp_make.sh _make_index out 1 1 $(MS_MODULES) > $@

ms_clean: ms_dir_idx
	rm -rf `cat ms_dir_idx`
 
###################################################################
#               install mediaserver
###################################################################
.PHONY: ms_restart
SRC_SYSTEM_LIB=out/target/product/$(TARGET)/system/lib
DST_SYSTEM_LIB=/system/lib

SRC_SYSTEM_LIB64=out/target/product/$(TARGET)/system/lib64
DST_SYSTEM_LIB64=/system/lib64
 
SRC_SYSTEM_BIN=out/target/product/$(TARGET)/system/bin
DST_SYSTEM_BIN=/system/bin
 
define restart_mediaserver
#	adb shell killall -9 media.extractor
#	adb shell killall -9 mediaserver
#	adb shell killall -9 media.codec
#	adb shell killall -9 mediadrmserver
#	adb shell killall -9 android.process.media
#	adb shell killall -9 "android.hardware.drm@1.0-service"
#	adb shell killall -9 system_server
#	~/bin/aosp_helper.sh _aosp_hot_reboot
endef

ms_restart:
	$(call restart_mediaserver) | true
 
 
.PHONY: ms_install
MS_SYSTEM_BIN_LIST=mediaserver mediaextractor
MS_SYSTEM_LIB_LIST=libmedia_jni.so \
					 libmediaplayerservice.so \
					 libmedia.so \
					 libstagefright_foundation.so \
					 libstagefright_httplive.so \
					 libstagefright_omx.so \
					 libstagefright.so
MS_SYSTEM_LIB64_LIST=libmedia_jni.so \
					 libmedia.so \
					 libstagefright_foundation.so \
					 libstagefright_httplive.so \
					 libstagefright_omx.so \
					 libstagefright.so
MS_VENDOR2_BIN_HW_LIST="android.hardware.media.omx@1.0-service"
MS_VENDOR2_LIB_LIST=libmediacodecservice.so

ms_install:
	~/bin/aosp_make.sh _make_install "out/target/product/$(TARGET)/system/bin" "/system/bin" "$(MS_SYSTEM_BIN_LIST)"
	~/bin/aosp_make.sh _make_install "out/target/product/$(TARGET)/system/lib" "/system/lib" "$(MS_SYSTEM_LIB_LIST)"
ifeq ($(TARGET),generic_x86_64)
	~/bin/aosp_make.sh _make_install "out/target/product/$(TARGET)/system/lib64" "/system/lib64" "$(MS_SYSTEM_LIB64_LIST)"
endif
ifneq ($(TARGET),generic)
	~/bin/aosp_make.sh _make_install "out/target/product/$(TARGET)/vendor/bin/hw" "/vendor/bin/hw" "$(MS_VENDOR2_BIN_HW_LIST)"
	~/bin/aosp_make.sh _make_install "out/target/product/$(TARGET)/vendor/lib" "/vendor/lib" "$(MS_VENDOR2_LIB_LIST)"
endif
	#restart new media server that we built
	$(call restart_mediaserver) | true

 
 
 
#-----------------------------------------------------------  
#                       mediaserver linked diagram
#-----------------------------------------------------------
#
# mediaextractor ->               libmediaextractorservice.so (same Android.mk)
#                                
# libmediaextractorservice.so ->  libstagefright.so
 
###################################################################
#               mediaextractor
###################################################################
FRAMEWORK_AV_SERVICES=frameworks/av/services
MEDIAEXTRACTOR=$(FRAMEWORK_AV_SERVICES)/mediaextractor
LIBFFMPEG_EXTRACTOR=vendor/ali/media/extractor
 
SRC_VENDOR_LIB=out/target/product/$(TARGET)/vendor/lib
DST_VENDOR_LIB=/vendor/lib

.PHONY:  
ex: ms
	@~/bin/aosp_make.sh _make_mmm $(LIBFFMPEG_EXTRACTOR) $(MEDIAEXTRACTOR)
 
###################################################################
#               remove mediaextractor
###################################################################
.PHONY: ex_clean
ex_clean: ms_clean
	rm -rf out/target/product/$(TARGET)/obj/SHARED_LIBRARIES/libmediaextractorservice_intermediates
	rm -rf out/target/product/$(TARGET)/obj/EXECUTABLES/mediaextractor_intermediates
	rm -rf out/target/product/$(TARGET)/obj/SHARED_LIBRARIES/libffmpeg_extractor_intermediates
 
 
###################################################################
#               retstart mediaextrator
###################################################################
.PHONY: ex_restart vimeokill
define restart_mediaextractor
	adb shell killall -9 media.extractor
	adb shell killall -9 mediaserver
	adb shell killall -9 media.codec
	adb shell killall -9 com.vimeo.android.videoapp
endef
ex_restart:
	$(call restart_mediaextractor) | true
 
vimeokill:
	adb shell killall -9 com.vimeo.android.videoapp
 
SRC_VENDOR_LIB=out/target/product/$(TARGET)/vendor/lib
DST_VENDOR_LIB=/vendor/lib
 
###################################################################
#               install mediaextrator
###################################################################
.PHONY: ex_install
EX_SYSTEM_LIB_LIST=libmediaextractorservice.so
EX_SYSTEM_BIN_LIST=mediaextractor
EX_VENDOR_LIB_LIST=libffmpeg_extractor.so
 
ex_install: ms_install
#delete
	$(foreach P,$(EX_SYSTEM_LIB_LIST),adb shell rm -rf $(DST_SYSTEM_LIB)/$P ;)
	$(foreach P,$(EX_VENDOR_LIB_LIST),adb shell rm -rf $(DST_VENDOR_LIB)/$P ;)
	$(foreach P,$(EX_SYSTEM_BIN_LIST),adb shell rm -rf $(DST_SYSTEM_BIN)/$P ;)
#push new one
	$(foreach P,$(EX_SYSTEM_LIB_LIST),adb push $(SRC_SYSTEM_LIB)/$P $(DST_SYSTEM_LIB)/ ;)
	$(foreach P,$(EX_VENDOR_LIB_LIST),adb push $(SRC_VENDOR_LIB)/$P $(DST_VENDOR_LIB)/ ;)
	$(foreach P,$(EX_SYSTEM_BIN_LIST),adb push $(SRC_SYSTEM_BIN)/$P $(DST_SYSTEM_BIN)/ ;)
#restart new media server that we built
	$(call restart_mediaextractor) | true

