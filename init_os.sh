#!/bin/bash

echo "🚀 Open-Cognitive OS: Çekirdek Başlatılıyor (Release Mode)..."
echo "================================================================="

# 1. WASM Araçlarını Derle (Release Mode)
echo "[1/4] WASM Sandbox Araçları donanım seviyesinde derleniyor..."
cd ~/open-cognitive/tool-wasi-sdk
rustup target add wasm32-unknown-unknown > /dev/null 2>&1
cargo build --target wasm32-unknown-unknown --release -q
echo "  -> OK: tool_wasi_sdk.wasm hazır."

# 2. Neural Engine (Sistem 1) Başlat
echo "[2/4] Nöral Motor (FPU) başlatılıyor..."
cd ~/open-cognitive/neural-engine
cargo run --release --bin neural_engine -q &
PID_NEURAL=$!

# 3. Sandbox (Sistem 3) Başlat
echo "[3/4] Güvenli Yürütme Ortamı (WASM) başlatılıyor..."
cd ~/open-cognitive/safe-execution-env
# Not: Yolu Release olarak değiştirdik!
sed -i 's/debug/release/g' src/main.rs
cargo run --release -q &
PID_SANDBOX=$!

sleep 1 

# 4. Logic Gate Core (Sistem 2) Başlat
echo "[4/4] Bilişsel Mantık Çekirdeği (CPU) başlatılıyor..."
cd ~/open-cognitive/logic-gate-core
cargo run --release -q &
PID_LOGIC=$!

echo "================================================================="
echo "✅ SİSTEM HAZIR VE DİNLİYOR! (Işık Hızında - Release)"
echo "Sistemi kapatmak için bu ekranda CTRL+C tuşuna basabilirsiniz."
echo "================================================================="

trap "echo -e '\n🛑 Kapatma sinyali alındı. Tüm çekirdekler durduruluyor...'; kill $PID_NEURAL $PID_SANDBOX $PID_LOGIC; exit" INT
wait