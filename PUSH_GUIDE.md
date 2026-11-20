# 推送到 GitHub 用 CI 自动出 APK

本工程已内置 GitHub Actions 工作流。按下面几步操作即可拿到 APK。

## 1. 新建 GitHub 仓库

在 github.com 新建一个空仓库（不要勾选任何初始化选项），记下仓库地址。

## 2. 本机推送（任选其一）

### 方式一：命令行（装 git 即可，无需装 Flutter）
```bash
cd /root/projects/project_APP
git init
git add .
git commit -m "feat: 干净的本地阅读器"
git branch -M main
git remote add origin <你的仓库地址>
git push -u origin main
```

### 方式二：直接在 GitHub 网页上传
把工程里的文件拖到仓库页上传即可（`.github/workflows/build.yml` 记得带上）。

## 3. 触发构建

推送到 main 分支会自动触发。也可以到仓库的 **Actions** 标签页手动点 **Run workflow**。

## 4. 下载 APK

构建成功后，打开 **Actions** → 最新一次构建 → 底部 **Artifacts**，
下载 `pure-reader-release`，里面的 `.apk` 装到 Android 手机即可。

> 提示：Android 安装非商店应用需允许"安装未知来源应用"。
> 正式上架（Google Play / 国内应用市场）需另配签名密钥，属后话。
