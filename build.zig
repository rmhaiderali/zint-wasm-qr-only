const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.resolveTargetQuery(.{ .cpu_arch = .wasm32, .os_tag = .wasi });
    const optimize: std.builtin.OptimizeMode = .ReleaseSmall;

    const translate_c = b.addTranslateC(.{
        .root_source_file = b.path("src/c.h"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    translate_c.addIncludePath(b.path("zint/backend"));
    translate_c.defineCMacro("ZINT_NO_PNG", null);

    const wasm = b.addExecutable(.{
        .name = "zint",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/wasm.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
            .imports = &.{
                .{ .name = "c", .module = translate_c.createModule() },
            },
        }),
    });

    wasm.entry = .disabled;
    wasm.rdynamic = true;
    wasm.wasi_exec_model = .reactor;

    wasm.root_module.addCSourceFiles(.{
        .root = b.path("zint/backend"),
        .files = zint_sources,
        .flags = &.{"-DZINT_NO_PNG"},
    });

    wasm.root_module.addIncludePath(b.path("zint/backend"));

    b.installArtifact(wasm);
}

const zint_sources: []const []const u8 = &.{
    "common.c",
    "eci.c",
    "filemem.c",
    "general_field.c",
    "gs1.c",
    "large.c",
    "library.c",
    "reedsol.c",
    "qr.c",
    "bmp.c",
    "emf.c",
    "gif.c",
    "output.c",
    "pcx.c",
    "ps.c",
    "raster.c",
    "svg.c",
    "tif.c",
    "vector.c",
};
