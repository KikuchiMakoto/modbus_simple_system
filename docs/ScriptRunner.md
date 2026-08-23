# ScriptRunner（自動制御ガイド）

計測アプリに内蔵されたPython（Pyodide）で、測定と出力を自動で回す機能の解説です。追加インストールは不要です。

> 🔰 使い方の基本（タブ操作・Import/Export・System Log）は [計測アプリ](./Logger.md) と [loggerリポジトリのREADME](https://github.com/KikuchiMakoto/modbus_simple_logger) を参照。このページは**APIの性格と、材料試験での使いどころ**をまとめています。

## API一覧

アプリ内のAPI Reference（`scriptLanguages.ts`）に準拠。ch はチャネル番号です。

| API | 同期/非同期 | 中身 |
| --- | --- | --- |
| `await asyncio.sleep(s)` | — | 待ち時間は秒。**0.1秒未満禁止・`time.sleep()`厳禁**(後述) |
| `GetAiRaw(ch)` | 同期 | AI ch(0〜15)の生データ |
| `GetAiPhy(ch)` | 同期 | AI chの校正後物理値(a·Raw²+b·Raw+c)。**戻り値はスカラー**(配列ではない) |
| `SetAiTare(ch)` | 非同期 | 現在値が0になるようcを調整(a,bは据え置き) |
| `GetAo(ch)` | 同期 | AO ch(0〜7)の出力電圧 **[V]**(最後に適用された値) |
| `SetAo(ch, vlt)` | 非同期 | AO chへ出力 **[V]**。**0〜10Vにクランプ**(負値は0になる) |
| `GetParam(ch)` | 同期 | Parameter ch(0〜15)の値(float32)。**`==`で比較しない**(後述) |
| `SetParam(ch, val)` | 同期 | Parameter chへ値を置く(float32丸め)。画面表示・TSV記録される。永続化なし |
| `SetParamLabel(ch, text)` | 非同期 | Paramラベル設定。`""`で消す。UI編集と同様に永続化 |
| `Elapsed()` | 同期 | Startからの経過秒。単調（日付変わっても巻き戻らない） |

> ⚠️ **`SetAo()` / `GetAo()` の単位は [V]。** 一方、Modbus RTUのホールディングレジスタを直接読み書きするときの単位は **mV**（`10000` ＝ 10V）です。ScriptRunnerからはAPI経由なので[V]、外部ツールからレジスタ直叩きする場合は[mV]、と覚えてください。

> 🔰 importできるのは `asyncio` と `math` だけです（ネットワークがないため numpy / pandas はロード不可）。

## 重要な性格：読み取りは同期・書き込みは非同期

**読み取りは同期**（共有メモリから直接）、**書き込み（SetAo / SetAiTare / SetParamLabel）は非同期**（Modbusの転送が直列化されるため）です。

つまり **`SetAo()` の直後に `GetAo()` を呼んでも、まだ前の値が返ります。**「書いてすぐ読んで確認する」コードは正しく動きません。確認読みは次のイテレーション以降にしてください。

## 絶対に守るルール（破るとフリーズ・停止不可になります）

アプリがAIプロンプトに載せている規則(`promptRules`)と同じものです。これらは「動くけど危険」ではなく**確実に事故になる**ものです。

1. **待ち方は `await asyncio.sleep(s)` 一択。** `time.sleep()`・ビジーウェイト・`input()` はランタイムを占有し、**Stopが効かなくなる**
2. **0.1秒未満のsleep禁止。** 読み取り値はModbusポーリング周期(100ms)でしか更新されないので、それより速いループは同じ値を再読みするだけ
3. **すべてのループのすべての経路でsleepに到達すること。** ループ末尾に置き、`continue`で飛び越えさせない
4. **`while True:`だけの無限ループを書かない。** Stopで止まりますが、終了条件を持たないスクリプトは「完走したのか中断されたのか」を残せません。期限・目標到達・ステップ数など、必ず終わる条件を入れる（Stopまで回し続けたい試験なら、それが仕様だと明示的に書く）
5. **並行処理を使わない。** `asyncio.run()` / `create_task()` / `gather()` / スレッド等は禁止。すでにイベントループの中で動いており、Stopの対象外で動き続ける恐れがある。「2つ同時に」は1つのループで順番にやる
6. **素の `except:` や `except BaseException:` で例外を握らない。** Stopは例外として届くので、握ると止まらなくなる
7. **符号の前提を問う。** AI/AOチャネルのプラス・マイナスが物理的にどちらを意味するかは装置ごとに違う。ラベルだけでは分からないので、符号に依存するコードを書く前にユーザーに確認する

## やってはいけない使い方（制御編）

- **AOでオンオフ制御をしない。** ループは約5Hz(0.2s)。フルスケール指令が200ms放置されるのは制御ではなく振動です。オンオフが妥当なのは「開/閉の2値しかないバルブ」などAOをデジタル代わりに使う場合だけ
- **Paramをカウンタや積算器に使わない。** float32(有効桁約7桁)で丸められるため、累積誤差が出ます。走行合計はPython変数で持ち、表示用だけParamへ
- **float32の `==` 比較をしない。** `SetParam(0, 0.3)` の後の `GetParam(0)` は `0.3000000119...` です。許容誤差比較(`abs(x-0.3)<1e-6`)を使う
- **モータ・空圧機器は生の `SetAo()` を直接呼ばず、名前付きヘルパ関数で包む。** `SetMotorSpeed(mm_per_min)` のように物理単位で呼べる関数の中に、ch番号・極性・V換算定数・クランプを一箇所に集める。テスト計画と照合できる形になります

## Stopと再開の作法

- **実行状態はParamに置く。** 変数はStartのたびに初期化されますが、Paramと名前空間は残ります。「Stop→Startで続きから」を実装するならフェーズ番号をParamに入れ、起動時に読んで完了済みステップをスキップする
- **`Elapsed()` はStartごとに0に戻る。** 再開をまたぐ期限は「残り秒」をParamに置いてカウントダウンする形にする
- **AOはStop後も最後の値を保持し続ける。** スクリプトのヘッダコメントに「止めたとき出力がどうなるか」を書くこと。危険な保持値を出すスクリプトなら、終了時に0へ戻す処理を入れる
- **print()は控えめに。** System Logは有限(直近2000行)なので、毎イテレーションの出力は他のログを押し流します。状態変化時とN回に1回、`Elapsed()`付きで出す。結果はSystem LogのCopyボタン経由でのみ手元に戻るため、読み返す必要があるものは整形して印字する

## 最小例：書いて→待って→読む

```python
import asyncio

await SetAo(0, 5.0)         # AO0へ5V指示（非同期：転送はこれから行われる）
await asyncio.sleep(0.2)    # 転送とデバイスの応答を待つ
v = GetAo(0)                # ここでようやく 5.0 が読める（V単位）
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
        print(GetAiPhy(0))                # 保持中も値を見えるように出す
print("done")
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
        print(f"load c{cycle} {v}V: {GetAiPhy(0)}")
    # 除荷（MAX → 0）。**ここが重要**：戻り値が0点に戻るか見ている
    for i in range(5, -1, -1):
        v = MAX_V * i / 5
        await SetAo(0, v)
        await asyncio.sleep(STEP_DWELL)
        print(f"unload c{cycle} {v}V: {GetAiPhy(0)}")
print("done")
```

除荷終端の値が最初の0点に戻らなければ、塑性変形・座屈などを疑います（→ [Calibration](./Calibration.md) の⚠️）。

## レシピ③ 目標値への簡易フィードバック

`GetAiPhy(ch)` を見ながら `SetAo()` を回す、P制御的な使い方です。終了条件（ここでは60秒）を必ず入れます。

```python
import asyncio

TARGET = 10.0    # 目標物理値
KP = 0.8         # 比例ゲイン [V/単位ずれ]
AO_CH = 0        # 出力チャネル
AI_CH = 0        # フィードバックチャネル
TIMEOUT = 60.0   # 秒。必ず終わる条件を入れる

while Elapsed() < TIMEOUT:
    err = TARGET - GetAiPhy(AI_CH)
    v = max(0.0, min(10.0, KP * err))      # 0〜10Vにクランプ
    await SetAo(AO_CH, v)
    await asyncio.sleep(0.2)
await SetAo(AO_CH, 0.0)                    # 終了時に出力を戻す
print("done")
```

Stopはどんなループの中でも効きますが、上記のとおり終了条件を持たせるのが作法です。

> ⚠️ **フィードバック制御を回す前に必ず手動確認を。** ゲインが大きすぎると出力が振動します。まず `KP` を小さく始め、装置にストッパ（機械的限界）があることを確認してから自動化してください。モータや空圧機器の力・圧制御は**ダミー試料でチューニング**するのが前提です（アプリ内AIプロンプトにも同旨の規則があります）。

## 初心者向けの注意

- API名は **PascalCase**（`SetAo()`）。snake_case（`set_ao()`）では動きません
- 校正していないチャネルの `GetAiPhy(ch)` は、生データに係数が掛かっただけの値です。**スクリプトより先に校正**（→ [Calibration](./Calibration.md)）
- 実行中はエディタが読み取り専用になります（Runした時点のコードが渡っているため）
- 長時間実行の前に、TSV保存の保存レート設定を確認しておく（→ [Logger](./Logger.md)）
- スクリプトの異常は System Log に ERROR で出ます。動かないときはまずそこを見る

## 関連ページ

[計測アプリ](./Logger.md) ／ [キャリブレーション](./Calibration.md) ／ [Modbus RTU](./ModbusRTU.md) ／ [困ったときは](./Troubleshooting.md)

