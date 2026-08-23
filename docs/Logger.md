# 計測アプリ（modbus_simple_logger）

ブラウザ上で動く Modbus RTU ロガーです。インストール不要で、Chrome / Edge で開くだけで使えます。

👉 **https://kikuchimakoto.github.io/modbus_simple_logger/**

> 🔰 ロガー＝計測データを記録するソフト、Modbus RTU＝このシステムで基板とやり取りするときの通信の決まり（→ [ModbusRTU.md](./ModbusRTU.md)）です。今は分からなくても先へ進めます。

## まず開く

1. Arduino Nano R4 をUSB接続する
2. 「接続」ボタンからシリアルポート（COMポート＝WindowsがUSB機器を見つけたときに割り当てる通信の窓口）を選ぶ
3. AI0〜AI15の値がグラフに出れば成功

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
| Tutorial | メニュー最上部の初学者案内。ステップ0〜8を必須／推奨／任意バッジ付きで表示、EN/JA切替可（→ 下記「Tutorial」） |
| キャリブレーション | チャネルごとの2次式（a·x²+b·x+c）とワンタッチTare。JSON入出力対応（→ [Calibration.md](./Calibration.md)） |
| TSV保存 | File System Access API によるストリーミング保存。保存中のクラッシュからも復旧します |
| ScriptRunner | 内蔵Python（Pyodide）で `GetAiPhy(ch)` / `SetAo(ch, vlt)` などを自動実行。Stopはどんなループでも効きます（→ [ScriptRunner.md](./ScriptRunner.md)） |
| PWA | ブラウザの「インストール」機能に対応。インストールすればインターネット無し（オフライン）でも動きます |

## ScriptRunnerの単位だけ、ここでも一度

- **ScriptRunner API（`SetAo` / `GetAo`）＝ V単位**（小数可）
- **Modbusホールディングレジスタ直叩き ＝ mV単位**（10V = `10000`）

この2つは数値が1000倍違います。詳細と注意点は [ScriptRunner.md](./ScriptRunner.md) へ。

## Tutorial（メニュー最上部の🔰）

アプリ内に組み込まれた初学者向けの手順ガイドです。メニューの **Tutorial** で開き、**EN/JA** を切り替えられます。各ステップには重要度バッジが付いています。

| バッジ | 意味 |
| --- | --- |
| **MUST**（必須） | 飛ばすと記録や制御が正しく成立しない |
| **RECOMMEND**（推奨） | やらないと精度・効率が落ちる |
| **OPTIONAL**（任意） | 上級者向け |

### ログ・制御 共通項目

**ステップ0【MUST】Connector Manual を参照してセンサーを接続**

HX711・ADS1115・GP8403など不明な単語は、GitHubの [ModbusSimpleSystem](https://github.com/KikuchiMakoto/modbus_simple_system) ページか、AI（Gemini, ChatGPT, Claude等）に聞くこと。基板のリビジョンで配線は異なる——**実物のシルク印刷が常に正しい情報源。**

**ステップ1【MUST】使用するチャネルのラベルを記入**

物理値の単位が分かる場合は `[mm]`・`(kN)` のように括弧書きでラベルに含めること。このラベルは **TSVヘッダーとAIプロンプトに使われる**ので、来月の自分が見ても分かる名前を付けること。特殊な注意事項はすべて Device Memo に追記すること。

**ステップ2【RECOMMEND】Input Calib Value または Input Calibrator でキャリブレーション**

キャリブレーションしないと、物理量ではなく **ADCの生値を記録することになる**。既にExcel等でRaw→物理値の計算が済んでいるなら Input Calib Value に直接入力。今から校正するなら Input Calibrator——単押しで瞬時値、長押しで平均値が取得できる。

**ステップ3【RECOMMEND】Device Memo に記入**

個人的な日記をたらたら書くのだけはNG。それ以外は何でもOK——有効なデータ、この日にキャリブレーションのズレがあった、機械的な限界、変な動きをした、動作がおかしかった等、**装置の特徴を書いておくこと。**

### 制御専用項目

**ステップ4【RECOMMEND】Device Memo にとにかくたくさん追記**

Device Memo は **AI Promptに利用される**ので、とにかくたくさん書く。どんなセンサーを使っているか、仕様をこう変更した、異音がした等、フィードバックや制御対象に関する事項を何でも書き込んでおくこと。**AIはあなたの装置について常識を持っていない**——あなたにとって自明なことでも書くこと。

**ステップ5【RECOMMEND】Output Setter で出力を確認**

出力に対する挙動をまだ知らない場合は、実際に動かして確認すること。範囲を掃引して**不感帯や飽和を調べる。**得られたキャリブレーション値、不感帯、出力限界——とにかくたくさん Device Memo に記載すること。

> ⚠️ **10Vで壊れるものに10Vを掛けてはいけない。** 全範囲を掃引する前に、接続先の定格を必ず確認すること。

**ステップ6【MUST】Script Runner ページ下部の API Reference を読む**

Pythonで制御するにあたっての、このアプリ独自の制御API（`GetAiPhy` / `SetAo` / `SetParam` …）をざっと読むこと。使い方を間違えると、ScriptRunした瞬間にアプリが止まる。

**ステップ7【MUST】Copy AI Prompt を使ってAIでコーディングを試す（Gemini, ChatGPT, Claude等）**

Flagshipモデルを推奨する理由：200〜300行を超えるようなコントロールになると、無料・低価格モデルでは意図しないプログラムをAIが出力する恐れがある。**装置を壊したくなければ、自分でコードを確認するか、本当にFlagship/最先端なモデルを使うこと。**不安なら事前にそのAIに相談を。

Copy AI Prompt を押すと、ステップ1〜6の情報に加えて、作者（Kuno MAKOTO）が考えた最低限の最適プロンプトがコピーされる。これをお気に入りのAIに入力して制御プログラムを作成してもらうこと。

### 大いなる力を求める者

**ステップ8【OPTIONAL】プログラムをForkする**

やりたいことが複雑な場合は、GitHubで公開されているこのプログラム——[modbus_simple_logger](https://github.com/KikuchiMakoto/modbus_simple_logger)——をForkして改造版を自作すること。やり方は勉強するかAIに聞く。さらなる機能追加、よく使う機能のAPI化・固定、安定化・ロバスト化ができる。

> 🕷 大いなる力には大いなる責任が伴う 🕷

> 🔰 このページの説明はアプリ内 Tutorial の要約です。UI上の名称（Chip表示）が常に正なので、食い違いがあれば実物を優先してください。

## 初心者向けの注意

- **校正値はそのPCのブラウザの中にしかありません。** サイトデータの削除・PCの載せ替えで警告なく消えます。JSON書き出しや紙のメモで必ずバックアップしてください（→ [Calibration.md](./Calibration.md)）
- COMポートは同時に1つのソフトしか開けません。Arduino IDEのシリアルモニタを閉じてから接続してください（→ [USBCDC.md](./USBCDC.md)）
- ScriptRunnerのAPIは **PascalCase**（`SetAo()`）です。snake_case（`set_ao()`）では動きません
- ポートが突然消えたら、ケーブルより先にファームウェアの停止・リセットを疑ってください（→ [USBCDC.md](./USBCDC.md)）

## 関連ページ

[はじめてガイド](./GettingStarted.md) ／ [キャリブレーション](./Calibration.md) ／ [Modbus RTU](./ModbusRTU.md) ／ [USB CDC ACM](./USBCDC.md) ／ [仕様まとめ](./Specs.md)
