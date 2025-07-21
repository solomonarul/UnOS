const MultiBoot = @import("../../multiboot.zig");
const GDT = @import("../../x86/kernel/gdt.zig");

export var multiboot align(4) linksection(".multiboot") =
    MultiBoot.Header{};

export var stack_bytes: [16 * 1024]u8 align(16) linksection(".bss") = undefined;
const stack = stack_bytes[0..];

extern fn kmain() void;

pub inline fn init() void {

    // Set up the stack.
    asm volatile (
        \\ movl %[stk], %esp
        \\ movl %esp, %ebp
        :
        : [stk] "{ecx}" (@intFromPtr(&stack) + @sizeOf(@TypeOf(stack))),
    );

    GDT.init();

    asm volatile (
        \\ call kmain
    );

    // TODO: make a panic mechanism or something as kmain should not end
}
