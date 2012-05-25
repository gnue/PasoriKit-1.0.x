# PasoriKit

Cocoaアプリで FeliCaリーダ "PaSoRi" を使うためのフレームワークです。

* [Cocoa Life Vol.4][cocoa-life] にて原稿『PaSoRi x Mac 応用編』を寄稿しています

[cocoa-life]: http://www.cocoa-study.com/book/

#### 特徴

* Cocoaアプリケーションとの相性がいい
* USBデバイスの挿抜に対応
* タッチ／アンタッチの自動判別
* 非同期通信なので UI をブロックしない
* フレームワークのインストールが不要
* Suica/Edyデータためのユーティリティ（構造体、マクロ等）を用意
* 無料・無保証

#### 新着情報

* [2012-05-25] github に移動
* [2009-10-06] バージョン 1.0.1 を公開しました
* [2008-08-14] Cocoa Life Vo.4 の発売に合わせて PasoriKit を公開しました
* [2008-08-14] 8/16(土) コミケ２日目 西-"く"13a にて Cocoa Life Vo.4 が販売されます
* [2008-07-16] 公開準備

#### 動作環境

* Mac OS X 10.5以上
* Xcode 3.0 以上
* [PaSoRi RC-S320](http://www.amazon.co.jp/exec/obidos/ASIN/B0009YVAW4/gnue-22)

#### 更新履歴

* [2009-10-06] 1.0.1
  * 動作環境を Mac OS X 10.5 以上に変更
  * USBDeviceクラスに reopenメソッドを追加。スリープ解除からの自動復帰サポート
  * x86_64バイナリに対応
  * PASORI_STATE_POLLING_DONE で処理をしなかったときに PASORI_STATE_IDLE に状態遷移しない問題を修正
* [2008-08-14] 1.0 最初の公開バージョン

#### ドキュメント

現在のところ Cocoa Life Vo.4 の記事とサンプルソースコードしかありません。<br/>
余裕があったらそのうち整備します....たぶん

* [PasoriKit FAQ](PasoriKitFAQ.md)

#### ライセンス

PasoriKitフレームワーク

* 本ソフトウェアにはいかなる保証もありません
* 本ソフトウェアによって生じたいかなる損害に関しても一切責任を負わないものとします
* 自由にアプリに組込んで配布することができます
* なお、特に利用制限はありませんが、公式フレームワークではありませんのでそれを踏まえ、常識的な判断でご使用下さい

サンプルコード

* 修正BSDライセンス

#### ダウンロード

[最新版]

* [github レポジトリを参照](https://github.com/gnue/PasoriKit-1.0.x)

[v1.0.1]

* [ParoriKitフレームワーク 1.0.1](http://trac.so-kukan.com/tools/attachment/wiki/PasoriKit/PasoriKit1.0.1.dmg)
* [Suica利用履歴サンプル 1.0.1](http://trac.so-kukan.com/tools/attachment/wiki/PasoriKit/SuicaExample1.0.1.dmg)
  ([実行ファイル](http://trac.so-kukan.com/tools/attachment/wiki/PasoriKit/SuicaExample1.0.1app.dmg))
* [Edy利用履歴サンプル 1.0.1](http://trac.so-kukan.com/tools/attachment/wiki/PasoriKit/EdyExample1.0.1.dmg)
  ([実行ファイル](http://trac.so-kukan.com/tools/attachment/wiki/PasoriKit/EdyExample1.0.1app.dmg))

[v1.0]

* [ParoriKitフレームワーク 1.0](http://trac.so-kukan.com/tools/attachment/wiki/PasoriKit/PasoriKit1.0.dmg)
* [Suica利用履歴サンプル 1.0](http://trac.so-kukan.com/tools/attachment/wiki/PasoriKit/SuicaExample1.0.dmg)
  ([実行ファイル](http://trac.so-kukan.com/tools/attachment/wiki/PasoriKit/SuicaExample1.0app.dmg))
* [Edy利用履歴サンプル 1.0](http://trac.so-kukan.com/tools/attachment/wiki/PasoriKit/EdyExample1.0.dmg)
  ([実行ファイル](http://trac.so-kukan.com/tools/attachment/wiki/PasoriKit/EdyExample1.0app.dmg))

#### 作者

GNUE(鵺)

#### 参考

* [IC SFCard Fan](http://www014.upp.so-net.ne.jp/SFCardFan/)
* [FeliCa Library Wiki @ SF.jp](http://sourceforge.jp/projects/felicalib/wiki/FrontPage)
* [PaSoRi解析情報(osdev-j)](http://wiki.osdev.info/index.php?PaSoRi%2FRC-S320)
* [libpasori](http://libpasori.sourceforge.jp)
* [Sony Japan | FeliCa](http://www.sony.co.jp/Products/felica/)
