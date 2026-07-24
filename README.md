# Modbus Simple System

材料試験（ロードセル・変位計などのアナログ計測、アナログ出力制御）向けに構築した、HX711 / ADS1115 / GP8403 を統合した Modbus RTU 計測・制御エコシステムです。

基板設計・ファームウェア・計測アプリケーションの3つのリポジトリで構成されており、本リポジトリはそれらを束ねるハブ（システム概要）です。

## システム構成

```
┌───────────────────────┐        Modbus RTU (RS485 / USB CDC, 38400bps)
│  PC / タブレット等      │ ◀──────────────────────────────────────────┐
│  Webブラウザ            │                                              │
│  (modbus_simple_logger) │                                              │
│  ・Web Serial API        │                                              │
│  ・リアルタイム計測/描画  │                                              ▼
│  ・Pyodide(Python)実行   │                                   ┌──────────────────────┐
└───────────────────────┘                                   │ Arduino Nano R4       │
                                                              │ (modbus_simple_firmware)│
                                                              │ ・AI 16ch / AO 8ch     │
                                                              └──────────┬───────────┘
                                                                         │
                                                              ┌──────────▼───────────┐
                                                              │ 計測基板              │
                                                              │ (modbus_simple_pcb)   │
                                                              │ HX711×8 / ADS1115×2   │
                                                              │ GP8403×4              │
                                                              └───────────────────────┘
```

## 構成リポジトリ

| リポジトリ | 役割 | 主な内容 |
| --- | --- | --- |
| [modbus_simple_logger](https://github.com/KikuchiMakoto/modbus_simple_logger) | 計測用アプリケーション | ブラウザで動作する Modbus RTU ロガー（SPA/PWA）。Web Serial API でデバイスに接続し、計測・キャリブレーション・チャート表示・TSV保存を行う。Pyodide による Python スクリプト実行で簡易制御が可能 |
| [modbus_simple_pcb](https://github.com/KikuchiMakoto/modbus_simple_pcb) | 基板設計 | KiCAD による回路図・PCB設計データ、および製作方法 |
| [modbus_simple_firmware](https://github.com/KikuchiMakoto/modbus_simple_firmware) | ファームウェア | Arduino Nano R4 用ファームウェア。Modbus RTU スレーブとして動作し、アナログ入出力を制御 |

## 各コンポーネントの概要

### 📊 計測用アプリケーション（modbus_simple_logger）

- Modbus RTU 通信（Web Serial API、非対応環境では WebUSB フォールバック）
- アナログ入力 16ch（HX711×8 + ADS1115×8 相当）をリアルタイム計測（200ms〜5分間隔でポーリング）
- アナログ出力 8ch の制御
- チャネルごとの多項式キャリブレーション（`a·x² + b·x + c`）、ワンタッチ Tare（0点補正）
- Plotly.js によるリアルタイムチャート表示、File System Access API による TSV ストリーミング保存
- PWA 対応でオフライン動作可能
- **Pyodide（Python 3.14 / Web Worker + SharedArrayBuffer）による Python スクリプト実行**
  - `set_ao()` によるアナログ出力の制御や Tare の自動実行など、スクリプトによる簡易制御が可能
  - ブラウザ内で完結するため追加のランタイムインストール不要
- 動作環境：Web Serial API に対応した Chromium 系ブラウザ（Chrome / Edge 等）。Safari / Firefox は Web Serial 未対応のため非対応

### 🔧 基板（modbus_simple_pcb）

- KiCAD による回路図（`.kicad_sch`）・基板設計データ（`.kicad_pcb`）・プロジェクトファイル一式
- 独自シンボル／フットプリントライブラリを同梱
- 上記ファームウェアが動作する計測基板の製作に使用

### 💾 ファームウェア（modbus_simple_firmware）

- 対応ボード：Arduino Nano R4
- 使用ライブラリ：HX711 Arduino Library / ADS1115_WE / DFRobot_GP8403 / ModbusRTUSlave
- アナログ入力 16ch
  - AI0-7：HX711×8（ロードセル用）
  - AI8-15：ADS1115×2（汎用ADC、0〜6.114V）
- アナログ出力 8ch：GP8403×4（AO0-7、0〜10V出力）
- Modbus RTU 通信仕様：USB CDC シリアル、38400bps、スレーブID 1
  - 入力レジスタ 0-15：AI0-15（int16_t）
  - ホールディングレジスタ 0-7：AO0-7（mV, uint16_t）

## クイックスタート

1. **基板を製作する** — [modbus_simple_pcb](https://github.com/KikuchiMakoto/modbus_simple_pcb) の KiCAD データを参照し、基板を製作・実装する
2. **ファームウェアを書き込む** — [modbus_simple_firmware](https://github.com/KikuchiMakoto/modbus_simple_firmware) を参照し、必要なライブラリを導入した上で Arduino Nano R4 に書き込む
3. **計測アプリを起動する** — [modbus_simple_logger](https://github.com/KikuchiMakoto/modbus_simple_logger) を Chromium 系ブラウザで開き、Web Serial API 経由でボードに接続する
4. **計測・制御を行う** — チャネルのキャリブレーションや Tare を設定し、必要であれば Pyodide 上で Python スクリプトを実行して自動制御を行う

## ライセンス

各リポジトリのライセンスに従います（modbus_simple_logger は MIT License）。詳細は各リポジトリを参照してください。
