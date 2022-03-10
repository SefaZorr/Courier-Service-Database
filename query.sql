
--KULLANICILARIN C�NS�YET VE YA�LARINA G�RE TOPLAM ��RKETE VERD�KLER� �CRETLER VE BUNLARIN C�NS�YET VE YIL BAZLI OLARAK TOPLAM �CRETLER�
SELECT COALESCE(CONVERT(varchar,DATEDIFF(year,TM.Dogum_Tarihi,GETDATE())),'GENEL_YA�') YA�,
	COALESCE(TM.Cinsiyet,'GENEL_C�NS�YET') C�NS�YET,
		SUM(TK.Toplam_Ucret) TOPLAM_UCRET from tblMusteri TM
			INNER JOIN tblKargo TK ON TM.ID = TK.G�nderenMusteriId
				GROUP BY CUBE(DATEDIFF(year,TM.Dogum_Tarihi,GETDATE()),TM.Cinsiyet)


--HER B�R �R�N KATEGOR�S�NE G�RE �IKI� �EH�R BAZLI TOPLAM ALINAN �CRET VE S�PAR�� SAYILARI
SELECT TS.Sehir,TUK.Kategori_Tipi,SUM(TU.Fiyat) TOPLAM ,COUNT(TU.ID) M�KTAR FROM tblUrun TU
	INNER JOIN tblUrunKategorisi TUK ON TUK.ID = TU.UrunKategoriId 
		INNER JOIN tblKargo TK ON TK.ID = TU.KargoId
			INNER JOIN tblAdres TA ON TA.ID = TK.CikisAdresId
				INNER JOIN tblSehir TS ON TS.ID = TA.SehirId
					GROUP BY TS.Sehir,TUK.Kategori_Tipi
						ORDER BY TS.Sehir

-- �SM� A �LE BA�LAYAN �ALI�ANLARIN BULUNDU�U �UBELERDEN GE�EN KARGOLIN TESL�M ED�LD��� M��TER�LER�N ADI SOYADI  VE ADRES B�LG�LER� 

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


-- B�RDEN FAZLA KARGO G�NDEREN M��TER�LER VE KARGO SAYILARI
SELECT TM.Ad,TM.Soyad,COUNT(TK.ID) S�PAR��_ADED� FROM tblMusteri TM
	INNER JOIN tblKargo TK ON TK.G�nderenMusteriId = TM.ID
		GROUP BY TM.Ad,TM.Soyad
			HAVING COUNT(TK.ID) > 1

--Kategoriye g�re kargolanan �r�n say�s�.
Select UK.Kategori_Tipi,Count(UK.ID) ToplamUrunSayisi
    From tblUrun U
        Inner Join tblUrunKategorisi UK On UK.ID=U.UrunKategoriId
            Group By UK.Kategori_Tipi
--3 G�nden az s�rede teslim edilen kargolar�n barkod numaras� ve tarihleri.
Select K.Barkod_Numaras�,K.Teslim_Al�m_Tarihi,K.Teslim_Edilme_Tarihi
    From tblKargo K
        Where DATEDIFF(DD,K.Teslim_Al�m_Tarihi,K.Teslim_Edilme_Tarihi)<3


--Hangi Durumda ka� kargo oldugunu g�steren tablo.
Select KH.KargoDurumId,KD.Durum, COUNT(KH.KargoId) DurumdakiKargoSayisi
    From tblKargoHareketleri KH
        Inner Join tblKargoDurumu KD On KH.KargoDurumId=KD.ID
            Group By KH.KargoDurumId,KD.Durum
--Toplam �creti ortalama toplam �cretinden d���k olan kargolar�n listesi.
Select*
    From tblKargo K
        Where K.Toplam_Ucret<(Select Sum(K.Toplam_Ucret)/Count(K.ID) ORTALAMA
                                From tblKargo K)










			 