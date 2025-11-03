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

pub fn main() void {
    runUmkaHello() catch {
        std.log.err("Failed to run umka script", .{});
    };

    runEngine() catch {
        std.log.err("Failed to run engine", .{});
    };
}

fn runEngine() !void {
    // Simulate a loop.
    // Our goal is to later create a simple engine that will expose some
    // functions to the script to move an object.
    const fps: u64 = 60;
    const frame_time_ns: u64 = 1_000_000_000 / fps;

    var timer = try std.time.Timer.start();

    var frame: usize = 0; // incremented at the beginning of the loop

    while (frame <= 600) {
        const delta_time_ns = timer.lap();
        const dt: f64 = @floatFromInt(delta_time_ns);

        frame += 1;

        // The frame logic will go there
        if (@mod(frame, fps) == 0) {
            std.log.debug("Frame #{d}, dt = {} seconds", .{ frame, dt / 1_000_000_000.0 });
        }

        callScriptUpdate(delta_time_ns);
        callEngineUpdate(delta_time_ns);
        callEngineRender();

        // Calculate how long to sleep to maintain 60 fps
        const elapsed_time_ns: u64 = timer.read();
        if (elapsed_time_ns < frame_time_ns) {
            std.posix.nanosleep(0, frame_time_ns - elapsed_time_ns);
        }
    }
}

fn callEngineRender() void {
    // TODO: Render stuff
}

fn callEngineUpdate(dt_ns: u64) void {
    // engine updates positions & detects collisions
    _ = dt_ns;
}

fn callScriptUpdate(dt_ns: u64) void {
    // call script update functions
    _ = dt_ns;
}

fn runUmkaHello() !void {
    const allocator = std.heap.page_allocator;

    // Allocate memory for the interpreter
    const interp = umka.umkaAlloc() orelse {
        std.log.err("Failed to allocate memory for interpreter", .{});
        return UmkaError.Alloc;
    };
    defer umka.umkaFree(interp);

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
    try initInterpreter(interp, "hello.um", c_args);
    std.log.info("Interpreter initialized", .{});

    try compileProgram(interp);
    std.log.info("Program compiled successfully", .{});

    try runProgram(interp);
    std.log.info("Program finished successfully", .{});
}

fn initInterpreter(interp: ?*anyopaque, filename: [*c]const u8, c_args: [][*c]u8) !void {
    const argc: c_int = @intCast(c_args.len);
    const argv: [*c][*c]u8 = c_args.ptr;

    // Naming parameters allow us to remember what they are used for
    const source_string = null;
    const stack_size = 2048; // with 1024 we got a stack overflow
    const file_system_enabled = false;
    const impl_libs_enabled = false;
    const warning_callback: umka.UmkaWarningCallback = null;

    const init_ok = umka.umkaInit(
        interp,
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
        logUmkaError(interp, "Failed to initialize the interpreter instance");
        return UmkaError.Init;
    }
}

fn compileProgram(interp: ?*anyopaque) !void {
    const compile_ok = umka.umkaCompile(interp);
    if (!compile_ok) {
        logUmkaError(interp, "Failed to compile source file");
        return UmkaError.Compile;
    }
}

fn runProgram(interp: ?*anyopaque) !void {
    const run_ok = umka.umkaRun(interp);
    if (run_ok != 0) {
        logUmkaError(interp, "Failed to run the program");
        return UmkaError.Run;
    }
}

fn logUmkaError(interp: ?*anyopaque, msg: []const u8) void {
    if (interp) |h| {
        const err_ptr = umka.umkaGetError(h);
        if (err_ptr) |err| {
            std.log.err("{s}: {s}", .{ msg, err.*.msg });
        } else {
            std.log.err("{s}: (no additional info)", .{msg});
        }
    } else {
        std.log.err("{s}: (null interp)", .{msg});
    }
}
