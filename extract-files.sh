#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017-2020 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

DEVICE=marble
VENDOR=xiaomi

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}/../../.."

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

KANG=
SECTION=

while [ "${#}" -gt 0 ]; do
    case "${1}" in
    -n | --no-cleanup)
        CLEAN_VENDOR=false
        ;;
    -k | --kang)
        KANG="--kang"
        ;;
    -s | --section)
        SECTION="${2}"
        shift
        CLEAN_VENDOR=false
        ;;
    *)
        SRC="${1}"
        ;;
    esac
    shift
done

if [ -z "${SRC}" ]; then
    SRC="adb"
fi

function blob_fixup() {
    case "${1}" in
    vendor/etc/camera/marble*_motiontuning.xml)
        sed -i 's/xml=version/xml\ version/g' "${2}"
        ;;
    vendor/etc/camera/pureView_parameter.xml)
        sed -i "s/=\([0-9]\+\)>/=\"\1\">/g" "${2}"
        ;;
    vendor/bin/init.qti.media.sh)
        sed -i "s#build_codename -le \"13\"#build_codename -le \"14\"#" "${2}"
        ;;
    vendor/bin/sensors.qti)
        "${PATCHELF}" --replace-needed "libprotobuf-cpp-lite-3.9.1.so" "libprotobuf-cpp-full-3.9.1.so" "${2}"
        ;;
    vendor/bin/sensors-qesdk)
        "${PATCHELF}" --replace-needed "libprotobuf-cpp-lite-3.9.1.so" "libprotobuf-cpp-full-3.9.1.so" "${2}"
        ;;
    vendor/lib64/libqshcamera.so)
        "${PATCHELF}" --replace-needed "libprotobuf-cpp-lite-3.9.1.so" "libprotobuf-cpp-full-3.9.1.so" "${2}"
        ;;
    vendor/lib64/libsnsdiaglog.so)
        "${PATCHELF}" --replace-needed "libprotobuf-cpp-lite-3.9.1.so" "libprotobuf-cpp-full-3.9.1.so" "${2}"
        ;;
    vendor/lib64/sensors.touch.detect.so)
        "${PATCHELF}" --replace-needed "libprotobuf-cpp-lite-3.9.1.so" "libprotobuf-cpp-full-3.9.1.so" "${2}"
        ;;
    vendor/lib64/sensors.ssc.so)
        "${PATCHELF}" --replace-needed "libprotobuf-cpp-lite-3.9.1.so" "libprotobuf-cpp-full-3.9.1.so" "${2}"
        ;;
    vendor/lib64/libssc.so)
        "${PATCHELF}" --replace-needed "libprotobuf-cpp-lite-3.9.1.so" "libprotobuf-cpp-full-3.9.1.so" "${2}"
        ;;
    vendor/lib64/libsensorcal.so)
        "${PATCHELF}" --replace-needed "libprotobuf-cpp-lite-3.9.1.so" "libprotobuf-cpp-full-3.9.1.so" "${2}"
        ;;
    vendor/lib64/mediadrm/libwvdrmengine.so)
        "${PATCHELF}" --replace-needed "libprotobuf-cpp-lite-3.9.1.so" "libprotobuf-cpp-full-3.9.1.so" "${2}"
        ;;
    vendor/lib64/libsnsapi.so)
        "${PATCHELF}" --replace-needed "libprotobuf-cpp-lite-3.9.1.so" "libprotobuf-cpp-full-3.9.1.so" "${2}"
        ;;
    vendor/lib64/libssccalapi@2.0.so)
        "${PATCHELF}" --replace-needed "libprotobuf-cpp-lite-3.9.1.so" "libprotobuf-cpp-full-3.9.1.so" "${2}"
        ;;
    vendor/lib64/libgnss.so)
        "${PATCHELF}" --replace-needed "libprotobuf-cpp-lite-3.9.1.so" "libprotobuf-cpp-full-3.9.1.so" "${2}"
        ;;
    vendor/lib64/libwvhidl.so)
        "${PATCHELF}" --replace-needed "libprotobuf-cpp-lite-3.9.1.so" "libprotobuf-cpp-full-3.9.1.so" "${2}"
        ;;
    vendor/lib/libsnsdiaglog.so)
        "${PATCHELF}" --replace-needed "libprotobuf-cpp-lite-3.9.1.so" "libprotobuf-cpp-full-3.9.1.so" "${2}"
        ;;
    vendor/lib/sensors.touch.detect.so)
        "${PATCHELF}" --replace-needed "libprotobuf-cpp-lite-3.9.1.so" "libprotobuf-cpp-full-3.9.1.so" "${2}"
        ;;
    vendor/lib/sensors.ssc.so)
        "${PATCHELF}" --replace-needed "libprotobuf-cpp-lite-3.9.1.so" "libprotobuf-cpp-full-3.9.1.so" "${2}"
        ;;
    vendor/lib/libssc.so)
        "${PATCHELF}" --replace-needed "libprotobuf-cpp-lite-3.9.1.so" "libprotobuf-cpp-full-3.9.1.so" "${2}"
        ;;
    vendor/lib/libsensorcal.so)
        "${PATCHELF}" --replace-needed "libprotobuf-cpp-lite-3.9.1.so" "libprotobuf-cpp-full-3.9.1.so" "${2}"
        ;;
    vendor/lib/mediadrm/libwvdrmengine.so)
        "${PATCHELF}" --replace-needed "libprotobuf-cpp-lite-3.9.1.so" "libprotobuf-cpp-full-3.9.1.so" "${2}"
        ;;
    vendor/lib/libsnsapi.so)
        "${PATCHELF}" --replace-needed "libprotobuf-cpp-lite-3.9.1.so" "libprotobuf-cpp-full-3.9.1.so" "${2}"
        ;;
    vendor/lib/libssccalapi@2.0.so)
        "${PATCHELF}" --replace-needed "libprotobuf-cpp-lite-3.9.1.so" "libprotobuf-cpp-full-3.9.1.so" "${2}"
        ;;
    vendor/lib/libgnss.so)
        "${PATCHELF}" --replace-needed "libprotobuf-cpp-lite-3.9.1.so" "libprotobuf-cpp-full-3.9.1.so" "${2}"
        ;;
    vendor/bin/hw/android.hardware.security.keymint-service-qti)
        "${PATCHELF}" --replace-needed "android.hardware.security.keymint-V1-ndk_platform.so" "android.hardware.security.keymint-V1-ndk.so" "${2}"
        "${PATCHELF}" --replace-needed "android.hardware.security.secureclock-V1-ndk_platform.so" "android.hardware.security.secureclock-V1-ndk.so" "${2}"
        "${PATCHELF}" --replace-needed "android.hardware.security.sharedsecret-V1-ndk_platform.so" "android.hardware.security.sharedsecret-V1-ndk.so" "${2}"
        "${PATCHELF}" --add-needed "android.hardware.security.rkp-V3-ndk.so" "${2}"
        ;;
    vendor/lib64/libqtikeymint.so)
        "${PATCHELF}" --replace-needed "android.hardware.security.keymint-V1-ndk_platform.so" "android.hardware.security.keymint-V1-ndk.so" "${2}"
        "${PATCHELF}" --replace-needed "android.hardware.security.secureclock-V1-ndk_platform.so" "android.hardware.security.secureclock-V1-ndk.so" "${2}"
        "${PATCHELF}" --replace-needed "android.hardware.security.sharedsecret-V1-ndk_platform.so" "android.hardware.security.sharedsecret-V1-ndk.so" "${2}"
        "${PATCHELF}" --add-needed "android.hardware.security.rkp-V3-ndk.so" "${2}"
        ;;
    vendor/lib64/libcamximageformatutils.so)
        "${PATCHELF}" --replace-needed "vendor.qti.hardware.display.config-V2-ndk_platform.so" "vendor.qti.hardware.display.config-V2-ndk.so" "${2}"
        ;;
    vendor/lib64/vendor.qti.hardware.qxr-V1-ndk_platform.so)
        "${PATCHELF}" --replace-needed "android.hardware.common-V2-ndk_platform.so" "android.hardware.common-V2-ndk.so" "${2}"
        ;;
    vendor/lib64/libgarden.so)
        "${PATCHELF}" --replace-needed "android.hardware.gnss-V1-ndk_platform.so" "android.hardware.gnss-V1-ndk.so" "${2}"
        ;;
    vendor/lib64/libgarden_haltests_e2e.so)
        "${PATCHELF}" --replace-needed "android.hardware.gnss-V1-ndk_platform.so" "android.hardware.gnss-V1-ndk.so" "${2}"
        ;;
    vendor/lib/hw/android.hardware.gnss-aidl-impl-qti.so)
        "${PATCHELF}" --replace-needed "android.hardware.gnss-V1-ndk_platform.so" "android.hardware.gnss-V1-ndk.so" "${2}"
        ;;
    vendor/lib64/hw/android.hardware.gnss-aidl-impl-qti.so)
        "${PATCHELF}" --replace-needed "android.hardware.gnss-V1-ndk_platform.so" "android.hardware.gnss-V1-ndk.so" "${2}"
        ;;
    vendor/bin/hw/android.hardware.gnss-aidl-service-qti)
        "${PATCHELF}" --replace-needed "android.hardware.gnss-V1-ndk_platform.so" "android.hardware.gnss-V1-ndk.so" "${2}"
        ;;
    vendor/lib64/libdlbdsservice.so | vendor/lib64/soundfx/libhwdap.so)
        "${PATCHELF}" --replace-needed "libstagefright_foundation.so" "libstagefright_foundation-v33.so" "${2}"
        ;;
    vendor/lib/libcodec2_hidl@1.0.stock.so)
        "${PATCHELF}" --set-soname "libcodec2_hidl@1.0.stock.so" "${2}"
        "${PATCHELF}" --replace-needed "libcodec2_vndk.so" "libcodec2_vndk.stock.so" "${2}"
        ;;
    vendor/lib/libcodec2_vndk.stock.so)
        "${PATCHELF}" --set-soname "libcodec2_vndk.stock.so" "${2}"
        ;;
    vendor/bin/hw/android.hardware.security.keymint-service-qti | vendor/lib64/libqtikeymint.so)
            "${PATCHELF}" --add-needed "android.hardware.security.rkp-V1-ndk_platform.so" "${2}"
        ;;
    vendor/lib64/libcom.xiaomi.mawutils.so | vendor/lib64/libmis_plugin_morpho.so | vendor/lib64/camera/components/com.qti.node.dewarp.so | vendor/lib64/camera/components/com.mi.node.skinbeautifier.so | vendor/lib64/camera/components/com.mi.node.mawsaliency.so | vendor/lib64/camera/components/com.mi.node.aiasd.so | vendor/lib64/camera/components/com.xiaomi.node.misv3.so | vendor/lib64/camera/components/com.xiaomi.node.gme.so | vendor/lib64/camera/components/com.mi.node.eisv2.so | vendor/lib64/camera/components/com.mi.node.test_rearvideo.so | vendor/lib64/camera/components/com.mi.node.facealign.so | vendor/lib64/camera/components/com.mi.node.tsskinbeautifier.so | vendor/lib64/camera/components/com.mi.node.videobokeh.so | vendor/lib64/camera/components/com.xiaomi.node.misv2.so | vendor/lib64/camera/plugins/com.xiaomi.plugin.skinbeautifier.so | vendor/lib64/camera/plugins/com.xiaomi.plugin.tsskinbeautifier.so | vendor/lib64/libqvrcamera_client.qti.so | vendor/lib64/libmialgoengine.so | vendor/lib64/libmis_plugin_vidhance.so | vendor/lib64/libcom.xiaomi.grallocutils.so | vendor/lib64/libmis_plugin_his.so | vendor/lib64/hw/camera.xiaomi.so)
        "${PATCHELF}" --replace-needed "libui.so" "libui_camera.so" "${2}"
        ;;
        system/lib64/libcamera_mianode_jni.xiaomi.so|system/lib64/libcamera_algoup_jni.xiaomi.so|system/lib64/libmicampostproc_client.so)
        "${PATCHELF}" --replace-needed "libui.so" "libui_camera.so" "${2}"
        ;;
    vendor/lib/libcodec2_hidl@1.0.stock.so)
        "${PATCHELF}" --set-soname "libcodec2_hidl@1.0.stock.so" "${2}"
        "${PATCHELF}" --replace-needed "libcodec2_vndk.so" "libcodec2_vndk.stock.so" "${2}"
        ;;
    vendor/lib/libcodec2_vndk.stock.so)
        "${PATCHELF}" --set-soname "libcodec2_vndk.stock.so" "${2}"
        ;;
    esac
}

# Initialize the helper
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false "${CLEAN_VENDOR}"

extract "${MY_DIR}/proprietary-files.txt" "${SRC}" "${KANG}" --section "${SECTION}"

"${MY_DIR}/setup-makefiles.sh"
