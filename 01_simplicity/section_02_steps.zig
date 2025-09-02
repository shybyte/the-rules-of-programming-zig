const std = @import("std");

pub const x1 = struct {
    fn countStepPatterns(step_count: i32) i32 {
        if (step_count < 0) {
            return 0;
        }

        if (step_count == 0) {
            return 1;
        }

        return countStepPatterns(step_count - 3) +
            countStepPatterns(step_count - 2) +
            countStepPatterns(step_count - 1);
    }
};

pub const x2 = struct {
    const AutoHashMap = std.hash_map.AutoHashMap;

    fn countStepPatterns(step_count: i32) i32 {
        var hash_table = AutoHashMap(i32, i32).init(std.heap.page_allocator);
        defer hash_table.deinit();
        return countStepPatternsInternal(step_count, &hash_table);
    }

    fn countStepPatternsInternal(stepCount: i32, hash_table: *AutoHashMap(i32, i32)) i32 {
        if (stepCount < 0) {
            return 0;
        } else if (stepCount == 0) {
            return 1;
        } else if (hash_table.get(stepCount)) |cached_result| {
            return cached_result;
        } else {
            const result = countStepPatternsInternal(stepCount - 3, hash_table) +
                countStepPatternsInternal(stepCount - 2, hash_table) +
                countStepPatternsInternal(stepCount - 1, hash_table);

            hash_table.put(stepCount, result) catch {};
            return result;
        }
    }
};

pub const x3 = struct {
    const allocator = std.heap.page_allocator;

    fn countStepPatterns(step_count: usize) !i32 {
        var step_pattern_counts = try std.ArrayList(i32).initCapacity(allocator, step_count + 30);
        defer step_pattern_counts.deinit(allocator);

        step_pattern_counts.appendSliceAssumeCapacity(&[_]i32{ 0, 0, 1 });

        for (0..step_count) |i| {
            const newCount = step_pattern_counts.items[i] +
                step_pattern_counts.items[i + 1] +
                step_pattern_counts.items[i + 2];

            step_pattern_counts.appendAssumeCapacity(newCount);
        }

        return step_pattern_counts.getLast();
    }
};

pub const x4 = struct {
    fn countStepPatterns(step_count: usize) !i32 {
        var a: i32 = 0;
        var b: i32 = 0;
        var c: i32 = 1;

        for (0..step_count) |_| {
            const newCount = a + b + c;
            a = b;
            b = c;
            c = newCount;
        }

        return c;
    }
};

pub const x5 = struct {
    pub const Ordinal = struct {
        pub const Word = u32;

        words: std.ArrayList(Word),
        _alloc: std.mem.Allocator,

        // Constructors
        pub fn init(alloc: std.mem.Allocator) !Ordinal {
            return .{ ._alloc = alloc, .words = try std.ArrayList(Word).initCapacity(alloc, 0) };
        }

        pub fn fromU32(alloc: std.mem.Allocator, value: u32) !Ordinal {
            var o = try Ordinal.init(alloc);
            try o.words.append(alloc, value);
            return o;
        }

        pub fn fromU64(alloc: std.mem.Allocator, value: u64) !Ordinal {
            var o = try Ordinal.init(alloc);
            try o.words.append(alloc, @as(u32, @intCast(value & 0xffffffff)));
            try o.words.append(alloc, @as(u32, @intCast(value >> 32)));
            return o;
        }

        pub fn deinit(self: *Ordinal) void {
            self.words.deinit(self._alloc);
        }

        fn getWord(self: *const Ordinal, word_index: usize) Word {
            return if (word_index < self.words.items.len)
                self.words.items[word_index]
            else
                0;
        }

        // Ordinal + Ordinal
        pub fn add(self: *const Ordinal, other: *const Ordinal) !Ordinal {
            var result = try Ordinal.init(self._alloc);

            const word_count = @max(self.words.items.len, other.words.items.len);
            var carry: u64 = 0;

            var i: usize = 0;
            while (i < word_count) : (i += 1) {
                const sum: u64 =
                    carry +
                    @as(u64, self.getWord(i)) +
                    @as(u64, other.getWord(i));

                try result.words.append(result._alloc, @as(u32, @intCast(sum & 0xffffffff)));
                carry = sum >> 32;
            }

            if (carry > 0) {
                try result.words.append(result._alloc, @as(u32, @intCast(carry)));
            }

            return result;
        }

        // Equality with zero-fill up to max length (matches the C++)
        pub fn eql(self: *const Ordinal, other: *const Ordinal) bool {
            const count = @max(self.words.items.len, other.words.items.len);
            var i: usize = 0;
            while (i < count) : (i += 1) {
                if (self.getWord(i) != other.getWord(i)) return false;
            }
            return true;
        }
    };

    fn countStepPatterns(step_count: usize) !Ordinal {
        const allocator = std.heap.page_allocator;

        var step_pattern_counts = try std.ArrayList(Ordinal).initCapacity(allocator, step_count + 30);
        defer step_pattern_counts.deinit(allocator);

        step_pattern_counts.appendSliceAssumeCapacity(
            &[_]Ordinal{ try Ordinal.fromU32(allocator, 0), try Ordinal.fromU32(allocator, 0), try Ordinal.fromU32(allocator, 1) },
        );

        for (0..step_count) |i| {
            const newCount = try (try step_pattern_counts.items[i].add(&step_pattern_counts.items[i + 1])).add(&step_pattern_counts.items[i + 2]);

            step_pattern_counts.appendAssumeCapacity(newCount);
        }

        return step_pattern_counts.getLast();
    }
};

pub const x6 = struct {
    const allocator = std.heap.page_allocator;

    fn countStepPatterns(step_count: usize) !i32 {
        // NOTE (chris) can't represent the pattern count in an int once we get past 36 steps...
        std.debug.assert(step_count <= 36);

        var a: i32 = 0;
        var b: i32 = 0;
        var c: i32 = 1;

        for (0..step_count) |_| {
            const newCount = a + b + c;
            a = b;
            b = c;
            c = newCount;
        }

        return c;
    }
};

test "Iterate over all structs and test countStepPatterns" {
    const structs = [_]type{ x1, x2, x3, x4, x6 };
    inline for (structs) |Struct| {
        try std.testing.expectEqual(1, Struct.countStepPatterns(1));
        try std.testing.expectEqual(2, Struct.countStepPatterns(2));
        try std.testing.expectEqual(4, Struct.countStepPatterns(3));
        try std.testing.expectEqual(7, Struct.countStepPatterns(4));
        try std.testing.expectEqual(13, Struct.countStepPatterns(5));
        try std.testing.expectEqual(121415, Struct.countStepPatterns(20));

        const start_time = std.time.nanoTimestamp();
        try std.testing.expectEqual(53798080, Struct.countStepPatterns(30));
        std.debug.print("Runtime of {}: {} ms\n", .{ Struct, @as(f64, @floatFromInt(std.time.nanoTimestamp() - start_time)) / 1_000_000_000.0 });
    }
}

test "countStepPatterns with Ordinal" {
    const Ordinal = x5.Ordinal;
    const allocator = std.heap.page_allocator;

    try std.testing.expect((try x5.countStepPatterns(1)).eql(&try Ordinal.fromU32(allocator, 1)));
    try std.testing.expect((try x5.countStepPatterns(36)).eql(&try Ordinal.fromU32(allocator, 2082876103)));
    try std.testing.expect((try x5.countStepPatterns(37)).eql(&try Ordinal.fromU32(allocator, 3831006429)));
}

test "x6 simple solution with assertion" {
    try std.testing.expectEqual(2082876103, x6.countStepPatterns(36));
    // try std.testing.expectEqual(121415, x6.countStepPatterns(37));
}

test "Ordinal basics" {
    const Ordinal = x5.Ordinal;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    var a = try Ordinal.fromU32(alloc, 123);
    defer a.deinit();

    var b = try Ordinal.fromU64(alloc, 0xffffffff_00000002);
    defer b.deinit();

    var c = try a.add(&b);
    defer c.deinit();

    // a == [123]
    // b == [2, 0xffffffff >> 32 == 0x00000001]  (low first, then high)
    // c == a + b
    try std.testing.expect(!a.eql(&b));
    try std.testing.expect(c.words.items.len >= 1);
}
