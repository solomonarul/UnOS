const cpu = @import("cpu_data");
const std = @import("std");

const InternalSerial = switch (cpu.arch) {
    .x86 => @import("../arch/x86/kernel/serial.zig"),
    .aarch64 => @import("../arch/x86/kernel/serial.zig"),
    else => null,
};

fn writer_callback(_: void, string: []const u8) error{}!usize {
    puts(string);
    return string.len;
}

const writer = std.io.Writer(void, error{}, writer_callback){ .context = {} };

pub fn init() void {
    InternalSerial.init();
    puts("Serial output initialised!\r\n");
}

pub fn puts(data: []const u8) void {
    for (data) |c|
        putch(c);
}

pub fn putch(data: u8) void {
    InternalSerial.putch(data);
}

pub fn printf(comptime format: []const u8, args: anytype) void {
    std.fmt.format(writer, format, args) catch unreachable;
}
