# 2025-06: ACPI was witnessed killing cargo (Lenovo ThinkPad Gen12) on
# linux-6.8.12. this seemed to be due to a kernel proc called irq/9-acpi
# notably, cat /proc/interrupts seemed to be showing a high number of interrupts
# continually appearing on CPU#1 (not #0); irq9: which is described by
# /proc/interrupts as 'IR-IO-APIC    9-fasteoi   acpi'

# further, looking through /sys/firmware/acpi/interrupts, we see
# /sys/firmware/acpi/interrupts/gpe6E:   53155     STS enabled      masked
# where 53155 roughly tallies with the interrupt count seen for irq#9 in
# /proc/interrupts

# disabling the interrupt, as below, clearly solved the issue

# https://forum.manjaro.org/t/irq-9-acpi-is-killing-my-system/176107/13
# https://unix.stackexchange.com/questions/242013/disable-gpe-acpi-interrupts-on-boot

{ ... }: { boot.kernelParams = [ "acpi_mask_gpe=0x6E" ]; }
