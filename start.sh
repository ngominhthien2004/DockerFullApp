#!/bin/bash

set -e

# Start X virtual framebuffer (only if not already running)
export DISPLAY=:0
if pgrep -x Xvfb >/dev/null 2>&1; then
	echo "Xvfb already running"
else
	if [ -e /tmp/.X0-lock ] && ! pgrep -f ":0" >/dev/null 2>&1; then
		rm -f /tmp/.X0-lock || true
	fi
	Xvfb :0 -screen 0 1024x768x24 &
	sleep 1
fi

# Start a lightweight desktop (xfce) under a session bus as user `dev`
# Use dbus-launch for a session bus so desktop components work.
if id dev >/dev/null 2>&1; then
	if command -v dbus-launch >/dev/null 2>&1; then
		su - dev -c "dbus-launch --exit-with-session setsid startxfce4 >/dev/null 2>&1 &" || true
	else
		su - dev -c "setsid startxfce4 >/dev/null 2>&1 &" || true
	fi
else
	setsid startxfce4 >/dev/null 2>&1 || true
fi

# Ensure home dir
mkdir -p /home/dev/.vnc
chown -R dev:dev /home/dev || true
mkdir -p /var/log/mongodb /var/log/apache2 /run/mysqld /data/db

MYSQL_APP_USER="${MYSQL_APP_USER:-dev}"
MYSQL_APP_PASSWORD="${MYSQL_APP_PASSWORD:-devpass}"
MYSQL_APP_DATABASE="${MYSQL_APP_DATABASE:-appdb}"

# Create a helper script for runtime verification from noVNC terminal.
cat >/home/dev/check-runtimes.sh <<'EOF'
#!/bin/bash
echo "=== Runtime versions in combined image ==="
echo "Node:   $(node --version 2>/dev/null || echo missing)"
echo "NPM:    $(npm --version 2>/dev/null || echo missing)"
echo "Python: $(python --version 2>/dev/null || echo missing)"
echo "Java:   $(java -version 2>&1 | head -n 1 || echo missing)"
echo "Javac:  $(javac -version 2>&1 || echo missing)"
echo "PHP:    $(php --version 2>/dev/null | head -n 1 || echo missing)"
echo "Composer: $(composer --version 2>/dev/null || echo missing)"
echo "Git:    $(git --version 2>/dev/null || echo missing)"
echo "MySQL:  $(mysql --version 2>/dev/null || echo missing)"
echo "MongoDB: $(mongod --version 2>/dev/null | head -n 1 || echo missing)"
echo "Mongo Shell: $(mongosh --version 2>/dev/null || echo missing)"
echo "MongoDB Compass: $(dpkg-query -W -f='${Version}' mongodb-compass 2>/dev/null || echo missing)"
echo "VS Code: $(DONT_PROMPT_WSL_INSTALL=1 code --version --disable-gpu --user-data-dir /home/dev/.code-data 2>/dev/null | head -n 1 || echo missing)"
echo "GitHub Desktop: $(dpkg-query -W -f='${Version}' github-desktop 2>/dev/null || echo missing)"
echo "7-Zip: $(dpkg-query -W -f='${Version}' p7zip-full 2>/dev/null || echo missing)"
echo "VLC: $(dpkg-query -W -f='${Version}' vlc 2>/dev/null || echo missing)"
echo "LibreOffice: $(libreoffice --version 2>/dev/null || echo missing)"
echo "Draw.io Desktop: $(dpkg-query -W -f='${Version}' draw.io 2>/dev/null || dpkg-query -W -f='${Version}' drawio 2>/dev/null || echo missing)"
echo "Code::Blocks: $(dpkg-query -W -f='${Version}' codeblocks 2>/dev/null || echo missing)"
echo "PlantUML: $(plantuml -version 2>/dev/null | head -n 1 || echo missing)"
echo "R: $(R --version 2>/dev/null | head -n 1 || echo missing)"
if command -v gitk >/dev/null 2>&1; then
  echo "Git GUI: gitk available"
else
  echo "Git GUI: missing"
fi
if command -v github-desktop >/dev/null 2>&1; then
  echo "Git Desktop GUI: github-desktop available"
elif command -v gitg >/dev/null 2>&1; then
  echo "Git Desktop GUI: gitg available (fallback)"
else
  echo "Git Desktop GUI: missing"
fi
if command -v notepadqq >/dev/null 2>&1; then
  echo "Editor GUI: notepadqq available"
elif command -v mousepad >/dev/null 2>&1; then
  echo "Editor GUI: mousepad available (notepadqq fallback)"
else
  echo "Editor GUI: missing"
fi
echo
echo "You can run commands here. Type 'exit' to close this terminal."
exec bash
EOF
chmod +x /home/dev/check-runtimes.sh
chown dev:dev /home/dev/check-runtimes.sh

# Print runtime versions to logs for quick verification.
{
	echo "Node version: $(node --version 2>/dev/null || echo missing)"
	echo "NPM version: $(npm --version 2>/dev/null || echo missing)"
	echo "Python version: $(python --version 2>/dev/null || echo missing)"
	echo "Java version: $(java -version 2>&1 | head -n 1 || echo missing)"
	echo "Javac version: $(javac -version 2>&1 || echo missing)"
	echo "PHP version: $(php --version 2>/dev/null | head -n 1 || echo missing)"
	echo "Composer version: $(composer --version 2>/dev/null || echo missing)"
	echo "Git version: $(git --version 2>/dev/null || echo missing)"
	echo "MySQL version: $(mysql --version 2>/dev/null || echo missing)"
	echo "MongoDB version: $(mongod --version 2>/dev/null | head -n 1 || echo missing)"
	echo "Mongo Shell version: $(mongosh --version 2>/dev/null || echo missing)"
	echo "MongoDB Compass version: $(dpkg-query -W -f='${Version}' mongodb-compass 2>/dev/null || echo missing)"
	echo "VS Code version: $(su - dev -c 'DONT_PROMPT_WSL_INSTALL=1 code --version --disable-gpu --user-data-dir /home/dev/.code-data 2>/dev/null | head -n 1' || echo missing)"
	echo "GitHub Desktop version: $(dpkg-query -W -f='${Version}' github-desktop 2>/dev/null || echo missing)"
	echo "7-Zip version: $(dpkg-query -W -f='${Version}' p7zip-full 2>/dev/null || echo missing)"
	echo "VLC version: $(dpkg-query -W -f='${Version}' vlc 2>/dev/null || echo missing)"
	echo "LibreOffice version: $(su - dev -c 'libreoffice --version 2>/dev/null' || echo missing)"
	echo "Draw.io Desktop version: $(dpkg-query -W -f='${Version}' draw.io 2>/dev/null || dpkg-query -W -f='${Version}' drawio 2>/dev/null || echo missing)"
	echo "Code::Blocks version: $(dpkg-query -W -f='${Version}' codeblocks 2>/dev/null || echo missing)"
	echo "PlantUML version: $(plantuml -version 2>/dev/null | head -n 1 || echo missing)"
	echo "R version: $(R --version 2>/dev/null | head -n 1 || echo missing)"
} >>/var/log/runtime-versions.log

# Create VNC password non-interactively (use $VNC_PASSWORD or default to 'devpass')
VNC_PASS="${VNC_PASSWORD:-devpass}"
if [ -n "$VNC_PASS" ]; then
	# write password file directly from argument for reliable non-interactive setup
	x11vnc -storepasswd "$VNC_PASS" /home/dev/.vnc/passwd >/var/log/x11vnc.log 2>&1 || true
	chown -R dev:dev /home/dev/.vnc || true
fi

# Wait for X display :0 to be available (socket or Xvfb process)
echo "Waiting for X display :0" >> /var/log/x11vnc.log
count=0
until [ $count -ge 20 ] || [ -e /tmp/.X11-unix/X0 ] || pgrep -f "Xvfb :0" >/dev/null 2>&1; do
	sleep 0.5
	count=$((count+1))
done
if [ $count -ge 20 ]; then
	echo "Warning: X display :0 not ready after wait" >> /var/log/x11vnc.log
fi

# Start x11vnc to serve :0 (log to file) using the created password if present.
echo "Starting x11vnc" >> /var/log/x11vnc.log
if [ -f /home/dev/.vnc/passwd ]; then
	x11vnc -display :0 -rfbauth /home/dev/.vnc/passwd -forever -shared -rfbport 5900 >>/var/log/x11vnc.log 2>&1 &
else
	# fallback to no-password for testing
	x11vnc -display :0 -nopw -forever -shared -rfbport 5900 >>/var/log/x11vnc.log 2>&1 &
fi

# Wait up to 10s for VNC port to be ready before starting websockify
i=0
while [ $i -lt 10 ]; do
	if python3 - <<'PY'
import socket,sys
s=socket.socket()
s.settimeout(1)
try:
	s.connect(('127.0.0.1',5900))
	s.close()
	sys.exit(0)
except:
	sys.exit(1)
PY
	then
		echo "x11vnc listening on 5900" >> /var/log/x11vnc.log
		break
	fi
	i=$((i+1))
	sleep 1
done
if [ $i -ge 10 ]; then
	echo "Warning: VNC port 5900 not open after wait; websockify may fail" >> /var/log/x11vnc.log
fi

# Helper: start websockify reliably (serve noVNC webroot)
start_websockify() {
	# kill any existing websockify running on 6080
	pkill -f "websockify.*6080" || true
	sleep 1

	local retries=6
	local i=0
	while [ $i -lt $retries ]; do
		i=$((i+1))
		# ensure log file exists
		touch /var/log/websockify.log || true
		# Start websockify as a daemon, writing to /var/log/websockify.log
		/opt/noVNC/utils/websockify/run --web /opt/noVNC --log-file=/var/log/websockify.log --daemon 6080 localhost:5900 >/dev/null 2>&1 || true
		sleep 2
		# Check whether a websockify process is listening
		if pgrep -f "websockify.*6080" >/dev/null 2>&1; then
			echo "websockify started (attempt $i)" >> /var/log/websockify.log
			return 0
		fi
		echo "websockify failed to bind (attempt $i), retrying..." >> /var/log/websockify.log
		sleep 1
	done
	echo "websockify failed to start after $retries attempts" >> /var/log/websockify.log
	return 1
}

# Start websockify with retries
start_websockify || echo "Warning: websockify may not be running" >&2

# Start MariaDB
start_mariadb() {
	chown -R mysql:mysql /run/mysqld /var/lib/mysql || true
	if [ ! -d /var/lib/mysql/mysql ]; then
		mariadb-install-db --user=mysql --datadir=/var/lib/mysql >/var/log/mariadb-init.log 2>&1 || true
	fi
	mysqld_safe --datadir=/var/lib/mysql --socket=/run/mysqld/mysqld.sock >/var/log/mariadb.log 2>&1 &

	local i=0
	while [ $i -lt 30 ]; do
		if mysqladmin --protocol=socket --socket=/run/mysqld/mysqld.sock -uroot ping >/dev/null 2>&1; then
			break
		fi
		i=$((i + 1))
		sleep 1
	done

	if mysqladmin --protocol=socket --socket=/run/mysqld/mysqld.sock -uroot ping >/dev/null 2>&1; then
		mysql --protocol=socket --socket=/run/mysqld/mysqld.sock -uroot <<SQL >/var/log/mariadb-bootstrap.log 2>&1 || true
CREATE DATABASE IF NOT EXISTS \`${MYSQL_APP_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_APP_USER}'@'%' IDENTIFIED BY '${MYSQL_APP_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO '${MYSQL_APP_USER}'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
SQL
	else
		echo "Warning: MariaDB did not become ready in time" >>/var/log/mariadb.log
	fi
}

# Start MongoDB
start_mongodb() {
	chown -R mongodb:mongodb /data/db /var/log/mongodb || true
	if ! pgrep -x mongod >/dev/null 2>&1; then
		su -s /bin/bash -c "mongod --bind_ip 0.0.0.0 --dbpath /data/db --logpath /var/log/mongodb/mongod.log --fork" mongodb >/var/log/mongodb/start.log 2>&1 || true
	fi
}

# Start Apache with phpMyAdmin
start_apache_phpmyadmin() {
	ln -sfn /usr/share/phpmyadmin /var/www/html/phpmyadmin || true
	a2enconf phpmyadmin >/var/log/apache2/a2enconf.log 2>&1 || true
	apachectl -k start >/var/log/apache2/startup.log 2>&1 || true
}

start_mariadb
start_mongodb
start_apache_phpmyadmin

# Start sample apps as the non-root `dev` user.
su - dev -c "cd /home/dev/node-app && npm start" >/var/log/node-app.log 2>&1 &
su - dev -c "cd /home/dev/python-app && python app.py" >/var/log/python-app.log 2>&1 &

# Open an XFCE terminal window in noVNC for quick runtime checks.
su - dev -c "bash -lc 'sleep 3; DISPLAY=:0 xfce4-terminal --title=\"Runtime Check\" --command=/home/dev/check-runtimes.sh >/dev/null 2>&1 &'" || true

echo "Services started:"
echo "- noVNC: http://localhost:6080/vnc.html (password: ${VNC_PASS})"
echo "- Node app: http://localhost:3000"
echo "- Python app: http://localhost:5000"
echo "- phpMyAdmin: http://localhost/phpmyadmin"
echo "- MariaDB user: ${MYSQL_APP_USER} / ${MYSQL_APP_PASSWORD}"

# Keep container alive and stream logs
touch /var/log/runtime-versions.log /var/log/websockify.log /var/log/x11vnc.log /var/log/node-app.log /var/log/python-app.log /var/log/mariadb.log /var/log/mongodb/mongod.log /var/log/apache2/error.log
tail -F /var/log/runtime-versions.log /var/log/x11vnc.log /var/log/websockify.log /var/log/node-app.log /var/log/python-app.log /var/log/mariadb.log /var/log/mongodb/mongod.log /var/log/apache2/error.log
