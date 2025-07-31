
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
    semicolon,
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
