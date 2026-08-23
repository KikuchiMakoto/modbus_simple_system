# 用語集

ドキュメント全体で使う用語の1行定義です。詳しい説明は「→」先のページを参照してください。

## 計測・センサー系

| 用語 | 定義 | 詳細 |
| --- | --- | --- |
| AI / AO / DI / DO | アナログ入力／アナログ出力／接点入力／接点出力。産業の信号4区分。計測分野のAIはAnalog Input（人工知能ではない） | [Signals](./Signals.md) |
| ロードセル | 力や重さを電圧に変えるセンサー。ひずみゲージ式が主流 | [LoadCell](./LoadCell.md) |
| ひずみゲージ | 伸びると抵抗がわずかに増える金属箔。ΔR/R = K×ε（K≒2.0） | [StrainGauge](./StrainGauge.md) |
| ブリッジ回路 | 抵抗4本のひし形回路。バランス時の出力0を利用して微小変化だけを取り出す | [StrainGauge](./StrainGauge.md) |
| フルブリッジ | ゲージ4枚のブリッジ。出力は1/4ブリッジの4倍で温度補償も効く | [StrainGauge](./StrainGauge.md) |
| μST（マイクロストレイン） | ひずみの100万分の1単位。1mの棒が1μm伸びたら1μST | [StrainGauge](./StrainGauge.md) |
| mV/V（定格出力） | 電源1Vあたり定格荷重で何mV出るか。2.0mV/Vなら励起電圧に比例して出る | [LoadCell](./LoadCell.md) |
| LVDT | 差動トランス式変位計。**AC励起が必須**。「LVDT」と呼ばれても実体はひずみゲージ式のことが多い | [LVDT](./LVDT.md) |

## 励振・信号系

| 用語 | 定義 | 詳細 |
| --- | --- | --- |
| 励振（れいしん） | センサーのブリッジに掛ける電源。DC励起とAC励起がある | [Excitation](./Excitation.md) |
| DC励起 | 直流でブリッジを駆動する方式。HX711はこちら。ゼロ点ドリフトはTareで吸収 | [Excitation](./Excitation.md) |
| AC励起（搬送波型） | 交流で駆動し同期検波で復調する方式。熱起電力・オフセットに強い | [Excitation](./Excitation.md) |
| 同期検波 | 信号を搬送波周波数に乗せて運び、位相を揃えて取り出す検波方式 | [Excitation](./Excitation.md) |
| 熱起電力 | 異種金属の接点に生じる数μVの直流。温度差でふらつく | [Excitation](./Excitation.md) |
| 4〜20mA（電流ループ） | 電流の大きさで値を送る産業標準。0mA＝断線が分かる（ライブゼロ）。**本システムへの直結禁止** | [CurrentLoop](./CurrentLoop.md) |
| ディストリビュータ | 4〜20mAや0〜10Vを1〜5V等に絶縁変換する専用機器。ミスミ等で購入可 | [CurrentLoop](./CurrentLoop.md) |
| ライブゼロ | 測定値0を4mAに割り当て、0mAを故障判定に使う設計 | [CurrentLoop](./CurrentLoop.md) |
| シャント校正 | 校正用の既知抵抗をブリッジに並列に入れて疑似信号を作る方法（本システムでは未使用） | — |

## ノイズ・接地系

| 用語 | 定義 | 詳細 |
| --- | --- | --- |
| シールド | 信号線を筒状に覆う網。外来ノイズを遮る。**接地は片側だけ** | [Shield](./Shield.md) |
| グラウンドループ | シールドやGNDが輪になった状態。大地電位差で電流が回りノイズ源になる | [Shield](./Shield.md) |
| 信号グラウンド | 電圧を測る基準の0V。アースやシールドとは別物 | [Shield](./Shield.md) |
| 保護接地（アース/PE） | 感電防止のための大地への逃げ道。ノイズ対策ではない | [Shield](./Shield.md) |
| 特性インピーダンス | 高周波信号がケーブルを進むときの流れやすさ。同軸の「50Ω」はこれであり、**テスターで測れる抵抗ではない** | [Coax](./Coax.md) |

## 通信・システム系

| 用語 | 定義 | 詳細 |
| --- | --- | --- |
| Modbus RTU | 工場装置間の通信ルール。マスタが聞いてスレーブが答える。バイナリ+CRC16 | [ModbusRTU](./ModbusRTU.md) |
| マスタ／スレーブ | 通信の主導側／応答側。本システムではPC＝マスタ、基板＝スレーブ(ID=1) | [ModbusRTU](./ModbusRTU.md) |
| レジスタ | 16bitの番号付き箱。入力レジスタ0〜15がAI、ホールディングレジスタ0〜7がAO(mV) | [ModbusRTU](./ModbusRTU.md) |
| CRC | 誤り検出用の符号。RTUはフレーム末尾にCRC16を付ける | [ModbusRTU](./ModbusRTU.md) |
| USB CDC ACM | USB機器をCOMポートに見せる標準規格。Nano R4は変換ICなしのネイティブUSB | [USBCDC](./USBCDC.md) |
| COMポート | WindowsがUSB機器に割り当てる通信の窓口。同時に1ソフトしか開けない | [USBCDC](./USBCDC.md) |
| ボーレート | シリアル通信の速度表記。CDCでは実効速度の上限にならない（38400は表記上の値） | [USBCDC](./USBCDC.md) |
| ファームウェア | 機器（マイコン）の中で動くプログラム。基板の振る舞いそのものを決める | [Arduino](./Arduino.md) |
| スケッチ | Arduinoでのプログラムの呼び名。拡張子`.ino` | [Arduino](./Arduino.md) |
| ガーバーデータ | 基板工場に渡す業界標準の製造データ。`Gerber.zip`をアップロードして発注 | [PCB](./PCB.md) |
| BOM | Bill of Materials（部品表）。型番と個数の一覧 | [PCB](./PCB.md) |
| SMD | 表面実装部品。基板表面に貼る小さなタイプ | [PCB](./PCB.md) |

## 運用系

| 用語 | 定義 | 詳細 |
| --- | --- | --- |
| 校正（キャリブレーション） | 生データをN・kg・mm等の物理量に翻訳する作業。2次式 a·x²+b·x+c の係数を設定 | [Calibration](./Calibration.md) |
| Tare（風袋引き） | その瞬間の値を0にする操作。傾きは変えずオフセットだけずらす | [Calibration](./Calibration.md) |
| 塑性変形 | 除荷しても元に戻らない変形。除荷時も測らないと見つからない | [Calibration](./Calibration.md) |
| ポーリング | マスタが一定周期で読み取り要求を繰り返すこと。本システムは100ms固定 | [Logger](./Logger.md) |
| PWA | ブラウザの「インストール」機能に対応したアプリ形態。オフライン動作可 | [Logger](./Logger.md) |
| Pyodide | ブラウザ内で動くPython。ScriptRunnerの実行環境 | [ScriptRunner](./ScriptRunner.md) |

## 関連ページ

[はじめてガイド](./GettingStarted.md) ／ [仕様まとめ](./Specs.md) ／ [センサー接続早見表](./Sensors.md)

