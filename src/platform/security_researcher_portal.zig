const std = @import("std");

pub const Submission = struct {
    researcher: []const u8,
    title: []const u8,
    description: []const u8,
};

var allocator = std.heap.page_allocator;
var submissions = std.ArrayList(Submission).init(allocator);

pub fn submit(researcher: []const u8, title: []const u8, desc: []const u8) !void {

    try submissions.append(.{
        .researcher = researcher,
        .title = title,
        .description = desc,
    });

    std.debug.print(
        "🧑‍🔬 Research submission received: {s} by {s}\n",
        .{ title, researcher },
    );
}

pub fn review() void {

    std.debug.print(
        "\n🔍 Researcher Submissions\n",
        .{},
    );

    for (submissions.items) |s| {

        std.debug.print(
            "Researcher: {s}\nTitle: {s}\nDescription: {s}\n\n",
            .{ s.researcher, s.title, s.description },
        );
    }
}