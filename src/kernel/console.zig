const cpu = @import("cpu_data");
const std = @import("std");

const InternalConsole = switch (cpu.arch) {
    .x86 => @import("../arch/x86/kernel/console.zig"),
    .aarch64 => @import("../arch/aarch64/kernel/console.zig"),
    else => null,
};

const Serial = @import("serial.zig");

fn writer_callback(_: void, string: []const u8) error{}!usize {
    puts(string);
    return string.len;
}

const writer = std.io.GenericWriter(void, error{}, writer_callback){ .context = {} };

pub inline fn init() void {
    InternalConsole.init();
    Serial.puts("Console output has been initialised!\r\n");
}

pub inline fn clear() void {
    InternalConsole.clear();
}

pub fn puts(data: []const u8) void {
    for (data) |c|
        putch(c);
}

pub inline fn putch(data: u8) void {
    InternalConsole.putch(data);
}

pub inline fn printf(comptime format: []const u8, args: anytype) void {
    std.fmt.format(writer, format, args) catch unreachable;
}
