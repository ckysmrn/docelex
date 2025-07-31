const Cursor = @import("Cursor.zig");
const tknzr = @import("tknzr.zig");
const std = @import("std");

const Token = tknzr.Token;
const State = tknzr.State;
const Tag = tknzr.Tag;

const code =
    \\let abc = 5;
    \\let    xyz    =        abc;
    ;

fn println(comptime fmt: [:0]const u8, args: anytype) void {
    std.debug.print(fmt ++ "\n", args);
}

pub fn is_ident_head(c: u8) bool {
    return std.ascii.isAlphabetic(c) or c == '_';
}



fn tokenize(self: *Cursor) Token {
    println("before, pos: {d}", .{self.calculateLen()});
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
                println("try detect keywords: {s}", .{lexeme});
                const tag = tknzr.getKeyword(lexeme) orelse .ident;
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


test "tokenize" {
    var cursor = Cursor.new(code);
    while (true) {
        const token = tokenize(&cursor);
        if (token.tag == .eof) break;
        const beg = cursor.checkpoint;

        const lexeme = cursor.chars[beg..beg+token.len];
        println("tag: {?}, len: {d}, index: {d}, checkpoint: {d}, lexeme: {s}", .{token.tag, token.len, cursor.index, cursor.checkpoint, lexeme});
    }
}

test "Cursor::basic " {
    var cursor = Cursor.new(code);
    println("checkpoint: {d}\n", .{cursor.checkpoint});
    println("pos: {d}\n", .{cursor.calculateLen()});
    cursor.moveWhile(is_ident_head);

    println("pos: {d}\n", .{cursor.calculateLen()});
    cursor.recalculateLen();
    println("checkpoint: {d}\n", .{cursor.checkpoint});
}

test "tokenize single " {
    var cursor = Cursor.new(code);
    println("checkpoint: {d}\n", .{cursor.checkpoint});
    const token = tokenize(&cursor);
    println("tag: {?}, len: {d}", .{token.tag, token.len});

}
