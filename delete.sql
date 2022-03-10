--KAPATILACAK 2112310201 ÞUBE KODLU ÞUBENÝN ÇALIÞANLARI
DELETE FROM tblCalisan
	WHERE TC IN 
	(
	SELECT TC.TC FROM tblCalisan TC
		INNER JOIN tblSube TS
			ON TC.SubeId = TS.ID
				WHERE TS.Sube_Kodu = '2112310201'
	)

-- KAPATILAN 2112310201 ÞUBE KODLU ÞUBE
DELETE FROM tblSube
	WHERE Sube_Kodu = '2112310201'


-- HÝÇ KULLANILMAYAN 34SEO03 VE 34SEO05 PLAKALI ARAÇLAR FÝLODAN ÇIKARILDI
DELETE FROM tblArac
	WHERE Plaka IN (SELECT TA.Plaka FROM tblArac TA
	WHERE NOT TA.ID IN(SELECT DISTINCT TKH.AracId  FROM tblKargoHareketleri TKH 
	WHERE TKH.AracId IS NOT NULL))

--Amerika Birleþik Devletleri,Birleþik Arap Emirlikleri,Çin Halk Cumhuriyeti,Gabon,Doðu Timor ÜLKELERÝNE YURTDIÞI HÝZMET PLANINDAN ÇIKARILDI
DELETE FROM tblUlke
	WHERE Ulke IN ('Amerika Birleþik Devletleri','Birleþik Arap Emirlikleri','Çin Halk Cumhuriyeti','Gabon','Doðu Timor')


-- KRÝPTO ÖDEMELER YASAKLANDI
DELETE FROM tblOdemeTipi
	WHERE Tip = 'Kripto'

	
		