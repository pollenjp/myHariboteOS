# day04 ポインタに挑戦 - harib01c

## imgファイル作成

```
$ make
```

## 実行

```
$ make run
```

`ref/`には実行に関係ないファイルをしまっておくことにした

## `(char *)`をつけなかった時のエラー

```
gcc -march=i486 -m32 -nostdlib \
        -T os.lds \
        -o bootpack.hrb \
        bootpack.c nasmfunc.o
bootpack.c: In function ‘HariMain’:
bootpack.c:16:7: warning: assignment makes pointer from integer without a cast [-Wint-conversion]
     p = i;          // 番地の代入
       ^
cat asmhead.bin bootpack.hrb > haribote.sys
```
