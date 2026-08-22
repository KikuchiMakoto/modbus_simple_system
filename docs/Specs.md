# 仕様まとめ

3つのリポジトリの技術情報を1ページに集約しています。

## 信号構成

| 種別 | ch | デバイス | 範囲 |
| --- | --- | --- | --- |
| **AI0〜7** | 8 | [HX711](./HX711.md)×8 | ロードセル用（±3.906mV/V @ゲイン128） |
| **AI8〜15** | 8 | [ADS1115](./ADS1115.md)×2（4ch/IC） | 汎用電圧入力（0〜5.3V） |
| **AO0〜7** | 8 | [GP8403](./GP8403.md)×4（2ch/IC） | 0〜10V出力 |

種別の呼び方は [Signals.md](./Signals.md) を参照。

## 通信仕様

| 項目 | 値 |
| --- | --- |
| プロトコル | [Modbus RTU](./ModbusRTU.md) |
| 物理層 | USB CDCシリアル（→ [USBCDC.md](./USBCDC.md)。CDCなのでボーレートは実効速度の上限ではない） |
| ボーレート | 38400bps（表記上の値。実効速度はUSB側で決まる） |
| スレーブID | 1 |
| 入力レジスタ 0〜15 | AI0〜15（int16_t、読み取り専用） |
| ホールディングレジスタ 0〜7 | AO0〜7（mV単位、uint16_t） |

## ファームウェア（modbus_simple_firmware）

- 対応ボード：[Arduino Nano R4](./ArduinoNanoR4.md)
- 使用ライブラリ：HX711 Arduino Library 0.7.5 / ADS1115_WE 1.5.7 / DFRobot_GP8403 1.0.0 / ModbusRTUSlave 3.1.2
- Releasesにコミットごとの自動ビルド（`.bin` / `.hex` / `.elf`）を公開

## 計測アプリ（modbus_simple_logger）

- Web Serial API で接続（非対応環境ではWebUSBにフォールバック）
- ポーリング 100ms固定（チャートも同じ周期）。TSVの保存レートは200ms〜30分で独立して変更可（→ [Logger.md](./Logger.md)）
- チャネルごとの多項式キャリブレーションとワンタッチTare（→ [Calibration.md](./Calibration.md)）
- Plotly.js のリアルタイムチャート、File System Access API による TSV ストリーミング保存
- PWA対応でオフライン動作可能
- Pyodide（Python 3.14 / Web Worker + SharedArrayBuffer）でスクリプト実行
- React 19 / TypeScript 7 / Vite 8 / Tailwind CSS 4 / Plotly.js 3 / Bun
- ライセンス：MIT License

## 基板（modbus_simple_pcb）

- KiCADの回路図（`.kicad_sch`）・基板データ（`.kicad_pcb`）一式、独自ライブラリ同梱
- 組み立てガイドとBOMはWikiに掲載（→ [PCB.md](./PCB.md)）

## リリース

| リポジトリ | 最新 | 中身 |
| --- | --- | --- |
| [pcb](https://github.com/KikuchiMakoto/modbus_simple_pcb/releases) | v1.1 | `Gerber.zip`、`Schematic.pdf` |
| [firmware](https://github.com/KikuchiMakoto/modbus_simple_firmware/releases) | コミット単位 | `.bin` / `.hex` / `.elf` |
| [logger](https://github.com/KikuchiMakoto/modbus_simple_logger/releases) | 常時最新 | Web版（GitHub Pages）、Windows用 `modbus_simple_logger.exe` |

## 関連ページ

[Signals](./Signals.md) ／ [ModbusRTU](./ModbusRTU.md) ／ [PCB](./PCB.md) ／ [はじめてガイド](./GettingStarted.md) ／ [計測アプリ](./Logger.md)
