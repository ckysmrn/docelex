chars: [:0]const u8,
index: usize,
len_remaining: usize,

const Self = @This();
pub const WhilePredicate = fn(u8) bool;

pub fn new(chars: [:0]const u8) Self {
    return .{
        .chars = chars,
        .index = 0,
        .len_remaining = chars.len
    };
}

pub inline fn peek(self: Self, comptime n: u32) ?u8 {
    const i = self.index + n;
    if (i > self.chars.len) return null;
    return self.chars[i];
}

pub inline fn first(self: Self) u8 {
    return self.peek(1).?;
}

pub inline fn second(self: Self) u8 {
    return self.peek(2).?;
}

pub fn bump(self: *Self) ?u8 {
    return if (self.index > self.chars.len) null else self.chars[self.index];
}

pub inline fn isEnd(self: Self) bool {
    return self.index == self.chars.len;
}

pub inline fn getTokenLen(self: Self) u32 {
    return @intCast(self.len_remaining - (self.chars.len - self.index));
}

pub inline fn resetTokenLen(self: *Self) void {
    self.len_remaining = (self.chars.len - self.index);
}

pub fn moveWhile(self: *Self, comptime f: WhilePredicate) void {
    while(f(self.peek(0).?) and !self.isEnd()) {
        self.index += 1;
    }
}

pub fn moveUntil(self: *Self, c: u8) void {
    while(self.peek(0) != c) {
        self.index += 1;
    }
}
