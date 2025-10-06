const std = @import("std");

pub fn build(b: *std.Build) anyerror!void {
    const target = b.standardTargetOptions(.{ .default_target = .{ .cpu_arch = .aarch64, .os_tag = .freestanding, .abi = .none } });

    const optimize = b.standardOptimizeOption(.{});

    const kernel = b.addExecutable(.{
        .name = "kernel8.img",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/entry.zig"),
            .optimize = optimize,
            .target = target,
            .code_model = .medium
        })
    });
    kernel.setLinkerScript(b.path("src/arch/aarch64/linker.ld"));

    var options = b.addOptions();
    options.addOption(std.Target.Cpu.Arch, "arch", std.Target.Cpu.Arch.aarch64);
    kernel.root_module.addOptions("cpu_data", options);

    b.installArtifact(kernel);

    const kernel_step = b.step("kernel", "Build the Kernel for aarch64.");
    kernel_step.dependOn(b.getInstallStep());
}
