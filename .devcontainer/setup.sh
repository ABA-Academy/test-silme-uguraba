#!/bin/bash

echo "C++ Programlama Ortami Hazirlaniyor..."

# Git conflict onleme
git config pull.rebase false
git config merge.ours.driver true
git config --global user.email "${GITHUB_USER}@users.noreply.github.com" 2>/dev/null || true
git config --global user.name "${GITHUB_USER}" 2>/dev/null || true

# Repository ayarla
REPO_URL=$(git config --get remote.origin.url)
REPO_NAME=$(echo $REPO_URL | sed -E 's#.*github\.com[:/]([^/]+/[^/]+)(\.git)?$#\1#')
echo "$REPO_NAME" | gh repo set-default 2>/dev/null || true

# Tek komut sistemi
cat > ~/gonder.sh << 'SCRIPT'
#!/bin/bash

clear
echo "=========================================="
echo "KODUNUZ GONDERILIYOR..."
echo "=========================================="
echo ""

# Degisiklikleri kaydet
git add . 2>/dev/null

# Commit
MESAJ="Odev: $(date '+%d/%m/%Y %H:%M')"
git commit -m "$MESAJ" 2>/dev/null || echo "Degisiklik yok (zaten kaydedilmis)"

# Conflict olsa bile ogrenci kodu kazanir
git pull origin main -X ours --no-edit 2>/dev/null || true

# Push
if git push origin main 2>&1 | tee /tmp/push.log; then
    echo ""
    echo "KOD GONDERILDI!"
    echo ""
    echo "=========================================="
    echo "TESTLER CALISIYOR (60 saniye bekleyin)"
    echo "=========================================="
    echo ""
    
    # 60 saniye bekle
    for i in {60..1}; do
        printf "\rBekleniyor: %2d saniye..." $i
        sleep 1
    done
    echo ""
    echo ""
    
    echo "=========================================="
    echo "TEST SONUCLARI:"
    echo "=========================================="
    echo ""
    
    # Test sonuclarini goster
    gh run view --log 2>/dev/null || echo "Test sonuclari henuz hazir degil. 1-2 dakika sonra tekrar deneyin"
    
else
    echo ""
    echo "HATA: Gonderim basarisiz!"
    cat /tmp/push.log
    echo ""
    echo "Hocaya gosterin"
fi

echo ""
echo "=========================================="
SCRIPT

chmod +x ~/gonder.sh

# Bashrc'ye ekle
cat >> ~/.bashrc << 'EOF'

# Hosgeldin mesaji
if [ -f ~/.first_run ]; then
    clear
    echo "=========================================="
    echo "C++ PROGRAMLAMA ORTAMI HAZIR!"
    echo "=========================================="
    echo ""
    echo "NASIL KULLANILIR:"
    echo ""
    echo "1. main.cpp dosyasini acin (sol tarafta)"
    echo "2. Kodunuzu yazin"
    echo "3. Terminal'de sunu yazin:"
    echo ""
    echo "   ./gonder.sh"
    echo ""
    echo "4. Bekleyin, test sonuclari gelecek!"
    echo ""
    echo "=========================================="
    echo ""
    rm ~/.first_run
fi

# Kisayol
alias gonder='~/gonder.sh'

EOF

touch ~/.first_run

echo "Kurulum tamamlandi!"
