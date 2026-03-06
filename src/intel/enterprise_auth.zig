const std = @import("std");

pub const ApiKey = struct {
    key: []const u8,
    role: []const u8,
    rate_limit: usize,
};

pub fn authenticate(request: []const u8) bool {

    const keys = apiKeys();

    for (keys) |k| {

        if (std.mem.containsAtLeast(u8, request, 1, k.key)) {

            std.debug.print(
                "🔐 API key authenticated (role: {s})\n",
                .{k.role},
            );

            return true;
        }
    }

    std.debug.print(
        "🚫 API authentication failed\n",
        .{},
    );

    return false;
}

fn apiKeys() []const ApiKey {

    return &[_]ApiKey{

        .{
            .key = "CDB_ENTERPRISE_KEY_001",
            .role = "enterprise",
            .rate_limit = 10000,
        },

        .{
            .key = "CDB_SOC_KEY_002",
            .role = "soc",
            .rate_limit = 5000,
        },

        .{
            .key = "CDB_RESEARCH_KEY_003",
            .role = "research",
            .rate_limit = 2000,
        },
    };
}

pub fn checkRateLimit(role: []const u8, requests: usize) bool {

    const keys = apiKeys();

    for (keys) |k| {

        if (std.mem.eql(u8, role, k.role)) {

            if (requests > k.rate_limit) {

                std.debug.print(
                    "⚠️ Rate limit exceeded for role {s}\n",
                    .{role},
                );

                return false;
            }

            return true;
        }
    }

    return false;
}