# YOLOv11 EZ Trainer

[English](#english) | [繁體中文](#繁體中文) | [日本語](#日本語)

---

## English

A powerful, interactive, and foolproof PowerShell CLI tool designed to completely automate your Ultralytics YOLOv11 training pipeline. Stop memorizing long commands and debugging YAML paths—this "Swiss Army Knife" guides you through the entire setup process with a sleek, GUI-like terminal experience.

### Features
* **Interactive State Machine (Undo at any time):** Made a typo? Selected the wrong folder? Just type `b` at any prompt to magically go back to the previous step.
* **Drag & Drop Magic:** No more manual path typing. Simply drag and drop your project folder or `data.yaml` directly into the terminal.
* **Smart Model Assembler:** Select your vision task (Detection, Segmentation, Pose, OBB, Classification) and size, and the script automatically fetches the correct official weights (e.g., `yolo11m-seg.pt`). Custom `.pt` files are also fully supported!
* **Advanced VRAM Management:** Fully supports Ultralytics AutoBatch. Input `-1` to auto-calculate the optimal batch size, or `0.5` to strictly use 50% of your available GPU VRAM.
* **Zero-Touch Environment Setup:** Automatically locates your Conda installation, activates the selected environment via `conda run`, and installs `ultralytics` in the background if it's missing.

### Compatibility
* **Supported Models:** Fully supports **Ultralytics YOLOv11** (All vision tasks). *Support for future architectures (e.g., YOLOv12 ~ 26+) is planned for upcoming updates!*
* **Operating System:** Windows 10 / 11 (Requires PowerShell).
* **Hardware:** Optimized for NVIDIA GPUs with CUDA support (RTX 50, 40, 30 series, etc.). CPU training is supported, but a dedicated GPU is highly recommended for the `AutoBatch` feature.

### How to Use
1. Download `Yolo_EZ_Trainer.ps1`.
2. Open **PowerShell as Administrator**.
3. Navigate to the folder containing the script.
4. Run: `.\Yolo_EZ_Trainer.ps1`

*(Tested & Optimized on NVIDIA GeForce RTX 5080 / CUDA 13.1)*

---

## 繁體中文

這是一個強大、互動且具備極致防呆機制的 PowerShell 腳本，旨在全自動化您的 Ultralytics YOLOv11 訓練流程。不再需要死記硬背長串指令或為路徑報錯而頭痛——這把「AI 瑞士刀」將透過優雅的純文字選單，帶您無痛完成所有設定。

### 核心功能
* **時光機防呆機制 (隨時回溯)：** 打錯字？選錯資料夾？在任何步驟只要輸入 `b`，就能瞬間回到上一步重新設定，徹底告別重頭來過的挫折感。
* **無痛拖曳輸入：** 支援直接將專案資料夾或 `data.yaml` 拖曳至終端機視窗，腳本會自動清理路徑與引號。
* **智慧模型組裝：** 依序選擇視覺任務（偵測、分割、姿態、旋轉框、分類）與模型大小，腳本會自動為您精準拼湊出官方權重檔名（如 `yolo11m-seg.pt`）。亦支援自訂權重檔輸入！
* **進階顯存控管：** 完美支援 YOLO AutoBatch。輸入 `-1` 即可讓引擎自動計算最佳 Batch Size，或輸入 `0.5` 指定僅使用 50% 的 GPU 顯示記憶體。
* **跨環境依賴檢查：** 自動尋找系統中的 Conda，透過 `conda run` 跨環境執行訓練，若偵測到環境缺少 `ultralytics` 套件，將於背景自動補齊。

### 💻 支援清單
* **支援模型:** 完美支援 **Ultralytics YOLOv11** 全系列任務。*未來預計持續擴充支援新世代架構 (為未來的 YOLO26 做好準備！)*
* **作業系統:** Windows 10 / 11 (需使用 PowerShell 執行)
* **硬體需求:** 針對 NVIDIA 獨立顯卡與 CUDA 加速進行深度優化 (包含最新 RTX 50 系列)。亦支援純 CPU 訓練，但強烈建議使用 GPU 以完整體驗 `AutoBatch` 顯存控管功能

### 使用方式
1. 下載 `Yolo_EZ_Trainer.ps1`
2. 以**系統管理員身分**開啟 PowerShell
3. 導航至腳本所在的資料夾
4. 輸入：`.\Yolo_EZ_Trainer.ps1`

*(已於 NVIDIA GeForce RTX 5080 / CUDA 13.1 環境下通過測試)*

---

## 日本語

Ultralytics YOLOv11 の学習パイプラインを完全に自動化するために設計された、強力でインタラクティブ、かつフェイルセーフな PowerShell CLI ツールです。長いコマンドを暗記したり、YAML パスのエラーと格闘するのはもうやめましょう。この「スイスアーミーナイフ」は、GUI のような洗練されたターミナル体験でセットアップ全体をガイドします。

### 主な機能
* **やり直し機能（状態遷移マシン）：** タイプミスやフォルダの選択ミスがありましたか？任意のプロンプトで `b` と入力するだけで、いつでも前のステップに戻ることができます。
* **ドラッグ＆ドロップ対応：** パスの手入力は不要です。プロジェクトフォルダや `data.yaml` をターミナルに直接ドラッグ＆ドロップするだけで完了します。
* **スマートモデル選択：** タスク（物体検出、セグメンテーション、姿勢推定、OBB、画像分類）とサイズを選択すると、スクリプトが公式の重みファイル名（例：`yolo11m-seg.pt`）を自動生成します。カスタム `.pt` ファイルもサポートしています。
* **高度な VRAM 管理：** AutoBatch を完全にサポート。`-1` を入力すると最適なバッチサイズを自動計算し、`0.5` を入力すると利用可能な GPU VRAM の 50% を正確に使用します。
* **環境自動セットアップ：** Conda を自動的に探し出し、`conda run` を使用して環境を切り替えます。`ultralytics` パッケージが不足している場合は、バックグラウンドで自動的にインストールします。

### 対応環境・互換性
* **対応モデル:** **Ultralytics YOLOv11** の全タスクを完全サポート。*将来のバージョン（YOLOv26 など）への対応も今後のアップデートで予定しています！*
* **OS:** Windows 10 / 11 (PowerShell が必要です)。
* **ハードウェア:** CUDA 対応の NVIDIA GPU (RTX 50シリーズなど) に最適化されています。CPU での学習も可能ですが、`AutoBatch` 機能を利用するには GPU が強く推奨されます。

### 使用方法
1. `Yolo_EZ_Trainer.ps1` をダウンロードします。
2. **管理者として PowerShell** を開きます。
3. スクリプトが保存されているフォルダに移動します。
4. 実行：`.\Yolo_EZ_Trainer.ps1`

*(NVIDIA GeForce RTX 5080 / CUDA 13.1 環境にて動作確認済み)*

---

*Enjoy a smarter way to train your YOLO models! :3*