set -e
OUT=/test/manual
mkdir -p "$OUT/terminal" "$OUT/gui"
chmod 777 /test /test/manual /test/manual/terminal /test/manual/gui || true

cat > /tmp/runtime_versions.sh <<'EOF'
#!/bin/bash
echo "=== Runtime Version Check ==="
echo "node: $(node -v)"
echo "npm: $(npm -v)"
echo "python: $(python3 --version)"
echo "java: $(java -version 2>&1 | head -n 1)"
echo "javac: $(javac -version 2>&1)"
echo "php: $(php -v | head -n 1)"
echo "composer: $(composer --version | head -n 1)"
echo "git: $(git --version)"
echo "mysql: $(mysql --version)"
echo "mongosh: $(mongosh --version)"
echo "plantuml: $(plantuml -version | head -n 1)"
echo "R: $(R --version | head -n 1)"
echo
echo "DONE"
exec bash
EOF
chmod +x /tmp/runtime_versions.sh
su - dev -c "DISPLAY=:0 xfce4-terminal --title='Terminal-Runtime-Check' --command=/tmp/runtime_versions.sh >/tmp/terminal-runtime.log 2>&1 &"
sleep 5
DISPLAY=:0 scrot "$OUT/terminal/terminal-runtime-check.png"
pkill -f "xfce4-terminal.*Terminal-Runtime-Check" || true
sleep 2

cat > /tmp/service_checks.sh <<'EOF'
#!/bin/bash
echo "=== Service/API Check ==="
echo "node api:"
curl -s http://127.0.0.1:3000/api
echo
echo "python api:"
curl -s http://127.0.0.1:5000/api
echo
echo "mysql select 1:"
mysql -udev -pdevpass -e "SELECT 1 as ok;"
echo "mongo ping:"
mongosh --quiet --eval "db.adminCommand({ ping: 1 })"
echo
echo "DONE"
exec bash
EOF
chmod +x /tmp/service_checks.sh
su - dev -c "DISPLAY=:0 xfce4-terminal --title='Terminal-Service-Check' --command=/tmp/service_checks.sh >/tmp/terminal-service.log 2>&1 &"
sleep 6
DISPLAY=:0 scrot "$OUT/terminal/terminal-service-check.png"
pkill -f "xfce4-terminal.*Terminal-Service-Check" || true
sleep 2

su - dev -c "DISPLAY=:0 bash -lc 'code --disable-gpu --user-data-dir /home/dev/.code-data >/tmp/gui-vscode.log 2>&1 &'"
sleep 7
DISPLAY=:0 scrot "$OUT/gui/gui-vscode.png"
pkill -f "code --disable-gpu" || true
sleep 2

su - dev -c "DISPLAY=:0 bash -lc 'notepadqq >/tmp/gui-notepadqq.log 2>&1 &'"
sleep 5
DISPLAY=:0 scrot "$OUT/gui/gui-notepadqq.png"
pkill -f notepadqq || true
sleep 2

su - dev -c "DISPLAY=:0 bash -lc 'github-desktop >/tmp/gui-github-desktop.log 2>&1 &'"
sleep 8
DISPLAY=:0 scrot "$OUT/gui/gui-github-desktop.png"
pkill -f github-desktop || true
sleep 2

su - dev -c "DISPLAY=:0 bash -lc 'drawio >/tmp/gui-drawio.log 2>&1 &'"
sleep 8
DISPLAY=:0 scrot "$OUT/gui/gui-drawio.png"
pkill -f drawio || true
sleep 2

su - dev -c "DISPLAY=:0 bash -lc 'codeblocks >/tmp/gui-codeblocks.log 2>&1 &'"
sleep 6
DISPLAY=:0 scrot "$OUT/gui/gui-codeblocks.png"
pkill -f codeblocks || true
sleep 2

su - dev -c "DISPLAY=:0 bash -lc 'vlc >/tmp/gui-vlc.log 2>&1 &'"
sleep 6
DISPLAY=:0 scrot "$OUT/gui/gui-vlc.png"
pkill -f vlc || true
sleep 2

su - dev -c "DISPLAY=:0 bash -lc 'libreoffice --writer >/tmp/gui-libreoffice.log 2>&1 &'"
sleep 7
DISPLAY=:0 scrot "$OUT/gui/gui-libreoffice.png"
pkill -f libreoffice || true
sleep 2

su - dev -c "DISPLAY=:0 bash -lc 'mongodb-compass >/tmp/gui-mongodb-compass.log 2>&1 &'"
sleep 9
DISPLAY=:0 scrot "$OUT/gui/gui-mongodb-compass.png"
pkill -f mongodb-compass || true
sleep 2

su - dev -c "DISPLAY=:0 bash -lc 'gitk >/tmp/gui-gitk.log 2>&1 &'"
sleep 6
DISPLAY=:0 scrot "$OUT/gui/gui-gitk.png"
pkill -f gitk || true
sleep 2

cat > /test/manual/progress.txt <<'EOF'
Manual test with terminal commands and GUI screenshots completed.
Terminal screenshots:
- terminal/terminal-runtime-check.png
- terminal/terminal-service-check.png
GUI screenshots:
- gui/gui-vscode.png
- gui/gui-notepadqq.png
- gui/gui-github-desktop.png
- gui/gui-drawio.png
- gui/gui-codeblocks.png
- gui/gui-vlc.png
- gui/gui-libreoffice.png
- gui/gui-mongodb-compass.png
- gui/gui-gitk.png
EOF

find /test/manual -maxdepth 2 -type f | sort