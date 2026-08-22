# ArduinoNanoR4とは

今までのArduinoと違い、USB機能が強化された、ARM系マイコンです。

マイコンは **Renesas RA4M1（Arm Cortex-M4 48MHz / Flash 256KB / SRAM 32KB）**。従来のNano（ATmega328P: 16MHz / Flash 32KB / SRAM 2KB）と比べると一桁大きいので、RTOSも余裕で動きます。

今までと大きく違うのが、シリアルポート（COMポート）を開き直してもデバイスにリセットが掛からないことです。

シリアル通信は、変換ICを挟まないため、ほぼ遅延なしでPCとの通信が可能です。

## ざっくり仕様

| 項目 | 内容 |
| --- | --- |
| マイコン | Renesas RA4M1（32bit ARM Cortex-M4） |
| 動作電圧 | 5V（I/Oも5Vなので、5V部品と直結できる） |
| USB | マイコン内蔵のUSB（CDC）。変換ICなし |
| 大きさ | 従来のNanoと同じ。ピン配置も互換 |

## 本システムでの役割

Modbus RTUの「スレーブ（ID=1）」として動きます。

- HX711とADS1115から測った値を、レジスタに置いて待つ
- PCのブラウザから読み出し要求が来たら返す
- 出力の指示が来たらGP8403に渡す

つまり基板とPCの仲立ち役です。詳しくは [ModbusRTU.md](./ModbusRTU.md) を参照。

## 初心者向けの注意

- 5V品ですが、**アナログ入力に5.3Vを超える電圧を入れない**こと（→ [ADS1115.md](./ADS1115.md)）
- 書き込み時の「ボード」選択は必ず **Arduino Nano R4**。UNO R4やNano Every用のビルドは動きません
- リセットが掛からない＝計測中にアプリを開き直しても値が飛びません。従来Nanoからの乗り換え理由はここが大きいです（仕組みは [USBCDC.md](./USBCDC.md)）

## 関連ページ

[Arduino](./Arduino.md) ／ [USB CDC ACM](./USBCDC.md) ／ [Modbus RTU](./ModbusRTU.md) ／ [基板とKiCAD](./PCB.md)
