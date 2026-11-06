# SPDX-License-Identifier: GPL-2.0

load("//build/kernel/kleaf:kernel.bzl", "kernel_build_config")
load("//vendor/amlogic/kernel:kernel_platform.bzl", "amlogic_kernel_platform")
load("//vendor/amlogic/gpu-modules/bifrost:defs.bzl", "mali_bifrost_module")
load("//vendor/amlogic/media-modules:defs.bzl", "media_modules_module")
load("//vendor/amlogic/devices/kleaf:modules.bzl",
    "COMMON_DRIVERS_MODULES",
    "GKI_MODULES_REMOVE",
    "TARGET_MODULES",
    "MODULES_OUT_REMOVE",
    "SYSTEM_DLKM_MODULES"
)

def amlogic_kernel_device(target, build_config, target_dtb = [], target_dtbo = ["android_overlay_dt.dtbo"], kernel_modules = []):

    kernel_build = ":{}".format(target)
    mali_bifrost_module(name = "gpu_bifrost", kernel_build = kernel_build)

    media_modules_module(name = "media", kernel_build = kernel_build)

    amlogic_kernel_platform(
        name = target,
        dtb_outs = target_dtb + target_dtbo,
        module_outs = [m for m in TARGET_MODULES + COMMON_DRIVERS_MODULES + SYSTEM_DLKM_MODULES if m not in MODULES_OUT_REMOVE],
        gki_modules_remove = GKI_MODULES_REMOVE + SYSTEM_DLKM_MODULES,
        system_dlkm_modules_load = ["kernel/" + m for m in SYSTEM_DLKM_MODULES] + [""],
        build_config = ":{}_build_config".format(target),
        kmi_symbol_list = "//vendor/amlogic/kernel:android/abi_gki_aarch64_amlogic",
        kernel_modules = [
            ":gpu_bifrost",
            ":media",
        ] + kernel_modules,
    )

    kernel_build_config(
        name = "{}_build_config".format(target),
        srcs = [
            # do not sort
            "//vendor/amlogic/kernel:set_kernel_dir_build_config",
            "//vendor/amlogic/kernel:build.config.gki.aarch64",
            "//vendor/amlogic/devices/configs:{}".format(build_config),
        ],
    )
