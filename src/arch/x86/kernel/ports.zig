pub const Command = enum(u8) {
    FB_HIGH_BYTE = 14,
    FB_LOW_BYTE = 15,
};

pub const Port = enum(u16) {
    FB_COMMAND = 0x3D4,
    FB_DATA = 0x3D5,
};

pub fn output_b(port: u16, data: u8) void {
    asm volatile (
        \\ outb %al, %dx
        :
        : [port] "{dx}" (port), [data] "{al}" (data)
    );
}