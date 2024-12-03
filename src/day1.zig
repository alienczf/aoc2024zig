const std = @import("std");

fn bubbleSort(arr: []i32) void {
    const len = arr.len;
    for (0..len) |i| {
        for (0..len - i - 1) |j| {
            if (arr[j] > arr[j + 1]) {
                const temp = arr[j];
                arr[j] = arr[j + 1];
                arr[j + 1] = temp;
            }
        }
    }
}
fn readNumberPairs(path: []const u8, v1: *[1000]i32, v2: *[1000]i32) !usize {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    var count: usize = 0;
    var reader = file.reader();
    var buf: [5]u8 = undefined;

    while (true) {
        // Read first number (5 chars)
        const read1 = try reader.read(&buf);
        if (read1 == 0) break;
        v1[count] = try std.fmt.parseInt(i32, buf[0..read1], 10);
        // Skip 3 chars
        try reader.skipBytes(3, .{});
        // Read second number (5 chars)
        const read2 = try reader.read(&buf);
        if (read2 == 0) break;
        v2[count] = try std.fmt.parseInt(i32, buf[0..read2], 10);

        // Skip 1 char
        try reader.skipBytes(1, .{});
        count += 1;
    }

    return count;
}

pub fn solve(path: []const u8) !void {
    var v1: [1000]i32 = undefined;
    var v2: [1000]i32 = undefined;
    const i = try readNumberPairs(path, &v1, &v2);

    // sort v1
    bubbleSort(&v1);
    // sort v2
    bubbleSort(&v2);
    var abs_sum: i32 = 0;
    for (0..i) |j| {
        const diff = v1[j] - v2[j];
        abs_sum += if (diff < 0) -diff else diff;
    }
    std.debug.print("day11 abs_sum={d}\n", .{abs_sum});

    var buffer: [40960]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);

    var counts = std.AutoHashMap(i32, i32).init(fba.allocator());
    defer counts.deinit();

    for (0..i) |j| {
        const val = v2[j];
        const entry = try counts.getOrPut(val);
        if (!entry.found_existing) {
            entry.value_ptr.* = 0;
        }
        entry.value_ptr.* += 1;
    }

    var fancy_sum: i32 = 0;
    for (0..i) |j| {
        const val = v1[j];
        const res = counts.get(val) orelse 0;
        fancy_sum += val * res;
    }
    std.debug.print("day12 fancy_sum={d}\n", .{fancy_sum});
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len != 2) {
        std.debug.print("Usage: {s} <input_file>\n", .{args[0]});
        std.process.exit(1);
    }

    try solve(args[1]);
}
