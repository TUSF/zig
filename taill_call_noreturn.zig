const std = @import("std");
const builtin = std.builtin;
pub fn foo(message: []const u8, stack_trace: ?*builtin.StackTrace) noreturn {
    @call(.{ .modifier = .always_tail }, bar, .{ message, stack_trace });
}
pub fn bar(message: []const u8, stack_trace: ?*builtin.StackTrace) noreturn {
    _ = message;
    _ = stack_trace;
    std.process.exit(0);
}

pub fn main() void {
    foo("foo", null);
}

// run
// backend=llvm
// target=native
