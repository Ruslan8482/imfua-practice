# .NET CLI → GitHub Releases (`cd-dotnet-bin.yml`)

Источник: [Dotnet.md](https://github.com/rurewa/imfua/blob/main/content/DevOps/CI_CD/Pipelines/Dotnet.md)

## Что делает пайплайн

1. Запускается по тегу `v*` (или вручную).
2. Выполняет `dotnet restore` и `dotnet test` (xUnit).
3. Публикует self-contained single-file бинарники для RID `linux-x64`, `linux-arm64`, `osx-x64`, `osx-arm64`, `win-x64`.
4. Упаковывает их и публикует в GitHub Release.

## Локальный запуск

```bash
dotnet restore HelloCli.sln
dotnet test HelloCli.sln -c Release
dotnet publish HelloCli/HelloCli.csproj -c Release -r linux-x64 --self-contained true -p:PublishSingleFile=true -o out/linux-x64
```

## Скриншот

![Скриншот успешного workflow](evidence/workflow.png)

> Placeholder: положите реальный скриншот вкладки **Actions** и страницы Release.
