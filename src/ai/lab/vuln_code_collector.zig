const std = @import("std");
const Types = @import("vuln_lab_types.zig");

const CodeSample = Types.CodeSample;

pub fn collect(
    allocator: std.mem.Allocator,
) ![]CodeSample {

    var samples = std.ArrayList(CodeSample).init(allocator);

    try samples.append(.{
        .project = "example-project",
        .file = "auth_handler.c",
    });

    try samples.append(.{
        .project = "example-project",
        .file = "input_parser.c",
    });

    return samples.toOwnedSlice();
}