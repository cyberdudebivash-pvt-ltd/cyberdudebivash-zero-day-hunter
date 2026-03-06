const std = @import("std");
const Types = @import("vuln_lab_types.zig");

const VulnPattern = Types.VulnPattern;

pub fn patterns() []const VulnPattern {

    return &[_]VulnPattern{
        .{
            .pattern = "unsafe_strcpy",
            .category = "memory_corruption",
        },
        .{
            .pattern = "unsanitized_input",
            .category = "injection",
        },
    };
}