--Bir kargonun içerisindeki ürünlerin kategori tiplerine göre ayrılarak o kategorideki ortalama satış ile beraber raporlanması

IF OBJECT_ID('dbo.vKargo_Raporu') IS NOT NULL
	BEGIN
		DROP VIEW dbo.vKargo_Raporu
	END
GO

CREATE VIEW vKargo_Raporu AS
	SELECT
		TK.Barkod_Numarası,
		TUK.Kategori_Tipi,
		SUM(TU.Fiyat) AS URUN_BAZLI_FIYAT,
		TK.Toplam_Ucret AS ILGILI_KARGO_TOPLAM_UCRETI,
		dbo.KATEGORIYE_GORE_ORTALAMA_GONDERI_BASINA_GELIR(TUK.ID) AS KATEGORI_ORTALAMA,
		CASE 
			WHEN SUM(TU.Fiyat) < DBO.KATEGORIYE_GORE_ORTALAMA_GONDERI_BASINA_GELIR(TUK.ID) THEN 'Ortalamadan Düşük'
			WHEN SUM(TU.Fiyat) > DBO.KATEGORIYE_GORE_ORTALAMA_GONDERI_BASINA_GELIR(TUK.ID) THEN 'Ortalamadan Büyük'
			WHEN SUM(TU.Fiyat) = DBO.KATEGORIYE_GORE_ORTALAMA_GONDERI_BASINA_GELIR(TUK.ID) THEN 'Ortalamaya Eşit'
		END AS 'URUN/ORTALAMA'
	FROM tblUrun TU
	INNER JOIN tblUrunKategorisi TUK ON TU.UrunKategoriId = TUK.ID
		INNER JOIN tblKargo TK	ON TK.ID = TU.KargoId
			INNER JOIN tblOdemeTipi TOT	ON TOT.ID = TK.OdemeTipiId
				GROUP BY TK.Barkod_Numarası,TUK.Kategori_Tipi,TK.Toplam_Ucret,TUK.ID
GO

--View Test
SELECT  
		vKR.*,
		TMG.Ad + ' ' + TMG.Soyad  AS GONDEREN_MUSTERI,
		TMG.Telno AS GONDEREN_MUSTERI_TELEFON_NO,
		TMA.Ad + ' ' + TMA.Soyad  AS TESLIM_ALAN_MUSTERI,
		TMA.Telno AS TESLIM_ALAN_MUSTERI_TELEFON_NO,
		TOT.Tip AS ODEME_TIPI,
		FORMAT (TK.Teslim_Alım_Tarihi, 'MMMM yyyy,dddd', 'tr-tr')AS TESLIM_ALIM_TARIHI,
		FORMAT (TK.Teslim_Edilme_Tarihi, 'MMMM yyyy,dddd', 'tr-tr')AS TESLIM_ALIM_TARIHI,
		TAC.Acik_adres + ' '+ TIC.Ilce + '/' + TSC.Sehir  AS CIKIS_ADRESI,
		TAV.Acik_adres + ' '+ TIV.Ilce + '/' + TSV.Sehir  AS VARIS_ADRESI,
		ISNULL(TGD.Icerik,'Yorum yok') MUSTERI_YORUMU,
		TSUBEA.Sube_Kodu AS ALIS_SUBE_KODU,
		TSUBEV.Sube_Kodu AS VARIS_SUBE_KODU,
		TC.Ad + ' '+ TC.Soyad + ' TC:' + TC.TC + ' TEL NO:' + TC.Telno AS SORUMLU_CALISAN_BILGILERI
		
		FROM vKargo_Raporu vKR
		INNER JOIN tblKargo TK	ON TK.Barkod_Numarası = vKR.Barkod_Numarası
			INNER JOIN tblOdemeTipi TOT	ON TOT.ID = TK.OdemeTipiId
				INNER JOIN tblAdres TAC ON TAC.ID = TK.CikisAdresId
					INNER JOIN tblSehir TSC ON TSC.ID = TAC.SehirId
						INNER JOIN tblIlce TIC ON TIC.ID = TAC.IlceId
								INNER JOIN tblAdres TAV ON TAV.ID = TK.VarisAdresId
									INNER JOIN tblSehir TSV ON TSV.ID = TAC.SehirId
										INNER JOIN tblIlce TIV ON TIV.ID = TAC.IlceId
												LEFT JOIN tblGeridonut TGD ON  TGD.ID = TK.GeriDonutId
													INNER JOIN tblCalisan TC ON TC.ID = TK.ID
														INNER JOIN tblSube TSUBEA ON TSUBEA.ID = TK.AlisSubeId
															INNER JOIN tblSube TSUBEV ON TSUBEV.ID = TK.VarisSubeId
																INNER JOIN tblMusteri TMG ON TMG.ID = TK.GönderenMusteriId
																	INNER JOIN tblMusteri TMA ON TMA.ID = TK.TeslimAlanMusteriId