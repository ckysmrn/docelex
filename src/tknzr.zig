
const Cursor = @import("Cursor.zig");
const std = @import("std");

pub const Tag = enum {
    invalid,
    eof,
    ident,
    space,
    newline,
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
    invalid,
    ident,
};
