const std = @import("std");

pub fn listNodes() void {

    std.log.info(
        "Active CyberDudeBivash Hunter Grid nodes",
        .{},
    );

    std.log.info("APAC Node Online", .{});
    std.log.info("EU Node Online", .{});
    std.log.info("US Node Online", .{});
}