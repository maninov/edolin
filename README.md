# edolin

## 言語

* dart言語(flutter)

## 概要
* MS-DOSの内部コマンドであるラインエディタ（EDLIN）を現代風にアレンジしてみました（音だけはkotlinにもかぶってます）。キーバインドは、emacsライクで必要最低限のものしか実装していません。もちろん日本語対応しており、本README.mdも、edolinで作成しています。
* ※ 250行程度でコーディングされています。

## 環境
* linux

## 実行
* % cd edolin
* % flutter pub add  google_fonts scrollable_positioned_list
* % echo test > todo
* % flutter run

## 使い方 (C-はCtrlキーを押しながらという表記です)
* カーソル移動
----------------|-------------
C-p,C-n,C-f,C-p | 上,下,左,右
C-a,C-e | 先頭,末
ESC-<,ESC->,C-v | ページ先頭,末,送り

* 操作
----------------|-----------------
C-k | カーソル以降削除または行削除
C-d,BackSpace | 削除
C-y | C-kのペースト
C-t | 文字入れ替え
C-x | 保存
Tab | 空白２文字分インデント
Enter | 確定または改行

