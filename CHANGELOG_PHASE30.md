# Phase 30 — 第一视角、受击反馈与物品栏

## 本阶段结果

- 正式游玩默认进入第一视角，第三视角仍可按 `V` 切换。
- 新增第一视角黏土双手与四职业专属工具模型。
- 工具使用 12fps 定格式摆动，并响应移动、施法与受击。
- 受击震动按伤害量分级，大伤害拥有更强位移、倾斜与横向抖动。
- 新增全屏红色边缘冲击、伤害方向弧和低血量呼吸红边。
- 敌人普通攻击与巨型猫 Boss 攻击统一走同一套受击反馈。
- `Tab` 打开/关闭现场物品栏；打开时冻结玩家和现场逻辑。
- 物品栏显示 BioCoins、寻宝袋、估值、临时道具计时、职业强化与商品说明。
- 可从物品栏直接出售寻宝袋；现有 BODY MART 即买即用规则保持兼容。
- 帮助栏更新为 `Tab inventory` 与 `V view`。

## 验证

- Godot 4.7.2 headless 编辑器解析：0 error。
- 专项 smoke：
  `GODOT_PHASE30_FIRSTPERSON_INVENTORY_FEEDBACK_OK default=first_person tools=4 inventory=tab trauma=scaled red_edges=active`
- 完整 Phase 2–30 回归：
  `QA_GODOT_PHASE30_OK`
