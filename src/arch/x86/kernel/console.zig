const fmt = @import("std").fmt;
const Writer = @import("std").io.Writer;
const Port = @import("ports.zig");

const VGA_WIDTH = 80;
const VGA_HEIGHT = 25;
const VGA_SIZE = VGA_WIDTH * VGA_HEIGHT;

const ConsoleColors = enum(u8) {
    Black = 0,
    Blue = 1,
    Green = 2,
    Cyan = 3,
    Red = 4,
    Magenta = 5,
    Brown = 6,
    LightGray = 7,
    DarkGray = 8,
    LightBlue = 9,
    LightGreen = 10,
    LightCyan = 11,
    LightRed = 12,
    LightMagenta = 13,
    LightBrown = 14,
    White = 15,
};

var x: usize = 0;
var y: usize = 0;
var color = make_color(ConsoleColors.LightGray, ConsoleColors.Black);
var buffer: [*]volatile u16 = @as([*]volatile u16, @ptrFromInt(0xB8000));

fn make_color(fg: ConsoleColors, bg: ConsoleColors) u8 {
    return @as(u8, @intFromEnum(fg)) | (@as(u8, @intFromEnum(bg)) << 4);
}

fn make_vga_entry(uc: u8, new_color: u8) u16 {
    const c: u16 = new_color;
    return uc | (c << 8);
}

fn port_output_b(port: u16, data: u8) void {
    asm volatile (
        \\ outb %al, %dx
        :
        : [port] "{dx}" (port), [data] "{al}" (data)
    );
}

fn set_pos(index: usize) void {
    Port.output_b(
        @intFromEnum(Port.Port.FB_COMMAND),
        @intFromEnum(Port.Command.FB_HIGH_BYTE)
    );
    Port.output_b(
        @intFromEnum(Port.Port.FB_DATA), 
        @intCast((index >> 8) & 0xFF)
    );
    Port.output_b(
        @intFromEnum(Port.Port.FB_COMMAND), 
        @intFromEnum(Port.Command.FB_LOW_BYTE)
    );
    Port.output_b(
        @intFromEnum(Port.Port.FB_DATA), 
        @intCast(index & 0xFF)
    );
}

pub fn init() void {
    clear();
}

pub fn clear() void {
    @memset(buffer[0..VGA_SIZE], make_vga_entry(' ', color));
    y = 0;
    x = 0;
    set_pos(0);
}

pub fn putch(c: u8) void {
    
    if (c == '\n') {
        x = 0;
        y += 1;
        set_pos(y * VGA_WIDTH + x);
        return;
    }

    buffer[y * VGA_WIDTH + x] = make_vga_entry(c, color);
    x += 1;
    if (x == VGA_WIDTH) {
        x = 0;
        y += 1;
        if (y == VGA_HEIGHT)
            y = 0;
    }

    set_pos(y * VGA_WIDTH + x);
}
