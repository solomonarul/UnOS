const cpu = @import("cpu_data");

const InternalSetup = switch (cpu.arch) {
    .x86 => @import("../arch/x86/kernel/setup.zig"),
    .aarch64 => @import("../arch/aarch64/kernel/setup.zig"),
    else => null,
};

pub inline fn init() void {
    InternalSetup.init();
}
