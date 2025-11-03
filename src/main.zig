const std = @import("std");
const umka = @cImport({
    @cInclude("umka_api.h");
});

const UmkaError = error{
    Alloc,
    Init,
    Compile,
    Run,
};

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    // Allocate memory for the interpreter
    const handler = umka.umkaAlloc() orelse {
        std.log.err("Failed to allocate memory for interpreter", .{});
        return UmkaError.Alloc;
    };
    defer umka.umkaFree(handler);

    // Get arguments
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    // Convert args to argc,argv
    var c_args = try allocator.alloc([*c]u8, args.len);
    defer allocator.free(c_args);

    for (args, 0..) |arg, i| {
        // If we understand correctly umkaInit expects [*c]u8 but
        // arg.ptr won't be mutated. So @constCast should be safe.
        // We need to double check how c_args is used by umka.
        c_args[i] = @constCast(arg.ptr);
    }

    // TODO: pass the filename as an argument to our program
    try initInterpreter(handler, "hello.um", c_args);
    std.log.info("Interpreter initialized", .{});

    try compileProgram(handler);
    std.log.info("Program compiled succeefully", .{});

    try runProgram(handler);
    std.log.info("Program finished successfully", .{});
}

fn initInterpreter(handler: ?*anyopaque, filename: [*c]const u8, c_args: [][*c]u8) !void {
    const argc: c_int = @intCast(c_args.len);
    const argv: [*c][*c]u8 = c_args.ptr;

    // Naming parameters allow us to remember what they are used for
    const source_string = null;
    const stack_size = 4096;
    const file_system_enabled = false;
    const impl_libs_enabled = false;
    const warning_callback: umka.UmkaWarningCallback = null;

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
        return UmkaError.Init;
    }
}

fn compileProgram(handler: ?*anyopaque) !void {
    const compile_ok = umka.umkaCompile(handler);
    if (!compile_ok) {
        logUmkaError(handler, "Failed to compile source file");
        return UmkaError.Compile;
    }
}

fn runProgram(handler: ?*anyopaque) !void {
    const run_ok = umka.umkaRun(handler);
    if (run_ok != 0) {
        logUmkaError(handler, "Failed to run the program");
        return UmkaError.Run;
    }
}

fn logUmkaError(handler: ?*anyopaque, msg: []const u8) void {
    if (handler) |h| {
        const err_ptr = umka.umkaGetError(h);
        if (err_ptr) |err| {
            std.log.err("{s}: {s}", .{ msg, err.*.msg });
        } else {
            std.log.err("{s}: (no additional info)", .{msg});
        }
    } else {
        std.log.err("{s}: (null handler)", .{msg});
    }
}
