--KAPATILACAK 2112310201 �UBE KODLU �UBEN�N �ALI�ANLARI
DELETE FROM tblCalisan
	WHERE TC IN 
	(
	SELECT TC.TC FROM tblCalisan TC
		INNER JOIN tblSube TS
			ON TC.SubeId = TS.ID
				WHERE TS.Sube_Kodu = '2112310201'
	)

-- KAPATILAN 2112310201 �UBE KODLU �UBE
DELETE FROM tblSube
	WHERE Sube_Kodu = '2112310201'


-- H�� KULLANILMAYAN 34SEO03 VE 34SEO05 PLAKALI ARA�LAR F�LODAN �IKARILDI
DELETE FROM tblArac
	WHERE Plaka IN (SELECT TA.Plaka FROM tblArac TA
	WHERE NOT TA.ID IN(SELECT DISTINCT TKH.AracId  FROM tblKargoHareketleri TKH 
	WHERE TKH.AracId IS NOT NULL))

--Amerika Birle�ik Devletleri,Birle�ik Arap Emirlikleri,�in Halk Cumhuriyeti,Gabon,Do�u Timor �LKELER�NE YURTDI�I H�ZMET PLANINDAN �IKARILDI
DELETE FROM tblUlke
	WHERE Ulke IN ('Amerika Birle�ik Devletleri','Birle�ik Arap Emirlikleri','�in Halk Cumhuriyeti','Gabon','Do�u Timor')


-- KR�PTO �DEMELER YASAKLANDI
DELETE FROM tblOdemeTipi
	WHERE Tip = 'Kripto'

	
		