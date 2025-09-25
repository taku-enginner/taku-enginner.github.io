#!/bin/bash

# 1ページずつcurlしていく
# 末尾かどうかは、「〇件中△件」というところを抜き出して、値が一致してたら最終ページとする。（例：23件中 21-23件を表示中）

text=$(curl 'https://school.runteq.jp/v2/runteq_events?page=1')
echo $text

# イベント名を抜き出す
# -P オプションは非貪欲マッチングという最短マッチのオプション
# (?<=...)は肯定後読み、(?=...)は肯定後読み（マッチ結果に含まれない）
echo $text | grep -oP '(?<=<h2 class="runteq-event-title">).*?(?=</h2>)' > events.txt

# １つ１つのイベントを切り分けて配列みたいなもので保持するとよさそう
# 以下の文字列が含まれる
/v2/runteq_events/1570
