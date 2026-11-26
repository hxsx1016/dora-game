# `assets/audio/combat/` 音效清册与来源说明

本目录全部 WAV 音效为 FE-02（`feature/fe-02-reload-carry-craft`）离线程序化合成的 22050Hz 单声道 16-bit PCM 素材，无第三方版权限制（项目原创、可用于离线交付包与后续混音替换）。

| 文件 | 逻辑音轨 | 时长 | 用途与触发点 |
| --- | --- | --- | --- |
| `carry_start.wav` | `sfx` | 0.34s | 高石阶蹲背背起小满（`carryStart` / 排演切入背负） |
| `reload_open.wav` | `sfx` | 0.24s | 小满触盘进入 3×3 慢时换弹（`reloadOpen`） |
| `reload_node.wav` | `sfx` | 0.14s | 玩家实际连入合法相邻节点时响起（`reloadNode`） |
| `reload_invalid.wav` | `sfx` | 0.22s | 跳格、重复点或中途松手清回重画（`reloadInvalid`） |
| `reload_solved.wav` | `sfx` | 0.28s | 通用枪机复位咔嗒声（后端 `reloadSolved` 派发） |
| `reload_solved_knockback.wav` | `sfx` | 0.30s | 推退（`knockback`）路径结算气冲复位声 |
| `reload_solved_echo.wav` | `sfx` | 0.46s | 铃纹（`echo`）路径结算明式小铜铃余振声 |
| `reload_solved_light.wav` | `sfx` | 0.36s | 灯纹（`light`）路径结算火石轻燃声 |
| `reload_timeout.wav` | `sfx` | 0.26s | 4 秒作答超时收为普通装填（`reloadTimeout`） |
| `craft_done.wav` | `sfx` | 0.44s | 第三段工台确认制成落器与试握声（`craftDone`） |
| `craft_insufficient.wav` | `sfx` | 0.18s | 工台库存不足高亮缺项时的空木轻叩反馈 |
| `shot.wav` | `sfx` | 0.42s | 周戍与敌兵明式火铳击发黑火药脆响与街巷低频余震（`shotResolved`） |
| `cover_block.wav` | `sfx` | 0.24s | 铅丸击中木柜/石垒掩体的闷击与碎屑弹响（`coverBlocked`） |
| `actor_hit.wav` | `sfx` | 0.30s | 人物或敌兵受击时的低频沉闷撞击声（`actorHit` / `gateFailed`） |
