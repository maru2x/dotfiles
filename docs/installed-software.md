## 概要

本ドキュメントでは、`Brewfile`に記載されている各ソフトウェアについて、詳細な説明を提供する。

## 各ソフトウェアの詳細な説明


### bandwhich

`bandwhich` はネットワーク監視ツール．
このソフトウェアの実行にはsudo権限が必要であることと、brewで入れたソフトウェアはsudo権限で実行できないという理由から、`setcap`によって特殊な権限を付与する運用とする。
これにより、`sudo`権限ではないものの特権的な権限を`bandwidth`に持たせることができる。
実行時には、 `bandwhich -i wlp3s0` などをユーザー権限で実行できる。


`setcap`により`bandwhich`に特殊な権限をもたせるために、以下のコマンドを実行。
```
  sudo apt install libcap2-bin
  sudo setcap 'cap_sys_ptrace,cap_dac_read_search,cap_net_raw,cap_net_admin+ep' "$(readlink -f "$(command -v bandwhich)")"
```
