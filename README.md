# 月下山谷

这是一个使用 Dora SSR 和 TypeScript 编写的简单场景示例。

## 运行

1. 安装 Dora SSR，并打开项目文件夹。
2. 使用 Dora SSR 构建 `init.ts`，然后运行项目。
3. 按 `Esc` 打开退出菜单。

入口源码是 `init.ts`。`init.lua` 是由它生成的运行文件；修改场景时请以 `init.ts` 为准，重新构建后再一并提交生成的 `init.lua`。

## 参与修改

先 Fork 本仓库，再克隆你自己的 Fork：

```sh
git clone https://github.com/<你的用户名>/dora-game.git
cd dora-game
git switch -c feature/my-change
```

完成修改并在 Dora SSR 中构建、运行验证后，提交并推送分支：

```sh
git add init.ts init.lua
git commit -m "描述这次修改"
git push -u origin feature/my-change
```

然后在 GitHub 上向本仓库发起 Pull Request。也可以直接邀请协作者，并让对方在自己的分支上工作、通过 Pull Request 合并。
