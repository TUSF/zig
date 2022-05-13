const std = @import("std");

pub fn panic(message: []const u8, stack_trace: ?*std.builtin.StackTrace) noreturn {
    _ = stack_trace;
    if (std.mem.eql(u8, message, "reached unreachable code")) {
        std.process.exit(0);
    }
    std.process.exit(1);
}

const U = union(enum(u32)) {
    X: u8,
};

pub fn main() !void {
    var u: U = undefined;
    @memset(@ptrCast([*]u8, &u), 0x55, @sizeOf(U));
    switch (u) {
        .X => @breakpoint(),
    }
    return error.TestFailed;
}

// run
// backend=stage1
