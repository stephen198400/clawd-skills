#!/bin/bash
# Clawd 周报查询脚本
# 用法: fetch-reports.sh <command> [args...]

set -euo pipefail

API_BASE="https://api.myclawd.work/rpc"

if [ -z "${CLAWD_API_KEY:-}" ]; then
	echo "ERROR: 环境变量 CLAWD_API_KEY 未设置。请先设置你的 API Key：" >&2
	echo "  export CLAWD_API_KEY=\"your-api-key-here\"" >&2
	exit 1
fi

API_KEY="${CLAWD_API_KEY}"

call_api() {
	local endpoint="$1"
	local body="$2"
	curl -sf "${API_BASE}/${endpoint}" \
		-H "Content-Type: application/json" \
		-H "x-api-key: ${API_KEY}" \
		-d "${body}"
}

case "${1:-}" in
	review)
		offset="${2:-0}"
		team="${3:-}"
		name="${4:-}"
		body="{\"weekOffset\":${offset}"
		[ -n "$team" ] && body="${body},\"teamCode\":\"${team}\""
		[ -n "$name" ] && body="${body},\"name\":\"${name}\""
		body="${body}}"
		call_api "externalGetWeeklyReportReview" "$body"
		;;
	search)
		# 按名字搜索的快捷方式: search <name> [weekOffset]
		search_name="${2:?用法: fetch-reports.sh search <name> [weekOffset]}"
		offset="${3:-0}"
		call_api "externalGetWeeklyReportReview" "{\"weekOffset\":${offset},\"name\":\"${search_name}\"}"
		;;
	user)
		user_id="${2:?用法: fetch-reports.sh user <userId> [limit]}"
		limit="${3:-20}"
		call_api "externalGetUserWeeklyReports" "{\"userId\":\"${user_id}\",\"limit\":${limit}}"
		;;
	detail)
		report_id="${2:?用法: fetch-reports.sh detail <reportId>}"
		call_api "externalGetWeeklyReportById" "{\"reportId\":\"${report_id}\"}"
		;;
	*)
		echo "用法: fetch-reports.sh <review|search|user|detail> [args...]"
		echo ""
		echo "命令:"
		echo "  review [weekOffset] [teamCode] [name]  获取周报审查数据"
		echo "  search <name> [weekOffset]             按员工名字搜索周报"
		echo "  user <userId> [limit]                  获取用户周报列表"
		echo "  detail <reportId>                      获取周报详情"
		exit 1
		;;
esac
