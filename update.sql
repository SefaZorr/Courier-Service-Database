
--ONUR �EL�K ADLI KULLANICI MA�L ADRES�N� DE���MEK �STED�
UPDATE tblMusteri
SET Mail = 'onrclk1391@hotmail.com'
WHERE TC = '63054879258'


--531119401 KODLU �UBEN�N TELEFON NUMARASI DE���T�
UPDATE tblSube
SET Telno = '8509151905'
WHERE Sube_Kodu = '531119401'

--STANDART KARGO TA�IMASININ F�YATLANDIRMASI DE���T�
UPDATE tblUrunKategorisi
SET Desi_Fiyat = 2, Kg_Fiyat = 15
WHERE Kategori_Tipi = 'STANDART'


-- SEO53211607 BARKODUN GER� D�N�T�NDE M��TER� DE����KL�K YAPTI
UPDATE tblGeridonut
SET Icerik = '�r�n kutusunda hasar vard�'
WHERE MusteriId = (
SELECT TK.TeslimAlanMusteriId FROM tblKargo TK
	WHERE TK.Barkod_Numaras� = 'SEO53211607'
) AND ID = (SELECT TK.GeriDonutID FROM tblKargo TK
			WHERE TK.Barkod_Numaras� = 'SEO53211607')

-- 63014339114 TC'YE SAH�P PERSONEL �HT�YA� SEBEB�YLE BA�KA �UBEYE AKTARILDI
UPDATE tblCalisan
SET SubeId = (SELECT TS.ID FROM tblSube TS
 WHERE TS.Sube_Kodu = '2112310701'
)
WHERE TC = '63014339114'

-- ADRES�N� YANLI� G�REN 36574124785 TC NOLU M��TER� D�ZELTME YAPTI
UPDATE tblAdres
SET Acik_adres = 'Koru Sokak No:12 Daire:5'
WHERE MusteriId =  (
SELECT TM.ID FROM tblMusteri TM
	WHERE TM.TC = '36574124785'
) AND Acik_adres = 'Koru Sokak No:12'