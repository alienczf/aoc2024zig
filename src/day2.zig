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
fn readMatrix(path: []const u8, mat: *[1000][9]i32) !usize {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    var rowbuf: [80]u8 = undefined; // needed as cache for read file data
    var reader = file.reader();
    var row: usize = 0;
    var col: usize = 0;

    while (try reader.readUntilDelimiterOrEof(&rowbuf, '\n')) |line| {
        col = 0;
        // splitSequence: splits on exact string sequence
        // splitAny: splits on any character in given string
        // splitScalar: splits on single character (most efficient for single char)
        var it = std.mem.splitScalar(u8, line, ' ');
        while (it.next()) |val| {
            if (val.len == 0) continue;
            mat[row][col] = try std.fmt.parseInt(i32, val, 10);
            col += 1;
        }
        mat[row][8] = @as(i32, @intCast(col));
        row += 1;
    }

    return row;
}

fn verifyrow(row: []const i32) bool {
    if (row.len == 0) return true;
    var prev = row[0];
    var prev_diff: i32 = 0;
    for (row, 0..) |val, idx| {
        if (val == 0) break;
        var diff = val - prev;
        if (diff * prev_diff < 0) {
            // std.debug.print("fail diff={d} prev_diff={d}\n", .{ diff, prev_diff });
            return false;
        }
        prev_diff = diff;
        prev = val;
        diff = if (diff < 0) -diff else diff;
        if (idx != 0 and !(1 <= diff and diff <= 3)) {
            // std.debug.print("fail diff={d}\n", .{diff});
            return false;
        }
    }
    return true;
}

pub fn solve(path: []const u8) !void {
    var mat: [1000][9]i32 = [_][9]i32{[_]i32{0} ** 9} ** 1000;
    const rows = try readMatrix(path, &mat);
    var passes: usize = 0;
    for (0..rows) |r_id| {
        const len: usize = @as(usize, @intCast(mat[r_id][8]));
        if (!verifyrow(mat[r_id][0..len])) {} else {
            passes += 1;
        }
    }
    std.debug.print("part 1 count={d}\n", .{passes});

    passes = 0;
    var tmp: [9]i32 = undefined;
    for (0..rows) |r_id| {
        const len: usize = @as(usize, @intCast(mat[r_id][8]));
        if (!verifyrow(mat[r_id][0..len])) {
            for (0..len) |skip| {
                var col: usize = 0;
                for (0..len) |i| {
                    if (i == skip) continue;
                    tmp[col] = mat[r_id][i];
                    col += 1;
                }
                if (verifyrow(tmp[0..(len - 1)])) {
                    passes += 1;
                    break;
                }
            }
        } else {
            passes += 1;
        }
    }
    std.debug.print("part 2 count={d}\n", .{passes});
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
test "verifyrow" {
    // 7 6 4 2 1: Safe because the levels are all decreasing by 1 or 2.
    try std.testing.expect(verifyrow(&[_]i32{ 7, 6, 4, 2, 1 }));
    // 1 2 7 8 9: Unsafe because 2 7 is an increase of 5.
    try std.testing.expect(!verifyrow(&[_]i32{ 1, 2, 7, 8, 9 }));
    // 9 7 6 2 1: Unsafe because 6 2 is a decrease of 4.
    try std.testing.expect(!verifyrow(&[_]i32{ 9, 7, 6, 2, 1 }));
    // 1 3 2 4 5: Unsafe because 1 3 is increasing but 3 2 is decreasing.
    try std.testing.expect(!verifyrow(&[_]i32{ 1, 3, 2, 4, 5 }));
    // 8 6 4 4 1: Unsafe because 4 4 is neither an increase or a decrease.
    try std.testing.expect(!verifyrow(&[_]i32{ 8, 6, 4, 4, 1 }));
    // 1 3 6 7 9: Safe because the levels are all increasing by 1, 2, or 3.
    try std.testing.expect(verifyrow(&[_]i32{ 1, 3, 6, 7, 9 }));
}
