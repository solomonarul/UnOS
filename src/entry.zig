const Setup = @import("kernel/setup.zig");
const Console = @import("kernel/console.zig");

export fn _start() callconv(.Naked) noreturn {
    Setup.init(); // This initializes platform specific stuff and calls kmain.
    while (true) {}
}

const Version = struct {
    major: u8,
    minor: u8,
    patch: u8,
};

export fn kmain() void {
    const version = Version{
        .major = 0,
        .minor = 1,
        .patch = 0,
    };
    Console.init();
    Console.printf("Welcome to UnOS! v. {}.{}.{}\n", version);
    Console.puts("-------------------------\n\n> ");
}
