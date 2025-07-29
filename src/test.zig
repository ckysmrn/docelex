const Cursor = @import("Cursor.zig");
const std = @import("std");
const code = 
    \\let a = 1;
    \\let b = 2;
    ;


pub fn is_ident_head(c: u8) bool {
    return std.ascii.isAlphabetic(c) or c == '_';
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


