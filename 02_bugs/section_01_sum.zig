const std = @import("std");

pub const x1 = struct {
    /// Sum all elements in `values`.
    pub fn sumVector(values: []const i32) i32 {
        var sum: i32 = 0;
        for (values) |v| {
            sum += v;
        }
        return sum;
    }
};

pub const x2 = struct {
    /// Reduce `values` using `reduceFn`, starting from `initial_value`.
    pub fn reduce(initial_value: i32, reduceFn: fn (i32, i32) i32, values: []const i32) i32 {
        var reduced = initial_value;
        for (values) |v| {
            reduced = reduceFn(reduced, v);
        }
        return reduced;
    }

    pub fn sum(a: i32, b: i32) i32 {
        return a + b;
    }

    pub fn example() i32 {
        const values = [_]i32{ 1, 2, 3, 4 };
        return reduce(0, sum, &values);
    }
};

// -------------------- Tests --------------------

test "x1.sumVector sums elements" {
    const values = [_]i32{ 1, 2, 3, 4 };
    try std.testing.expectEqual(@as(i32, 10), x1.sumVector(&values));
}

test "x1.sumVector on empty slice is zero" {
    const empty: []const i32 = &[_]i32{};
    try std.testing.expectEqual(@as(i32, 0), x1.sumVector(empty));
}

test "x2.reduce with x2.sum" {
    const values = [_]i32{ 1, 2, 3, 4 };
    try std.testing.expectEqual(@as(i32, 10), x2.reduce(0, x2.sum, values[0..]));
}

test "x2.reduce respects initial value on empty input" {
    const empty: []const i32 = &[_]i32{};
    try std.testing.expectEqual(@as(i32, 5), x2.reduce(5, x2.sum, empty));
}

test "x2.example returns 10" {
    try std.testing.expectEqual(@as(i32, 10), x2.example());
}
