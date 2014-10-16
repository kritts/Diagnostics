LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE    := process_image
LOCAL_SRC_FILES := find_fiducals.cpp


all:
	@echo $(LOCAL_PATH)


include $(BUILD_SHARED_LIBRARY)