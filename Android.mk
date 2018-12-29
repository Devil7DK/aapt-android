#
# Copyright (C) 2014 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# This tool is prebuilt if we're doing an app-only build.
ifeq ($(TARGET_BUILD_APPS)$(filter true,$(TARGET_BUILD_PDK)),)

# ==========================================================
# Setup some common variables for the different build
# targets here.
# ==========================================================
LOCAL_PATH:= $(call my-dir)

aaptMain := Main.cpp
aaptSources := \
    AaptAssets.cpp \
    AaptConfig.cpp \
    AaptUtil.cpp \
    AaptXml.cpp \
    ApkBuilder.cpp \
    Command.cpp \
    CrunchCache.cpp \
    FileFinder.cpp \
    Images.cpp \
    Package.cpp \
    pseudolocalize.cpp \
    Resource.cpp \
    ResourceFilter.cpp \
    ResourceIdCache.cpp \
    ResourceTable.cpp \
    SourcePos.cpp \
    StringPool.cpp \
    WorkQueue.cpp \
    XMLNode.cpp \
    ZipEntry.cpp \
    ZipFile.cpp

aaptStaticLibs := \
    libandroidfw_static \
    libpng \
    libutils \
    liblog \
    libcutils \
    libexpat \
    libziparchive \
    libz \
    libbase

aaptCFlags := -DAAPT_VERSION=\"$(BUILD_NUMBER_FROM_FILE)\"
aaptCFlags += -Wall -Werror

aaptLdLibs_linux := -ldl -lz


# ==========================================================
# Build the static library: libaapt
# ==========================================================
include $(CLEAR_VARS)

LOCAL_MODULE := libaapt
LOCAL_CFLAGS := -Wno-format-y2k -DSTATIC_ANDROIDFW_FOR_TOOLS $(aaptCFlags)
LOCAL_CPPFLAGS := $(aaptCppFlags)
LOCAL_SRC_FILES := $(aaptSources)
LOCAL_C_INCLUDES := $(LOCAL_PATH)/include
LOCAL_STATIC_LIBRARIES := $(aaptStaticLibs)

include $(BUILD_STATIC_LIBRARY)

# ==========================================================
# Build the executable: aapt
# ==========================================================
include $(CLEAR_VARS)

LOCAL_MODULE := aapt
LOCAL_CFLAGS := $(aaptCFlags)
LOCAL_CPPFLAGS := $(aaptCppFlags)
LOCAL_LDLIBS := $(aaptLdLibs)
LOCAL_SRC_FILES := $(aaptMain)
LOCAL_C_INCLUDES := $(LOCAL_PATH)/include
LOCAL_STATIC_LIBRARIES := libaapt $(aaptStaticLibs)
LOCAL_FORCE_STATIC_EXECUTABLE := true

include $(BUILD_EXECUTABLE)

# ==========================================================
# Build the executable: apkname
# ==========================================================
include $(CLEAR_VARS)

LOCAL_MODULE := apkname
LOCAL_CFLAGS := $(aaptCFlags)
LOCAL_CPPFLAGS := $(aaptCppFlags)
LOCAL_LDLIBS := $(aaptLdLibs)
LOCAL_SRC_FILES := ApkName.cpp
LOCAL_C_INCLUDES := $(LOCAL_PATH)/include
LOCAL_STATIC_LIBRARIES := libaapt $(aaptStaticLibs)
LOCAL_FORCE_STATIC_EXECUTABLE := true

include $(BUILD_EXECUTABLE)

# Include subdirectory makefiles
# ============================================================

# If we're building with ONE_SHOT_MAKEFILE (mm, mmm), then what the framework
# team really wants is to build the stuff defined by this makefile.
ifeq (,$(ONE_SHOT_MAKEFILE))
include $(call first-makefiles-under,$(LOCAL_PATH))
endif

endif # No TARGET_BUILD_APPS or TARGET_BUILD_PDK
