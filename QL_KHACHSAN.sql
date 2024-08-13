CREATE DATABASE QL_KHACHSAN
GO
USE QL_KHACHSAN
GO
SET DATEFORMAT DMY

CREATE TABLE NhanVien
(
    MaNV VARCHAR(5) NOT NULL,
    TenNV NVARCHAR(50) NOT NULL,
	NgaySinh DATE NOT NULL,
	DiaChi NVARCHAR(100) NOT NULL,
	GioiTinh NVARCHAR(3) NOT NULL,
	Luong INT NOT NULL,
    ChucVu NVARCHAR(50) NOT NULL,
	CCCD VARCHAR(12) NOT NULL UNIQUE,
    SDT VARCHAR(10) NOT NULL UNIQUE,
    Email VARCHAR(100) UNIQUE,
	
	CONSTRAINT PK_NhanVien PRIMARY KEY (MaNV)
)
CREATE TABLE TaiKhoan
(
    TenTK NVARCHAR(50) NOT NULL,
    MatKhau NVARCHAR(1000) NOT NULL,
	MaNV VARCHAR(5) NOT NULL,
    CapQuyen INT NOT NULL,

	CONSTRAINT PK_TaiKhoan PRIMARY KEY (TenTK),
	CONSTRAINT PK_TaiKhoan_NhanVien FOREIGN KEY(MaNV) REFERENCES NhanVien(MaNV)
)
CREATE TABLE KhachHang
(
    MaKH VARCHAR(5) NOT NULL,
    TenKH NVARCHAR(50) NOT NULL,
    SDT VARCHAR(10),
    CCCD VARCHAR(12) NOT NULL UNIQUE,
    QuocTich NVARCHAR(30) NOT NULL,
    GioiTinh NVARCHAR(3) NOT NULL,
	
	CONSTRAINT PK_KhachHang PRIMARY KEY (MaKH)
)
CREATE TABLE LoaiPhong
(
    MaLPH VARCHAR(5),
    TenLPH NVARCHAR(20) NOT NULL,
    SoGiuong INT NOT NULL,
    SoNguoiToiDa INT NOT NULL,
    GiaNgay MONEY NOT NULL,
    GiaGio MONEY NOT NULL
	CONSTRAINT PK_LoaiPhong PRIMARY KEY (MaLPH)
)
CREATE TABLE Phong
(
    MaPH VARCHAR(5) NOT NULL,
    TTPH NVARCHAR(20) NOT NULL,--Tình trạng phòng
    TTDD NVARCHAR(20) NOT NULL,--Tình trạng dọn dẹp
    GhiChu NVARCHAR(100),
    MaLPH VARCHAR(5) NOT NULL,
	
	CONSTRAINT PK_Phong PRIMARY KEY (MaPH),
	CONSTRAINT FK_Phong_LoaiPhong FOREIGN KEY(MaLPH) REFERENCES LoaiPhong(MaLPH)
)
CREATE TABLE PhieuThue
(
    MaPT VARCHAR(5) NOT NULL,
    NgayLap DATETIME NOT NULL,
    MaKH VARCHAR(5) NOT NULL,
    MaNV VARCHAR(5) NOT NULL,

	CONSTRAINT PK_PhieuThue PRIMARY KEY (MaPT),
	CONSTRAINT FK_PhieuThue_KhachHang FOREIGN KEY(MaKH) REFERENCES KhachHang(MaKH),
    CONSTRAINT FK_PhieuThue_NhanVien FOREIGN KEY(MaNV) REFERENCES NhanVien(MaNV)
)
CREATE TABLE CTDP
(
    MaCTDP VARCHAR(7),
    SoNguoi INT,
    MaPT VARCHAR(5) NOT NULL, -- mã phiếu thuê
    MaPH VARCHAR(5) NOT NULL, -- mã phòng
    CheckIn DATETIME NOT NULL,
    CheckOut DATETIME NOT NULL,
    TrangThai NVARCHAR(20) NOT NULL,
	DonGia MONEY,
    ThanhTien MONEY DEFAULT 0,
	TheoGio BIT DEFAULT 0,
	CONSTRAINT PK_CTDP PRIMARY KEY (MaCTDP),
	CONSTRAINT FK_CTDP_PhieuThue FOREIGN  KEY(MaPT) REFERENCES PhieuThue(MaPT),
	CONSTRAINT FKCTDP_MaPH_Phong FOREIGN  KEY(MaPH) REFERENCES Phong(MaPH)
)
CREATE TABLE TienNghi
(
    MaTN VARCHAR(5),
    TenTN NVARCHAR(50) NOT NULL,
	
	CONSTRAINT PK_TienNghi PRIMARY KEY (MaTN)
)
CREATE TABLE DichVu
(
    MaDV VARCHAR(5),
    TenDV NVARCHAR(20) NOT NULL,
    DonGia MONEY NOT NULL,
    SLConLai INT DEFAULT -1,
    LoaiDV NVARCHAR(20) NOT NULL,

	CONSTRAINT PK_DichVu PRIMARY KEY (MaDV)
)

CREATE TABLE HoaDon
(
    MaHD NVARCHAR(5),
    NgayLap DATETIME ,
    TriGia MONEY DEFAULT 0,
    MaNV VARCHAR(5),
    TrangThai NVARCHAR(20) NOT NULL,
    MaCTDP VARCHAR(7) NOT NULL,
	
	CONSTRAINT PK_HoaDon PRIMARY KEY (MaHD),
    CONSTRAINT FK_HoaDon_NhanVien FOREIGN KEY(MaNV) REFERENCES NhanVien(MaNV),
	CONSTRAINT FK_HoaDon_CTDP FOREIGN KEY(MaCTDP) REFERENCES CTDP(MaCTDP)
)
CREATE TABLE CTTN
(
    MaLPH VARCHAR(5) NOT NULL, -- mã loại phòng
    MaTN VARCHAR(5) NOT NULL, -- mã tiện nghi
    SL INT DEFAULT -1, -- số lượng
	
    CONSTRAINT PK_CTTN PRIMARY KEY(MaLPH,MaTN),
	CONSTRAINT FK_CTTN_LoaiPhong FOREIGN KEY (MaLPH) REFERENCES LoaiPhong(MaLPH),
	CONSTRAINT FK_CTTN_TienNghi FOREIGN KEY (MaTN) REFERENCES TienNghi(MaTN)
)

CREATE TABLE CTDV
(
    MaCTDP VARCHAR(7) NOT NULL, -- mã chi tiết đặt phòng
    MaDV VARCHAR(5) NOT NULL, -- mã dịch vụ
	DonGia INT NOT NULL, 
    SL INT NOT NULL,
    ThanhTien INT DEFAULT 0,
    CONSTRAINT PK_CTDV PRIMARY KEY(MaCTDP,MaDV,DonGia),
	CONSTRAINT FK_CTDV_CTDV FOREIGN KEY (MaCTDP) REFERENCES CTDP(MaCTDP),
	CONSTRAINT FK_CTDV_DichVu FOREIGN KEY (MaDV) REFERENCES DichVu(MaDV)
)
GO
-- Trigger Update Giá phòng
CREATE TRIGGER CapNhatGiaCTDP ON CTDP FOR INSERT,UPDATE
AS
BEGIN
	DECLARE @MaPhong NVARCHAR(5)
	SET @MaPhong = (SELECT MaPH FROM inserted)
	DECLARE @MaCTDP NVARCHAR(7)
	SET @MaCTDP = (SELECT MaCTDP FROM inserted)
	DECLARE @GiaNgay MONEY
	SET @GiaNgay = (SELECT  LoaiPhong.GiaNgay
					FROM Phong JOIN LoaiPhong ON Phong.MaLPH=LoaiPhong.MaLPH
					WHERE Phong.MaPH=@MaPhong
					)
	DECLARE @GiaGio MONEY
	SET @GiaGio = (SELECT  LoaiPhong.GiaGio
					FROM Phong JOIN LoaiPhong ON Phong.MaLPH=LoaiPhong.MaLPH
					WHERE Phong.MaPH=@MaPhong
					)
	DECLARE @CheckIn SMALLDATETIME, @CheckOut SMALLDATETIME,@KhoangTGNgay INT, @KhoangTGGio INT
	SET @CheckIn = (SELECT CheckIn FROM inserted)
	SET @CheckOut = (SELECT CheckOut FROM inserted)
	SET @KhoangTGNgay=  (SELECT DATEDIFF(DAY, @CheckIn, @CheckOut))
	IF @KhoangTGNgay < 1
	BEGIN
	SET @KhoangTGGio=  (SELECT DATEDIFF(HOUR, @CheckIn, @CheckOut))		
		IF @KhoangTGGio < 4
			BEGIN
				DECLARE @DonGia MONEY
				SET @DonGia = (SELECT GiaGio FROM LoaiPhong JOIN Phong ON LoaiPhong.MaLPH = Phong.MaLPH JOIN CTDP ON CTDP.MaPH=Phong.MaPH WHERE CTDP.MaCTDP=@MaCTDP) 
				UPDATE CTDP
				SET ThanhTien= @KhoangTGGio * @GiaGio
				WHERE @MaCTDP = MaCTDP
				UPDATE CTDP
				SET TheoGio= 1
				WHERE @MaCTDP = MaCTDP
				UPDATE CTDP
				SET DonGia= @DonGia
				WHERE @MaCTDP = MaCTDP
			END
		ELSE
			BEGIN
				UPDATE CTDP
				SET ThanhTien= @GiaNgay
				WHERE @MaCTDP = MaCTDP
			END
	END
	ELSE
	BEGIN
		UPDATE CTDP
		SET "DonGia"= @GiaNgay
		WHERE @MaCTDP = MaCTDP
		UPDATE CTDP
		SET "ThanhTien"= @KhoangTGNgay * @GiaNgay
		WHERE @MaCTDP = MaCTDP
	END
END
-- Trigger update Gia CTDV
GO 
CREATE TRIGGER CapNhatGiaDV ON CTDV FOR INSERT,UPDATE
AS
BEGIN
	DECLARE @MaCTDP NVARCHAR(7), @MaDV NVARCHAR(5), @GiaTien MONEY, @SL INT
	SET @MaCTDP = (SELECT MaCTDP FROM inserted)
	SET @MaDV = (SELECT MaDV FROM inserted)
	SET @GiaTien = (SELECT DonGia FROM DichVu WHERE DichVu.MaDV=@MaDV)
	SET @SL = (SELECT SL FROM inserted)
	UPDATE CTDV
	SET DonGia=@GiaTien
	WHERE MaDV = @MaDV AND MaCTDP = @MaCTDP
	UPDATE CTDV
	SET ThanhTien= @SL * @GiaTien
	WHERE MaDV = @MaDV AND MaCTDP = @MaCTDP
END
-- TRIGGER udpate giá trị hóa đơn
GO
CREATE TRIGGER CapNhatGiaTriHoaDon ON HoaDon FOR INSERT,UPDATE
AS
BEGIN
	DECLARE @MaHD NVARCHAR(5), @MaCTDP NVARCHAR(7), @TongTienHD MONEY, @TongTienDV MONEY, @TongTienPhong MONEY
	SET @MaHD = (SELECT MaHD FROM inserted)
	SET @MaCTDP = (SELECT MaCTDP FROM inserted)
	SET @TongTienDV = 0
	SET @TongTienDV = (SELECT SUM(ThanhTien) FROM CTDV WHERE MaCTDP = @MaCTDP GROUP BY MaCTDP)
	SET @TongTienPhong = (SELECT ThanhTien FROM CTDP WHERE MaCTDP=@MaCTDP)
	IF ( NOT EXISTS( SELECT * FROM CTDV WHERE MaCTDP = @MaCTDP))
	BEGIN 
		SET @TongTienDV = 0
	END
	UPDATE HoaDon
	SET TriGia = @TongTienDV+@TongTienPhong
	WHERE MaHD=@MaHD
END
GO

-- INSERT DATA
INSERT INTO NhanVien 
VALUES 
	('AD001',N'Nguyễn Phúc Bình', '30/09/2003', N'Đường Hàn Thuyên, khu phố 6, Thủ Đức, Thành phố Hồ Chí Minh', N'Nam',40000000,N'Quản lý', '072000001212','0907219273','21520638@gm.uit.edu.vn'),
	('AD002',N'Phan Tuấn Thành', '11/10/2003',N'Đường Hàn Thuyên, khu phố 6, Thủ Đức, Thành phố Hồ Chí Minh', N'Nam',45000000,N'Quản lý', '072000001213','071223431','21520455@gm.uit.edu.vn'),
	('AD003',N'Lê Thanh Tuấn', '10/06/1989', N'Đường Hàn Thuyên, khu phố 6, Thủ Đức, Thành phố Hồ Chí Minh', N'Nam',50000000,N'Quản lý', '072000001214','010311231','21520519@gm.uit.edu.vn'),
	('QL001',N'Phạm Thị A', '09/03/1995',N'Đường Hàn Thuyên, khu phố 6, Thủ Đức, Thành phố Hồ Chí Minh', N'Nữ',5500000,N'Tiếp tân', '072000001215','095411231','NV215235119@gmail.com'),
	('NV001',N'Trần Thị B', '23/01/1993',N'Đường Hàn Thuyên, khu phố 6, Thủ Đức, Thành phố Hồ Chí Minh', N'Nữ',5500000,N'Tiếp tân', '072000001217','091311231','NV545205119@gmail.com'),
	('NV002',N'Nguyễn Phuc C ', '21/11/1986',N'Đường Hàn Thuyên, khu phố 6, Thủ Đức, Thành phố Hồ Chí Minh', N'Nam',5500000,N'Tiếp tân', '072000001220','092311231','NV6152051@gmail.com'),
	('NV003',N'Lê Văn D', '05/7/1990',N'Đường Hàn Thuyên, khu phố 6, Thủ Đức, Thành phố Hồ Chí Minh', N'Nam',5500000,N'Tiếp tân', '072000001221','090317231','NV2152119@gmail.com'),
	('NV004',N'Hồ Văn E', '27/10/2000',N'Đường Hàn Thuyên, khu phố 6, Thủ Đức, Thành phố Hồ Chí Minh', N'Nam',5500000,N'Bảo vệ', '072000001282','090312231','NV715205119@gmail.com'),
	('NV005',N'Nguyễn Văn F', '24/02/1998',N'Đường Hàn Thuyên, khu phố 6, Thủ Đức, Thành phố Hồ Chí Minh', N'Nam',5500000,N'Nhân viên vệ sinh', '072000009012','090111231','NV52015119@gmail.com'),
	('NV006',N'Phạm Thị P', '02/08/2001',N'Đường Hàn Thuyên, khu phố 6, Thủ Đức, Thành phố Hồ Chí Minh', N'Nữ',5500000,N'Nhân viên vệ sinh', '072000002134','090311232','NV15205119@gmail.com'),
	('NV007',N'Nguyễn Văn G', '12/09/2002',N'Đường Hàn Thuyên, khu phố 6, Thủ Đức, Thành phố Hồ Chí Minh', N'Nam',5500000,N'Bảo vệ', '072000028912','090311233','NV215595119@gmail.com')
-- Tai Khoan

INSERT INTO TaiKhoan (TenTK,MatKhau,MaNV,CapQuyen)
VALUES 
    ('Quanly', '1234', 'QL001', 2),
    ('NhanVien', '1234', 'NV001', 1);
-- Khach Hang
INSERT INTO KhachHang (MaKH,TenKH, GioiTinh, QuocTich, CCCD, SDT)
VALUES
	('KH001',N'Nguyễn Văn A', N'Nam', N'Việt Nam', '072001056912', '092391233'),
	('KH002',N'Nguyễn Văn B', N'Nam', N'Việt Nam', '072001056913', '092391234'),
	('KH003',N'Nguyễn Văn C', N'Nam', N'Việt Nam', '072001056914', '092391235'),
	('KH004',N'Phạm Thi P', N'Nữ', N'Việt Nam', '072001546231', '092361213'),
	('KH005',N'Phạm Thi G', N'Nữ', N'Việt Nam', '072001012231', '082361233'),
	('KH006',N'Nguyễn Văn D', N'Nam', N'Việt Nam', '072001056952', '092391236'),
	('KH007',N'Nguyễn Văn E', N'Nam', N'Việt Nam', '072001056911', '092391237'),
	('KH008',N'Phạm Thi H', N'Nữ', N'Việt Nam', '072001078231', '096361233'),
	('KH009',N'Nguyễn Văn F', N'Nam', N'Việt Nam', '072001056976', '092391238'),
	('KH010',N'Nguyễn Văn G', N'Nam', N'Việt Nam', '072001056919', '092391229'),
	('KH011',N'Phạm Thi U', N'Nữ', N'Việt Nam', '072071756231', '071236123'),
	('KH012',N'Phạm Thi T', N'Nữ', N'Việt Nam', '072041056231', '022361233')
-- Dich Vu
INSERT INTO DiCHVU(MaDV,TenDV,LoaiDV,SLConLai,DonGia)
VALUES 
	('DV01', N'Nước suối', N'Thức uống', '100','10000'),
	('DV02', N'Coca cola', N'Thức uống', '100','15000'),
	('DV03', N'Pepsi', N'Thức uống', '100','15000'),
	('DV04', N'Bia Sài Gòn', N'Thức uống', '100','20000'),
	('DV05', N'Mì ăn liền', N'Đồ ăn', '100','15000'),
	('DV06', N'Đưa đón', N'Dịch vụ', '-1','100000'),
	('DV07', N'Giặt ủi', N'Dịch vụ', '-1','25000')

-- Loai Phong
INSERT INTO LOAIPHONG
VALUES
	('VIP01', N'VIP đơn','1','2', '500000', '150000'),
	('VIP02', N'VIP đôi','2','4', '700000', '200000'),
	('NOR01', N'Thường đơn','1','2', '300000', '80000'),
	('NOR02', N'Thường đôi','2','4', '400000', '120000')
-- Phong
INSERT INTO PHONG (MaPH, MaLPH, TTPH, TTDD)
VALUES 
	('P101', 'NOR01', N'Bình thường', N'Đã dọn dẹp'),
	('P102', 'NOR01', N'Bình thường', N'Đã dọn dẹp'),
	('P103', 'NOR02', N'Bình thường', N'Chưa dọn dẹp'),
	('P104', 'NOR01', N'Đang sửa chữa', N'Đã dọn dẹp'),
	('P105', 'NOR02', N'Bình thường', N'Đã dọn dẹp'),
	('P106', 'VIP01', N'Bình thường', N'Đã dọn dẹp'),
	('P201', 'NOR02', N'Bình thường', N'Chưa dọn dẹp'),
	('P202', 'NOR01', N'Bình thường', N'Đã dọn dẹp'),
	('P203', 'VIP02', N'Bình thường', N'Đã dọn dẹp'),
	('P204', 'VIP02', N'Bình thường', N'Chưa dọn dẹp'),
	('P301', 'VIP01', N'Bình thường', N'Đã dọn dẹp'),
	('P302', 'NOR01', N'Bình thường', N'Chưa dọn dẹp'),
	('P303', 'NOR02', N'Bình thường', N'Đã dọn dẹp'),
	('P304', 'VIP02', N'Bình thường', N'Đã dọn dẹp'),
	('P305', 'VIP01', N'Bình thường', N'Đã dọn dẹp'),
	('P401', 'VIP02', N'Bình thường', N'Đã dọn dẹp'),
	('P402', 'VIP02', N'Bình thường', N'Đã dọn dẹp'),
	('P403', 'VIP01', N'Bình thường', N'Chưa dọn dẹp'),
	('P404', 'VIP01', N'Bình thường', N'Chưa dọn dẹp'),
	('P501', 'VIP02', N'Bình thường', N'Đã dọn dẹp'),
	('P502', 'VIP02', N'Bình thường', N'Đã dọn dẹp')
-- Tiện nghi	
INSERT INTO TienNghi
VALUES 
	('TN001', N'Máy lạnh'),
	('TN002', N'Máy quạt'),
	('TN003', N'Tủ lạnh'),
	('TN004', N'Tivi'),
	('TN005', N'Đèn ngủ'),
	('TN006', N'Bàn'),
	('TN007', N'Ghế'),
	('TN008', N'Bàn trang điểm'),
	('TN009', N'Bồn tắm'),
	('TN010', N'Vòi sen'),
	('TN011', N'Máy sấy tóc'),
	('TN012', N'Máy nước nóng')
-- CTTN
-- Phòng Thường 1 giường
INSERT INTO CTTN (MaLPH,MaTN, SL)
VALUES 
	( 'NOR01','TN002','2'), -- Máy quạt
	( 'NOR01','TN004','1'),-- Tivi
	( 'NOR01','TN005','1'), -- Đèn ngủ
	( 'NOR01','TN006','1'), -- Bàn 
	( 'NOR01','TN007','1'), -- Ghế
	( 'NOR01','TN010','1'), -- Vòi sen
	( 'NOR01','TN011','1'), -- Máy sấy tóc
	( 'NOR01','TN012','1') -- Máy nước nóng
-- Phòng thường 2 giường
INSERT INTO CTTN (MaLPH,MaTN, SL)
VALUES 
	( 'NOR02','TN002','3'), -- Máy quạt
	( 'NOR02','TN004','1'), -- Tivi
	( 'NOR02','TN005','2'), -- Đèn ngủ
	( 'NOR02','TN006','1'), -- Bàn 
	( 'NOR02','TN007','2'), -- Ghế
	( 'NOR02','TN010','1'), -- Vòi sen
	( 'NOR02','TN011','1'), -- Máy sấy tóc
	( 'NOR02','TN012','1') -- Máy nước nóng
-- Phòng VIP 1 giường
INSERT INTO CTTN (MaLPH,MaTN, SL)
VALUES 
	( 'VIP01','TN001','1'), -- Máy lạnh
	( 'VIP01','TN004','1'), -- Tivi
	( 'VIP01','TN005','1'), -- Đèn ngủ
	( 'VIP01','TN006','1'), -- Bàn 
	( 'VIP01','TN007','1'), -- Ghế
	( 'VIP01','TN009','1'), -- Bồn tắm
	( 'VIP01','TN010','1'), -- Vòi sen
	( 'VIP01','TN011','1'), -- Máy sấy tóc
	( 'VIP01','TN012','1') -- Máy nước nóng
-- Phòng VIP 2 giường
	INSERT INTO CTTN (MaLPH,MaTN, SL)
	VALUES 
	( 'VIP02','TN001','1'), -- Máy lạnh
	( 'VIP02','TN004','1'), -- Tivi
	( 'VIP02','TN005','2'), -- Đèn ngủ
	( 'VIP02','TN006','1'), -- Bàn 
	( 'VIP02','TN007','2'), -- Ghế
	( 'VIP02','TN009','1'), -- Bồn tắm
	( 'VIP02','TN010','1'), -- Vòi sen
	( 'VIP02','TN011','2'), -- Máy sấy tóc
	( 'VIP02','TN012','1') -- Máy nước nóng
-- Phiếu Thuê
	INSERT INTO PhieuThue(MaPT,NgayLap,MaKH,MaNV) 
	VALUES 
	('PT001', '10/05/2022','KH002','NV002'), -- Đã thuê xong
	('PT002', '12/06/2022','KH004','QL001'), -- Đã thuê xong
	('PT003', '15/07/2022','KH003','NV001'), -- Đã thuê xong
	('PT004', '28/11/2022','KH001','NV001'), -- Đang thuê
	('PT005', '28/08/2022','KH001','NV001'), -- Đang thuê
	('PT006', '28/05/2022','KH001','NV001'), -- Đang thuê
	('PT007', '28/03/2022','KH001','NV001'), -- Đang thuê
	('PT008', '05/01/2023','KH001','NV001'), -- Đang thuê
	('PT009', '03/02/2023','KH001','NV001'), -- Đang thuê
	('PT010', '04/02/2023','KH001','NV001'), -- Đang thuê
	('PT011', '06/01/2023','KH001','NV001'), -- Đang thuê
	('PT012', '08/02/2023','KH001','NV001'), -- Đang thuê
	('PT013', '09/02/2023','KH001','NV001'), -- Đang thuê
	('PT014', '10/02/2022','KH001','NV001'), -- Đang thuê
	('PT015', '28/12/2022','KH001','NV001'), -- Đang thuê
	('PT016', '11/11/2022','KH001','NV001'), -- Đang thuê
	('PT017', '15/10/2022','KH001','NV001'), -- Đang thuê
	('PT018', '18/09/2022','KH001','NV001'), -- Đang thuê
	('PT019', '30/08/2022','KH001','NV001'), -- Đang thuê
	('PT020', '26/01/2023','KH001','NV001'), -- Đang thuê
	('PT021', '27/11/2022','KH001','NV001'), -- Đang thuê
	('PT022', '11/06/2022','KH001','NV001'), -- Đang thuê
	('PT023', '11/11/2022','KH001','NV001') -- Đang thuê

-- CTDP
SELECT*FROM CTDP

	INSERT INTO CTDP(MaCTDP,MaPT,MaPH,CheckIn,CheckOut,TrangThai,ThanhTien,DonGia,SoNguoi) 
	VALUES
	('CTDP001','PT001','P101','11/05/2022','15/05/2022',N'Đã xong',1200000,300000,2)
	INSERT INTO CTDP(MaCTDP,MaPT,MaPH,CheckIn,CheckOut,TrangThai,ThanhTien,DonGia,SoNguoi) 
	VALUES	('CTDP002','PT001','P103','11/06/2022','15/06/2022',N'Đã xong',1600000,400000,2) 
		INSERT INTO CTDP(MaCTDP,MaPT,MaPH,CheckIn,CheckOut,TrangThai,ThanhTien,DonGia,SoNguoi) 
	VALUES('CTDP003','PT002','P201','15/07/2022','18/07/2022',N'Đã xong',1200000,400000,2) 
		INSERT INTO CTDP(MaCTDP,MaPT,MaPH,CheckIn,CheckOut,TrangThai,ThanhTien,DonGia,SoNguoi) 
	VALUES('CTDP004','PT003','P104','16/09/2022','20/09/2022',N'Đã xong',1200000,300000,2) 
		INSERT INTO CTDP(MaCTDP,MaPT,MaPH,CheckIn,CheckOut,TrangThai,ThanhTien,DonGia,SoNguoi) 
	VALUES('CTDP005','PT003','P204','01/12/2022','06/12/2022',N'Đã xong',1500000,300000,2) 
		INSERT INTO CTDP(MaCTDP,MaPT,MaPH,CheckIn,CheckOut,TrangThai,ThanhTien,DonGia,SoNguoi) 
	VALUES('CTDP006','PT004','P105','08/11/2022','10/12/2022',N'Đã xong',600000,300000,2) 
		INSERT INTO CTDP(MaCTDP,MaPT,MaPH,CheckIn,CheckOut,TrangThai,ThanhTien,DonGia,SoNguoi) 
	VALUES('CTDP007','PT023','P101','10/12/2022','20/12/2022',N'Đã xong',3000000,300000,2)
	INSERT INTO CTDP(MaCTDP,MaPT,MaPH,CheckIn,CheckOut,TrangThai,ThanhTien,DonGia,SoNguoi) 
	VALUES	('CTDP008','PT022','P301','17/12/2022','20/12/2022', N'Đã xong',900000,300000,2)
		INSERT INTO CTDP(MaCTDP,MaPT,MaPH,CheckIn,CheckOut,TrangThai,ThanhTien,DonGia,SoNguoi) 
	VALUES('CTDP009','PT005','P201','30/09/2022','05/10/2022', N'Đã xong',1200000,400000,2)

		INSERT INTO CTDP(MaCTDP,MaPT,MaPH,CheckIn,CheckOut,TrangThai,ThanhTien,DonGia,SoNguoi) 
	VALUES('CTDP010','PT006','P101','03/12/2022','20/12/2022', N'Đã xong',1200000,400000,2) 

	INSERT INTO CTDP(MaCTDP,MaPT,MaPH,CheckIn,CheckOut,TrangThai,ThanhTien,DonGia,SoNguoi) 
	VALUES	('CTDP011','PT007','P301','20/12/2022','25/12/2022', N'Đã xong',1200000,400000,2) 

		INSERT INTO CTDP(MaCTDP,MaPT,MaPH,CheckIn,CheckOut,TrangThai,ThanhTien,DonGia,SoNguoi) 
	VALUES('CTDP012','PT008','P401','08/08/2022','15/08/2022', N'Đã xong',1200000,400000,2) 

		INSERT INTO CTDP(MaCTDP,MaPT,MaPH,CheckIn,CheckOut,TrangThai,ThanhTien,DonGia,SoNguoi) 
	VALUES('CTDP013','PT008','P501','09/10/2022','11/10/2022', N'Đã xong',1200000,400000,2) 

		INSERT INTO CTDP(MaCTDP,MaPT,MaPH,CheckIn,CheckOut,TrangThai,ThanhTien,DonGia,SoNguoi) 
	VALUES('CTDP014','PT009','P202','18/07/2022','20/07/2022', N'Đã xong',1200000,400000,2) 

		INSERT INTO CTDP(MaCTDP,MaPT,MaPH,CheckIn,CheckOut,TrangThai,ThanhTien,DonGia,SoNguoi) 
	VALUES('CTDP015','PT010','P203','11/11/2022','20/11/2022', N'Đã xong',1200000,400000,2) 

		INSERT INTO CTDP(MaCTDP,MaPT,MaPH,CheckIn,CheckOut,TrangThai,ThanhTien,DonGia,SoNguoi) 
	VALUES('CTDP017','PT012','P105','17/09/2022','21/09/2022', N'Đã xong',1200000,400000,2)

		INSERT INTO CTDP(MaCTDP,MaPT,MaPH,CheckIn,CheckOut,TrangThai,ThanhTien,DonGia,SoNguoi) 
	VALUES('CTDP018','PT013','P302','01/01/2023','03/01/2023', N'Đã xong',1200000,400000,2)

		INSERT INTO CTDP(MaCTDP,MaPT,MaPH,CheckIn,CheckOut,TrangThai,ThanhTien,DonGia,SoNguoi) 
	VALUES('CTDP019','PT014','P303','15/12/2022','20/12/2022', N'Đã xong',1200000,400000,2) 

		INSERT INTO CTDP(MaCTDP,MaPT,MaPH,CheckIn,CheckOut,TrangThai,ThanhTien,DonGia,SoNguoi) 
	VALUES('CTDP020','PT015','P102','04/02/2023','07/02/2023', N'Đã xong',1200000,400000,2) 

	INSERT INTO CTDP(MaCTDP,MaPT,MaPH,CheckIn,CheckOut,TrangThai,ThanhTien,DonGia,SoNguoi) 
	VALUES	('CTDP021','PT016','P101','03/02/2023','07/02/2023', N'Đã xong',1200000,400000,2)

		INSERT INTO CTDP(MaCTDP,MaPT,MaPH,CheckIn,CheckOut,TrangThai,ThanhTien,DonGia,SoNguoi) 
	VALUES('CTDP022','PT017','P105','02/02/2023','08/02/2023', N'Đã xong',1200000,400000,2)

		INSERT INTO CTDP(MaCTDP,MaPT,MaPH,CheckIn,CheckOut,TrangThai,ThanhTien,DonGia,SoNguoi) 
	VALUES('CTDP023','PT018','P202','03/02/2023','09/02/2023', N'Đã xong',1200000,400000,2) 

		INSERT INTO CTDP(MaCTDP,MaPT,MaPH,CheckIn,CheckOut,TrangThai,ThanhTien,DonGia,SoNguoi) 
	VALUES('CTDP024','PT019','P303','15/01/2023','17/01/2023', N'Đã xong',1200000,400000,2) 

		INSERT INTO CTDP(MaCTDP,MaPT,MaPH,CheckIn,CheckOut,TrangThai,ThanhTien,DonGia,SoNguoi) 
	VALUES('CTDP025','PT020','P401','17/01/2023','19/01/2023', N'Đã xong',1200000,400000,2)

		INSERT INTO CTDP(MaCTDP,MaPT,MaPH,CheckIn,CheckOut,TrangThai,ThanhTien,DonGia,SoNguoi) 
	VALUES('CTDP026','PT021','P302','20/01/2023','25/01/2023', N'Đã xong',1200000,400000,2) 
--CTDV
	INSERT INTO CTDV(MaCTDP,MaDV,SL,ThanhTien,DonGia)
	VALUES
	('CTDP001','DV01','2','20000','10000'),
	('CTDP001','DV02','2','30000','15000'),
	('CTDP001','DV06','1','100000','100000'),
	('CTDP002','DV01','1','10000','10000'),
	('CTDP002','DV04','1','20000','20000'),
	('CTDP002','DV06','1','100000','100000'),
	('CTDP003','DV04','1','20000','20000'),
	('CTDP004','DV07','1','25000','25000'),
	('CTDP005','DV04','2','40000','20000'),
	('CTDP007','DV01','2','20000','10000'),
	('CTDP008','DV02','2','30000','15000'),
	('CTDP008','DV03','2','30000','15000'),
	('CTDP009','DV01','2','30000','15000'),
	('CTDP010','DV05','2','30000','15000'),
	('CTDP011','DV04','2','30000','15000'),
	('CTDP012','DV02','2','30000','15000'),
	('CTDP013','DV07','2','30000','15000'),
	('CTDP014','DV02','2','30000','15000'),
	('CTDP015','DV06','2','30000','15000'),
	('CTDP017','DV02','2','30000','15000'),
	('CTDP018','DV03','2','30000','15000'),
	('CTDP015','DV01','2','30000','15000'),
	('CTDP019','DV06','2','30000','15000'),
	('CTDP020','DV05','2','30000','15000'),
	('CTDP021','DV04','2','30000','15000'),
	('CTDP022','DV02','2','30000','15000'),
	('CTDP023','DV05','2','30000','15000'),
	('CTDP024','DV03','2','30000','15000'),
	('CTDP025','DV02','2','30000','15000'),
	('CTDP025','DV01','2','30000','15000')
-- HoaDon
INSERT INTO HoaDon (MaHD,NgayLap,MaNV,MaCTDP,TrangThai,TriGia)
VALUES
	('HD001','15/05/2022','NV001','CTDP001',N'Đã thanh toán','1350000'),-- Update Tri gia sau
	('HD002','15/06/2022','NV001','CTDP002',N'Đã thanh toán','1730000'),-- Update Tri gia sau
	('HD003','18/07/2022','NV001','CTDP003',N'Đã thanh toán','1730000'),-- Update Tri gia sau
	('HD004','20/09/2022','NV001','CTDP004',N'Đã thanh toán','1225000') ,-- Update Tri gia sau
	('HD005','06/12/2022','NV001','CTDP005',N'Đã thanh toán','1540000'), -- Update Tri gia sau
	('HD006','10/12/2022','NV001','CTDP006',N'Đã thanh toán','600000'), -- Update Tri gia sau
	('HD007','20/12/2022','NV001','CTDP007',N'Đã thanh toán','0'),
	('HD008','20/12/2022','NV001','CTDP008',N'Đã thanh toán','0'),
	('HD009','05/10/2022','NV001','CTDP009',N'Đã thanh toán','0'),
	('HD010','20/12/2022','NV001','CTDP010',N'Đã thanh toán','0'),
	('HD011','25/12/2022','NV001','CTDP011',N'Đã thanh toán','0'),
	('HD012','18/12/2022','NV001','CTDP012',N'Đã thanh toán','0'),
	('HD013','15/08/2022','NV001','CTDP013',N'Đã thanh toán','0'),
	('HD014','20/07/2022','NV001','CTDP014',N'Đã thanh toán','0'),
	('HD015','20/11/2022','NV001','CTDP015',N'Đã thanh toán','0'),
	('HD018','03/01/2023','NV001','CTDP018',N'Đã thanh toán','0'),
	('HD019','20/12/2022','NV001','CTDP019',N'Đã thanh toán','0'),
	('HD020','07/02/2023','NV001','CTDP020',N'Đã thanh toán','0'),
	('HD021','07/02/2023','NV001','CTDP020',N'Đã thanh toán','0'),
	('HD022','08/02/2023','NV001','CTDP020',N'Đã thanh toán','0'),
	('HD023','09/02/2023','NV001','CTDP020',N'Đã thanh toán','0'),
	('HD024','17/01/2023','NV001','CTDP020',N'Đã thanh toán','0'),
	('HD025','19/01/2023','NV001','CTDP020',N'Đã thanh toán','0'),
	('HD026','25/01/2023','NV001','CTDP020',N'Đã thanh toán','0')

SELECT * FROM NhanVien
SELECT * FROM TaiKhoan
SELECT * FROM DichVu
SELECT * FROM TienNghi
SELECT * FROM LoaiPhong
SELECT * FROM CTTN
SELECT * FROM Phong
SELECT * FROM KhachHang
SELECT * FROM PhieuThue
SELECT * FROM CTDP
SELECT * FROM CTDV
SELECT * FROM HoaDon


SELECT * FROM TienNghi
SELECT * FROM LoaiPhong
SELECT * FROM CTTN
-- GỌI LÀ LẤY RA NHỮNG TIỆN NGHI CHƯA ĐƯỢC SỬ DỤNG TRONG CTTN
SELECT TienNghi.*
FROM TienNghi
LEFT JOIN CTTN ON TienNghi.MaTN = CTTN.MaTN AND CTTN.MaLPH='NOR01'
WHERE CTTN.MaTN IS NULL;


SELECT
    PT.NgayLap AS NgayThue,
    KH.TenKH,
    P.MaPH,
    LP.TenLPH,
    SUM(ISNULL(DV.DonGia, 0) * ISNULL(CTDV.SL, 0)) AS TongTienDichVu,
    SUM(ISNULL(LP.GiaNgay, 0)) AS TongTienPhong,
    SUM(ISNULL(DV.DonGia, 0) * ISNULL(CTDV.SL, 0)) + SUM(ISNULL(LP.GiaNgay, 0)) AS ThanhTien
FROM
    KhachHang KH
    INNER JOIN PhieuThue PT ON KH.MaKH = PT.MaKH
    LEFT JOIN CTDP ON PT.MaPT = CTDP.MaPT
    LEFT JOIN Phong P ON CTDP.MaPH = P.MaPH
    LEFT JOIN LoaiPhong LP ON P.MaLPH = LP.MaLPH
    LEFT JOIN CTDV ON CTDP.MaCTDP = CTDV.MaCTDP
    LEFT JOIN DichVu DV ON CTDV.MaDV = DV.MaDV
GROUP BY
    PT.NgayLap,
    KH.TenKH,
    P.MaPH,
    LP.TenLPH
ORDER BY
    PT.NgayLap;

-- procedure doanh thu hôm nay
CREATE PROCEDURE DoanhThuHomNay
AS
BEGIN
    DECLARE @Today DATE
    SET @Today = GETDATE()

    SELECT 
        ISNULL(SUM(HD.TriGia), 0) AS TotalRevenue
    FROM HoaDon HD
    WHERE CONVERT(DATE, HD.NgayLap) = @Today
END
EXEC DoanhThuHomNay

-- số phòng đang thuê trong ngày hôm nay
CREATE PROCEDURE GetSoPhongDangThueHomNay
AS
BEGIN
    DECLARE @Today DATE
    SET @Today = GETDATE()

    SELECT 
        COUNT(DISTINCT CTDP.MaPH) AS SoPhongDangThue
    FROM CTDP
    INNER JOIN PhieuThue ON CTDP.MaPT = PhieuThue.MaPT
    WHERE CONVERT(DATE, PhieuThue.NgayLap) = @Today
END
EXEC GetSoPhongDangThueHomNay
-- số phòng đã đặt hôm nay

CREATE PROCEDURE GetSoPhongDaDatHomNay
AS
BEGIN
    DECLARE @Today DATE
    SET @Today = GETDATE()

    SELECT 
        COUNT(DISTINCT PT.MaPH) AS SoPhongDaDat
    FROM CTDP AS PT
    WHERE CONVERT(DATE, PT.CheckIn) = @Today and pt.TrangThai=N'Đã đặt'
END
EXEC GetSoPhongDaDatHomNay

-- số phòng trống hôm nay
CREATE PROCEDURE GetSoPhongTrongHomNay
AS
BEGIN
    DECLARE @Today DATE
    SET @Today = GETDATE()

    SELECT 
        COUNT(P.MaPH) AS SoPhongTrong
    FROM Phong P
    WHERE P.MaPH NOT IN (
        SELECT DISTINCT CTDP.MaPH
        FROM CTDP
        INNER JOIN PhieuThue ON CTDP.MaPT = PhieuThue.MaPT
        WHERE CONVERT(DATE, PhieuThue.NgayLap) = @Today
    )
END
exec GetSoPhongTrongHomNay

EXEC GetSoPhongDangThueHomNay
-- truy vấn doanh thu hôm nay
SELECT 
    CAST(NgayLap AS DATE) AS NgayLap, 
    SUM(TriGia) AS TongTienTongCong
FROM HoaDon
WHERE CAST(NgayLap AS DATE) = CAST(GETDATE() AS DATE) and TrangThai=N'Đã thanh toán'
GROUP BY CAST(NgayLap AS DATE)
ORDER BY CAST(NgayLap AS DATE) ASC;
-- truy vấn doanh thu 7 ngày qua
SELECT CAST(NgayLap AS DATE) AS NgayLap, SUM(TriGia) AS TongTienTongCong
                     FROM HOADON 
                    WHERE NgayLap >= DATEADD(DAY, -7, GETDATE()) AND NgayLap <= GETDATE() and TrangThai=N'Đã thanh toán'
                     GROUP BY CAST(NgayLap AS DATE)
                    ORDER BY CAST(NgayLap AS DATE) ASC;

-- truy vấn doanh thu hôm qua 
SELECT CAST(NgayLap AS DATE) AS NgayLap, SUM(TriGia) AS TongTienTongCong
                    FROM HOADON
                   WHERE CAST(NgayLap AS DATE) = CAST(DATEADD(DAY, -1, GETDATE()) AS DATE) AND TrangThai = N'Đã thanh toán'
                   GROUP BY CAST(NgayLap AS DATE) 
                   ORDER BY CAST(NgayLap AS DATE) ASC; 
-- doanh thu tháng trước
SELECT CAST(NgayLap AS DATE) AS NgayLap, SUM(TriGia) AS TongTienTongCong
                     FROM HOADON
                     WHERE DATEPART(YEAR, NgayLap) = DATEPART(YEAR, DATEADD(MONTH, -1, GETDATE()))
                    AND DATEPART(MONTH, NgayLap) = DATEPART(MONTH, DATEADD(MONTH, -1, GETDATE()))
                     AND TrangThai = N'Đã thanh toán'
                    GROUP BY CAST(NgayLap AS DATE)
                    ORDER BY CAST(NgayLap AS DATE) ASC; 
-- doanh thu tháng này
SELECT CAST(NgayLap AS DATE) AS NgayLap, SUM(TriGia) AS TongTienTongCong
        FROM HOADON
         WHERE DATEPART(YEAR, NgayLap) = DATEPART(YEAR, GETDATE())
         AND DATEPART(MONTH, NgayLap) = DATEPART(MONTH, GETDATE())
        AND TrangThai = N'Đã thanh toán'
        GROUP BY CAST(NgayLap AS DATE) 
        ORDER BY CAST(NgayLap AS DATE) ASC;
-- năm nay
SELECT MONTH(HOADON.NgayLap) AS NgayLap, SUM(TriGia) as TongTienTongCong
                     FROM HOADON
                     WHERE YEAR(HOADON.NgayLap) = DATEPART(YEAR, GETDATE()) AND TrangThai = N'Đã thanh toán' GROUP BY MONTH(HOADON.NgayLap)
                    ORDER BY  MONTH(HOADON.NgayLap)
		
		
--	drop trigger   trg_UpdateCTDPStatus
--CREATE TRIGGER trg_UpdateCTDPStatus
--ON CTDP
--AFTER UPDATE
--AS
--BEGIN
--    -- Kiểm tra và cập nhật trạng thái cho các bản ghi
--    UPDATE CTDP
--    SET TrangThai = N'Đã xong'
--    FROM INSERTED
--    WHERE CTDP.MaCTDP = INSERTED.MaCTDP
--          AND INSERTED.CheckOut < GETDATE();  -- Kiểm tra thời gian checkout bé hơn thời gian hiện tại
--END;

DECLARE @MaCTDP VARCHAR(7);

SELECT @MaCTDP = MaCTDP
FROM CTDP
WHERE CheckOut < GETDATE();

UPDATE CTDP
SET TrangThai = N'Đã xong'
WHERE MaCTDP = @MaCTDP;

