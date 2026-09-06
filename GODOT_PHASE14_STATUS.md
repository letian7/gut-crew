# GUT CREW — Phase 14 状态

日期：2026-09-01  
阶段：胃部解剖环境与角色 V5 建模

## 正式备份

`BACKUPS/PHASE14_ANATOMY_CHARACTERS_20260901_130955`

## 胃部环境

新增 `scripts/stomach_anatomy_factory.gd`，作为不修改玩法碰撞的视觉层：

- 5 个可辨认区域：贲门、胃底、胃体、胃窦、幽门
- 30 条地面黏膜褶皱与 18 条胃壁褶皱
- 28 个胃小凹及腺体微光
- 黏膜血管、分支、黏液膜、黏液拉丝和分泌液
- 8 条蠕动收缩带
- 危险度会强化褶皱起伏与蠕动
- 湿润高光材质保持手工黏土感，避免写实血腥

旧 Map V4 的巨大球形褶皱已压扁并贴合胃壳，中央路线与高地碰撞未改。

## 角色 V5

新增 `scripts/character_detail_factory.gd`，接入原 `character_factory.gd`：

- 鼻部、下唇、眼睑、眼部高光与指压纹
- 手掌、拇指、独立手指
- 鞋头、鞋底及黏土鞋底压纹
- 胸部接缝、护肘与手捏凹痕
- Spark：胸前导电螺栓、耳侧线圈
- Kaka：背部脊骨、前臂骨甲
- Bubble：体内悬浮血细胞、表面水滴
- Shroom：菌盖放射菌褶、菌盖滴坠

零件数：Spark 73、Kaka 81、Bubble 71、Shroom 80。

## 验证

新增：

- `tests/phase14_anatomy_character_smoke.gd`
- `tests/phase14_capture.gd`
- `QA_GODOT_PHASE14.bat`

结果：

- Godot 4.7.2 editor parse：0 error
- `GODOT_PHASE14_ANATOMY_CHARACTER_OK anatomy=220 counts=[73, 81, 71, 80] zones=5`
- `GODOT_PHASE3_FULL_ROUND_OK clues=3 phase=win`
- `QA_GODOT_PHASE14_OK`

截图位于 `GUT_CREW_QA_SHOTS/phase14_*.png`。
