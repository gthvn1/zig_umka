const std = @import("std");
const Ansi = @import("ansi.zig").Ansi;

pub const Engine = struct {
    term: Ansi,

    pub fn init(writer: *std.Io.Writer) Engine {
        return .{
            .term = Ansi.init(writer),
        };
    }

    pub fn run(self: *const Engine) !void {
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
                self.term.writeDebug("Frame #{d}, dt = {} seconds", .{ frame, dt / 1_000_000_000.0 });
            }

            self.callScriptUpdate(delta_time_ns);
            self.callEngineUpdate(delta_time_ns);
            self.callEngineRender();

            // Calculate how long to sleep to maintain 60 fps
            const elapsed_time_ns: u64 = timer.read();
            if (elapsed_time_ns < frame_time_ns) {
                std.posix.nanosleep(0, frame_time_ns - elapsed_time_ns);
            }
        }
    }

    fn callEngineRender(self: *const Engine) void {
        // TODO: Render stuff
        _ = self;
    }

    fn callEngineUpdate(self: *const Engine, dt_ns: u64) void {
        // engine updates positions & detects collisions
        _ = self;
        _ = dt_ns;
    }

    fn callScriptUpdate(self: *const Engine, dt_ns: u64) void {
        // call script update functions
        _ = self;
        _ = dt_ns;
    }
};
