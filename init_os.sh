#!/bin/bash

echo "🚀 Open-Cognitive OS: Çekirdek Başlatılıyor (Boot Sequence)..."
echo "================================================================="

# 1. WASM Araçlarını Derle
echo "[1/4] WASM Sandbox Araçları donanım seviyesinde derleniyor..."
cd ~/open-cognitive/tool-wasi-sdk
# Eğer target yüklü değilse ekle
rustup target add wasm32-unknown-unknown > /dev/null 2>&1
cargo build --target wasm32-unknown-unknown -q
echo "  -> OK: tool_wasi_sdk.wasm hazır."

# 2. Neural Engine (Sistem 1) Başlat
echo "[2/4] Nöral Motor (FPU) başlatılıyor..."
cd ~/open-cognitive/neural-engine
cargo run -q &
PID_NEURAL=$!

# 3. Sandbox (Sistem 3) Başlat
echo "[3/4] Güvenli Yürütme Ortamı (WASM) başlatılıyor..."
cd ~/open-cognitive/safe-execution-env
cargo run -q &
PID_SANDBOX=$!

sleep 1 # Bellek otobüsünün (Memory Bus) açılması için bekle

# 4. Logic Gate Core (Sistem 2 - Master) Başlat
echo "[4/4] Bilişsel Mantık Çekirdeği (CPU) başlatılıyor..."
cd ~/open-cognitive/logic-gate-core
cargo run -q &
PID_LOGIC=$!

echo "================================================================="
echo "✅ SİSTEM HAZIR VE DİNLİYOR! (Loglar aşağıda akacaktır)"
echo "Sistemi kapatmak için bu ekranda CTRL+C tuşuna basabilirsiniz."
echo "================================================================="
echo ""
echo "TEST İÇİN BAŞKA BİR TERMİNAL AÇIP ŞUNU YAZIN:"
echo "cd ~/open-cognitive/cognitive-cli && cargo run -- \"6 sayısının karesini hesapla\""
echo "-----------------------------------------------------------------"

# Kapatma (Teardown) Sinyali Yakalayıcı
trap "echo -e '\n🛑 Kapatma sinyali alındı. Tüm çekirdekler durduruluyor...'; kill $PID_NEURAL $PID_SANDBOX $PID_LOGIC; exit" INT

# Arka plandaki işlemlerin loglarını bu ekranda tut
wait
