
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
