{ ... }:

# from:
# https://android.googlesource.com/kernel/mediatek/+/android-4.4.4_r3/drivers/usb/storage/Kconfig
#
#	tristate "Realtek Card Reader support"
# additional code to support the power-saving function for Realtek RTS51xx USB
# card readers.

{
  boot.initrd.availableKernelModules = [ "ums_realtek" ];
}
