const std = @import("std.zig");
const builtin = @import("builtin");
const root = @import("root");
const c = std.c;

const math = std.math;
const assert = std.debug.assert;
const os = std.os;
const fs = std.fs;
const mem = std.mem;
const meta = std.meta;
const File = std.fs.File;

pub const Mode = enum {
    /// I/O operates normally, waiting for the operating system syscalls to complete.
    blocking,

    /// I/O functions are generated async and rely on a global event loop. Event-based I/O.
    evented,
};

const mode = std.options.io_mode;
pub const is_async = mode != .blocking;

/// This is an enum value to use for I/O mode at runtime, since it takes up zero bytes at runtime,
/// and makes expressions comptime-known when `is_async` is `false`.
pub const ModeOverride = if (is_async) Mode else enum { blocking };
pub const default_mode: ModeOverride = if (is_async) Mode.evented else .blocking;

fn getStdOutHandle() os.fd_t {
    if (builtin.os.tag == .windows) {
        if (builtin.zig_backend == .stage2_x86_64 or builtin.zig_backend == .stage2_aarch64) {
            // TODO: this is just a temporary workaround until we advance x86 backend further along.
            return os.windows.GetStdHandle(os.windows.STD_OUTPUT_HANDLE) catch os.windows.INVALID_HANDLE_VALUE;
        }
        return os.windows.peb().ProcessParameters.hStdOutput;
    }

    if (@hasDecl(root, "os") and @hasDecl(root.os, "io") and @hasDecl(root.os.io, "getStdOutHandle")) {
        return root.os.io.getStdOutHandle();
    }

    return os.STDOUT_FILENO;
}

/// TODO: async stdout on windows without a dedicated thread.
/// https://github.com/ziglang/zig/pull/4816#issuecomment-604521023
pub fn getStdOut() File {
    return File{
        .handle = getStdOutHandle(),
        .capable_io_mode = .blocking,
        .intended_io_mode = default_mode,
    };
}

fn getStdErrHandle() os.fd_t {
    if (builtin.os.tag == .windows) {
        if (builtin.zig_backend == .stage2_x86_64 or builtin.zig_backend == .stage2_aarch64) {
            // TODO: this is just a temporary workaround until we advance x86 backend further along.
            return os.windows.GetStdHandle(os.windows.STD_ERROR_HANDLE) catch os.windows.INVALID_HANDLE_VALUE;
        }
        return os.windows.peb().ProcessParameters.hStdError;
    }

    if (@hasDecl(root, "os") and @hasDecl(root.os, "io") and @hasDecl(root.os.io, "getStdErrHandle")) {
        return root.os.io.getStdErrHandle();
    }

    return os.STDERR_FILENO;
}

/// This returns a `File` that is configured to block with every write, in order
/// to facilitate better debugging. This can be changed by modifying the `intended_io_mode` field.
pub fn getStdErr() File {
    return File{
        .handle = getStdErrHandle(),
        .capable_io_mode = .blocking,
        .intended_io_mode = .blocking,
    };
}

fn getStdInHandle() os.fd_t {
    if (builtin.os.tag == .windows) {
        if (builtin.zig_backend == .stage2_x86_64 or builtin.zig_backend == .stage2_aarch64) {
            // TODO: this is just a temporary workaround until we advance x86 backend further along.
            return os.windows.GetStdHandle(os.windows.STD_INPUT_HANDLE) catch os.windows.INVALID_HANDLE_VALUE;
        }
        return os.windows.peb().ProcessParameters.hStdInput;
    }

    if (@hasDecl(root, "os") and @hasDecl(root.os, "io") and @hasDecl(root.os.io, "getStdInHandle")) {
        return root.os.io.getStdInHandle();
    }

    return os.STDIN_FILENO;
}

/// TODO: async stdin on windows without a dedicated thread.
/// https://github.com/ziglang/zig/pull/4816#issuecomment-604521023
pub fn getStdIn() File {
    return File{
        .handle = getStdInHandle(),
        .capable_io_mode = .blocking,
        .intended_io_mode = default_mode,
    };
}

pub const Reader = @import("io/reader.zig").Reader;
pub const Writer = @import("io/writer.zig").Writer;
pub const SeekableStream = @import("io/seekable_stream.zig").SeekableStream;

pub const BufferedWriter = @import("io/buffered_writer.zig").BufferedWriter;
pub const bufferedWriter = @import("io/buffered_writer.zig").bufferedWriter;

pub const BufferedReader = @import("io/buffered_reader.zig").BufferedReader;
pub const bufferedReader = @import("io/buffered_reader.zig").bufferedReader;
pub const bufferedReaderSize = @import("io/buffered_reader.zig").bufferedReaderSize;

pub const PeekStream = @import("io/peek_stream.zig").PeekStream;
pub const peekStream = @import("io/peek_stream.zig").peekStream;

pub const FixedBufferStream = @import("io/fixed_buffer_stream.zig").FixedBufferStream;
pub const fixedBufferStream = @import("io/fixed_buffer_stream.zig").fixedBufferStream;

pub const CWriter = @import("io/c_writer.zig").CWriter;
pub const cWriter = @import("io/c_writer.zig").cWriter;

pub const LimitedReader = @import("io/limited_reader.zig").LimitedReader;
pub const limitedReader = @import("io/limited_reader.zig").limitedReader;

pub const CountingWriter = @import("io/counting_writer.zig").CountingWriter;
pub const countingWriter = @import("io/counting_writer.zig").countingWriter;
pub const CountingReader = @import("io/counting_reader.zig").CountingReader;
pub const countingReader = @import("io/counting_reader.zig").countingReader;

pub const MultiWriter = @import("io/multi_writer.zig").MultiWriter;
pub const multiWriter = @import("io/multi_writer.zig").multiWriter;

pub const BitReader = @import("io/bit_reader.zig").BitReader;
pub const bitReader = @import("io/bit_reader.zig").bitReader;

pub const BitWriter = @import("io/bit_writer.zig").BitWriter;
pub const bitWriter = @import("io/bit_writer.zig").bitWriter;

pub const ChangeDetectionStream = @import("io/change_detection_stream.zig").ChangeDetectionStream;
pub const changeDetectionStream = @import("io/change_detection_stream.zig").changeDetectionStream;

pub const FindByteWriter = @import("io/find_byte_writer.zig").FindByteWriter;
pub const findByteWriter = @import("io/find_byte_writer.zig").findByteWriter;

pub const FindByteOutStream = @compileError("deprecated; use `FindByteWriter`");
pub const findByteOutStream = @compileError("deprecated; use `findByteWriter`");

pub const BufferedAtomicFile = @import("io/buffered_atomic_file.zig").BufferedAtomicFile;

pub const StreamSource = @import("io/stream_source.zig").StreamSource;

/// A Writer that doesn't write to anything.
pub const null_writer = @as(NullWriter, .{ .context = {} });

const NullWriter = Writer(void, error{}, dummyWrite);
fn dummyWrite(context: void, data: []const u8) error{}!usize {
    _ = context;
    return data.len;
}

test "null_writer" {
    null_writer.writeAll("yay" ** 10) catch |err| switch (err) {};
}

pub fn poll(
    allocator: std.mem.Allocator,
    comptime StreamEnum: type,
    files: PollFiles(StreamEnum),
) Poller(StreamEnum) {
    const enum_fields = @typeInfo(StreamEnum).Enum.fields;
    var result: Poller(StreamEnum) = undefined;
    inline for (0..enum_fields.len) |i| {
        result.fifos[i] = .{
            .allocator = allocator,
            .buf = &.{},
            .head = 0,
            .count = 0,
        };
        result.poll_fds[i] = .{
            .fd = @field(files, enum_fields[i].name).file.handle,
            .events = switch (@field(files, enum_fields[i].name).direction) {
                .in => os.POLL.IN,
                .out => os.POLL.OUT,
            },
            .revents = undefined,
        };
    }
    return result;
}

pub fn Poller(comptime StreamEnum: type) type {
    return struct {
        const enum_fields = @typeInfo(StreamEnum).Enum.fields;
        const Fifo = std.fifo.LinearFifo(u8, .Dynamic);

        fifos: [enum_fields.len]Fifo,
        //directions: [enum_fields.len]PollFile.Direction,
        //handles: [enum_fields.len]std.fs.File.Handle,
        poll_fds: [enum_fields.len]std.os.pollfd,

        const Self = @This();

        pub fn poll(self: *Self) !void {
            if (builtin.os.tag == .windows) {
                return pollWindows(self);
            } else {
                return pollPosix(self);
            }
        }

        pub inline fn fifo(self: *Self, comptime which: StreamEnum) *Fifo {
            return &self.fifos[@enumToInt(which)];
        }

        pub fn done(self: Self) bool {
            for (self.poll_fds) |poll_fd| {
                if (poll_fd.fd != -1) return false;
            } else return true;
        }

        fn pollWindows(self: *Self) !void {
            _ = self;
            @compileError("TODO");
        }

        fn pollPosix(self: *Self) !void {
            // We ask for ensureUnusedCapacity with this much extra space. This
            // has more of an effect on small reads because once the reads
            // start to get larger the amount of space an ArrayList will
            // allocate grows exponentially.
            const bump_amt = 512;

            const err_mask = os.POLL.ERR | os.POLL.NVAL | os.POLL.HUP;

            const events_len = try os.poll(&self.poll_fds, std.math.maxInt(i32));
            if (events_len == 0) return;

            inline for (0..enum_fields.len) |i| {
                // Try reading whatever is available before checking the error
                // conditions.
                // It's still possible to read after a POLL.HUP is received,
                // always check if there's some data waiting to be read first.
                if (self.poll_fds[i].revents & os.POLL.IN != 0) {
                    const q = &self.fifos[i];
                    const buf = try q.writableWithSize(bump_amt);
                    const amt = try os.read(self.poll_fds[i].fd, buf);
                    q.update(amt);
                    std.debug.print("read {d} bytes\n", .{amt});
                    if (amt == 0) {
                        // Remove the fd when the EOF condition is met.
                        self.poll_fds[i].fd = -1;
                    }
                } else if (self.poll_fds[i].revents & err_mask != 0) {
                    // Exclude the fds that signaled an error.
                    self.poll_fds[i].fd = -1;
                } else if (self.poll_fds[i].revents & os.POLL.OUT != 0) {
                    const q = &self.fifos[i];
                    const amt = try os.write(self.poll_fds[i].fd, q.readableSlice(0));
                    q.discard(amt);
                    if (amt == 0) {
                        self.poll_fds[i].fd = -1;
                    }
                }
            }
        }
    };
}

/// Given an enum, returns a struct with fields of that enum, each field
/// representing an I/O stream for polling.
pub fn PollFiles(comptime StreamEnum: type) type {
    const enum_fields = @typeInfo(StreamEnum).Enum.fields;
    var struct_fields: [enum_fields.len]std.builtin.Type.StructField = undefined;
    for (&struct_fields, enum_fields) |*struct_field, enum_field| {
        struct_field.* = .{
            .name = enum_field.name,
            .type = PollFile,
            .default_value = null,
            .is_comptime = false,
            .alignment = @alignOf(PollFile),
        };
    }
    return @Type(.{ .Struct = .{
        .layout = .Auto,
        .fields = &struct_fields,
        .decls = &.{},
        .is_tuple = false,
    } });
}

pub const PollFile = struct {
    file: File,
    direction: Direction,

    pub const Direction = enum { in, out };
};

test {
    _ = @import("io/bit_reader.zig");
    _ = @import("io/bit_writer.zig");
    _ = @import("io/buffered_atomic_file.zig");
    _ = @import("io/buffered_reader.zig");
    _ = @import("io/buffered_writer.zig");
    _ = @import("io/c_writer.zig");
    _ = @import("io/counting_writer.zig");
    _ = @import("io/counting_reader.zig");
    _ = @import("io/fixed_buffer_stream.zig");
    _ = @import("io/reader.zig");
    _ = @import("io/writer.zig");
    _ = @import("io/peek_stream.zig");
    _ = @import("io/seekable_stream.zig");
    _ = @import("io/stream_source.zig");
    _ = @import("io/test.zig");
}
