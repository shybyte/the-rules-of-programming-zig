const std = @import("std");

pub const Card = struct {
    m_ordinal: i32,
};

pub const x1 = struct {
    pub fn shuffleOnce(allocator: std.mem.Allocator, cards: []const Card) ![]Card {
        var shuffled = try std.ArrayList(Card).initCapacity(allocator, cards.len);
        defer shuffled.deinit(allocator);

        const split_index = cards.len / 2;
        var left_index: usize = 0;
        var right_index: usize = split_index;

        const random = std.crypto.random;

        while (true) {
            if (left_index >= split_index) {
                // take all remaining right side
                while (right_index < cards.len) : (right_index += 1) {
                    shuffled.appendAssumeCapacity(cards[right_index]);
                }
                break;
            } else if (right_index >= cards.len) {
                // take all remaining left side
                while (left_index < split_index) : (left_index += 1) {
                    shuffled.appendAssumeCapacity(cards[left_index]);
                }
                break;
            } else if (random.int(u1) == 1) {
                shuffled.appendAssumeCapacity(cards[right_index]);
                right_index += 1;
            } else {
                shuffled.appendAssumeCapacity(cards[left_index]);
                left_index += 1;
            }
        }

        return try shuffled.toOwnedSlice(allocator);
    }

    pub fn shuffle(allocator: std.mem.Allocator, cards: []const Card) ![]Card {
        var shuffled = try allocator.dupe(Card, cards);
        errdefer allocator.free(shuffled);

        var i: usize = 0;
        while (i < 7) : (i += 1) {
            const tmp = try shuffleOnce(allocator, shuffled);
            allocator.free(shuffled);
            shuffled = tmp;
        }

        return shuffled;
    }
};

pub const x2 = struct {
    pub fn shuffle(allocator: std.mem.Allocator, cards: []const Card) ![]Card {
        // Copy input cards into a new owned slice
        var shuffled = try allocator.dupe(Card, cards);
        errdefer allocator.free(shuffled);

        const random = std.crypto.random;

        // Fisher–Yates shuffle
        var card_index: usize = shuffled.len;
        while (card_index > 0) {
            card_index -= 1;

            const swap_index = random.uintLessThan(usize, card_index + 1);

            // const tmp = shuffled[card_index];
            // shuffled[card_index] = shuffled[swap_index];
            // shuffled[swap_index] = tmp;
            std.mem.swap(Card, &shuffled[card_index], &shuffled[swap_index]);
        }

        return shuffled;
    }
};

pub const x3 = struct {
    pub fn copyCard(
        destination: *std.ArrayList(Card),
        source: []const Card,
        source_index: *usize,
    ) !void {
        try destination.append(source[source_index.*]);
        source_index.* += 1;
    }

    pub fn copyCardsAssumeCapacity(
        destination: *std.ArrayList(Card),
        source: []const Card,
        source_index: *usize,
        end_index: usize,
    ) void {
        while (source_index.* < end_index) {
            destination.appendAssumeCapacity(source[source_index.*]);
            source_index.* += 1;
        }
    }

    pub fn shuffleOnce(allocator: std.mem.Allocator, cards: []const Card) ![]Card {
        var shuffled = try std.ArrayList(Card).initCapacity(allocator, cards.len);
        defer shuffled.deinit(allocator);

        const split_index = cards.len / 2;
        var left_index: usize = 0;
        var right_index: usize = split_index;

        const random = std.crypto.random;

        while (true) {
            if (left_index >= split_index) {
                copyCardsAssumeCapacity(&shuffled, cards, &right_index, cards.len);
                break;
            } else if (right_index >= cards.len) {
                copyCardsAssumeCapacity(&shuffled, cards, &left_index, split_index);
                break;
            } else if (random.int(u1) == 1) {
                shuffled.appendAssumeCapacity(cards[right_index]);
                right_index += 1;
            } else {
                shuffled.appendAssumeCapacity(cards[left_index]);
                left_index += 1;
            }
        }

        return try shuffled.toOwnedSlice(allocator);
    }

    pub fn shuffle(allocator: std.mem.Allocator, cards: []const Card) ![]Card {
        var shuffled = try allocator.dupe(Card, cards);
        errdefer allocator.free(shuffled);

        var i: usize = 0;
        while (i < 7) : (i += 1) {
            const tmp = try shuffleOnce(allocator, shuffled);
            allocator.free(shuffled);
            shuffled = tmp;
        }

        return shuffled;
    }
};

pub const Deck = struct {
    m_cards: std.ArrayList(Card),

    pub fn init(allocator: std.mem.Allocator, count: usize) !Deck {
        var list = try std.ArrayList(Card).initCapacity(allocator, count);

        for (0..count) |i| {
            list.appendAssumeCapacity(Card{ .m_ordinal = @as(i32, @intCast(i)) });
        }

        return Deck{ .m_cards = list };
    }

    pub fn deinit(self: *Deck, allocator: std.mem.Allocator) void {
        self.m_cards.deinit(allocator);
    }
};

pub fn getSum(cards: []const Card) i32 {
    var sum: i32 = 0;
    for (cards) |card| {
        sum += card.m_ordinal;
    }
    return sum;
}

test "Iterate over all structs and test shuffle" {
    const structs = [_]type{ x1, x2, x3 };
    inline for (structs) |Struct| {
        var allocator = std.testing.allocator;

        for (0..5) |_| {
            var deck = try Deck.init(allocator, 20);
            defer deck.deinit(allocator);

            const shuffled = try Struct.shuffle(allocator, deck.m_cards.items);
            defer allocator.free(shuffled);

            try std.testing.expectEqual(190, getSum(shuffled));
            // std.debug.print("{any}", .{shuffled});
        }
    }
}
