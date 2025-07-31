
const Cursor = @import("Cursor.zig");
const std = @import("std");

pub const Tag = enum {
    invalid,
    eof,
    ident,
    space,
    newline,
    eq1,
    eq2,
    numberic,
    semicolon,

    word_and,
    word_break,
    word_const,
    word_or,
    word_var,


};


pub const Token = struct {
    tag: Tag,
    len: u32,


    pub fn new(tag: Tag, len: u32) Token {
        return Token{ .tag = tag, .len = len };
    }
}; // Token

pub const State = enum {
    start,
    illegal,
    identifier,
    numberic,
    startwith_at,
};

const keywords = std.StaticStringMap(Tag).initComptime(.{
    .{"and", .word_and},
    .{"break", .word_break},
    .{"const", .word_const},
    .{"or", .word_or},
    .{"var", .word_var},
});

pub fn getKeyword(bytes: []const u8) ?Tag {
    return keywords.get(bytes);
}

pub fn is_ident_head(c: u8) bool {
    return std.ascii.isAlphabetic(c) or c == '_';
}



pub export fn tokenize(self: *Cursor) Token {
    self.recalculateLen();

    state: switch(State.start) {
        .start => switch(self.peek(0).?) {
            0 => if (self.index == self.chars.len) {
                return .{ .tag = .eof, .len = 0 };
            } else {
                self.index += 1;
                const len = self.calculateLen();
                return .{ .tag = .invalid, .len = len };
            },
            ' ' => {

                self.index += 1;
                while (self.peek(0).? == ' ') {
                    self.index += 1;
                }
                const len = self.calculateLen();
                return .{ .tag = .space, .len = len };
            },
            '\n' => {
                self.index += 1;
                while (self.peek(0).? == '\n') {
                    self.index += 1;
                }
                const len = self.calculateLen();
                return .{ .tag = .newline, .len = len };
            },
            '\t', '\r' => {
                self.index += 1;
                continue :state .start;
            },
            'a'...'z', 'A'...'Z', '_' => {
                const beg = self.index;
                self.index += 1;

                self.moveWhile(is_ident_head);
                const len = self.calculateLen();
                const lexeme = self.chars[beg..self.index];
                const tag = getKeyword(lexeme) orelse .ident;
                return .{.tag = tag, .len = len};
            },
            '0'...'9' => {
                self.index += 1;
                self.moveWhile(std.ascii.isDigit);
                return .{
                    .tag = .numberic, .len = self.calculateLen()
                };
            },
            '=' => {
                self.index += 1;
                switch (self.peek(1).?) {
                    '=' => {
                        self.index += 1;
                        return .{.tag = .eq2, .len = 2};
                    },
                    else => return .{.tag = .eq1, .len = 1}
                }
            },
            ';' => {
                self.index += 1;
                return .{.tag = .semicolon, .len=1};
            },
            else => {
                self.index += 1;
                self.moveUntil('\n');
                const len = self.calculateLen();
                return .{ .tag = .invalid, .len = len };
            },
        },
        else => unreachable,
    }
}


