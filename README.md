# combined-image

This image runs:

- noVNC desktop at `http://localhost:6080/vnc.html`
- Node app at `http://localhost:3000`
- Python app at `http://localhost:5000`
- phpMyAdmin at `http://localhost:8081/phpmyadmin`
- MariaDB at `localhost:3306`
- MongoDB at `localhost:27017`
- MongoDB Compass GUI in noVNC desktop (`mongodb-compass`)
- Visual Studio Code GUI (`code`) in noVNC desktop
- Notepadqq GUI (`notepadqq`) in noVNC desktop
- GitHub Desktop GUI (`github-desktop`) in noVNC desktop
- Draw.io Desktop GUI (`drawio`)
- Code::Blocks GUI (`codeblocks`)
- 7-Zip CLI (`7z`)
- VLC media player GUI (`vlc`)
- LibreOffice GUI (`libreoffice`)
- Start UML (`plantuml`)
- R (`r-base`)

## Installed software and GUI/CLI

GUI apps:

- `mongodb-compass`
- `code` (Visual Studio Code)
- `notepadqq`
- `github-desktop`
- `drawio`
- `codeblocks`
- `plantuml -gui`
- `vlc`
- `libreoffice`
- `gitk`
- `git gui`
- `gitg`
- `phpmyadmin` (web GUI at `http://localhost:8081/phpmyadmin`)

Non-GUI / CLI apps:

- `node`, `npm`
- `python`, `pip`
- `java`, `javac`
- `php`, `composer`
- `git`
- `mysql` / `mariadb`
- `mongod`, `mongosh`, `mongodb-database-tools`
- `7z`
- `R`

## Hướng dẫn cài đặt

Xem hướng dẫn cài đặt đầy đủ (Docker Hub và GitHub) tại:

- [HUONG_DAN_CAI_DAT.md](HUONG_DAN_CAI_DAT.md)

## Run container

```powershell
cd D:\Crack\DockerFullApp\combined-image
docker compose up --build -d
```

## Run prebuilt image from Docker Hub

```powershell
docker pull ngominhthien22/combined-image:latest
docker rm -f combined-dev
docker run -d --name combined-dev `
  -p 6080:6080 -p 3000:3000 -p 5000:5000 -p 3306:3306 -p 27017:27017 -p 8081:80 `
  -e VNC_PASSWORD=devpass `
  -e MYSQL_APP_USER=dev `
  -e MYSQL_APP_PASSWORD=devpass `
  -e MYSQL_APP_DATABASE=appdb `
  ngominhthien22/combined-image:latest
```

Default noVNC password: `devpass` (override with env var `COMBINED_VNC_PASSWORD`).
Default MariaDB app user/password/database:

- user: `dev` (override `COMBINED_MYSQL_USER`)
- password: `devpass` (override `COMBINED_MYSQL_PASSWORD`)
- database: `appdb` (override `COMBINED_MYSQL_DATABASE`)

## Quick runtime check in container

```powershell
docker exec -it combined-dev bash -lc "node -v && npm -v && python --version && java -version && php -v && composer --version && git --version && mysql --version && mongod --version | head -n 1 && su - dev -c 'DONT_PROMPT_WSL_INSTALL=1 code --version --disable-gpu --user-data-dir /home/dev/.code-data | head -n 1'"
```

In noVNC desktop, a terminal named `Runtime Check` is opened automatically on startup.
You can also open terminal manually from XFCE menu and run:

```bash
node -v
npm -v
python --version
java -version
php --version
composer --version
git --version
mysql --version
mongod --version
mongosh --version
dpkg-query -W mongodb-compass
code --version
notepadqq --version
dpkg-query -W github-desktop
dpkg-query -W draw.io
dpkg-query -W codeblocks
dpkg-query -W p7zip-full
vlc --version
libreoffice --version
plantuml -version
R --version
```

Git GUI apps installed in desktop:

- `gitk`
- `git gui`
- `github-desktop`
- `gitg` (fallback)

Database checks:

```powershell
docker exec -it combined-dev bash -lc "mysql -udev -pdevpass -e 'SELECT 1;'"
docker exec -it combined-dev bash -lc "mongosh --quiet --eval 'db.adminCommand({ ping: 1 })'"
```

MongoDB Compass is bundled in this image as a desktop GUI app.

## Open GUI apps

Use one of these ways:

1. Open noVNC (`http://localhost:6080/vnc.html`), then run command in desktop terminal.
2. Run from host terminal with `docker exec` (app appears in noVNC desktop).

Run from host terminal (PowerShell):

```powershell
# VS Code - open
docker exec -u dev -d combined-dev bash -lc "export DISPLAY=:0; DONT_PROMPT_WSL_INSTALL=1 /usr/share/code/code --no-sandbox --disable-gpu --user-data-dir /home/dev/.code-data"
# VS Code - close
docker exec -u dev combined-dev bash -lc "pkill -f '/usr/share/code/code|/usr/bin/code' || true"

# Notepadqq - open
docker exec -u dev -d combined-dev bash -lc "export DISPLAY=:0; notepadqq"
# Notepadqq - close
docker exec -u dev combined-dev bash -lc "pkill -f notepadqq || true"

# GitHub Desktop - open
docker exec -u dev -d combined-dev bash -lc "export DISPLAY=:0; /usr/lib/github-desktop/github-desktop --no-sandbox --disable-gpu"
# GitHub Desktop - close
docker exec -u dev combined-dev bash -lc "pkill -f github-desktop || true"

# Draw.io - open
docker exec -u dev -d combined-dev bash -lc "export DISPLAY=:0; drawio"
# Draw.io - close
docker exec -u dev combined-dev bash -lc "pkill -f drawio || true"

# Code::Blocks - open
docker exec -u dev -d combined-dev bash -lc "export DISPLAY=:0; codeblocks"
# Code::Blocks - close
docker exec -u dev combined-dev bash -lc "pkill -f codeblocks || true"

# MongoDB Compass - open
docker exec -u dev -d combined-dev bash -lc "export DISPLAY=:0; mongodb-compass"
# MongoDB Compass - close
docker exec -u dev combined-dev bash -lc "pkill -f mongodb-compass || true"

# VLC - open
docker exec -u dev -d combined-dev bash -lc "export DISPLAY=:0; vlc"
# VLC - close
docker exec -u dev combined-dev bash -lc "pkill -f vlc || true"

# LibreOffice Writer - open
docker exec -u dev -d combined-dev bash -lc "export DISPLAY=:0; libreoffice --writer"
# LibreOffice - close
docker exec -u dev combined-dev bash -lc "pkill -f 'soffice.bin|libreoffice' || true"

# PlantUML GUI - open
docker exec -u dev -d combined-dev bash -lc "export DISPLAY=:0; plantuml -gui"
# PlantUML GUI - close
docker exec -u dev combined-dev bash -lc "pkill -f 'plantuml|net.sourceforge.plantuml' || true"

# gitk - open
docker exec -u dev -d combined-dev bash -lc "export DISPLAY=:0; gitk"
# gitk - close
docker exec -u dev combined-dev bash -lc "pkill -f gitk || true"

# git gui - open
docker exec -u dev -d combined-dev bash -lc "export DISPLAY=:0; git gui"
# git gui - close
docker exec -u dev combined-dev bash -lc "pkill -f 'git gui|git-gui' || true"

# gitg - open
docker exec -u dev -d combined-dev bash -lc "export DISPLAY=:0; gitg"
# gitg - close
docker exec -u dev combined-dev bash -lc "pkill -f gitg || true"

# Close all GUI apps (quick cleanup)
docker exec -u dev combined-dev bash -lc "pkill -f 'github-desktop|mongodb-compass|drawio|codeblocks|notepadqq|/usr/share/code/code|/usr/bin/code|vlc|soffice.bin|libreoffice|plantuml|gitk|git gui|git-gui|gitg' || true"
```

Run inside noVNC desktop terminal:

```bash
# VS Code - open
DONT_PROMPT_WSL_INSTALL=1 /usr/share/code/code --no-sandbox --disable-gpu --user-data-dir /home/dev/.code-data &
# VS Code - close
pkill -f '/usr/share/code/code|/usr/bin/code' || true

# Notepadqq - open
notepadqq &
# Notepadqq - close
pkill -f notepadqq || true

# GitHub Desktop - open
/usr/lib/github-desktop/github-desktop --no-sandbox --disable-gpu &
# GitHub Desktop - close
pkill -f github-desktop || true

# Draw.io - open
drawio &
# Draw.io - close
pkill -f drawio || true

# Code::Blocks - open
codeblocks &
# Code::Blocks - close
pkill -f codeblocks || true

# MongoDB Compass - open
mongodb-compass &
# MongoDB Compass - close
pkill -f mongodb-compass || true

# VLC - open
vlc &
# VLC - close
pkill -f vlc || true

# LibreOffice Writer - open
libreoffice --writer &
# LibreOffice - close
pkill -f 'soffice.bin|libreoffice' || true

# PlantUML GUI - open
plantuml -gui &
# PlantUML GUI - close
pkill -f 'plantuml|net.sourceforge.plantuml' || true

# gitk - open
gitk &
# gitk - close
pkill -f gitk || true

# git gui - open
git gui &
# git gui - close
pkill -f 'git gui|git-gui' || true

# gitg - open
gitg &
# gitg - close
pkill -f gitg || true

# Close all GUI apps (quick cleanup)
pkill -f 'github-desktop|mongodb-compass|drawio|codeblocks|notepadqq|/usr/share/code/code|/usr/bin/code|vlc|soffice.bin|libreoffice|plantuml|gitk|git gui|git-gui|gitg' || true
```

`mongodb-compass` and `drawio` are wrapped with `--no-sandbox` in this image.

## Manual screenshots to `/test`

Inside container, use:

```bash
mkdir -p /test
cat >/tmp/uml-sample.puml <<'EOF'
@startuml
Alice -> Bob: hello
@enduml
EOF
plantuml -version > /test/plantuml_test.txt
plantuml /tmp/uml-sample.puml -o /test
cp /test/uml-sample.png /test/plantuml.png

R --version > /test/r-base_test.txt
R -q -e '1+1' >> /test/r-base_test.txt
cat >/tmp/r_plot.R <<'EOF'
png('/test/r-base.png')
plot(1:10, col='blue', pch=19, main='R Test Plot')
grid()
dev.off()
EOF
Rscript /tmp/r_plot.R >> /test/r-base_test.txt
```

## Test with Playwright

```powershell
cd D:\Crack\DockerFullApp\combined-image\tests
powershell -ExecutionPolicy Bypass -File .\run-e2e.ps1
```

The script will:

1. Build and start `combined-dev`
2. Wait until healthcheck passes (noVNC + node + python)
3. Run Playwright tests
4. Stop container automatically
   #   D o c k e r F u l l A p p 
    
    
