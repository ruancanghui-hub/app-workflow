# 松息本地可点击原型

打开 `index.html` 即可审阅。推荐在本目录运行：

```bash
python3 -m http.server 4173
```

然后访问 `http://127.0.0.1:4173/`。

验证重点：

1. 四个根 Tab 使用同一个 `root-tabbar` DOM，只切换激活状态。
2. 从“声音 → 松林细雨 → 开始睡眠 → 结束并查看报告”可走完 MVP 闭环。
3. 右上状态选择器可审阅加载、空、错误、权限拒绝和中断恢复文案。
4. 原型为本地依赖零实现；CDB/Figma 插件可用后再执行 preflight、preview 与 send。

