const std = @import("std");

pub const x1 = struct {
    pub fn countSetBits(value: i32) i32 {
        var count: i32 = 0;
        var tmp_value = value;

        while (tmp_value != 0) : (count += 1) {
            tmp_value = tmp_value & (tmp_value - 1);
        }

        return count;
    }
};

pub const x2 = struct {
    pub fn countSetBits(value: i32) i32 {
        var v: i64 = value;
        v = ((v & 0xaaaaaaaa) >> 1) + (v & 0x55555555);
        v = ((v & 0xcccccccc) >> 2) + (v & 0x33333333);
        v = ((v & 0xf0f0f0f0) >> 4) + (v & 0x0f0f0f0f);
        v = ((v & 0xff00ff00) >> 8) + (v & 0x00ff00ff);
        v = ((v & 0xffff0000) >> 16) + (v & 0x0000ffff);

        return @intCast(v);
    }
};

pub const x3 = struct {
    pub fn countSetBits(value: i32) i32 {
        var count: i32 = 0;
        for (0..32) |bit| {
            const mask: i32 = (@as(i32, 1) << @as(u5, @intCast(bit)));
            if (value & mask != 0) {
                count += 1;
            }
        }

        return count;
    }
};

pub const x4 = struct {
    pub fn countSetBits(value: i32) i32 {
        return @popCount(value);
    }
};

test "Iterate over all structs and test countSetBits" {
    const structs = [_]type{ x1, x2, x3, x4 };
    inline for (structs) |Struct| {
        try std.testing.expectEqual(0, Struct.countSetBits(0));
        try std.testing.expectEqual(1, Struct.countSetBits(1));
        try std.testing.expectEqual(1, Struct.countSetBits(2));
        try std.testing.expectEqual(2, Struct.countSetBits(3));
        try std.testing.expectEqual(4, Struct.countSetBits(15));
        try std.testing.expectEqual(8, Struct.countSetBits(255));
        try std.testing.expectEqual(16, Struct.countSetBits(65535));
    }
}
