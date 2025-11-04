const std = @import("std");
const umka = @cImport({
    @cInclude("umka_api.h");
});
const Ansi = @import("ansi.zig").Ansi;

const ScriptError = error{
    Alloc,
    Init,
    Compile,
    Run,
};

pub const ScriptRunner = struct {
    allocator: std.mem.Allocator,
    term: Ansi,
    interp: ?*anyopaque,

    pub fn init(allocator: std.mem.Allocator, writer: *std.Io.Writer) !ScriptRunner {
        // Allocate memory for the interpreter
        const interp = umka.umkaAlloc() orelse {
            try writer.print("Failed to allocate memory for interpreter", .{});
            try writer.flush();
            return ScriptError.Alloc;
        };

        return .{
            .allocator = allocator,
            .term = Ansi.init(writer),
            .interp = interp,
        };
    }

    pub fn deinit(self: *const ScriptRunner) void {
        umka.umkaFree(self.interp);
    }

    pub fn run(self: *const ScriptRunner, filename: []const u8) !void {
        // TODO: pass some parameters to the script
        try self.initInterpreter(filename.ptr);
        self.term.writeInfo("Interpreter initialized.", .{});

        try self.compileProgram();
        self.term.writeInfo("Program compiled successfully", .{});

        try self.runProgram();
        self.term.writeInfo("Program finished successfully", .{});
    }

    fn initInterpreter(self: *const ScriptRunner, filename: [*c]const u8) !void {
        // Naming parameters allow us to remember what they are used for
        const source_string = null;
        const stack_size = 2048; // with 1024 we got a stack overflow
        const argc = 0;
        const argv = null;
        const file_system_enabled = false;
        const impl_libs_enabled = false;
        const warning_callback: umka.UmkaWarningCallback = null;

        const init_ok = umka.umkaInit(
            self.interp,
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
            self.logUmkaError("Failed to initialize the interpreter instance");
            return ScriptError.Init;
        }
    }

    fn compileProgram(self: *const ScriptRunner) !void {
        const compile_ok = umka.umkaCompile(self.interp);
        if (!compile_ok) {
            self.logUmkaError("Failed to compile source file");
            return ScriptError.Compile;
        }
    }

    fn runProgram(self: *const ScriptRunner) !void {
        const run_ok = umka.umkaRun(self.interp);
        if (run_ok != 0) {
            self.logUmkaError("Failed to run the program");
            return ScriptError.Run;
        }
    }

    fn logUmkaError(self: *const ScriptRunner, msg: []const u8) void {
        if (self.interp) |h| {
            const err_ptr = umka.umkaGetError(h);
            if (err_ptr) |err| {
                self.term.writeError("{s}: {s}", .{ msg, err.*.msg });
            } else {
                self.term.writeError("{s}: (no additional info)", .{msg});
            }
        } else {
            self.term.writeError("{s}: (null interp)", .{msg});
        }
    }
};
