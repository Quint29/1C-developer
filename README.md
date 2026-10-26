# 1C-developer — режим «Разработчик 1С» для Cursor

Локальный комплект для AI-assisted разработки на 1С: skills, справка платформы, стандарты, опционально LSP / граф конфигурации / YaXUnit.

Работа идёт с **файловой выгрузкой конфигурации (XML)** или расширением. Этот репозиторий — набор инструментов, не сама конфигурация.

Источник каталога инструментов: [aitools1c.dev](https://aitools1c.dev/). Версии компонентов — в [VERSIONS.md](VERSIONS.md).

## Требования

- Windows
- [Cursor](https://cursor.com)
- **Java 17+** (`java -version`) — для JAR в `bin/`
- Установленная платформа **1С:Предприятие 8.3** (путь к каталогу версии)
- Для второго этапа (по желанию): Docker (LSP-bridge, Metacode), учебная база + YaXUnit

## Быстрый старт

1. Клонируйте репозиторий (или скопируйте комплект) на диск.
2. Откройте PowerShell в корне комплекта и укажите папку своей XML-выгрузки:

```powershell
.\install.ps1 -ProjectDir "D:\work\MyConfigXml"
```

С путём к платформе сразу:

```powershell
.\install.ps1 -ProjectDir "D:\work\MyConfigXml" -PlatformPath "C:\Program Files\1cv8\8.3.27.1606"
```

Глобально для всех проектов Cursor:

```powershell
.\install.ps1 -Global -PlatformPath "C:\Program Files\1cv8\8.3.27.1606"
```

3. Откройте в Cursor **папку выгрузки**, не каталог `1C-developer`.
4. Сделайте **полный перезапуск** Cursor.
5. Проверьте, что MCP не красные (минимум: BSL Context, v8std). Если в `mcp.json` остался `CHANGE_ME` — подставьте свой каталог платформы.

### Параметры install.ps1

| Параметр | Назначение |
|---|---|
| `-ProjectDir` | Куда ставить `.cursor` (выгрузка) |
| `-Global` | Ставить в `%USERPROFILE%\.cursor` |
| `-PlatformPath` | Каталог платформы 1С |
| `-SkipBsp` | Не копировать skill БСП |
| `-SkipMcp` | Не трогать `mcp.json` |

## Минимальный и полный контур

**Старт:** skills (`cursor-1c-skills` + БСП) + MCP **BSL Context** + **v8std**.

**Второй этап:** `mcp-bsl-lsp-bridge` (Docker), `1c-mcp-metacode` (Docker/Neo4j), `YaXUnit Runner` (JDK, учебная ИБ, конфиг из `mcp-onec-test-runner/docs/`). Настройки — в README соответствующих папок; в `mcp.json.example` блоки уже есть, но без Docker/базы серверы будут недоступны.

## Состав комплекта

| Путь | Назначение |
|---|---|
| `cursor-1c-skills/` | Skills и rules Cursor (объекты, формы, CFE, …) |
| `1c-ssl-skills/` | Skill по БСП |
| `bin/*.jar` | Готовые MCP: справка платформы, YaXUnit runner |
| `mcp-bsl-platform-context/` | Исходники BSL Context |
| `v8std/` | Стандарты разработки |
| `mcp-bsl-lsp-bridge/` | Диагностики BSL LS |
| `1c-mcp-metacode/` | Граф метаданных/кода |
| `mcp-onec-test-runner/` | Сборка и тесты |
| `mcp.json.example` | Шаблон MCP |
| `install.ps1` | Установка для коллег |

## Важно

- Не разрабатывайте «в боевой базе» как базовый сценарий — правки в файлах выгрузки, загрузка обычным контуром 1С.
- Публичный MCP v8std (`https://ai.v8std.ru/mcp`) видит текст запросов; для закрытого кода поднимите локальный сервер из `v8std/`.
- ИИ не заменяет ревью разработчика и знание предметной области.

## Лицензии

Компоненты — open-source с собственными лицензиями в подкаталогах. Используйте с учётом лицензий исходных проектов.
