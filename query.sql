
--KULLANICILARIN CÝNSÝYET VE YAÞLARINA GÖRE TOPLAM ÞÝRKETE VERDÝKLERÝ ÜCRETLER VE BUNLARIN CÝNSÝYET VE YIL BAZLI OLARAK TOPLAM ÜCRETLERÝ
SELECT COALESCE(CONVERT(varchar,DATEDIFF(year,TM.Dogum_Tarihi,GETDATE())),'GENEL_YAÞ') YAÞ,
	COALESCE(TM.Cinsiyet,'GENEL_CÝNSÝYET') CÝNSÝYET,
		SUM(TK.Toplam_Ucret) TOPLAM_UCRET from tblMusteri TM
			INNER JOIN tblKargo TK ON TM.ID = TK.GönderenMusteriId
				GROUP BY CUBE(DATEDIFF(year,TM.Dogum_Tarihi,GETDATE()),TM.Cinsiyet)


--HER BÝR ÜRÜN KATEGORÝSÝNE GÖRE ÇIKIÞ ÞEHÝR BAZLI TOPLAM ALINAN ÜCRET VE SÝPARÝÞ SAYILARI
SELECT TS.Sehir,TUK.Kategori_Tipi,SUM(TU.Fiyat) TOPLAM ,COUNT(TU.ID) MÝKTAR FROM tblUrun TU
	INNER JOIN tblUrunKategorisi TUK ON TUK.ID = TU.UrunKategoriId 
		INNER JOIN tblKargo TK ON TK.ID = TU.KargoId
			INNER JOIN tblAdres TA ON TA.ID = TK.CikisAdresId
				INNER JOIN tblSehir TS ON TS.ID = TA.SehirId
					GROUP BY TS.Sehir,TUK.Kategori_Tipi
						ORDER BY TS.Sehir

-- ÝSMÝ A ÝLE BAÞLAYAN ÇALIÞANLARIN BULUNDUÐU ÞUBELERDEN GEÇEN KARGOLIN TESLÝM EDÝLDÝÐÝ MÜÞTERÝLERÝN ADI SOYADI  VE ADRES BÝLGÝLERÝ 

SELECT DISTINCT TMUS.Ad,TMUS.Soyad,TS.Sehir,TI.Ilce,TM.Mahalle, TA.Acik_adres FROM tblKargo TK
	INNER JOIN (SELECT *  FROM tblKargoHareketleri TKH
		WHERE TKH.VarisSubeId IN (SELECT TC.SubeId FROM tblCalisan TC WHERE TC.Ad LIKE 'A%')
			OR TKH.CikisSubeId IN (SELECT TC.SubeId FROM tblCalisan TC WHERE TC.Ad LIKE 'A%')) T
		ON T.KargoId = TK.ID
			INNER JOIN tblMusteri TMUS ON TMUS.ID = TK.TeslimAlanMusteriId
				INNER JOIN tblAdres TA ON TK.TeslimAlanMusteriId = TA.MusteriId
					INNER JOIN tblUlke TU ON TU.ID = TA.UlkeId
						INNER JOIN tblSehir TS ON TS.ID = TA.SehirId
							INNER JOIN tblIlce TI ON TI.ID = TA.IlceId
								INNER JOIN tblMahalle TM ON TM.ID = TA.MahalleId


-- BÝRDEN FAZLA KARGO GÖNDEREN MÜÞTERÝLER VE KARGO SAYILARI
SELECT TM.Ad,TM.Soyad,COUNT(TK.ID) SÝPARÝÞ_ADEDÝ FROM tblMusteri TM
	INNER JOIN tblKargo TK ON TK.GönderenMusteriId = TM.ID
		GROUP BY TM.Ad,TM.Soyad
			HAVING COUNT(TK.ID) > 1

--Kategoriye göre kargolanan ürün sayýsý.
Select UK.Kategori_Tipi,Count(UK.ID) ToplamUrunSayisi
    From tblUrun U
        Inner Join tblUrunKategorisi UK On UK.ID=U.UrunKategoriId
            Group By UK.Kategori_Tipi
--3 Günden az sürede teslim edilen kargolarýn barkod numarasý ve tarihleri.
Select K.Barkod_Numarasý,K.Teslim_Alým_Tarihi,K.Teslim_Edilme_Tarihi
    From tblKargo K
        Where DATEDIFF(DD,K.Teslim_Alým_Tarihi,K.Teslim_Edilme_Tarihi)<3


--Hangi Durumda kaç kargo oldugunu gösteren tablo.
Select KH.KargoDurumId,KD.Durum, COUNT(KH.KargoId) DurumdakiKargoSayisi
    From tblKargoHareketleri KH
        Inner Join tblKargoDurumu KD On KH.KargoDurumId=KD.ID
            Group By KH.KargoDurumId,KD.Durum
--Toplam ücreti ortalama toplam ücretinden düþük olan kargolarýn listesi.
Select*
    From tblKargo K
        Where K.Toplam_Ucret<(Select Sum(K.Toplam_Ucret)/Count(K.ID) ORTALAMA
                                From tblKargo K)










			 