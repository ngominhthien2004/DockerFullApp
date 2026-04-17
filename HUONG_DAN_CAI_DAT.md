# Hướng dẫn cài đặt combined-image

Tài liệu này mô tả 2 cách cài đặt/chạy dự án:

- Cách A: Kéo image đã build sẵn từ Docker Hub (nhanh nhất).
- Cách B: Clone mã nguồn từ GitHub rồi build bằng Docker Compose.

## 1) Điều kiện cần

- Docker Desktop (hoặc Docker Engine + Docker Compose plugin)
- Git
- Các cổng còn trống trên máy host: `6080`, `3000`, `5000`, `3306`, `27017`, `8081`

## 2) Cách A - Kéo image từ Docker Hub

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

Kiểm tra nhanh sau khi chạy:

- noVNC: `http://localhost:6080/vnc.html`
- Node API: `http://localhost:3000/api`
- Python API: `http://localhost:5000/api`
- phpMyAdmin: `http://localhost:8081/phpmyadmin`

Dừng và xóa container:

```powershell
docker rm -f combined-dev
```

## 3) Cách B - Clone repo từ GitHub rồi build local

```powershell
git clone https://github.com/ngominhthien22/combined-image.git
cd combined-image
docker compose up --build -d
```

Kiểm tra nhanh sau khi chạy:

- noVNC: `http://localhost:6080/vnc.html`
- Node API: `http://localhost:3000/api`
- Python API: `http://localhost:5000/api`
- phpMyAdmin: `http://localhost:8081/phpmyadmin`

Dừng hệ thống:

```powershell
docker compose down --remove-orphans
```

Lưu ý:

- Nếu tên thư mục local khác `combined-image`, hãy `cd` vào đúng thư mục chứa `docker-compose.yml` trước khi chạy `docker compose up`.
- Mật khẩu noVNC mặc định: `devpass`.
- MariaDB mặc định:
  - User: `dev`
  - Password: `devpass`
  - Database: `appdb`
