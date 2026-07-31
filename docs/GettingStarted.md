# はじめてガイド

3つの手順で動きます。**基板を作る → 書き込む → ブラウザで開く**、それだけです。

> 🔰 詰まったら、エラーメッセージをそのまま生成AIに貼るのが最短です。

## ステップ0：用意するもの

- Windows / Mac のPC（**Chrome または Edge** が必要。Safari・Firefoxは非対応）
- [Arduino Nano R4](./ArduinoNanoR4.md)
- USBケーブル（**充電専用でないもの**）
- （基板を自作するなら）はんだごて一式

## ステップ1：基板発注と電子部品の買い物（modbus_simple_pcb）

**発注する（おすすめ）**：[Releases](https://github.com/KikuchiMakoto/modbus_simple_pcb/releases) の `Gerber.zip` を JLCPCB や PCBWay にアップロードして注文。部品は [Wiki](https://github.com/KikuchiMakoto/modbus_simple_pcb/wiki) のBOMを見て購入し、自分ではんだ付けします。

**設計から確認する**：[KiCAD](https://www.kicad.org/)（無料）で `.kicad_pro` を開きます。

→ 詳しい説明は **[PCB.md](./PCB.md)**、組み立て手順は [Wiki](https://github.com/KikuchiMakoto/modbus_simple_pcb/wiki) へ。

## ステップ2：組み立てたら書き込もう（modbus_simple_firmware）

Arduino Nano R4 をUSB接続し、**Windowsなら PowerShell でこの1行**だけです。

```powershell
powershell -ExecutionPolicy Bypass -c "irm https://raw.githubusercontent.com/KikuchiMakoto/modbus_simple_system/main/scripts/flash-firmware-windows.ps1 | iex"
```

やっていること：

1. `winget` で Arduino CLI を導入（あればスキップ）
2. Nano R4用のボードコアを導入
3. [最新Release](https://github.com/KikuchiMakoto/modbus_simple_firmware/releases) から `ArduinoNanoR4.bin` を取得
4. COMポートを検出して書き込み

> 🔰 不安なら [スクリプト本体](../scripts/flash-firmware-windows.ps1) を先に読んでください。結果は同じです。

Mac/Linuxや、ソースから書き込む場合は [Arduino IDE](https://www.arduino.cc/en/software) を使います（→ [Arduino.md](./Arduino.md)）。

## ステップ3：じゃあ動かしてみよう（modbus_simple_logger）

インストール不要。**Chrome / Edge** で開くだけです。

👉 **https://kikuchimakoto.github.io/modbus_simple_logger/**

1. Arduino Nano R4 をUSB接続する
2. 「接続」ボタンからシリアルポートを選ぶ
3. AI0〜AI15の値がグラフに出れば成功

## ステップ4：使ってみる

| やること | 内容 |
| --- | --- |
| **校正** | 生データを N・mm に変換する式を設定（→ [Calibration.md](./Calibration.md)） |
| **Tare** | ボタン一つでその時点を0点に |
| **記録** | リアルタイムグラフ＋TSV保存 |
| **自動制御** | 内蔵Python（Pyodide）で `set_ao()` などを実行。**インストール不要** |

## うまくいかないときは

**[Troubleshooting.md](./Troubleshooting.md)** に症状別のチェックリストがあります。

## 関連ページ

[基板とKiCAD](./PCB.md) ／ [Arduino](./Arduino.md) ／ [キャリブレーション](./Calibration.md) ／ [困ったときは](./Troubleshooting.md) ／ [仕様まとめ](./Specs.md)
