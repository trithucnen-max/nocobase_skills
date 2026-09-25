# Hướng Dẫn & Bộ Khung Tài Liệu OpenWiki Cho Plugin NocoBase

> Mỗi plugin NocoBase chuyên nghiệp cần có thư mục tài liệu kiến trúc `openwiki/` đặt ở thư mục gốc của plugin.

---

## 1. Cấu Trúc Bắt Buộc Của Thư Mục `openwiki/`

```
openwiki/
├── README.md          # Điểm truy cập trung tâm: mục tiêu, tech stack, điều hướng nhanh
├── architecture.md    # Kiến trúc đa tầng, cơ chế dual-client, sơ đồ tương tác
├── services.md        # Danh mục và mô tả chi tiết tất cả service classes / engine
├── data-flow.md       # Sơ đồ tuần tự và luồng dữ liệu nghiệp vụ
├── database.md        # Chi tiết cấu trúc CSDL 100%, sơ đồ quan hệ ERD
└── patterns.md        # Các quy ước bất di bất dịch, cạm bẫy kỹ thuật và cách phòng tránh
```

---

## 2. Quy Tắc Biên Soạn OpenWiki

1. **Dòng Tóm Tắt Đầu Tiên (One-line Summary)**: Mọi tệp markdown trong `openwiki/` bắt buộc phải có câu blockquote tóm tắt giá trị ở ngay dưới tiêu đề H1:
   ```markdown
   # Tên Tài Liệu
   > Tóm tắt 1 câu về nội dung và phạm vi của tài liệu này để Agent/Developer đọc trước khi tải toàn bộ.
   ```
2. **Sơ Đồ Trực Quan (Mermaid)**: Mọi tệp kiến trúc, luồng dữ liệu và cơ sở dữ liệu bắt buộc phải có ít nhất 1 sơ đồ Mermaid chuẩn cú pháp (`graph TD`, `sequenceDiagram`, `stateDiagram-v2`, `erDiagram`).
3. **Cập Nhật Đồng Bộ**: Khi mã nguồn có thay đổi cấu trúc DB hoặc thêm Custom API, phải cập nhật đồng bộ các tệp tương ứng trong `openwiki/`.
