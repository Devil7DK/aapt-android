# Copyright (C) 2010 The Android Open Source Project
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

LOCAL_PATH:= $(call my-dir)

# libandroidfw is partially built for the host (used by obbtool, aapt, and others)
# These files are common to host and target builds.

Sources := \
    Asset.cpp \
    AssetDir.cpp \
    AssetManager.cpp \
    LocaleData.cpp \
    misc.cpp \
    ObbFile.cpp \
    ResourceTypes.cpp \
    StreamingZipInflater.cpp \
    TypeWrappers.cpp \
    ZipFileRO.cpp \
    ZipUtils.cpp

# To use with aapt for android
# =====================================================

include $(CLEAR_VARS)

LOCAL_MODULE:= libandroidfw_static
LOCAL_SRC_FILES:= $(Sources)
LOCAL_C_INCLUDES := \
    system/core/include
LOCAL_STATIC_LIBRARIES := libziparchive libbase
LOCAL_SHARED_LIBRARIES := \
    libbinder \
    liblog \
    libcutils \
    libgui \
    libutils \
    libz

LOCAL_CFLAGS += -Wall -Werror -Wunused -Wunreachable-code

include $(BUILD_STATIC_LIBRARY)
