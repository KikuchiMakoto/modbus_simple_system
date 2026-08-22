# Modbus Simple System

材料試験向けの、自作 Modbus RTU 計測・制御システムです。
**アナログ入力16ch・出力8ch**を、ブラウザだけで記録・制御できます。

👉 **[計測アプリを開く](https://kikuchimakoto.github.io/modbus_simple_logger/)**（Chrome / Edge、インストール不要）

> 🔰 **はじめての方は [はじめてガイド](./GettingStarted.md) へ。** 詰まったら [困ったときは](./Troubleshooting.md)。

## このシステムの原点

東京大学の地盤研で三軸試験機向けに使われてきた計測・制御システム **[DigitShow 系](https://github.com/mkt-kuno/DigitShowSystem)** が原点です（Windows98時代の王林氏作 DigitShow → Windows2000時代の本多剛氏作 DigitShowBasic）。PCから拡張スロットが消えたため、Interface/CONTECのAD/DAボードを**USB接続の自作Modbusボードに置き換えた、その趣味版**が本システムです。

## 全体像

```
[センサー] ──▶ [計測基板] ──▶ [Arduino Nano R4] ──USB──▶ [ブラウザ]
 ロードセル      HX711 ×8        Modbus RTUスレーブ         グラフ・保存
 変位計          ADS1115 ×2                                 Python制御
                 GP8403 ×4
```

| | リポジトリ | やること | 解説 |
| --- | --- | --- | --- |
| ① | [pcb](https://github.com/KikuchiMakoto/modbus_simple_pcb) | 基板発注と電子部品の買い物 | [PCB.md](./PCB.md) |
| ② | [firmware](https://github.com/KikuchiMakoto/modbus_simple_firmware) | 組み立てたら書き込もう | [Arduino.md](./Arduino.md) |
| ③ | [logger](https://github.com/KikuchiMakoto/modbus_simple_logger) | じゃあ動かしてみよう | [Logger.md](./Logger.md) |

## できること

- **AI16ch / AO8ch** の計測と制御（→ [Signals.md](./Signals.md)）
- リアルタイムグラフとTSV保存（→ [Logger.md](./Logger.md)）
- チャネルごとの校正・Tare（→ [Calibration.md](./Calibration.md)）
- ブラウザ内蔵Pythonで自動制御（追加インストール不要）

技術仕様は **[Specs.md](./Specs.md)** に集約しています。

## ドキュメント

**はじめる**
[はじめてガイド](./GettingStarted.md) ／ [基板・KiCAD・ガーバー](./PCB.md) ／ [Arduino](./Arduino.md) ／ [計測アプリ](./Logger.md) ／ [困ったときは](./Troubleshooting.md)

**測る仕組み**
[ロードセル](./LoadCell.md) ／ [ひずみゲージとブリッジ](./StrainGauge.md) ／ [DC励起とAC励起](./Excitation.md) ／ [LVDT](./LVDT.md) ／ [キャリブレーション](./Calibration.md)

**基板に載っているIC**
[HX711](./HX711.md)（AI0-7） ／ [ADS1115](./ADS1115.md)（AI8-15） ／ [GP8403](./GP8403.md)（AO0-7） ／ [I2C](./I2C.md)

**つなぐ・守る**
[AI/AO/DI/DO](./Signals.md) ／ [⚠️ 4〜20mAの受け方](./CurrentLoop.md) ／ [シールドとアース](./Shield.md) ／ [同軸・BNC・50Ω](./Coax.md)

**通信**
[Modbus RTU](./ModbusRTU.md) ／ [USB CDC ACM](./USBCDC.md) ／ [Arduino Nano R4](./ArduinoNanoR4.md) ／ [仕様まとめ](./Specs.md)

## ライセンス

各リポジトリのライセンスに従います（modbus_simple_logger は MIT License）。
