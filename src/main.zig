const std = @import("std");
const umka = @cImport({
    @cInclude("umka_api.h");
});

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    // Get arguments
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    // Convert args to argc,argv
    var c_argv = try allocator.alloc([*c]u8, args.len);
    defer allocator.free(c_argv);

    for (args, 0..) |arg, i| {
        c_argv[i] = @constCast(arg.ptr);
    }

    // Parameters used for the initialization
    // Allocate memory for the interpreter
    const handler = umka.umkaAlloc() orelse {
        std.log.err("Failed to allocate memory for interpreter", .{});
        return;
    };
    defer umka.umkaFree(handler);

    const filename = "hello.um";
    const source_string = null;
    const stack_size = 4096;
    const file_system_enabled = false;
    const impl_libs_enabled = false;
    const warning_callback: umka.UmkaWarningCallback = null;
    const argc: c_int = @intCast(c_argv.len);
    const argv: [*c][*c]u8 = c_argv.ptr;

    const init_ok = umka.umkaInit(
        handler,
        filename,
        source_string,
        stack_size,
        null, // reserved
        argc,
        argv,
        file_system_enabled,
        impl_libs_enabled,
        warning_callback,
    );

    if (!init_ok) {
        logUmkaError(handler, "Failed to initialize the interpreter instance");
        return;
    }

    std.log.info("Instance initialized", .{});

    const compile_ok = umka.umkaCompile(handler);
    if (!compile_ok) {
        logUmkaError(handler, "Failed to compile source file");
        return;
    }

    const run_ok = umka.umkaRun(handler);
    if (run_ok == 0) {
        std.log.info("Program finishes successfully", .{});
    } else {
        logUmkaError(handler, "Program failed to execute");
    }
}

fn logUmkaError(handler: ?*anyopaque, msg: []const u8) void {
    if (handler) |h| {
        std.log.err("{s}", .{msg});
        const err_ptr = umka.umkaGetError(h);
        if (err_ptr) |err| {
            std.log.err("{s}", .{err.*.msg});
        } else {
            std.log.err("No error can be reported", .{});
        }
    }
}
