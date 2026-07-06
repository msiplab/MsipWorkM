# MsipWorkM

村松正吾『多次元信号・画像処理の基礎と展開』（コロナ社）の MATLAB サンプルコード集です。
本文の例・例題および章末問題に対応するライブスクリプト（プレーンテキスト .m 形式）を収録しています。

Python 版は [MsipWorkPy](https://github.com/msiplab/MsipWorkPy) を参照してください（準備中）。

## 動作環境

- MATLAB R2025b / R2026a で動作確認
- 必要なツールボックス
  - Image Processing Toolbox
  - Deep Learning Toolbox（第9〜10章）
- 第9章の NSOLT 設計例（example09_03）は同梱の [SaivDr パッケージ](https://github.com/msiplab/SaivDr)（`code/SaivDr-*`）を利用します

## 使い方

MATLAB でプロジェクトファイルを開くと、パス設定が自動で行われます。

```matlab
openProject('msip_project.prj')
```

その後、各章のスクリプトを実行してください。

```matlab
example03_02   % 例3.2（ガウシアンフィルタ）
```

- 学習を伴うスクリプト（example09_02, 09_03, 10_02 など）は、学習済みパラメータが
  `data/` にあればそれを読み込み、なければ学習を実行して保存します。
- 依存関係のあるスクリプトは実行順に注意してください
  （例：example10_03 / 10_04 は example10_02 の学習結果を利用します）。

## フォルダ構成

```
MsipWorkM/
├── code/
│   ├── scripts/ch01 ... ch10   例・例題（example*.m）と章末問題（exercise*.m）
│   ├── +msip/                  共通ユーティリティ関数
│   └── SaivDr-*/               NSOLT 設計用パッケージ（第9章）
├── data/                       画像データ・学習済みパラメータ（.mat）
├── results/                    スクリプトが出力する図・画像
└── msip_project.prj            MATLAB プロジェクトファイル
```

## 章別スクリプト一覧

| 章 | 内容 | example | exercise |
|----|------|--------:|---------:|
| ch01 | 多次元信号・画像処理の概要 | 14 | 2 |
| ch02 | 画素処理 | 6 | 5 |
| ch03 | 近傍処理 | 9 | 11 |
| ch04 | 周波数解析 | 6 | 3 |
| ch05 | 幾何処理 | 2 | 2 |
| ch06 | 画像変換 | 8 | 5 |
| ch07 | 画像近似 | 7 | 5 |
| ch08 | 画像復元 | 3 | 0 |
| ch09 | 辞書学習 | 3 | 3 |
| ch10 | 学習復元 | 6 | 0 |

スクリプト名 `exampleCC_NN.m` は本文の例・例題 CC.NN に対応します
（各ファイル冒頭のヘッダに対応する例・例題名を記載）。

## データ

- `msipimg*.tif` : 本書用のサンプル画像
- `kodim*.png` : [Kodak Lossless True Color Image Suite](https://r0k.us/graphics/kodak/)
- `example*.mat` : 学習済みパラメータ（再学習で再生成可能）

## ライセンス・著作権

© Shogo MURAMATSU, All rights reserved.

書籍の内容・正誤情報については出版社のサポートページを参照してください。
