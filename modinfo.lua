name = "DST Sophisticated Backpacks | 精妙背包 (Upgrade Kit Prototype)"
description = [[五级可升级背包（24/36/48/60/72 存储格），预留 1/2/3/5/7 模块槽。升级方式：先合成升级材料包，再使用在放在地上的上一级背包上。使用原版贴图，功能模块尚未实装。]]
author = "DST Sophisticated Backpacks Project"
version = "0.2.0"
api_version = 10
dst_compatible = true
dont_starve_compatible = false
reign_of_giants_compatible = false
all_clients_require_mod = true
client_only_mod = false
server_filter_tags = { "backpack", "storage", "精妙背包" }
icon_atlas = nil
icon = nil

configuration_options = {
    {
        name = "speed_mult",
        label = "背包移动速度系数 / Speed multiplier",
        hover = "1.0 = 不减速；0.8 = 移速为原本的 80%",
        options = {
            { description = "1.00 (不减速)", data = 1.0 },
            { description = "0.90", data = 0.9 },
            { description = "0.80", data = 0.8 },
        },
        default = 1.0,
    },
}
