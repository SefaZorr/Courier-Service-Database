/*
    Kargodaki hareketliliklerin sproc içerisinde Insert edilirken kurallara uygunluğunu daha sonra ise 
    kargo istatisliklerinin tutulduğu tabloda kargo durumuna göre istatistiklerin güncellenmesi yapılıyor.
*/

IF OBJECT_ID('dbo.trgKargo_Hareketleri') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.trgKargo_Hareketleri
	END
GO

CREATE TRIGGER trgKargo_Hareketleri ON tblKargoHareketleri AFTER INSERT AS 

	DECLARE @DurumId INT
	DECLARE @KargoSonDurumId INT
	DECLARE @KargoId INT
	DECLARE @VarisSubeId varchar(50)
	DECLARE @CikisSaati time(7)
	DECLARE @VarisSaati time(7)

	-- inserted tablosundan gerekli bilgilerin çekilmesi
	SELECT @DurumId = KargoDurumId,@KargoId=KargoId,@VarisSubeId=VarisSubeId,
		@CikisSaati=CikisSaati,@VarisSaati = VarisSaati
	FROM inserted
	
	--Kargonun insertten önceki son durumu tblkargo tablosundan çekiliyor
	SELECT @KargoSonDurumId = KargoSonDurumId FROM tblKargo WHERE ID= @KargoId

	
	IF @KargoSonDurumId = 6
		BEGIN
			RAISERROR('KARGO ÇOKTAN TESLİM EDİLMİŞ,TESLİM DURUMUNDA BİR DEĞİŞİKLİK YAPAMAZSINIZ',16,1)
			ROLLBACK
		END
	ELSE IF @KargoSonDurumId = @DurumId
		BEGIN
			RAISERROR('KARGO ZATEN MEVCUT DURUMDA',16,1)
			ROLLBACK
		END
	ELSE IF @DurumId = 3
		BEGIN
			IF @VarisSaati IS NOT NULL OR @VarisSubeId IS NOT NULL
				BEGIN
					RAISERROR('ARACA YÜKLENEN BİR ÜRÜNÜN VARDIĞI BİR ŞUBE VE VARIŞ SAATİ OLAMAZ',16,1)
					ROLLBACK
				END
		END
	ELSE IF @DurumId = 5
		BEGIN
			IF @VarisSubeId IS NOT NULL
				BEGIN
					RAISERROR('KARGO,KURYEYE TESLİM EDİLMİŞ OLMALI,ŞUBEYE DEĞİL',16,1)
					ROLLBACK
				END
		END
	ELSE IF @DurumId = 6
		BEGIN
		IF @VarisSubeId IS NOT NULL OR @CikisSaati IS NOT NULL
				BEGIN
					RAISERROR('TESLİM EDİLEN BİR KARGONUN VARIŞ ŞUBESİ VEYA ÇIKIŞ SAATİ OLAMAZ',16,1)
					ROLLBACK
				END
		END
	
	IF @DurumId = 1
		BEGIN 
        --Teslim edilemeyen ürün tekrar dağıtıma çıkarılırsa
			IF @KargoSonDurumId = 7
				UPDATE tblKargoIstatistikleri SET Basarisiz_Teslim_Sayisi = Basarisiz_Teslim_Sayisi - 1,Islemde_Olan_Kargo_Sayisi = Islemde_Olan_Kargo_Sayisi + 1
			ELSE IF @KargoSonDurumId IS NULL
				UPDATE tblKargoIstatistikleri SET Islemde_Olan_Kargo_Sayisi =  Islemde_Olan_Kargo_Sayisi + 1

		END
	IF @DurumId = 6
		BEGIN 
        -- Teslim edilemeyen ürün teslim edilirse
			IF @KargoSonDurumId = 7
				UPDATE tblKargoIstatistikleri SET Basarisiz_Teslim_Sayisi = Basarisiz_Teslim_Sayisi -1,Teslim_Sayisi = Teslim_Sayisi + 1
			ELSE
				UPDATE tblKargoIstatistikleri SET Islemde_Olan_Kargo_Sayisi =  Islemde_Olan_Kargo_Sayisi - 1,Teslim_Sayisi = Teslim_Sayisi + 1

		END
	IF @DurumId = 7
		BEGIN 
			UPDATE tblKargoIstatistikleri SET Islemde_Olan_Kargo_Sayisi =  Islemde_Olan_Kargo_Sayisi - 1,Basarisiz_Teslim_Sayisi = Basarisiz_Teslim_Sayisi + 1
		END


--trigger test 1 => hatasız
select * from tblKargoIstatistikleri

DECLARE @DateTimeForTry AS DATETIME = GETDATE();
DECLARE @DateForTry DATE
SET @DateForTry =  CONVERT(date, @DateTimeForTry)
DECLARE @TimeForTry time(0)
SET @TimeForTry = CONVERT(time(7), @DateTimeForTry)
DECLARE @Plaka varchar(10)
DECLARE @BarkodNumarası varchar(200)
DECLARE @DurumBilgisi varchar(50)
DECLARE @VarisSubeKodu varchar(50)
DECLARE @CikisSubeKodu varchar(50)

SELECT @Plaka = Plaka FROM tblArac WHERE ID = 1
SELECT @BarkodNumarası=Barkod_Numarası FROM tblKargo WHERE ID = 16
SELECT @DurumBilgisi=Durum FROM tblKargoDurumu Where ID = 1
SELECT @VarisSubeKodu = Sube_Kodu FROM tblSube WHERE ID = 3
SELECT @CikisSubeKodu= Sube_Kodu FROM tblSube WHERE ID = 2

EXEC spKargo_Durumu_Update @DateForTry,@DateForTry,@Plaka,@BarkodNumarası,@DurumBilgisi,NULL,@TimeForTry,NULL,@CikisSubeKodu

select * from tblKargoIstatistikleri

--trigger test 2 => hatalı

DECLARE @DateTimeForTry AS DATETIME = GETDATE();
DECLARE @DateForTry DATE
SET @DateForTry =  CONVERT(date, @DateTimeForTry)
DECLARE @TimeForTry time(0)
SET @TimeForTry = CONVERT(time(7), @DateTimeForTry)
DECLARE @Plaka varchar(10)
DECLARE @BarkodNumarası varchar(200)
DECLARE @DurumBilgisi varchar(50)
DECLARE @VarisSubeKodu varchar(50)
DECLARE @CikisSubeKodu varchar(50)
SELECT @Plaka = Plaka FROM tblArac WHERE ID = 1
SELECT @BarkodNumarası=Barkod_Numarası FROM tblKargo WHERE ID = 23
SELECT @DurumBilgisi=Durum FROM tblKargoDurumu Where ID = 1
SELECT @VarisSubeKodu = Sube_Kodu FROM tblSube WHERE ID = 3
SELECT @CikisSubeKodu= Sube_Kodu FROM tblSube WHERE ID = 2
EXEC spKargo_Durumu_Update @DateForTry,@DateForTry,@Plaka,@BarkodNumarası,@DurumBilgisi,NULL,@TimeForTry,NULL,@CikisSubeKodu

select * from tblKargoHareketleri
--trigger test 3 => hatalı

DECLARE @DateTimeForTry AS DATETIME = GETDATE();
DECLARE @DateForTry DATE
SET @DateForTry =  CONVERT(date, @DateTimeForTry)
DECLARE @TimeForTry time(0)
SET @TimeForTry = CONVERT(time(7), @DateTimeForTry)
DECLARE @Plaka varchar(10)
DECLARE @BarkodNumarası varchar(200)
DECLARE @DurumBilgisi varchar(50)
DECLARE @VarisSubeKodu varchar(50)
DECLARE @CikisSubeKodu varchar(50)
SELECT @Plaka = Plaka FROM tblArac WHERE ID = 1
SELECT @BarkodNumarası=Barkod_Numarası FROM tblKargo WHERE ID = 17
SELECT @DurumBilgisi=Durum FROM tblKargoDurumu Where ID = 1
SELECT @VarisSubeKodu = Sube_Kodu FROM tblSube WHERE ID = 3
SELECT @CikisSubeKodu= Sube_Kodu FROM tblSube WHERE ID = 2
EXEC spKargo_Durumu_Update @DateForTry,@DateForTry,@Plaka,@BarkodNumarası,@DurumBilgisi,NULL,@TimeForTry,NULL,@CikisSubeKodu





