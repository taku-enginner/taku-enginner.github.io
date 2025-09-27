#!/bin/bash

# 1ページずつcurlしていく
# 末尾かどうかは、「〇件中△件」というところを抜き出して、値が一致してたら最終ページとする。（例：23件中 21-23件を表示中）

text=$(curl 'https://school.runteq.jp/v2/runteq_events?page=1')

# イベント名を抜き出す
# -P オプションは非貪欲マッチングという最短マッチのオプション
# (?<=...)は肯定後読み、(?=...)は肯定後読み（マッチ結果に含まれない）
events=$(echo $text | grep -oP '(?<=<h2 class="runteq-event-title">).*?(?=</h2>)')
event_links=$(echo $text | grep -oP '(?<=<a class="runteq-event-item-link" href=").*?(?=">)' | uniq)

# 配列に置換するために半角スペースをすべて消す。グローバル置換の//。/gはsedなどの外部コマンドで使われるが、bashのパラメータ展開では使わない。
events=${events// /}
event_links=${event_links// /}

# 配列に置換
event_array=(${events//"\n"/})
event_link_array=(${event_links//"\n"/})

# フィルタリング配列
echo "---------------------------------------------------------------------------------------------------------------------------------"
filter_array=("期生" "アウトプット" "期限定" "関西")

echo "filter_array: ${filter_array[@]}"
echo "---------------------------------------------------------------------------------------------------------------------------------"
echo "| No. | URL                                            | イベント名 "
echo "| --- | ---------------------------------------------- | ------------------------------------------------------------------------ "
for i in `seq 0 $((${#event_array[@]} - 1 ))`
do
  match_flg=0
  #echo "i: $(( i+1))"
  # フィルタリング配列をループして、イベント名に含まれているか確認
  for j in `seq 0 $((${#filter_array[@]} - 1 ))`
  do
    #echo "ループに入りました: ${filter_array[$j]}"
    #echo "event: ${event_array[$i]}    filter: ${filter_array[$j]}"
    if [[ ${event_array[$i]} == *"${filter_array[$j]}"* ]]; then
      #echo "フィルタにマッチしました: ${filter_array[$j]}"
      match_flg=1
    fi
  done
  if [ $match_flg -eq 0 ]; then
    echo "| $((i+1))   | https://school.runteq.jp${event_link_array[$i]} | ${event_array[$i]} "
  fi
done
echo "---------------------------------------------------------------------------------------------------------------------------------"
