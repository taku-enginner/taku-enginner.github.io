#!/bin/bash

BASE_URL='https://school.runteq.jp/v2/runteq_events?page='
#filter_array=("期生" "アウトプット" "期限定" "関西" "ホームルーム")
filter_array=("アウトプット")

page=1
event_array=()
event_link_array=()
date_time_array=()

while true
do
  text=$(curl "$BASE_URL$page")

  # イベント名を抜き出す
  # -P オプションは非貪欲マッチングという最短マッチのオプション
  # (?<=...)は肯定後読み、(?=...)は肯定後読み（マッチ結果に含まれない）
  events=$(echo $text | grep -oP '(?<=<h2 class="runteq-event-title">).*?(?=</h2>)')
  event_links=$(echo $text | grep -oP '(?<=<a class="runteq-event-item-link" href=").*?(?=">)' | uniq)
  date_times=$(echo $text | grep -oP '(?<=<i class="far fa-clock"></i>).*?(?=</div>)')

  # 配列に置換するために半角スペースをすべて消す。グローバル置換の//。/gはsedなどの外部コマンドで使われるが、bashのパラメータ展開では使わない。
  events=${events// /}
  event_links=${event_links// /}
  date_times=${date_times// /}

  # 配列に置換
  tmp_event_array=(${events//"\n"/})
  tmp_event_link_array=(${event_links//"\n"/})
  tmp_date_time_array=(${date_times//"\n"/})

  # 配列を結合
  event_array+=("${tmp_event_array[@]}")
  event_link_array+=("${tmp_event_link_array[@]}")
  date_time_array+=("${tmp_date_time_array[@]}")

  max_event_number=$(echo $text | grep -oP '(?<=<span class="pagination-text">).*?(?=件中)')
  current_event_number=$(echo "$text" | grep -oP '\d+(?=件を表示中)')
  if [ "$max_event_number" -eq "$current_event_number" ]; then
    break
  fi
  page=$((page + 1))
done

result_array=()
for i in `seq 0 $((${#event_array[@]} - 1 ))`
do
  match_flg=0
  for j in `seq 0 $((${#filter_array[@]} - 1 ))`
  do
    if [[ ${event_array[$i]} == *"${filter_array[$j]}"* ]]; then
      match_flg=1
    fi
  done
  if [ $match_flg -eq 0 ]; then
    result_array+=("| https://school.runteq.jp${event_link_array[$i]} | ${date_time_array[$i]} | ${event_array[$i]}")
  fi
done

IFS=$'\n'
cat << EVENT_FILTER_RESULT > event_filter_result.txt
-----------------------------------------------------------------------------------------------------------------------------------
| 実行日時           ： $(date)
-----------------------------------------------------------------------------------------------------------------------------------
| フィルタリング対象 : ${filter_array[@]}
-----------------------------------------------------------------------------------------------------------------------------------
| URL                                            | 開催日時                       |  イベント名 "
| ---------------------------------------------- | ------------------------------ | -----------------------------------------------
${result_array[*]}
-----------------------------------------------------------------------------------------------------------------------------------
EVENT_FILTER_RESULT
