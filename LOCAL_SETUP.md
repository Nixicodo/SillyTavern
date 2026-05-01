# 本地安装说明

- 本体目录：`D:/SillyTavern`
- 默认用户目录：`data/default-user`
- 默认模型：`deepseek-v4-flash`
- 已安装第三方扩展：`JS-Slash-Runner`、`SillyTavern-LATheme`、`SillyTavern-MoonlitEchoesTheme`、`SillyTavern-Not-A-Discord-Theme`
- 已导入主题：`Celestial Macaron`、`Anime Sakura Dream`、`Kawaii Mint Night`、`Moonlit Neko Cafe`

## 一键重建

如果后续想重建本地配置，可以执行：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\local-setup.ps1 -DeepSeekApiKey '你的-key' -InstallExtensions
```

## 启动

1. 在 `D:/SillyTavern` 执行：`npm start`
2. 浏览器打开：`http://127.0.0.1:8000`
3. 在 API 连接中选择 `DeepSeek`
4. 模型应默认为 `deepseek-v4-flash`
5. 在扩展页启用需要的第三方扩展
6. 在界面主题里切换喜欢的主题

## 参考来源

- 官方安装文档：https://docs.sillytavern.app/installation/windows/
- 类脑 Wiki：https://wiki.xn--35zx7g.org/zh/home
- 酒馆助手文档：https://n0vi028.github.io/JS-Slash-Runner-Doc/
