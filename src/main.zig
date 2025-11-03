const std = @import("std");
const ScriptRunner = @import("script.zig").ScriptRunner;
const Engine = @import("engine.zig").Engine;

pub fn main() !void {
    const GPAtype = std.heap.GeneralPurposeAllocator(.{});
    var gpa = GPAtype{};
    const allocator = gpa.allocator();

    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    const script = try ScriptRunner.init(allocator, stdout);
    defer script.deinit();

    script.run("hello.um") catch {
        std.log.err("Failed to run umka script", .{});
    };

    const engine = Engine.init(stdout);

    engine.run() catch {
        std.log.err("Failed to run engine", .{});
    };
}
