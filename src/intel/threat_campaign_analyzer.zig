const std = @import("std");

const Campaign = @import("threat_campaign_types.zig").ThreatCampaign;

pub const CampaignSummary = struct {
    total_campaigns: u32,
    critical_campaigns: u32,
};

pub fn analyze(campaigns: []Campaign) CampaignSummary {

    var critical: u32 = 0;

    for (campaigns) |c| {

        if (std.mem.eql(u8, c.threat_level, "critical"))
            critical += 1;
    }

    return CampaignSummary{
        .total_campaigns = @intCast(campaigns.len),
        .critical_campaigns = critical,
    };
}