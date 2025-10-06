const std = @import("std");

const x86Feature = std.Target.x86.Feature;

pub fn build(b: *std.Build) anyerror!void {
    const enabled_features = [_]x86Feature{
        .soft_float,
    };
    const disabled_features = [_]x86Feature{
        .mmx,
        .sse,
        .sse2,
        .avx,
        .avx2,
    };
    const target = b.standardTargetOptions(.{ .default_target = .{
        .cpu_arch = .x86,
        .os_tag = .freestanding,
        .abi = .none,
        .cpu_features_sub = std.Target.x86.featureSet(&disabled_features),
        .cpu_features_add = std.Target.x86.featureSet(&enabled_features),
    } });

    const optimize = b.standardOptimizeOption(.{});

    const kernel = b.addExecutable(.{
        .name = "kernel.elf",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/entry.zig"),
            .optimize = optimize,
            .target = target,
            .code_model = .medium
        })
    });
    kernel.setLinkerScript(b.path("src/arch/x86/linker.ld"));

    var options = b.addOptions();
    options.addOption(std.Target.Cpu.Arch, "arch", std.Target.Cpu.Arch.x86);
    kernel.root_module.addOptions("cpu_data", options);

    b.installArtifact(kernel);

    const kernel_step = b.step("kernel", "Build the Kernel for x86.");
    kernel_step.dependOn(b.getInstallStep());
}
