pub fn output_b(port: u16, data: u8) void {
    asm volatile (
        \\ outb %al, %dx
        :
        : [port] "{dx}" (port), [data] "{al}" (data)
    );
}