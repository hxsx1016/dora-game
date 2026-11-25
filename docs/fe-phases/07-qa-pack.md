# 第三阶段收口施工书：`feature/fe-07-qa-audio-pack`（全量验收、打包与交接）

> **触发口令**：`开工前端收口阶段` / `开工 fe-07`
> **执行属性**：**串行收口（必须在 M2 全功能合流后执行）**
> **推荐分工**：两人联手收口（huihui/GPT 负责全量回归、打包脚本、状态边界与后端对接清单；Gemini 负责视觉/静音/灰度统一审核、音频混音平衡、字库检查与 3 人盲测引导微调）
> **建分支命令**：
> ```sh
> git fetch origin --prune
> git worktree add ~/dev/.wt/2026gamejam/fe-07-qa-audio-pack -b feature/fe-07-qa-audio-pack --no-track origin/feature/fe-dual-route
> ```

---

## 一、收口验收总清单（逐项打勾）

### 1. 代码整洁度与后端零侵入核查
- [ ] `git diff --name-only origin/feature/watch-level-rework...HEAD` 核对：确认 **0 处改动** 落在 `play.ts`、`run.ts`、`rooms.ts`、`depth.ts`、`escort.ts`、`input.ts`、`keys.ts`、`app.ts`、`init.ts` 及对应 `.lua`。
- [ ] `Dora cli build -p . --lang ts` 零错误，所有新增/改动 `.ts` 与 `.lua` 成对更新。
- [ ] `python3 tools/check-repo.py` 与 `git diff --cached --check` 全部通过；无密钥、无 `.agent/.cache/.build/.download/.upload` 泄漏。
- [ ] 引擎自动化回归全绿：`verify-d6`、`verify-d7`、`verify-d8`、`verify-d9`、`verify-integration`、`verify-trial`、`replay-gate`、`replay-d5`。

正式玩法验收从默认剧情入口进入，记录过门血量快照，分别用 79/100 与 80/100 的固定用例核对边界。换房、重试、恢复后仍按锁存路线演出。1439 拍预先按住的输入须释放再按，男主线另测重按 35/36 有效拍、提前松手与暂停。后端接口尚缺时交付标注「排演」的样片，对应正式流程记为「待联调」。

### 2. 字体缺字与分轨混音检查
- [ ] 扫描 `Script/watch/fe/**` 中全部新增中文文案，对照 `assets/font/lxgw-neo-zhisong.ttf` 与 `assets/font/longcang-brush.ttf` 字库 cmap，确保 **0 缺字**。
- [ ] 听感平衡复核：重点核对风台第 18/19/20 声配音在风声、海/水声混合下清晰可辨；空村砖面与铁盆回声一耳可分；博物馆第一声叩响与厨柜第二声叩响衔接自然。

### 3. 静音 / 灰度 / 明朝红线与状态残留检查
- [ ] **静音 + 灰度截图复审**：街道举器与柜边、城门内外同一辆红布板车（红布固定在左端）、空村桌下鞋底与双落点、3×3 线盘三种纹样、北塔空行与满行、军粮棚与第三段工台同尺度对照。
- [ ] **明朝考据体检**：无清式顶戴/辫子、近代军帽、西式板甲、仙侠光效、工业路灯、现代枪械/弹壳/探照灯。
- [ ] **边界状态恢复实测**：
  - 风台中段（如 12s / 18s）按 Esc 暂停再恢复 → 画面、数字、转景进度与声音停在同拍续播；
  - 男主重逢长按 0.3s 中途松开再重新长按满 0.6s → 袖口退回并可正常触发一次重逢；
  - 换弹慢时中段暂停再续 → 慢时与 4 秒作答路径同时冻结并延续；
  - 工台确认制成后读档 / 博物馆中途退出续读 / 切房重试 → 无旧声圈、旧准星、旧红晕残留。

### 4. 默认低引导 3 人盲测记录（对照交付单）
- [ ] 在默认设置（按键辅助 = 关）下，记录 3 位首次试玩者对以下 3 处的表现（先看哪里、先按什么、何处打开暂停操作表）：
  1. 两线风台数满二十后的下一步发现；
  2. 空村桌下观察鞋底与双材质投瓶；
  3. 首次背负 3×3 换弹连线。
- [ ] 若 2 人在同一处误读，优先调整该处构图、角色小动作或环境音，再用新玩家复测并记录。

成品时长按两条路线分别记录，每线至少三位首玩者从叫醒到结局，扣暂停、含实际重试。每线中位目标 85–95 分钟，两线相差目标 5 分钟以内。

### 5. Windows x64 离线包适配与实测
- [ ] 更新 [tools/make-windows-pack.sh](../../tools/make-windows-pack.sh)：确保所有新增资源目录（如 `assets/audio/` 及新增贴图/资源目录）被完整复制到离线包 `dist/` 中。
- [ ] 按 `720p`、`1080p`、`1440p` 及一次非 `16:9` 窗口验证离线包冷启动：中文完整、资源离线可读、缩放后准星与落点偏差 <= 1 美术像素。

---

## 二、写给 tqym 的最终交付物（贴入 GitHub Issue #8）

合入 `feature/fe-dual-route` 并推送后，在 [Issue #8](https://github.com/hxsx1016/dora-game/issues/8) 回复最终交付报告，必须包含：

1. **分支与基线信息**：交付分支 `feature/fe-dual-route`、最新提交号、起点基线 `feature/watch-level-rework@648ff43`、确认零侵入后端文件。
2. **实测环境与回归结果**：系统/分辨率、自动化脚本通过项、Windows 离线包实测结果（未在真机测过的项如实标“Windows 待测”）。
3. **样片与实机录屏索引**（严格区分样片与实机，标注拍号）：
   - 风台 0/6/12/18/24 秒 5 帧同机位图 + 袖口三镜 + 两版风台带声样片；
   - 空村桌下截图与投瓶录屏、背负换弹录屏、军粮棚 vs 工台对照图；
   - 北塔双结局并排对比、双通关水井与博物馆三态演示（未开放 / 完整流程 / 中途续读）；
   - 3 人默认设置盲测记录摘要。
4. **给后端的 `contract.ts` 对接总表**：逐条列出 8 个接口字段的精确类型、触发条件、样例值以及暂停/读档恢复预期，标注输入意图由谁消费、哪个后端事件确认结果，以及录屏采用正式入口还是排演。

---

## 三、最终冻结动作

```sh
git push -u origin feature/fe-07-qa-audio-pack
# 切到 feature/fe-dual-route 工作区合并收口分支并复跑最终验证
git merge --no-ff feature/fe-07-qa-audio-pack
python3 tools/check-repo.py
git push -u origin feature/fe-dual-route
```

推送完成后，通知 tqym 从 `origin/feature/fe-dual-route` 合并前端全部成果。
