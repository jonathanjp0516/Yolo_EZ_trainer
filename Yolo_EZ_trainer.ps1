#YOLO EZ Trainer
# Search for Conda
$condaPath = $null
$cmd = Get-Command "conda.exe" -ErrorAction SilentlyContinue
if ($cmd) {
    $condaPath = $cmd.Source
} else {
    $commonPaths = @(
        "$env:USERPROFILE\miniconda3\Scripts\conda.exe",
        "$env:USERPROFILE\anaconda3\Scripts\conda.exe",
        "$env:LOCALAPPDATA\miniconda3\Scripts\conda.exe",
        "$env:LOCALAPPDATA\anaconda3\Scripts\conda.exe",
        "C:\ProgramData\miniconda3\Scripts\conda.exe",
        "C:\ProgramData\anaconda3\Scripts\conda.exe",
        "C:\miniconda3\Scripts\conda.exe",
        "C:\anaconda3\Scripts\conda.exe"
    )
    foreach ($p in $commonPaths) {
        if (Test-Path $p) {
            $condaPath = $p
            $condaDir = [System.IO.Path]::GetDirectoryName($p)
            $env:Path = "$condaDir;" + $env:Path
            break
        }
    }
}

if ($null -eq $condaPath) {
    Write-Host "[!] Conda is not installed or not found. Please install Miniconda first." -ForegroundColor Red
    Pause; Exit
}

function Get-CondaEnvs {
    return (conda env list | Where-Object { $_ -match '^\w+' } | ForEach-Object { ($_ -split '\s+')[0] })
}

#init
$step = 1
$config = @{}

while ($step -le 6) {
    Clear-Host
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "          YOLO EZ Trainer v1.1.0          " -ForegroundColor Cyan
    Write-Host "     (Input 'b' at any time to go back)   " -ForegroundColor Cyan
    Write-Host "==========================================" -ForegroundColor Cyan

    switch ($step) {
        1 {
            Write-Host "`n[Step 1/6] Select Environment" -ForegroundColor Yellow
            $envs = Get-CondaEnvs
            for ($i = 0; $i -lt $envs.Count; $i++) { Write-Host "$($i + 1). $($envs[$i])" }
            
            $input = Read-Host "Select your PyTorch/YOLO environment (Number)"
            if ($input -eq "b") { Write-Host "Already at first step."; Pause; continue }
            
            if ($input -match "^\d+$" -and [int]$input -ge 1 -and [int]$input -le $envs.Count) {
                $config.targetEnv = $envs[[int]$input - 1]
                Write-Host "  -> Selected Environment: $($config.targetEnv)" -ForegroundColor Green
                
                # Check Ultralytics
                Write-Host "`n[Checking Dependencies...]" -ForegroundColor DarkGray
                $checkYolo = conda run -n $($config.targetEnv) python -c "import ultralytics" 2>&1
                if ($LASTEXITCODE -ne 0) {
                    Write-Host "  -> 'ultralytics' not found. Installing now..." -ForegroundColor DarkYellow
                    conda run --no-capture-output -n $($config.targetEnv) pip install ultralytics
                } else {
                    Write-Host "  -> 'ultralytics' is ready!" -ForegroundColor Green
                }
                Pause
                $step++
            } else {
                Write-Host "Invalid selection! Please try again." -ForegroundColor Red; Pause
            }
        }

        2 {
            Write-Host "`n[Step 2/6] Project Workspace" -ForegroundColor Yellow
            Write-Host "Current Env: $($config.targetEnv)" -ForegroundColor DarkGray
            Write-Host "You can DRAG & DROP the folder here."
            $input = Read-Host "Enter Project Folder Path (or 'b')"
            if ($input -eq "b") { $step--; continue }
            
            $path = $input.Trim('"').Trim("'")
            if (Test-Path $path -PathType Container) {
                $config.workDir = $path
                $step++
            } else {
                Write-Host "Invalid path. Folder not found!" -ForegroundColor Red; Pause
            }
        }

        3 {
            Write-Host "`n[Step 3/6] Dataset Configuration" -ForegroundColor Yellow
            Write-Host "Workspace: $($config.workDir)" -ForegroundColor DarkGray
            Write-Host "You can DRAG & DROP your 'data.yaml' file here."
            $input = Read-Host "Enter data.yaml Path (or 'b')"
            if ($input -eq "b") { $step--; continue }
            
            $path = $input.Trim('"').Trim("'")
            if (Test-Path $path -PathType Leaf) {
                $config.yamlPath = $path
                $step++
            } else {
                Write-Host "data.yaml not found! Make sure it's a valid file." -ForegroundColor Red; Pause
            }
        }

        4 {
            Write-Host "`n[Step 4/6] Model Task & Architecture" -ForegroundColor Yellow
            Write-Host "--- Step 1: select Task ---"
            Write-Host "1. Object Detection [default]"
            Write-Host "2. Instance Segmentation"
            Write-Host "3. Pose/Keypoints"
            Write-Host "4. Oriented Detection"
            Write-Host "5. Classification"
            Write-Host "6. Custom Weight"
            $tChoice = Read-Host "Select Task (1-6, or 'b')"
            if ($tChoice -eq "b") { $step--; continue }

            if ($tChoice -eq "6") {
                Write-Host "`n--- Custom Weight ---" -ForegroundColor Yellow
                Write-Host "You can DRAG & DROP your .pt file here."
                $customPt = Read-Host "Enter .pt file Path (or 'b' to reselect task)"
                if ($customPt -eq "b") { continue }
                
                $path = $customPt.Trim('"').Trim("'")
                if (Test-Path $path) {
                    $config.modelFile = $path
                    $config.task = "auto"
                    $step++
                } else {
                    Write-Host "Custom weight file not found!" -ForegroundColor Red; Pause
                }
            } else {
                $tasks = @{ "1"="detect"; "2"="segment"; "3"="pose"; "4"="obb"; "5"="classify" }
                $suffixes = @{ "1"=""; "2"="-seg"; "3"="-pose"; "4"="-obb"; "5"="-cls" }

                if ([string]::IsNullOrWhiteSpace($tChoice)) { $tChoice = "1" }

                if ($tasks.ContainsKey($tChoice)) {
                    $config.task = $tasks[$tChoice]
                    $suf = $suffixes[$tChoice]

                    Write-Host "`n--- Step 2: select Size ---" -ForegroundColor Yellow
                    Write-Host "1. n (Nano - Fast/Lightest) [default]"
                    Write-Host "2. s (Small - For General Purposes)"
                    Write-Host "3. m (Medium - Balanced)"
                    Write-Host "4. l (Large - High Precision)"
                    Write-Host "5. x (Extra Large - Maxium Precision)"
                    $sizeChoice = Read-Host "Select Size (1-5, or 'b' to reselect task)"
                    if ($sizeChoice -eq "b") { continue }

                    $size = "n"
                    switch ($sizeChoice) {
                        "2" { $size = "s" }
                        "3" { $size = "m" }
                        "4" { $size = "l" }
                        "5" { Write-Host "Warning: Heavy Load, Proceed with caution." -ForegroundColor DarkYellow; $size = "x" }
                    }

                    $config.modelFile = "yolo11$size$suf.pt"
                    $step++
                } else {
                    Write-Host "Invalid Task selection!" -ForegroundColor Red; Pause
                }
            }
        }

        5 {
            Write-Host "`n[Step 5/6] Select Hyperparameters" -ForegroundColor Yellow
            
            $ep = Read-Host "Enter Epochs [Default: 100, or 'b']"
            if ($ep -eq "b") { $step--; continue }
            if ([string]::IsNullOrWhiteSpace($ep)) { $ep = "100" }
            
            $img = Read-Host "Enter Image Size [Default: 640, or 'b']"
            if ($img -eq "b") { continue }
            if ([string]::IsNullOrWhiteSpace($img)) { $img = "640" }

            Write-Host "`n[Batch Size Hint]" -ForegroundColor DarkGray
            Write-Host "- Enter integer (e.g. 16, 32): Fixed Batch Size" -ForegroundColor DarkGray
            Write-Host "- Enter -1: Using AutoBatch" -ForegroundColor DarkGray
            Write-Host "- Enter Decimal (e.g. 0.5): uses 50% available VRAM" -ForegroundColor DarkGray
            $bat = Read-Host "Enter Batch Size [Default: -1, or 'b']"
            if ($bat -eq "b") { continue }
            if ([string]::IsNullOrWhiteSpace($bat)) { $bat = "-1" }

            $lr = Read-Host "`nEnter Learning Rate (lr0) [Default: 0.01, or 'b']"
            if ($lr -eq "b") { continue }
            if ([string]::IsNullOrWhiteSpace($lr)) { $lr = "0.01" }

            Write-Host "`n[Freeze Backbone Hint]" -ForegroundColor DarkGray
            Write-Host "- Enter layer number (e.g. 10 for YOLOv8/11 backbone)" -ForegroundColor DarkGray
            $freeze = Read-Host "Enter Freeze layers [Default: 0 (None), or 'b']"
            if ($freeze -eq "b") { continue }
            if ([string]::IsNullOrWhiteSpace($freeze)) { $freeze = "" }

            # 新增: 自訂義參數
            Write-Host "`n[Custom Arguments Hint]" -ForegroundColor DarkGray
            Write-Host "- e.g. workers=8 patience=50 device=0" -ForegroundColor DarkGray
            $custom = Read-Host "Enter any Custom Options [Default: None, or 'b']"
            if ($custom -eq "b") { continue }
            if ([string]::IsNullOrWhiteSpace($custom)) { $custom = "" }

            $config.epochs = $ep
            $config.imgsz = $img
            $config.batch = $bat
            $config.lr0 = $lr
            $config.freeze = $freeze
            $config.customArgs = $custom
            $step++
        }

        6 {
            Write-Host "`n[Step 6/6] Ready to Train!" -ForegroundColor Yellow
            Write-Host "Environment : $($config.targetEnv)" -ForegroundColor DarkGray
            Write-Host "Workspace   : $($config.workDir)" -ForegroundColor DarkGray
            Write-Host "Dataset     : $($config.yamlPath)" -ForegroundColor DarkGray
            Write-Host "Model       : $($config.modelFile)" -ForegroundColor DarkGray
            Write-Host "Epochs      : $($config.epochs)" -ForegroundColor DarkGray
            Write-Host "Image Size  : $($config.imgsz)" -ForegroundColor DarkGray
            Write-Host "Batch Size  : $($config.batch)" -ForegroundColor DarkGray
            Write-Host "Learning Rt : $($config.lr0)" -ForegroundColor DarkGray
            if ($config.freeze) { Write-Host "Freeze      : $($config.freeze) layers" -ForegroundColor DarkGray }
            if ($config.customArgs) { Write-Host "Custom Args : $($config.customArgs)" -ForegroundColor DarkGray }
            Write-Host "------------------------------------------"

            $baseCmd = "data=`"$($config.yamlPath)`" model=`"$($config.modelFile)`" epochs=$($config.epochs) imgsz=$($config.imgsz) batch=$($config.batch) lr0=$($config.lr0) project=`"runs`" name=`"train_result`""
            
            if ($config.freeze) { $baseCmd += " freeze=$($config.freeze)" }
            if ($config.customArgs) { $baseCmd += " $($config.customArgs)" }

            if ($config.task -eq "auto") {
                $trainCmd = "yolo mode=train $baseCmd"
            } else {
                $trainCmd = "yolo task=$($config.task) mode=train $baseCmd"
            }

            Write-Host "Command to execute:" -ForegroundColor DarkGray
            Write-Host $trainCmd -ForegroundColor Cyan

            $startTrain = Read-Host "`nStart training now? (Y/N, or 'b' to edit settings)"

            if ($startTrain -eq "b") { 
                $step--; continue
            } elseif ($startTrain -match "^[Yy]$") {
                Set-Location $config.workDir
                Write-Host "`nLaunching YOLOv11 Engine..." -ForegroundColor Green
                Invoke-Expression "conda run --no-capture-output -n $($config.targetEnv) $trainCmd"
                Pause
                $step++
            } else {
                Write-Host "`nTraining aborted. Have a nice day :3" -ForegroundColor DarkYellow
                Pause
                $step++
            }
        }
    }
}