const std = @import("std");
const script = @import("script.zig");
const engine = @import("engine.zig");

pub fn main() void {
    script.runUmkaHello() catch {
        std.log.err("Failed to run umka script", .{});
    };

    engine.run() catch {
        std.log.err("Failed to run engine", .{});
    };
}
