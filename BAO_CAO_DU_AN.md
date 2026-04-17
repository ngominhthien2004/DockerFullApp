# BÁO CÁO DỰ ÁN - COMBINED IMAGE

Ngày báo cáo: 2026-04-16
Đường dẫn repo: D:/Crack/DockerFullApp/combined-image

## 1) Thông tin tổng quan

- Tên dự án: combined-image.
- Mục tiêu chính: cung cấp 1 Docker image/dev container tích hợp môi trường desktop qua noVNC + runtime đa ngôn ngữ + công cụ GUI + dịch vụ DB.
- Nền tảng: Docker, Ubuntu 22.04, docker compose.
- Thành phần ứng dụng mẫu:
  - Node.js app: Express, trả về API sức khỏe tại /api.
  - Python app: Flask, trả về API sức khỏe tại /api.
- Dịch vụ hệ thống bên trong container:
  - noVNC + x11vnc + Xvfb + XFCE desktop.
  - MariaDB, MongoDB, Apache + phpMyAdmin.

## 2) Mục tiêu và phạm vi

- Mục tiêu:
  - Tạo môi trường all-in-one để dev/test nhanh trên 1 container.
  - Hỗ trợ vừa web endpoint vừa desktop GUI qua trình duyệt.
  - Có bộ script kiểm thử E2E và manual capture để xác nhận runtime.
- Phạm vi trong repo hiện tại:
  - Đóng gói image và startup: Dockerfile, docker-compose.yml, start.sh.
  - App mẫu: node-app, python-app.
  - Kiểm thử tự động: tests/ (Playwright).
  - Minh chứng kiểm thử thủ công và archive kết quả: test/manual, test/archive.
- Ngoài phạm vi:
  - Chưa có pipeline CI/CD chính thức trong repo.
  - Chưa có bộ metric/monitoring production.

## 3) Kiến trúc hệ thống

- Kiến trúc 1 service compose:
  - Service: combined-dev.
  - Build trực tiếp từ Dockerfile tại root.
- Luồng khởi động tổng quan:
  1. Khởi tạo Xvfb + XFCE desktop.
  2. Khởi tạo x11vnc (5900) và websockify/noVNC (6080).
  3. Khởi tạo MariaDB, MongoDB, Apache/phpMyAdmin.
  4. Chạy Node app (3000) và Python app (5000).
  5. Healthcheck gọi 3 điểm: /vnc.html, Node /api, Python /api.
- Ports mapping (host -> container):
  - 6080 -> 6080 (noVNC web)
  - 3000 -> 3000 (Node app)
  - 5000 -> 5000 (Python app)
  - 3306 -> 3306 (MariaDB)
  - 27017 -> 27017 (MongoDB)
  - 8081 -> 80 (Apache/phpMyAdmin)

## 4) Thành phần chính

- Docker layer:
  - Dockerfile cài đặt runtime/tooling: node 20, python3, mongodb-org, mongosh, mariadb, code, phpmyadmin, plantuml, r-base, và nhiều GUI app.
- Runtime startup:
  - start.sh điều phối toàn bộ tiến trình hệ thống và app.
  - Tạo user dev, setup VNC password, bootstrap DB user/database thông qua env.
- Ứng dụng mẫu:
  - node-app/index.js:
    - GET / -> HTML thông báo app đang chạy.
    - GET /api -> JSON {"status":"ok","service":"node"}.
  - python-app/app.py:
    - GET / -> HTML thông báo app đang chạy.
    - GET /api -> JSON {"status":"ok","service":"python"}.
- Kiểm thử:
  - tests/specs/combined.spec.js có 3 testcase: noVNC reachable, Node API reachable, Python API reachable.
  - tests/run-e2e.ps1 tự động bring-up compose, đợi healthy, chạy playwright, teardown.
  - tests/manual_capture.sh chụp ảnh terminal/gui và cập nhật test/manual/progress.txt.

## 5) Quy trình khởi động và vận hành

- Khởi động local bằng compose:

```powershell
cd D:/Crack/DockerFullApp/combined-image
docker compose up --build -d
```

- Truy cập endpoint sau khi lên:
  - noVNC: http://localhost:6080/vnc.html
  - Node API: http://localhost:3000/api
  - Python API: http://localhost:5000/api
  - phpMyAdmin: http://localhost:8081/phpmyadmin
  - MariaDB: localhost:3306
  - MongoDB: localhost:27017
- Kiểm tra nhanh trong container (từ README):

```powershell
docker exec -it combined-dev bash -lc "mysql -udev -pdevpass -e 'SELECT 1;'"
docker exec -it combined-dev bash -lc "mongosh --quiet --eval 'db.adminCommand({ ping: 1 })'"
```

- Dừng hệ thống:

```powershell
docker compose down --remove-orphans
```

## 6) Chiến lược kiểm thử

- Mục tiêu kiểm thử:
  - Xác nhận endpoint web chính sẵn sàng.
  - Xác nhận API mẫu trả dữ liệu đúng contract cơ bản.
  - Xác nhận GUI/runtime tồn tại qua screenshot và log.
- Lớp kiểm thử tự động (Playwright):
  - Cấu hình: tests/playwright.config.js, timeout 60s, trace retain-on-failure.
  - Script:

```powershell
cd D:/Crack/DockerFullApp/combined-image/tests
npm install
npx playwright install chromium
npm test
```

- Script tổng hợp:

```powershell
cd D:/Crack/DockerFullApp/combined-image/tests
./run-e2e.ps1
```

- Lớp kiểm thử thủ công:
  - Script: tests/manual_capture.sh.
  - Artifact: test/manual/terminal/_.png, test/manual/gui/_.png.
  - Log tóm tắt: test/manual/progress.txt.
- Bằng chứng regression:
  - test/archive/progress.md ghi nhận Playwright suite pass (3 passed).
  - test/archive có kết quả bổ sung cho PlantUML và R.

## 7) Đánh giá hiện trạng (điểm mạnh/rủi ro)

- Điểm mạnh:
  - Đóng gói all-in-one rõ ràng, chạy được bằng 1 lệnh compose.
  - Có healthcheck tích hợp noVNC + 2 API quan trọng.
  - Có bộ test E2E tự động và bộ minh chứng manual.
  - Có endpoint mẫu đơn giản để xác minh trạng thái nhanh.
- Rủi ro/hạn chế:
  - Container gom rất nhiều thành phần GUI/runtime -> image lớn, startup lâu, tốn RAM/CPU cao.
  - Quy trình test hiện phụ thuộc Docker local, chưa thấy CI pipeline trong repo.
  - Mật khẩu/default credentials tồn tại trong tài liệu và env mặc định (dev/devpass), cần quy định rõ môi trường sử dụng.
  - PlantUML archive cho thấy cảnh báo Graphviz dot chưa set đầy đủ (chỉ sequence diagram).

## 8) Kiến nghị cải tiến ưu tiên

1. Ưu tiên cao: Tách profile runtime

- Tạo nhiều profile compose (core, gui-full, test) để giảm tải cho use case thông thường.

2. Ưu tiên cao: Chuẩn hóa bảo mật cấu hình

- Đưa toàn bộ credential vào file env mẫu + tài liệu an toàn, loại bỏ giá trị nhạy cảm khỏi script/public docs khi lên production.

3. Ưu tiên trung bình: Bổ sung CI cho tests

- Chạy tests/run-e2e.ps1 hoặc Linux tương đương trên CI để bảo đảm regression liên tục.

4. Ưu tiên trung bình: Tăng cường quan sát

- Thêm script smoke check tổng hợp và xuất kết quả JSON để dễ theo dõi theo lần build.

5. Ưu tiên thấp-trung bình: Hoàn thiện PlantUML toolchain

- Cài đặt/cấu hình Graphviz đầy đủ để hỗ trợ đủ loại diagram.

## 9) Phụ lục lệnh nhanh

- Build và run:

```powershell
cd D:/Crack/DockerFullApp/combined-image
docker compose up --build -d
```

- Kiểm tra health container:

```powershell
docker compose ps
docker inspect --format "{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}" combined-dev
```

- Kiểm tra API trực tiếp:

```powershell
curl http://127.0.0.1:3000/api
curl http://127.0.0.1:5000/api
```

- Chạy E2E Playwright:

```powershell
cd D:/Crack/DockerFullApp/combined-image/tests
npm install
npx playwright install chromium
npm test
```

- Chạy quy trình E2E end-to-end tự động (bring-up -> test -> teardown):

```powershell
cd D:/Crack/DockerFullApp/combined-image/tests
./run-e2e.ps1
```

- Kiểm tra DB nhanh:

```powershell
docker exec -it combined-dev bash -lc "mysql -udev -pdevpass -e 'SELECT 1;'"
docker exec -it combined-dev bash -lc "mongosh --quiet --eval 'db.adminCommand({ ping: 1 })'"
```

- Dừng toàn bộ:

```powershell
cd D:/Crack/DockerFullApp/combined-image
docker compose down --remove-orphans
```
