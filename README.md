# Modbus Simple System

材料試験（ロードセル・変位計などのアナログ計測、アナログ出力制御）向けに作った、自作 Modbus RTU 計測・制御システムです。

「基板」「ファームウェア」「ブラウザ計測」の3リポジトリ構成なので、このリポジトリでは**全体像と最短手順**をまとめています。

> 🔰 **Arduino初心者でも進められます。**
> 詰まったら、エラーメッセージをそのまま生成AIに貼って確認してください。READMEにも要点だけ注記しています。

## これは何をするもの？

ロードセル（重さ・力を測るセンサー）などのアナログ信号を基板で読み取り、パソコンのブラウザに接続して、リアルタイムでグラフ表示・記録・簡単な自動制御ができるシステムです。専用ソフトのインストールは不要で、**ブラウザだけで計測画面が開けます**。

- 最大16chのアナログ入力（ロードセル用アンプHX711、汎用ADCのADS1115）
- 最大8chのアナログ出力（GP8403、0〜10V）
- ブラウザ上でリアルタイムにグラフ表示・TSVファイル保存
- チャネルごとの校正（キャリブレーション）・0点補正（Tare）
- Python スクリプトを使った簡易自動制御（Pyodide、追加インストール不要）

## 全体像

```
[ロードセル等のセンサー]
        │
        ▼
┌──────────────────────────────────────┐
│ 計測基板 (modbus_simple_pcb)          │  KiCADで設計・自作 or 発注
│  HX711×8 / ADS1115×2 / GP8403×4       │
└───────────────┬───────────────────────┘
                │  I2C / アナログ
                ▼
┌───────────────────────────────────────┐
│ Arduino Nano R4                       │  ファームウェアを書き込む
│ (modbus_simple_firmware)              │  (modbus_simple_firmware)
│  Modbus RTUスレーブとして動作          │
└───────────────┬───────────────────────┘
                │  USB (Modbus RTU, 38400bps)
                ▼
┌───────────────────────────────────────┐
│ PCのブラウザ (Chrome / Edge)          │  インストール不要、URLを開くだけ
│ 計測アプリ (modbus_simple_logger)      │
│  ・Web Serial APIで接続                │
│  ・リアルタイム計測/グラフ/保存        │
│  ・Pyodideで Python 実行               │
└───────────────────────────────────────┘
```

## 使う3つのリポジトリ

| 順番 | リポジトリ | やること | 難易度の目安 |
| --- | --- | --- | --- |
| ① | [modbus_simple_pcb](https://github.com/KikuchiMakoto/modbus_simple_pcb) | 基板の製作（発注 or 自作） | はんだ付けができればOK |
| ② | [modbus_simple_firmware](https://github.com/KikuchiMakoto/modbus_simple_firmware) | Arduino Nano R4 にファームウェアを書き込む | PC操作のみ（配線済みなら） |
| ③ | [modbus_simple_logger](https://github.com/KikuchiMakoto/modbus_simple_logger) | ブラウザで計測アプリを開いて使う | ブラウザが使えればOK |

## はじめてガイド

### ステップ0：用意するもの

- Windows / Mac のPC（**Chrome または Edge** ブラウザが必要。Safari・Firefoxは対応していません）
- Arduino Nano R4
- USBケーブル（Arduino Nano R4 とPCを接続するもの）
- （基板を自作する場合）はんだごて等の工具一式

### ステップ1：基板を用意する

2通りの方法があります。

- **発注して作ってもらう（おすすめ・簡単）**：[modbus_simple_pcb の Releases](https://github.com/KikuchiMakoto/modbus_simple_pcb/releases) から `Gerber.zip`（基板データ）をダウンロードし、JLCPCB や PCBWay などの基板製造サービスにアップロードして発注します。部品は [Wiki の部品リスト（BOM）](https://github.com/KikuchiMakoto/modbus_simple_pcb/wiki) を参考に秋月電子・Amazon・SwitchScience 等で購入し、自分ではんだ付けします。
- **自分で設計から確認したい場合**：[KiCAD](https://www.kicad.org/)（無料）をインストールし、リポジトリ内の `.kicad_pro` を開くと回路図・基板データを確認できます。回路図だけ見たい場合は Releases の `Schematic.pdf` が手軽です。

組み立て手順・写真・YouTube動画は **[modbus_simple_pcb の Wiki](https://github.com/KikuchiMakoto/modbus_simple_pcb/wiki)** にまとまっています。特に以下は失敗しやすいポイントとして紹介されています。

- ADS1115・GP8403は部品の向き（VDD・極性）を間違えやすいので要確認
- HX711とロードセルをつなぐコネクタ部分はグルーガンで固定するのが推奨されています
- GP8403のI2Cアドレス設定（4段階）は基板ごとに要設定

> 🔰 部品の向きが図と合っているか不安なとき、はんだ付けの写真を生成AIに見せて「この部品の向きは合っていますか？」と聞くのも有効です。

### ステップ2：ファームウェアを書き込む

Arduino Nano R4 をUSB接続した状態で、**Windowsは下の1行を PowerShell で実行**すれば書き込みできます。

```powershell
powershell -ExecutionPolicy Bypass -c "irm https://raw.githubusercontent.com/KikuchiMakoto/modbus_simple_system/main/scripts/flash-firmware-windows.ps1 | iex"
```

実行内容：

1. `winget` で Arduino CLI を自動インストール（すでに入っていればスキップ）
2. Arduino Nano R4 用のボードコアを自動インストール
3. [modbus_simple_firmware の最新Release](https://github.com/KikuchiMakoto/modbus_simple_firmware/releases) から `ArduinoNanoR4.bin` を `%TEMP%` にダウンロード
4. 接続されているCOMポートを検出し、書き込みを実行

> 🔰 不安な場合は [scripts/flash-firmware-windows.ps1](./scripts/flash-firmware-windows.ps1) を先に確認してから、内容を貼り付け実行してください（同じ結果になります）。

Mac/Linuxやソースからビルドする場合は、[Arduino IDE](https://www.arduino.cc/en/software) を入れ、README記載のライブラリを追加して「Arduino Nano R4」へ書き込んでください。

> 🔰 エラーが出たら、メッセージをそのまま生成AIに貼るのが早いです（例: `winget` 未検出なら「アプリ インストーラー」の確認）。

### ステップ3：計測アプリを開く

インストール作業は不要です。**Chrome または Edge** で以下のURLを開くだけで使えます。

👉 **https://kikuchimakoto.github.io/modbus_simple_logger/**

（開発者向けのソース起動手順は [modbus_simple_logger の README](https://github.com/KikuchiMakoto/modbus_simple_logger) を参照）

1. Arduino Nano R4 をPCにUSB接続する
2. 上記アプリを開き、「接続」ボタンからシリアルポートを選択する（初回はブラウザがポート選択のダイアログを出します）
3. 接続できると、AI0〜AI15のリアルタイム値がグラフに表示されます

> 🔰 ポートが出ない/接続失敗時は、Chrome/Edge利用とポート占有の有無を確認。エラーはそのまま生成AIに貼るのが近道です。

### ステップ4：使ってみる

- **キャリブレーション**：各チャネルの生データを実際の物理値（N、mm等）に変換する式（`a·x² + b·x + c`）を設定します
- **Tare（0点補正）**：ボタン一つでその時点の値を0点にリセットできます
- **グラフ表示・保存**：Plotly.jsのグラフでリアルタイム表示しつつ、TSVファイルに保存できます
- **Pythonでの自動制御（応用）**：アプリ内蔵のPython実行環境（Pyodide）でスクリプトを書き、`set_ao()` でアナログ出力を制御したり、Tareを自動実行したりできます。ブラウザ内で完結するため、Pythonを別途インストールする必要はありません

## もう少し詳しく（技術情報）

<details>
<summary>各コンポーネントの技術仕様</summary>

### 計測用アプリケーション（modbus_simple_logger）

- Modbus RTU通信（Web Serial API、非対応環境ではWebUSBフォールバック）
- アナログ入力16ch（HX711×8 + ADS1115×8相当）を200ms〜5分間隔でポーリング
- アナログ出力8chの制御
- チャネルごとの多項式キャリブレーション、ワンタッチTare
- Plotly.jsによるリアルタイムチャート表示、File System Access APIによるTSVストリーミング保存
- PWA対応でオフライン動作可能
- Pyodide（Python 3.14 / Web Worker + SharedArrayBuffer）によるPythonスクリプト実行
- 技術スタック：React 19 / TypeScript 7 / Vite 8 / Tailwind CSS 4 / Plotly.js 3 / Bun
- ライセンス：MIT License

### 基板（modbus_simple_pcb）

- KiCADによる回路図（`.kicad_sch`）・基板設計データ（`.kicad_pcb`）・プロジェクトファイル一式
- 独自シンボル／フットプリントライブラリを同梱
- 組み立てガイド・部品リストはWikiに掲載

### ファームウェア（modbus_simple_firmware）

- 対応ボード：Arduino Nano R4
- 使用ライブラリ：HX711 Arduino Library / ADS1115_WE / DFRobot_GP8403 / ModbusRTUSlave
- アナログ入力16ch（AI0-7：HX711×8／ロードセル用、AI8-15：ADS1115×2／汎用ADC 0〜6.114V）
- アナログ出力8ch（AO0-7：GP8403×4／0〜10V出力）
- Modbus RTU通信仕様：USB CDCシリアル、38400bps、スレーブID 1
  - 入力レジスタ0-15：AI0-15（int16_t）
  - ホールディングレジスタ0-7：AO0-7（mV, uint16_t）
- Releasesには commit ごとの自動ビルド（`.bin` / `.hex` / `.elf`）が公開されています

</details>

## リリース情報

| リポジトリ | 最新リリース | 内容 |
| --- | --- | --- |
| [modbus_simple_pcb](https://github.com/KikuchiMakoto/modbus_simple_pcb/releases) | v1.1 | 回路図・Gerberデータ（`Gerber.zip`, `Schematic.pdf`） |
| [modbus_simple_firmware](https://github.com/KikuchiMakoto/modbus_simple_firmware/releases) | コミット単位の自動ビルド | Arduino Nano / Nano R4 向けビルド済みファイル（`.bin` / `.hex` / `.elf`） |
| [modbus_simple_logger](https://github.com/KikuchiMakoto/modbus_simple_logger) | （Releaseなし） | GitHub Pagesで常時最新版を公開中（上記URL） |

## 困ったときは

- まずは各リポジトリのREADME・Wikiを確認
- エラーや状況は、そのまま生成AIに貼ると切り分けが早いです
- Issue前の軽い確認にも生成AIが有効です

## ライセンス

各リポジトリのライセンスに従います（modbus_simple_logger は MIT License）。詳細は各リポジトリを参照してください。
