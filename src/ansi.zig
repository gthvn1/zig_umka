const std = @import("std");

// https://gist.github.com/ConnerWill/d4b6c776b509add763e17f9f113fd25b

pub const Ansi = struct {
    output: *std.Io.Writer,

    pub const Color = enum(u8) {
        black = 30,
        red = 31,
        green = 32,
        yellow = 33,
        blue = 34,
        magenta = 35,
        cyan = 36,
        white = 37,
        default = 39,
        reset = 0,
    };

    pub fn init(output: *std.Io.Writer) Ansi {
        return .{
            .output = output,
        };
    }

    pub fn resetColor(self: *const Ansi) !void {
        try self.setColor(Color.default);
        try self.output.flush();
    }

    pub fn resetAll(self: *const Ansi) !void {
        // Reset all modes
        try self.setColor(Color.reset);
        try self.output.flush();
    }

    pub fn setColor(self: *const Ansi, color: Color) !void {
        try self.output.print("\x1b[{d}m", .{@intFromEnum(color)});
    }

    pub fn setBold(self: *const Ansi) !void {
        try self.output.print("\x1b[1m", .{});
    }

    pub fn setItalic(self: *const Ansi) !void {
        try self.output.print("\x1b[3m", .{});
    }

    pub fn setUnderline(self: *const Ansi) !void {
        try self.output.print("\x1b[4m", .{});
    }

    pub fn setReverse(self: *const Ansi) !void {
        try self.output.print("\x1b[7m", .{});
    }

    pub fn writeError(self: *const Ansi, comptime fmt: []const u8, args: anytype) void {
        writeErrorHandler(self, fmt, args) catch std.log.err(fmt, args);
    }

    fn writeErrorHandler(self: *const Ansi, comptime fmt: []const u8, args: anytype) !void {
        try self.setColor(Color.red);
        try self.output.print("error: ", .{});
        try self.output.print(fmt ++ "\n", args);
        try self.resetColor();
        try self.output.flush();
    }

    pub fn writeInfo(self: *const Ansi, comptime fmt: []const u8, args: anytype) void {
        writeInfoHandler(self, fmt, args) catch std.log.info(fmt, args);
    }

    fn writeInfoHandler(self: *const Ansi, comptime fmt: []const u8, args: anytype) !void {
        try self.setColor(Color.blue);
        try self.output.print("info: ", .{});
        try self.output.print(fmt ++ "\n", args);
        try self.resetColor();
        try self.output.flush();
    }

    pub fn writeDebug(self: *const Ansi, comptime fmt: []const u8, args: anytype) void {
        writeDebugHandler(self, fmt, args) catch std.log.warn(fmt, args);
    }

    fn writeDebugHandler(self: *const Ansi, comptime fmt: []const u8, args: anytype) !void {
        try self.setColor(Color.yellow);
        try self.output.print("debug: ", .{});
        try self.output.print(fmt ++ "\n", args);
        try self.resetColor();
        try self.output.flush();
    }
    pub fn writeWarning(self: *const Ansi, comptime fmt: []const u8, args: anytype) void {
        writeWarningHandler(self, fmt, args) catch std.log.warn(fmt, args);
    }

    fn writeWarningHandler(self: *const Ansi, comptime fmt: []const u8, args: anytype) !void {
        try self.setColor(Color.magenta);
        try self.output.print("warning: ", .{});
        try self.output.print(fmt ++ "\n", args);
        try self.resetColor();
        try self.output.flush();
    }
};
