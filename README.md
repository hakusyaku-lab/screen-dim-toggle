# screen-dim-toggle

Windows 10 / 11 の画面を、ダブルクリック1回で3段階に切り替えるバッチファイルです。モニター本体の明るさを最小にしてもまだまぶしいときに使えます。インストールは不要で、Windows 標準の機能だけで動きます。

A single batch file that cycles a Windows 10 / 11 screen through three brightness stages on each double-click. Useful when the monitor is still too bright at its minimum brightness. No install needed; it only uses built-in Windows features.

## 3段階 / Stages

| 段階 / Stage | 配色 / Theme | 夜間モード / Night light | 減光 / Dimming |
|---|---|---|---|
| 1 通常 / Normal | ライト / Light | オフ / Off | なし / None |
| 2 暗め / Dim | ダーク / Dark | オン / On | なし / None |
| 3 より暗い / Dimmer | ダーク / Dark | オン / On | 約60% / about 60% |

押すたびに 1 → 2 → 3 → 1 の順で切り替わります。

Each run moves to the next stage: 1 → 2 → 3 → 1.

## 使い方

1. **screen-dim-toggle.bat** をダウンロードして、デスクトップなど好きな場所に置きます。
2. ダブルクリックします。切り替えには2秒ほどかかります。
3. 初回に「Windows によって PC が保護されました」と出たら、「詳細情報」→「実行」で進めます。
4. 夜間モードの強さはこのファイルでは変えません。「設定 → システム → ディスプレイ → 夜間モード」で好みの強さに合わせてください。

3段階目の暗さを変えるには、ファイルをメモ帳で開き、**$dim3=0.6** の数字を変えます。1.0 が通常で、小さいほど暗くなります。Windows の下限は 0.5 くらいです。

## How to use

1. Download **screen-dim-toggle.bat** and put it anywhere, for example on the desktop.
2. Double-click it. Switching takes about two seconds.
3. If Windows shows "Windows protected your PC" on the first run, choose "More info" and then "Run anyway".
4. The file does not change the night light strength. Set it once in Settings → System → Display → Night light.

To change how dark stage 3 is, open the file in Notepad and edit **$dim3=0.6**. 1.0 is normal and smaller is darker. Windows refuses values much below 0.5.

## 注意点

- 動作確認したのは Windows 11 の PC 1台だけです。利用は自己責任でお願いします。
- 夜間モードの切り替えは、Windows が公開していない設定値（レジストリ）を書き換える方式です。Windows の更新で効かなくなることがあります。設定値の形が想定と違う場合は何も書き換えず、代わりに設定の「夜間モード」画面を開きます。
- 3段階目の減光は、スリープ復帰、全画面ゲーム、画面設定の変更などで解除されることがあります。ボタンを一周押せば戻ります。
- HDR をオンにしている画面では、3段階目の減光が効かないことがあります。
- 現在の段階はレジストリの HKCU\Software\DimToggle に記録します。

## Notes

- Tested on a single Windows 11 PC only. Use at your own risk.
- Night light is toggled by rewriting an undocumented registry value, so a Windows update may break it. If the value does not look as expected, the script changes nothing and opens the Night light settings page instead.
- The stage 3 dimming can be reset by sleep and resume, full-screen games, or display setting changes. Cycle through the stages once to restore it.
- Stage 3 dimming may have no effect on displays with HDR turned on.
- The current stage is stored in the registry under HKCU\Software\DimToggle.

## やめるとき / Uninstall

1段階目（通常）に戻してから、ファイルを削除するだけです。

Switch back to stage 1 (normal), then delete the file.

## License

MIT
