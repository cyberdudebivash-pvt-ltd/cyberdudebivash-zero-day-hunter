const std = @import("std");

pub const CustomerPlan = struct {
    name: []const u8,
    api_key: []const u8,
    daily_quota: usize,
};

pub const UsageRecord = struct {
    api_key: []const u8,
    requests: usize,
};

var usage_table = std.StringHashMap(usize).init(std.heap.page_allocator);

pub fn registerRequest(api_key: []const u8) void {

    if (usage_table.getPtr(api_key)) |count| {

        count.* += 1;

    } else {

        usage_table.put(api_key, 1) catch {};
    }
}

pub fn checkQuota(api_key: []const u8) bool {

    const plans = plansDB();

    for (plans) |p| {

        if (std.mem.eql(u8, p.api_key, api_key)) {

            const used = usage_table.get(api_key) orelse 0;

            if (used >= p.daily_quota) {

                std.debug.print(
                    "⚠️ API quota exceeded for {s}\n",
                    .{p.name},
                );

                return false;
            }

            return true;
        }
    }

    return false;
}

pub fn reportUsage() void {

    std.debug.print(
        "\n📊 Sentinel APEX API Usage Report\n",
        .{},
    );

    var it = usage_table.iterator();

    while (it.next()) |entry| {

        std.debug.print(
            "API Key: {s} | Requests: {d}\n",
            .{ entry.key_ptr.*, entry.value_ptr.* },
        );
    }
}

fn plansDB() []const CustomerPlan {

    return &[_]CustomerPlan{

        .{
            .name = "Enterprise SOC",
            .api_key = "CDB_ENTERPRISE_KEY_001",
            .daily_quota = 100000,
        },

        .{
            .name = "SOC Team",
            .api_key = "CDB_SOC_KEY_002",
            .daily_quota = 50000,
        },

        .{
            .name = "Security Research",
            .api_key = "CDB_RESEARCH_KEY_003",
            .daily_quota = 10000,
        },
    };
}