const std = @import("std");

const GdtEntry = packed struct {
    limit_low: u16,
    base_low: u16,
    base_middle: u8,
    access: u8,
    granularity: u8,
    base_high: u8,
};

const Gdtr = packed struct {
    limit: u16,
    base: usize,
};

var gdt: [3]GdtEntry = undefined;

inline fn create_entry(index: usize, base: u32, limit: u32, access: u8, gran: u8) void {
    gdt[index] = GdtEntry{
        .limit_low = limit & 0xFFFF,
        .base_low = base & 0xFFFF,
        .base_middle = (base >> 16) & 0xFF,
        .access = access,
        .granularity = ((limit >> 16) & 0x0F) | (gran & 0xF0),
        .base_high = (base >> 24) & 0xFF,
    };
}

pub inline fn init() void {
    // Null descriptor
    create_entry(0, 0, 0, 0, 0);

    // Code segment:
    create_entry(1, 0, 0xFFFFFFFF, 0x9A, 0xCF);

    // Data segment:
    create_entry(2, 0, 0xFFFFFFFF, 0x92, 0xCF);

    const gdtr = Gdtr{
        .limit = @sizeOf([3]GdtEntry) - 1,
        .base = @intFromPtr(&gdt),
    };

    load_gdt(&gdtr);
}

inline fn load_gdt(gdtr: *const Gdtr) void {
    asm volatile (
        \\ lgdt (%eax)             // Load GDT register from memory pointed to by EAX
        \\ movw $0x10, %ax         // Load data segment selector (GDT entry 2)
        \\ movw %ax, %ds
        \\ movw %ax, %es
        \\ movw %ax, %fs
        \\ movw %ax, %gs
        \\ movw %ax, %ss
        \\ ljmp $0x08, $next       // Far jump to reload CS (GDT entry 1)
        \\ next:
        :
        : [gdtr] "{eax}" (gdtr),
        : .{ .memory = true, .ax = true }
    );
}
