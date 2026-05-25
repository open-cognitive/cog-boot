#!/bin/bash

clear
echo "================================================================="
echo "🚀 OPEN-COGNITIVE OS BOOT SEQUENCE"
echo "================================================================="
LOG_FILE="/tmp/cog-kernel.log"
echo "Kernel logları şuraya yönlendirildi: $LOG_FILE"
echo "--- OS BOOT ---" > $LOG_FILE

echo "[1/4] WASM Sandbox Araçları derleniyor..."
cd ~/open-cognitive/tool-wasi-sdk
cargo build --target wasm32-unknown-unknown --release -q >> $LOG_FILE 2>&1

echo "[2/4] Nöral Motor (System 1) belleğe yükleniyor..."
cd ~/open-cognitive/neural-engine
cargo run --release -q >> $LOG_FILE 2>&1 &
PID_NEURAL=$!

echo "[3/4] Güvenli Yürütme Ortamı (WASM) başlatılıyor..."
cd ~/open-cognitive/safe-execution-env
cargo run --release -q >> $LOG_FILE 2>&1 &
PID_SANDBOX=$!

sleep 1

echo "[4/4] Bilişsel Mantık Çekirdeği (System 2) başlatılıyor..."
cd ~/open-cognitive/logic-gate-core
cargo run --release -q >> $LOG_FILE 2>&1 &
PID_LOGIC=$!

echo "================================================================="
echo "✅ Çekirdek (Kernel) hazır. Kullanıcı alanına (User Space) geçiliyor..."
sleep 2

# Acil durumlar için (Kullanıcı CTRL+C yaparsa) tüm arka plan işlemlerini öldür
trap "echo -e '\n🛑 Acil Kapatma. Sistem durduruluyor...'; kill $PID_NEURAL $PID_SANDBOX $PID_LOGIC 2>/dev/null; exit" INT

# --- KULLANICI ARAYÜZÜ (CLI) ÖN PLANDA BAŞLATILIYOR ---
cd ~/open-cognitive/cognitive-cli
# -q parametresi "Compiling..." yazılarını gizler, temiz başlar
cargo run --release -q

# --- KULLANICI CLI'DAN ÇIKTIĞINDA BURAYA DÜŞER ---
echo ""
echo "🛑 Shell sonlandı. Donanım ve servisler kapatılıyor..."
kill $PID_NEURAL $PID_SANDBOX $PID_LOGIC 2>/dev/null
wait $PID_NEURAL $PID_SANDBOX $PID_LOGIC 2>/dev/null
echo "✅ Sistem güvenle kapatıldı."