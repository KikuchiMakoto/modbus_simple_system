# ScriptRunner（自動制御ガイド）

計測アプリに内蔵されたPython（Pyodide）で、測定と出力を自動で回す機能の解説です。追加インストールは不要です。

> 🔰 使い方の基本（タブ操作・Import/Export・System Log）は [計測アプリ](./Logger.md) と [loggerリポジトリのREADME](https://github.com/KikuchiMakoto/modbus_simple_logger) を参照。このページは**APIの性格と、材料試験での使いどころ**をまとめています。

## API一覧

| API | 動作 | 中身 |
| --- | --- | --- |
| `GetAiRaw()` | 読み取り | AI0〜15の生データ |
| `GetAiPhy()` | 読み取り | 校正後の物理値 |
| `GetAo()` | 読み取り | 現在のAO出力値（**V単位**） |
| `GetParam()` | 読み取り | Parameterチャネルの値 |
| `SetAo()` | 書き込み | AO0〜7へ**V単位**で出力指示（`SetAo(0, 5.0)` ＝ 5V。小数可） |
| `SetParam()` | 書き込み | Parameterチャネルへ値を置く |
| `SetAiTare()` | 書き込み | 指定チャネルのTare実行 |

> ⚠️ **`SetAo()` / `GetAo()` の単位は [V]。** 一方、Modbus RTUのホールディングレジスタを直接読み書きするときの単位は **mV**（`10000` ＝ 10V）です。ScriptRunnerからはAPI経由なので[V]、外部ツールからレジスタ直叩きする場合は[mV]、と覚えてください。

## 重要な性格：読み取りは同期・書き込みは非同期

**読み取りは同期**（共有メモリから直接）、**書き込みは非同期**（Modbusの転送が直列化されるため）です。

つまり **`SetAo()` の直後に `GetAo()` を呼んでも、まだ前の値が返ります。** 「書いてすぐ読んで確認する」コードは正しく動きません。待ちには `await asyncio.sleep(s)`（単位は秒）を使います。

```python
import asyncio

await SetAo(0, 5.0)         # AO0へ5V指示（非同期：転送はこれから行われる）
await asyncio.sleep(0.2)    # 転送とデバイスの応答を待つ
v = GetAo()                 # ここでようやく 5.0 が読める（V単位）
```

## レシピ① ステップ負荷の自動印加

圧密・載荷試験の定番です。AOで荷重指令を段階的に上げ、各段で十分に待ちます。

```python
import asyncio

STEPS = [0.0, 1.0, 2.0, 3.0, 4.0, 5.0]   # V指定
DWELL = 60.0                              # 各段の保持時間（秒）

for i, v in enumerate(STEPS):
    await SetAo(0, v)                     # AO0に出力
    print(f"step {i}: {v} V")
    for t in range(int(DWELL), 0, -10):
        await asyncio.sleep(10)
        print(GetAiPhy())                 # 保持中も値を見えるように出す
```

> 🔰 `print()` の出力は System Log に流れます。長時間の実行では「今どの段階か」を出しておくと、後でTSVと突き合わせるのが楽になります。

## レシピ② 繰返し載荷・除荷ループ

[キャリブレーション](./Calibration.md) の「本気で校正するなら」（多点・往復・除荷確認）を自動でやる形です。**除荷側も測って初めて塑性変形に気づける**ので、往復はスクリプトにやらせるのが得意分野です。

```python
import asyncio

MAX_V = 5.0
N_CYCLES = 3
STEP_DWELL = 30.0

for cycle in range(N_CYCLES):
    # 載荷（0 → MAX を5分割）
    for i in range(6):
        v = MAX_V * i / 5
        await SetAo(0, v)
        await asyncio.sleep(STEP_DWELL)
        print(f"load c{cycle} {v}V: {GetAiPhy()}")
    # 除荷（MAX → 0）。**ここが重要**：戻り値が0点に戻るか見ている
    for i in range(5, -1, -1):
        v = MAX_V * i / 5
        await SetAo(0, v)
        await asyncio.sleep(STEP_DWELL)
        print(f"unload c{cycle} {v}V: {GetAiPhy()}")
```

除荷終端の値が最初の0点に戻らなければ、塑性変形・座屈などを疑います（→ [Calibration](./Calibration.md) の⚠️）。

## レシピ③ 目標値への簡易フィードバック

`GetAiPhy()` を見ながら `SetAo()` を回す、P制御的な使い方です。

```python
import asyncio

TARGET = 10.0   # 目標物理値
KP = 800.0      # 比例ゲイン（mV/単位ずれ）

while True:
    err = TARGET - GetAiPhy()[0]     # 例：AI0で制御する場合
    v = max(0.0, min(10.0, KP * err / 1000))   # mV→V換算、0〜10Vにクランプ
    await SetAo(0, v)
    await asyncio.sleep(1.0)
```

Stopはどんなループの中でも効きます。出口の無い `while True:` を書いても止められるので、試験台ではむしろ素直な無限ループ推奨です。

> ⚠️ **フィードバック制御を回す前に必ず手動確認を。** ゲインが大きすぎると出力が振動します。まず `KP` を小さく始め、装置にストッパ（機械的限界）があることを確認してから自動化してください。

## 初心者向けの注意

- API名は **PascalCase**（`SetAo()`）。snake_case（`set_ao()`）では動きません
- 校正していないチャネルの `GetAiPhy()` は、生データに係数が掛かっただけの値です。**スクリプトより先に校正**（→ [Calibration](./Calibration.md)）
- 実行中はエディタが読み取り専用になります（Runした時点のコードが渡っているため）
- 長時間実行の前に、TSV保存の保存レート設定を確認しておく（→ [Logger](./Logger.md)）
- スクリプトの異常は System Log に ERROR で出ます。動かないときはまずそこを見る

## 関連ページ

[計測アプリ](./Logger.md) ／ [キャリブレーション](./Calibration.md) ／ [Modbus RTU](./ModbusRTU.md) ／ [困ったときは](./Troubleshooting.md)

