.PHONEY: all

c:
	@cmake -E remove_directory .zig-cache
	@cmake -E remove_directory zig-out
	@cmake -E remove_directory src/arch/x86/.zig-cache
	@cmake -E remove_directory src/arch/aarch64/.zig-cache

b86:
	@zig build -DprojectTarget=x86

r86: b86
	@qemu-system-x86_64 -kernel zig-out/bin/kernel.elf -debugcon stdio -vga virtio -m 4G -machine q35,accel=kvm:whpx:tcg -no-reboot -no-shutdown

b4b:
	@zig build -DprojectTarget=rpi4b

r4b: b4b
	@qemu-system-aarch64 -M raspi4b -serial stdio -kernel zig-out/bin/kernel8.img