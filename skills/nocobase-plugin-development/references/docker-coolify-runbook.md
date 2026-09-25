# Sổ Tay Triển Khai Docker / Coolify & Xử Lý Sự Cố Khẩn Cấp (Runbook)

> Hướng dẫn triển khai plugin lên môi trường Docker / Coolify và các bước cứu hộ khẩn cấp khi gặp sự cố màn hình đỏ hoặc RequireJS scripterror.

---

## 1. Quy Trình Triển Khai Chuẩn Lên Coolify / Docker

### Bước 1: Đóng gói tại máy phát triển
```bash
# Di chuyển vào thư mục plugin
cd packages/plugins/@scope/plugin-name

# Biên dịch kép cả v1 và v2
yarn build @scope/plugin-name

# Đóng gói file tarball
npm pack
# Kết quả: scope-plugin-name-x.y.z.tgz
```

### Bước 2: Tải lên giao diện NocoBase trên Coolify
1. Đăng nhập vào NocoBase trên server của bạn.
2. Truy cập **Settings > Plugin Manager** (`https://your-domain.com/admin/settings/plugin-manager`).
3. Nhấn nút **Upload plugin** ở góc trên bên phải và chọn file `.tgz`.
4. Tìm plugin vừa tải lên trong danh sách và bấm nút gạt **Enable**.

---

## 2. Xử Lý Khẩn Cấp Khi Trang Web Bị Treo Màn Hình Đỏ

Nếu xảy ra sự cố (ví dụ RequireJS scripterror hoặc plugin gây lỗi toàn trang):

### Cách 1: Sử dụng Terminal Coolify (Khuyên dùng)
1. Trên giao diện Coolify, vào service NocoBase của bạn.
2. Chọn tab **Terminal** ở cột bên trái.
3. Chọn container ứng dụng (thường bắt đầu bằng `app-...`).
4. Chạy lệnh tắt plugin ngay lập tức:
   ```bash
   yarn nocobase pm disable @scope/plugin-name
   ```
   *(hoặc `yarn pm disable @scope/plugin-name`)*
5. Nếu cần xóa hẳn thư mục chứa code lỗi:
   ```bash
   rm -rf storage/plugins/@scope/plugin-name
   ```
6. Bấm nút **Restart** container trên Coolify.
7. F5 lại trình duyệt, trang web sẽ hoạt động lại bình thường.

### Cách 2: Vô hiệu hóa trực tiếp trong Database (Postgres / MySQL)
Nếu không vào được terminal của App, vào terminal của Container CSDL (`postgres-...`):
1. Mở terminal container CSDL:
   ```bash
   psql -U $POSTGRES_USER -d $POSTGRES_DB
   ```
2. Chạy câu lệnh SQL tắt plugin:
   ```sql
   UPDATE "applicationPlugins" SET enabled = false WHERE name = '@scope/plugin-name';
   \q
   ```
3. Restart lại service NocoBase. Hệ thống sẽ bỏ qua plugin khi nạp.

---

## 3. Quy Tắc Truy Cập Sau Khi Kích Hoạt
NocoBase 2.x phân tách rõ ràng:
- Giao diện cài đặt cổ điển: `/admin/settings/...`
- Giao diện người dùng hiện đại và module mới: Bắt buộc có tiền tố **`/v/`** (ví dụ `/v/my-plugin`, `/v/admin/settings/my-plugin`).
