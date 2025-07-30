const Cursor = @import("Cursor.zig");
const tknzr = @import("tknzr.zig");
const std = @import("std");

const Token = tknzr.Token;
const State = tknzr.State;
const Tag = tknzr.Tag;

const code = "let a = 1;";


pub fn is_ident_head(c: u8) bool {
    return std.ascii.isAlphabetic(c) or c == '_';
}


fn tokenize(self: *Cursor) Token {

    state: switch(State.start) {
        .start => switch(self.peek(0).?) {
            0 => if (self.index == self.chars.len) {
                return .{ .tag = .eof, .len = 0 };
            } else {
                const len = self.getTokenLen();
                self.resetTokenLen();
                self.index += 1;
                return .{ .tag = .invalid, .len = len };
            },
            ' ' => {
                
                if (self.first() != ' ') {
                    const len = self.getTokenLen();
                    self.resetTokenLen();
                    self.index += 1;
                    return .{ .tag = .space, .len = len };
                }
                self.index += 1;
                continue :state .start;
            },
            '\n' => {
                if (self.first() == '\n') {
                   const len = self.getTokenLen();
                   self.resetTokenLen();
                   self.index += 1;
                   return .{ .tag = .newline, .len = len };
                }
                self.index += 1;
                continue :state .start;
            },
            '\t', '\r' => {
                self.index += 1;
                continue :state .start;
            },
            else => {
                self.index += 1;
                return .{ .tag = .invalid, .len = self.getTokenLen() };
            },
        },
        else => unreachable,
    }
}


test "Cursor::basic" {
    var cursor = Cursor.new(code);
    std.debug.print("len_remaining: {d}\n", .{cursor.len_remaining});
    std.debug.print("pos: {d}\n", .{cursor.getTokenLen()});
    cursor.moveWhile(is_ident_head);
    
    std.debug.print("pos: {d}\n", .{cursor.getTokenLen()});
    cursor.resetTokenLen();
    std.debug.print("len_remaining: {d}\n", .{cursor.len_remaining});
}


test "tokenize" {
    var cursor = Cursor.new(code);
    while (true) {
        const token = tokenize(&cursor);
        if (token.tag == .eof) break;
        std.debug.print("tag: {?}, len: {d}, index: {d}\n", .{token.tag, token.len, cursor.index});
    }
}
