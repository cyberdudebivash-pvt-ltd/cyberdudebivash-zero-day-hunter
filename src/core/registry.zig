const Hunter = @import("interface.zig").Hunter;

const memory = @import("../hunters/memory.zig");
const syscall = @import("../hunters/syscall.zig");
const behavioral = @import("../hunters/behavioral.zig");
const exposure = @import("../hunters/code_exposure.zig");

const rust_malware = @import("../hunters/rust_malware.zig");
const ai_model_backdoor = @import("../hunters/ai_model_backdoor.zig");
const cloud_escape = @import("../hunters/cloud_escape.zig");

pub const hunters = [_]Hunter{
    memory.plugin,
    syscall.plugin,
    behavioral.plugin,
    exposure.plugin,
    rust_malware.plugin,
    ai_model_backdoor.plugin,
    cloud_escape.plugin,
};