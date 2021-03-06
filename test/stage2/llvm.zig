const std = @import("std");
const TestContext = @import("../../src/test.zig").TestContext;
const build_options = @import("build_options");

// These tests should work with all platforms, but we're using linux_x64 for
// now for consistency. Will be expanded eventually.
const linux_x64 = std.zig.CrossTarget{
    .cpu_arch = .x86_64,
    .os_tag = .linux,
};

pub fn addCases(ctx: *TestContext) !void {
    {
        var case = ctx.exeUsingLlvmBackend("simple addition and subtraction", linux_x64);

        case.addCompareOutput(
            \\fn add(a: i32, b: i32) i32 {
            \\    return a + b;
            \\}
            \\
            \\export fn main() c_int {
            \\    var a: i32 = -5;
            \\    const x = add(a, 7);
            \\    var y = add(2, 0);
            \\    y -= x;
            \\    return y;
            \\}
        , "");
    }

    {
        var case = ctx.exeUsingLlvmBackend("hello world", linux_x64);

        case.addCompareOutput(
            \\extern fn puts(s: [*:0]const u8) c_int;
            \\
            \\export fn main() c_int {
            \\    _ = puts("hello world!");
            \\    return 0;
            \\}
        , "hello world!" ++ std.cstr.line_sep);
    }

    {
        var case = ctx.exeUsingLlvmBackend("simple if statement", linux_x64);

        case.addCompareOutput(
            \\fn add(a: i32, b: i32) i32 {
            \\    return a + b;
            \\}
            \\
            \\fn assert(ok: bool) void {
            \\    if (!ok) unreachable;
            \\}
            \\
            \\export fn main() c_int {
            \\    assert(add(1,2) == 3);
            \\    return 0;
            \\}
        , "");
    }

    {
        var case = ctx.exeUsingLlvmBackend("blocks", linux_x64);

        case.addCompareOutput(
            \\fn assert(ok: bool) void {
            \\    if (!ok) unreachable;
            \\}
            \\
            \\fn foo(ok: bool) i32 {
            \\    const val: i32 = blk: {
            \\        var x: i32 = 1;
            \\        if (!ok) break :blk x + 9;
            \\        break :blk x + 19;
            \\    };
            \\    return val + 10;
            \\}
            \\
            \\export fn main() c_int {
            \\    assert(foo(false) == 20);
            \\    assert(foo(true) == 30);
            \\    return 0;
            \\}
        , "");
    }

    {
        var case = ctx.exeUsingLlvmBackend("nested blocks", linux_x64);

        case.addCompareOutput(
            \\fn assert(ok: bool) void {
            \\    if (!ok) unreachable;
            \\}
            \\
            \\fn foo(ok: bool) i32 {
            \\    var val: i32 = blk: {
            \\        const val2: i32 = another: {
            \\            if (!ok) break :blk 10;
            \\            break :another 10;
            \\        };
            \\        break :blk val2 + 10;
            \\    };
            \\    return val;
            \\}
            \\
            \\export fn main() c_int {
            \\    assert(foo(false) == 10);
            \\    assert(foo(true) == 20);
            \\    return 0;
            \\}
        , "");
    }

    {
        var case = ctx.exeUsingLlvmBackend("while loops", linux_x64);

        case.addCompareOutput(
            \\fn assert(ok: bool) void {
            \\    if (!ok) unreachable;
            \\}
            \\
            \\export fn main() c_int {
            \\    var sum: u32 = 0;
            \\    var i: u32 = 0;
            \\    while (i < 5) : (i += 1) {
            \\        sum += i;
            \\    }
            \\    assert(sum == 10);
            \\    assert(i == 5);
            \\    return 0;
            \\}
        , "");
    }
}
