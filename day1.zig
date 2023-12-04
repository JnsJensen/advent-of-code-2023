const std = @import("std");

pub fn main() !void {
    var file = try std.fs.cwd().openFile("input/day1.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {

        // get all numbers in line
        var numbers: [16]u32 = undefined;
        for (line) |c| {
            if (c >= '0' and c <= '9') {
                // std.debug.print("{c}", .{c});
                numbers[0] = c;
            }
            // std.debug.print("\n", .{});
            std.debug.print("{numbers[0]}\n", .{});
        }
    }
}
