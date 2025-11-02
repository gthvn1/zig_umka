const std = @import("std");
const umka = @cImport({
    @cInclude("umka_api.h");
});

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    // Allocate memory for the interpreter
    const handler = umka.umkaAlloc() orelse {
        std.debug.print("Failed to allocate memory for interpreter\n", .{});
        return;
    };

    // We need to convert args into argc,argv available in C.
    var c_args = try allocator.alloc([*c]const u8, args.len);
    defer allocator.free(c_args);

    for (args, 0..) |arg, i| {
        c_args[i] = arg.ptr;
    }

    // Parameters used for the initialization
    const source_string = null;
    const stack_size = 4096;
    const file_system_enabled = false;
    const impl_libs_enabled = false;
    const warning_callback = null;
    const argc: c_int = @intCast(args.len);
    const argv: [*c][*c]u8 = @ptrCast(c_args.ptr);

    const init_ok = umka.umkaInit(
        handler,
        "./test.um",
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
        std.debug.print("Failed to initialize the interpreter instance\n", .{});
        const err_ptr = umka.umkaGetError(handler);
        if (err_ptr) |err| {
            std.debug.print("Error: {s}\n", .{err.*.msg});
        } else {
            std.debug.print("No error can be reported\n", .{});
        }
        return;
    }

    std.debug.print("Instance initialized\n", .{});
}
