
--ONUR ÇELÝK ADLI KULLANICI MAÝL ADRESÝNÝ DEÐÝÞMEK ÝSTEDÝ
UPDATE tblMusteri
SET Mail = 'onrclk1391@hotmail.com'
WHERE TC = '63054879258'


--531119401 KODLU ÞUBENÝN TELEFON NUMARASI DEÐÝÞTÝ
UPDATE tblSube
SET Telno = '8509151905'
WHERE Sube_Kodu = '531119401'

--STANDART KARGO TAÞIMASININ FÝYATLANDIRMASI DEÐÝÞTÝ
UPDATE tblUrunKategorisi
SET Desi_Fiyat = 2, Kg_Fiyat = 15
WHERE Kategori_Tipi = 'STANDART'


-- SEO53211607 BARKODUN GERÝ DÖNÜTÜNDE MÜÞTERÝ DEÐÝÞÝKLÝK YAPTI
UPDATE tblGeridonut
SET Icerik = 'Ürün kutusunda hasar vardý'
WHERE MusteriId = (
SELECT TK.TeslimAlanMusteriId FROM tblKargo TK
	WHERE TK.Barkod_Numarasý = 'SEO53211607'
) AND ID = (SELECT TK.GeriDonutID FROM tblKargo TK
			WHERE TK.Barkod_Numarasý = 'SEO53211607')

-- 63014339114 TC'YE SAHÝP PERSONEL ÝHTÝYAÇ SEBEBÝYLE BAÞKA ÞUBEYE AKTARILDI
UPDATE tblCalisan
SET SubeId = (SELECT TS.ID FROM tblSube TS
 WHERE TS.Sube_Kodu = '2112310701'
)
WHERE TC = '63014339114'

-- ADRESÝNÝ YANLIÞ GÝREN 36574124785 TC NOLU MÜÞTERÝ DÜZELTME YAPTI
UPDATE tblAdres
SET Acik_adres = 'Koru Sokak No:12 Daire:5'
WHERE MusteriId =  (
SELECT TM.ID FROM tblMusteri TM
	WHERE TM.TC = '36574124785'
) AND Acik_adres = 'Koru Sokak No:12'