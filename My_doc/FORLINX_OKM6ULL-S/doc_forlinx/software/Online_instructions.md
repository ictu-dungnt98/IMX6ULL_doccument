# Hướng Dẫn Sử Dụng Trực Tuyến

> **Lưu ý:** Cần đọc trước khi sử dụng.

---

## Mô Tả Hệ Thống

- **Hệ điều hành mặc định của nhà sản xuất:** Linux 4.1.15 + Qt 5.6
- **Hệ thống được hỗ trợ:** Linux 4.1.15 + Qt 5.6 *(cấu hình 256+256 không hỗ trợ Qt 5.6 theo mặc định)*

Để chuyển đổi hoặc nâng cấp hệ thống, hãy vào mục **"Tải xuống"** trên diễn đàn chính thức, tìm nền tảng tương ứng và tải xuống **"Bản ghi dữ liệu phát hành sản phẩm bo mạch phát triển OKMX6ULL-S"**. Sau đó, tìm liên kết Baidu Cloud cho hệ thống của bạn và tải xuống. Sau khi tải xuống, bạn cần phải nạp lại ảnh hệ thống tương ứng. Tham khảo phần hướng dẫn nạp ảnh trong sách hướng dẫn sử dụng để biết cách nạp ảnh.

- 📄 [05\_Hệ thống lập trình](https://forlinx-book.yuque.com/okypkp/okmx6ull-s/yivuga0sqpf37hwg)
- 🌐 [Diễn đàn học tập về hệ thống nhúng - Được hỗ trợ bởi Discuz!](http://bbs.witech.com.cn/)

> **Lưu ý:** Việc tải xuống tài liệu yêu cầu kích hoạt thẻ thành viên. Người dùng chưa có thẻ thành viên vui lòng liên hệ với đại diện bán hàng tương ứng để kích hoạt.

---

## Hướng Dẫn Sử Dụng Trực Tuyến

Khi xem hướng dẫn sử dụng, trước tiên bạn cần xác định **phiên bản hệ thống** của mình, sau đó chọn hướng dẫn sử dụng trực tuyến dành cho hệ thống tương ứng.

Các tài liệu hướng dẫn trực tuyến được chia thành bốn phần:

### 1. Hướng Dẫn Sử Dụng
Phần này chủ yếu mô tả các phương pháp khởi động và gỡ lỗi bo mạch phát triển, kiểm tra các chức năng giao diện và nạp hình ảnh.

### 2. Hướng Dẫn Biên Soạn Dành Cho Người Dùng
Phần này chủ yếu mô tả cách thiết lập môi trường phát triển, biên dịch SDK và biên dịch ứng dụng.

### 3. Hướng Dẫn Sử Dụng Phần Cứng
Tài liệu này chủ yếu mô tả các chức năng giao diện của bo mạch phát triển, giới thiệu giao diện, mức tiêu thụ điện năng của sản phẩm và cách khắc phục một số sự cố có thể xảy ra trong quá trình sử dụng.

### 4. Nguyên Tắc Thiết Kế Phần Cứng
Tài liệu này cung cấp tổng quan chi tiết về các yếu tố cần xem xét khi thiết kế các chức năng khác nhau trong sơ đồ mạch và thiết kế PCB trong quá trình người dùng tự thiết kế bo mạch chủ của riêng mình bằng cách sử dụng bo mạch lõi, bao gồm thông tin hỗ trợ chức năng giao diện và các phương pháp khắc phục sự cố đối với các vấn đề giao diện thường gặp.

### 5. Cẩm Nang Phát Triển
Đây là một số giải pháp và phương pháp được đúc kết trong quá trình phát triển thực tế, chẳng hạn như:
- Phương pháp tái sử dụng mã PIN
- Phương pháp thay thế logo
- Phương pháp xoay màn hình
- v.v.



# Hướng Dẫn Sử Dụng Linux 4.1.15 + Qt 5.6

| Thông tin        | Chi tiết                  |
|------------------|---------------------------|
| **Phiên bản**    | V2.5                      |
| **Ngày phát hành** | 16 tháng 7 năm 2024     |
| **Phân loại**    | ■ Công khai               |

---

## Tuyên Bố Miễn Trừ Trách Nhiệm

Tài liệu hướng dẫn này thuộc bản quyền của **Công ty TNHH Công nghệ Nhúng Baoding Feiling**. Không tổ chức hay cá nhân nào được phép sao chép, phân phối hoặc in lại bất kỳ phần nào của tài liệu hướng dẫn này dưới bất kỳ hình thức nào mà không có sự cho phép bằng văn bản của công ty; người vi phạm sẽ phải chịu trách nhiệm pháp lý.

Tất cả các dịch vụ do **Công ty TNHH Hệ thống Nhúng Baoding Feiling** cung cấp đều được thiết kế để hỗ trợ người dùng đẩy nhanh quá trình phát triển sản phẩm. Bất kỳ chương trình, tài liệu, kết quả thử nghiệm, giải pháp, hỗ trợ hoặc các tài liệu và thông tin khác được cung cấp trong quá trình cung cấp dịch vụ chỉ mang tính chất **tham khảo**. Người dùng có quyền không sử dụng hoặc tự ý sửa đổi chúng. Công ty chúng tôi không đảm bảo tính đầy đủ hoặc độ tin cậy. Công ty chúng tôi sẽ không chịu trách nhiệm đối với bất kỳ tổn thất đặc biệt, ngẫu nhiên hoặc gián tiếp nào phát sinh do bất kỳ lý do nào trong quá trình người dùng sử dụng.

---

## Tổng Quan

Bài viết này là hướng dẫn sử dụng Linux cho bo mạch phát triển **OKMX6ULL-S**, nội dung chính bao gồm:

- Giới thiệu sản phẩm
- Khởi động nhanh
- Kiểm tra chức năng
- Nạp firmware hệ thống

---

## Phạm Vi Áp Dụng

Sách hướng dẫn phần mềm này áp dụng cho thiết bị **OKMX6ULL-S** của Feiling Technology:

- Các bo mạch phát triển với cấu hình **RAM 512MB** và bộ nhớ Flash **eMMC 4GB & 8GB**
- Các bo mạch phát triển với cấu hình **RAM 256MB** và bộ nhớ Flash **NAND 256MB**

---

## Nhật Ký Cập Nhật

| Ngày | Phiên bản | Nội dung cập nhật |
|------|-----------|-------------------|
| 08/06/2020 | V1.0 | Sách hướng dẫn sử dụng Linux 4.1.15 + Qt 5.6, ấn bản đầu tiên. |
| 06/07/2020 | V1.1 | Sửa đổi hướng dẫn về quy trình đốt. |
| 22/09/2020 | V1.2 | Thêm hướng dẫn kiểm tra dịch vụ FTP. |
| 01/11/2020 | V1.3 | Sửa các lỗi sai trong tài liệu hướng dẫn; thay đổi cấu hình âm thanh. |
| 13/04/2021 | V1.4 | Thêm các phương pháp kiểm thử mô-đun EC20 4G. |
| 15/09/2021 | V2.0 | Điều chỉnh cấu trúc sách hướng dẫn và bổ sung các mô tả hướng dẫn. |
| 20/12/2021 | V2.1 | Thêm tính năng thích ứng màn hình; sửa đổi hướng dẫn kiểm tra. |
| 16/05/2022 | V2.2 | Thêm kiểm tra Bluetooth của hệ thống tập tin QT; thay đổi lệnh kiểm tra âm thanh; thay đổi lệnh truy cập máy chủ Linux qua SSH. |
| 29/08/2022 | V2.3 | Ôn lại mô tả chương kiểm tra GPRS; tính năng kiểm thử NAND không được hỗ trợ bởi phiên bản hệ thống tập tin; chỉnh sửa phần mô tả kiểm tra Bluetooth, thêm hỗ trợ RT8723BU; thay đổi minh họa địa chỉ IP mặc định trong kiểm tra mạng có dây và SSH. |
| 16/08/2023 | V2.4 | Thêm phần kiểm tra audio/video chip âm thanh NAU88C22. |
| 23/10/2023 | V2.5 | Thêm phương pháp thử nghiệm IPv6. |
| 16/07/2024 | V2.5 | Ấn bản đầu tiên của điệp viên. |