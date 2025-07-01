const cpu = @import("cpu_data");
const std = @import("std");

const InternalConsole = switch (cpu.arch) {
    .x86 => @import("../arch/x86/kernel/console.zig"),
    .aarch64 => @import("../arch/aarch64/kernel/console.zig"),
    else => null,
};

fn writer_callback(_: void, string: []const u8) error{}!usize {
    puts(string);
    return string.len;
}

const writer = std.io.Writer(void, error{}, writer_callback){ .context = {} };

pub fn init() void {
    InternalConsole.init();
}

pub fn clear() void {
    InternalConsole.clear();
}

pub fn puts(data: []const u8) void {
    for (data) |c|
        putch(c);
}

pub fn putch(data: u8) void {
    InternalConsole.putch(data);
}

pub fn printf(comptime format: []const u8, args: anytype) void {
    std.fmt.format(writer, format, args) catch unreachable;
}
