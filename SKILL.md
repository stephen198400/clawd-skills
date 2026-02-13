---
name: clawd
description: 查询 Clawd 周报数据。当用户询问周报提交情况、员工周报、按 team 查看周报、按员工名字查周报、或需要查看周报审查数据时使用。触发词包括"周报"、"weekly report"、"谁没交"、"提交情况"、某员工名字等。
allowed-tools: Bash(bash *)
---

# Clawd 周报查询

通过外部 API 查询周报数据。API Key 和地址已内置于脚本中。

```bash
bash .claude/skills/clawd-reports/scripts/fetch-reports.sh <command> [args...]
```

## 可用命令

### 1. review — 获取周报审查数据（老板视角）

```bash
bash .claude/skills/clawd-reports/scripts/fetch-reports.sh review [weekOffset] [teamCode] [name]
```

- `weekOffset`：0=本周，-1=上周，-2=上上周（范围 -52 到 0，默认 0）
- `teamCode`：可选，按团队筛选（us / cn / vn / ph）
- `name`：可选，按员工名字模糊搜索

### 2. search — 按员工名字搜索（快捷方式）

```bash
bash .claude/skills/clawd-reports/scripts/fetch-reports.sh search <name> [weekOffset]
```

- `name`：必填，员工名字（模糊匹配）
- `weekOffset`：可选，默认 0（本周）

### 3. user — 获取特定用户的周报列表

```bash
bash .claude/skills/clawd-reports/scripts/fetch-reports.sh user <userId> [limit]
```

- `userId`：必填，用户 ID（从 review/search 结果中获取）
- `limit`：可选，返回数量（默认 20，最大 100）

### 4. detail — 获取单个周报详情

```bash
bash .claude/skills/clawd-reports/scripts/fetch-reports.sh detail <reportId>
```

## 常见用法示例

| 用户说 | 执行 |
|--------|------|
| "本周周报提交情况" | `review 0` |
| "上周谁没交周报" | `review -1`，筛选 status=missing |
| "看看美国团队的周报" | `review 0 us` |
| "张三本周的周报" | `search 张三` |
| "越南团队上周谁没交" | `review -1 vn`，筛选 status=missing |
| "帮我看看这个周报详情 xxx" | `detail xxx` |

## 状态说明

判断周报是否完成/提交，**只看 `submissionStatus`**：

- **`submitted`**：已提交（即"交了"）
- **`missing`**：未提交（即"没交"，包括草稿未提交的情况）

用户问"谁交了/谁没交周报"时，按此二分判断，忽略 AI 分析等其他状态。
