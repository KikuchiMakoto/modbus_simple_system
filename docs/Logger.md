# 計測アプリ（modbus_simple_logger）

ブラウザ上で動く Modbus RTU ロガー（SPA / PWA）です。インストール不要で、Chrome / Edge で開くだけで使えます。

👉 **https://kikuchimakoto.github.io/modbus_simple_logger/**

## まず開く

1. Arduino Nano R4 をUSB接続する
2. 「接続」ボタンからシリアルポート（COMポート）を選ぶ
3. AI0〜AI15の値がチャートに出れば成功

通信設定（スレーブID 1、38400bps、ポーリング100ms）はアプリ側で固定されています。設定で迷うことがない代わりに、相手側（[Modbus RTU](./ModbusRTU.md)・ファームウェア）の仕様と一致している前提で動きます。

## 対応ブラウザ

Web Serial API などの新しいAPIを使うため、**Chromium系ブラウザが必須**です。

| ブラウザ | 可否 |
| --- | --- |
| Chrome / Edge（89以降） | ○ |
| Android Chrome | ○ |
| Safari / Firefox | ×（非対応） |

> 💡 Windows限定ですが、ブラウザ不要の**単一EXE版**を [Releases](https://github.com/KikuchiMakoto/modbus_simple_logger/releases) で公開しています。

## ポーリングと保存は別々の速さで回る

- **ポーリング（測定）**：100ms間隔で固定。チャート表示もこの周期です
- **保存レート（TSV書き込み）**：200ms〜30分で自由に変更できます

保存を遅くしても、測定・グラフ・自動制御は速いまま回ります。「長時間記録するからといって測定が粗くなる」ことはありません。

## 主な機能

| 機能 | 内容 |
| --- | --- |
| キャリブレーション | チャネルごとの2次式（a·x²+b·x+c）とワンタッチTare。JSON入出力対応（→ [Calibration.md](./Calibration.md)） |
| TSV保存 | File System Access API によるストリーミング保存。保存中のクラッシュからも復旧します |
| ScriptRunner | 内蔵Python（Pyodide）で `GetAiPhy()` / `SetAo()` などを自動実行。Stopはどんなループでも効きます |
| PWA | インストールすれば完全オフラインで動きます |

## 初心者向けの注意

- **校正値はそのPCのブラウザの中にしかありません。** サイトデータの削除・PCの載せ替えで警告なく消えます。JSON書き出しや紙のメモで必ずバックアップしてください（→ [Calibration.md](./Calibration.md)）
- COMポートは同時に1つのソフトしか開けません。Arduino IDEのシリアルモニタを閉じてから接続してください（→ [USBCDC.md](./USBCDC.md)）
- ScriptRunnerのAPIは **PascalCase**（`SetAo()`）です。snake_case（`set_ao()`）では動きません
- ポートが突然消えたら、ケーブルより先にファームウェアの停止・リセットを疑ってください（→ [USBCDC.md](./USBCDC.md)）

## 関連ページ

[はじめてガイド](./GettingStarted.md) ／ [キャリブレーション](./Calibration.md) ／ [Modbus RTU](./ModbusRTU.md) ／ [USB CDC ACM](./USBCDC.md) ／ [仕様まとめ](./Specs.md)
