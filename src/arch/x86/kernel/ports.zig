pub inline fn input_b(port: u16) u8 {
    var data: u8 = 0;

    asm volatile (
        \\ inb %dx, %al
        : [data] "={al}" (data),
        : [port] "{dx}" (port),
    );

    return data;
}

pub inline fn output_b(port: u16, data: u8) void {
    asm volatile (
        \\ outb %al, %dx
        :
        : [port] "{dx}" (port),
          [data] "{al}" (data),
    );
}
