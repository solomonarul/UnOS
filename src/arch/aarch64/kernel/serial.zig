const Ports = @import("ports.zig");

const COM1_BASE = 0x3F8;

const DATA_PORT_OFFSET = 0x00;
const FIFO_COMMAND_PORT_OFFSET = 0x02;
const LINE_COMMAND_PORT_OFFSET = 0x03;
const LINE_STATUS_PORT_OFFSET = 0x05;

const LINE_ENABLE_DLAB_COMMAND = 0x80;

inline fn serial_output_configure_baud_rate(com: u32, divisor: u16) void {
    // Enable DLAB (set baud rate divisor)
    Ports.output_b(com + LINE_COMMAND_PORT_OFFSET, LINE_ENABLE_DLAB_COMMAND);
    Ports.output_b(com + DATA_PORT_OFFSET, (divisor >> 8) & 0x00FF);
    Ports.output_b(com + DATA_PORT_OFFSET + 1, divisor & 0x00FF);
}

inline fn serial_output_configure_line(com: u32) void {
    // 8 bits, no parity, one stop bit
    Ports.output_b(com + LINE_COMMAND_PORT_OFFSET, 0x03);
}

inline fn serial_output_configure_buffers(com: u32) void {
    // Enable FIFO, clear them, with 14-byte threshold
    Ports.output_b(com + FIFO_COMMAND_PORT_OFFSET, 0xC7);
}

inline fn serial_output_is_fifo_empty(com: u32) bool {
    return (Ports.input_b(com + LINE_STATUS_PORT_OFFSET) & 0x20) != 0;
}

pub inline fn init() void {
    serial_output_configure_baud_rate(COM1_BASE, 3);
    serial_output_configure_line(COM1_BASE);
    serial_output_configure_buffers(COM1_BASE);
}

pub fn putch(ch: u8) void {
    while (!serial_output_is_fifo_empty(COM1_BASE)) {}
    Ports.output_b(COM1_BASE, ch);
}
