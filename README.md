# DST Sophisticated Backpacks v0.2.0 — 背包升级方式修复

> 实验性源码，尚未在 DST 客户端 / 联机服务器中运行验证。**不要用于没有备份的存档。**

## 为什么改成升级包？

原先的 v0.1 把 `piggyback` 或前一级 `sb_backpack_lvN` 直接写成 `Ingredient(...)`。但猪皮包/本 Mod 背包的 `inventoryitem.cangoincontainer = false`，不能进入玩家常规物品栏；DST 的原版配方搜索也不扫描装备本身，导致无法识别旧背包，配方不可正常完成。

v0.2 采用“升级材料包 + 地面旧背包”的两段式设计。**资源消耗总量保持原先定义**，只有交互方式变化。

1. 先在炼金引擎附近合成对应等级 `精妙背包 LVx 升级包`，配方只消耗原先配方中的普通资源。
2. 从身体装备栏卸下猪皮包 / 上一级背包，**将旧背包放到地面**。背包可以装着物品。
3. 从背包外的玩家物品栏取出升级包，使用它点击地上对应等级的旧背包。
4. 服务端验证旧背包 prefab 和装备/掉落状态，生成新背包，将旧包物品逐格搬到新包，再删除旧包和升级包。
5. 新背包留在旧背包原位置，拾取装备即可。

**只允许对放在地上的旧背包升级。**装备在玩家身上或别人的装备栏里时，操作无效。这是第一版的安全边界。

## 合成升级包材料（旧背包另需 1 个作为使用目标）

| 目标 | 升级包的合成材料 | 使用目标 |
| --- | --- | --- |
| LV1 (24 存储 + 1 模块槽) | 蜘蛛丝×10, 绳子×4, 木板×4 | 猪皮包 `piggyback` ×1 |
| LV2 (36+2) | 齿轮×3, 红宝石×2, 蓝宝石×2, 金块×10 | LV1 背包 ×1 |
| LV3 (48+3) | 绝望石×13, 紫宝石×3 | LV2 背包 ×1 |
| LV4 (60+5) | 绿宝石×3, 黄宝石×3, 橙宝石×3, 铥矿×10 | LV3 背包 ×1 |
| LV5 (72+7) | `voidcloth`×6, 纯粹恐惧×6, 亮茄壳×6, 纯粹辉煌×4 | LV4 背包 ×1 |

⚠️ LV3 仍按用户列出的绝望石 3+10 合计 13 个处理。LV5 的“墨荒皮”尚未确认，暂用 `voidcloth` 占位。可通过 `scripts/sb_backpack_defs.lua` 调整。

## 控制台测试

```lua
-- 生成升级材料包
c_give("sb_upgrade_kit_lv1")
c_give("sb_upgrade_kit_lv2")
-- 生成旧背包（用于放到地上尝试升级）
c_give("piggyback")
c_give("sb_backpack_lv1")
```

优先在新世界测试：

- 无猪皮包时，是否仍能合成 LV1 升级包（应该可以）。
- 猪皮包放地上后，携带 LV1 升级包点击猪皮包能否出现使用动作并成功升级。
- LV1 背包放地上后，携带 LV2 升级包是否可成功升级；错误等级背包不可升级。
- 包内存放不同槽位的食物、材料、装备后，升级前后数量和耐久是否保存。
- 中断升级、多人靠近同一个包操作、退出重进存档能否正常处理。
- 尝试用升级包对玩家装备栏内的背包操作，应该被拒绝。

## 目前的已知限制

- **未做实机验证**。尤其需要验证 `USEITEMON` 的客户端动作显现、服务器执行、多玩家下同步是否正确。
- 升级包暂时借用猪皮包贴图，可能与背包本体外观相似；后续增加专属图标。
- 大容量容器 UI 仍借用猪皮包 2×6 视觉背景，位置可能不美观、遮挡；后续需要专用布局。
- 模块槽仍为预留，目前未实现具体功能模块。
- 背包本体仍不能放入物品栏（保持原版背包风格）。

## Mac 本地安装

解压 ZIP 后，把 `DST_Sophisticated_Backpacks_v0_2` 文件夹复制到：

```
~/Library/Application Support/Steam/steamapps/common/Don't Starve Together/dontstarve_steam.app/Contents/mods/
```

测试前关闭 v0.1，防止重复注册同名 prefab。新版本与 v0.1 背包 prefab 名称相同，但升级配方和流程不同。

## 原版代码依据

- `scripts/components/builder.lua`：`Builder:HasIngredients`、`Builder:GetIngredients`。
- `scripts/components/inventory.lua`：`Inventory:Has`、`Inventory:GetCraftingIngredient`，不会从自身装备栏选用背包本体做材料。
- `scripts/components/useabletargeteditem.lua`：`SetOnUseFn`、`StartUsingItem`。
- `scripts/componentactions.lua`：`USEITEM` 上的 `useabletargeteditem` 动作识别。
- `scripts/actions.lua`：`ACTIONS.USEITEMON.fn`。

游戏源码镜像：https://github.com/taichunmin/dont-starve-together-game-scripts
