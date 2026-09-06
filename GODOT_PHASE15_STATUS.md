# GUT CREW — Phase 15 状态

日期：2026-09-01  
阶段：参考 INSIDE THE CAT 的器官世界小关卡

## 正式备份

`BACKUPS/PHASE15_ORGAN_WORLD_20260901_134631`

## 已实装

新增 `scripts/organ_world_factory.gd`，把猫胃大地图扩展为四个可到达的小关卡：

- Hairball Forest：毛发桥、毛球茧塔、隐藏亮点
- Intestinal Maze：肠道环、挤压门、黏液珍珠
- Lung Chamber：透明肺泡、气泡弹跳平台
- Nerve Highway：神经节点、电弧与高速路线

新增地图视觉部件：149。  
新增场景机关：5。  
新增怪物变种：8。  
游戏开局敌人总数：18。

## 场景机关

- Grooming Turbine：控制毛球森林怪物
- Peristalsis Drum：肠道收缩、伤害和击退
- Alveoli Bellows：高空弹射、短时加速
- Nerve Fast Travel Relay：传送至毛球森林
- Forest Synapse Relay：返回神经高速路

机关首次使用奖励 6 BioCoins，之后进入冷却。

## 怪物区别

- Fur Mite / Nest Roller：缠住玩家移动
- Gut Gnawer / Bile Bouncer：造成胆汁侵蚀追加伤害
- Bubble Leech / Pollen Puff：命中后把玩家弹飞
- Static Tick / Axon Chewer：扰乱 Q/E 技能冷却

## 文件与验证

- `tests/phase15_organ_world_smoke.gd`
- `tests/phase15_capture.gd`
- `QA_GODOT_PHASE15.bat`
- `GUT_CREW_ORGAN_WORLD_LEVEL_DESIGN.md`

验证结果：

- Godot 4.7.2 parse：0 error
- `GODOT_PHASE15_ORGAN_WORLD_OK zones=4 parts=149 props=5 enemies=18`
- `GODOT_PHASE3_FULL_ROUND_OK clues=3 phase=win`
- `QA_GODOT_PHASE15_OK`
