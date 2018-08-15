LOCAL_PATH:= $(call my-dir)

common_SRC_FILES := \
	lib/xmlparse.c \
	lib/xmlrole.c \
	lib/xmltok.c

common_CFLAGS := \
    -Wall \
    -Wmissing-prototypes -Wstrict-prototypes \
    -Wno-unused-parameter -Wno-missing-field-initializers \
    -fexceptions \
    -DHAVE_EXPAT_CONFIG_H

common_C_INCLUDES += \
	$(LOCAL_PATH)/lib

# Device static library
include $(CLEAR_VARS)

ifeq ($(TARGET_ARCH),arm)
    LOCAL_SDK_VERSION := 8
else
    LOCAL_SDK_VERSION := 9
endif

LOCAL_SRC_FILES := $(common_SRC_FILES)
LOCAL_CFLAGS += $(common_CFLAGS)
LOCAL_C_INCLUDES += $(common_C_INCLUDES)

LOCAL_MODULE:= libexpat
LOCAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_PATH)/Android.mk
LOCAL_MODULE_TAGS := optional
LOCAL_EXPORT_C_INCLUDE_DIRS := $(LOCAL_PATH)/lib

include $(BUILD_STATIC_LIBRARY)

# Device shared library
include $(CLEAR_VARS)

ifeq ($(TARGET_ARCH),arm)
    LOCAL_SDK_VERSION := 8
else
    LOCAL_SDK_VERSION := 9
endif

LOCAL_SYSTEM_SHARED_LIBRARIES := libc
LOCAL_SRC_FILES := $(common_SRC_FILES)
LOCAL_CFLAGS += $(common_CFLAGS)
LOCAL_C_INCLUDES += $(common_C_INCLUDES)

LOCAL_MODULE:= libexpat
LOCAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_PATH)/Android.mk
LOCAL_MODULE_TAGS := optional
LOCAL_EXPORT_C_INCLUDE_DIRS := $(LOCAL_PATH)/lib

include $(BUILD_SHARED_LIBRARY)
