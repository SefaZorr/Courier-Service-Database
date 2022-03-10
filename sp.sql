--Kargonun hareket durumunu değiştiren stored procedure + transaction

IF OBJECT_ID('dbo.spKargo_Durumu_Update') IS NOT NULL
	BEGIN
		DROP PROCEDURE dbo.spKargo_Durumu_Update
	END
GO

CREATE PROCEDURE spKargo_Durumu_Update(
@CikisTarihi DATE,
@VarisTarihi DATE,
@Plaka varchar(10),
@Barkod_Numarasi varchar(200),
@DurumBilgisi varchar(50),
@CikisSaati TIME(7) = NULL,
@VarisSaati TIME(7) = NULL,
@Varis_Sube_Kodu varchar(50) = NULL,
@Cikis_Sube_Kodu varchar(50) = NULL
)
AS
	DECLARE @TranCounter INT=@@TRANCOUNT;
	IF @TranCounter > 0
		SAVE TRANSACTION sproc_kayit

	BEGIN TRANSACTION
	BEGIN TRY

		DECLARE @DurumId INT;
		DECLARE @AracId INT;
		DECLARE @Varis_Sube_Id INT;
		DECLARE @Cikis_Sube_Id INT;
		DECLARE @KargoId INT;


		SELECT @DurumId = TD.ID FROM tblKargoDurumu TD
			WHERE TD.Durum = @DurumBilgisi

		SELECT @KargoId=ID FROM tblKargo TK
			WHERE TK.Barkod_Numarası = @Barkod_Numarasi

		SELECT @AracId=ID FROM tblArac TA
			WHERE TA.Plaka = @Plaka
	
		SELECT @Cikis_Sube_Id = ID FROM tblSube TS
			WHERE TS.Sube_Kodu = @Cikis_Sube_Kodu


		SELECT @Varis_Sube_Id = ID FROM tblSube TS
			WHERE TS.Sube_Kodu = @Varis_Sube_Kodu


	

		INSERT INTO tblKargoHareketleri
				VALUES 
				(@CikisTarihi,@VarisTarihi,@CikisSaati,@VarisSaati,@AracId,@Varis_Sube_Id,@Cikis_Sube_Id,@DurumId,@KargoId)
		
        --kargo tablosunda sonDurum bilgisi güncelleniyor
		UPDATE tblKargo SET KargoSonDurumId = @DurumId WHERE ID= @KargoId
		IF @DurumId = 6
            -- durumId 6(Teslim Edildi) ise kargo tablosundaki Teslim Tarihi güncelleniyor
			UPDATE tblKargo SET Teslim_Edilme_Tarihi = @VarisTarihi WHERE ID = @KargoId
		COMMIT
	END TRY

	BEGIN CATCH

		IF @TranCounter = 0 OR XACT_STATE() = -1
			ROLLBACK TRANSACTION
		ELSE
			BEGIN
				ROLLBACK TRANSACTION sproc_kayit
				COMMIT
			END
		DECLARE @ErrorMessage NVARCHAR(4000)
		SET @ErrorMessage = ERROR_MESSAGE()
		DECLARE @ErrorSeverity INT = ERROR_SEVERITY()
		DECLARE @ErrorState INT = ERROR_STATE()
		RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)
	END CATCH
GO


--sproc test (Dağıtım durumundaki ID'si 10 olan kargonun durumunu teslim edildi olarak değiştiriyor)
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
SELECT @BarkodNumarası=Barkod_Numarası FROM tblKargo WHERE ID = 10
SELECT @DurumBilgisi=Durum FROM tblKargoDurumu Where ID = 6
SELECT @VarisSubeKodu = Sube_Kodu FROM tblSube WHERE ID = 3
SELECT @CikisSubeKodu= Sube_Kodu FROM tblSube WHERE ID = 2
EXEC spKargo_Durumu_Update @DateForTry,@DateForTry,@Plaka,@BarkodNumarası,@DurumBilgisi,NULL,@TimeForTry,NULL,@CikisSubeKodu

SELECT * FROM tblKargoHareketleri WHERE KargoId = 10
SELECT * FROM tblKargo
