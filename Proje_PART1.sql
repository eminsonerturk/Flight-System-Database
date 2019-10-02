Use FlightSystem

GO

--�ylesine yaz�lm�� �rnek sorgular..

------------

-- T�m flight numberlar�n var�� ve kalk�� airport id lerini ve haftal�k 42 ve 42 den fazla u�u� alanlar�n� sorgulamaktad�r.
SELECT F.Flight_number, SUM(F.Weekdays) AS U_Sayisi, FL.Departure_airport_code, FL.Arrival_airport_code
FROM FLIGHT AS F
JOIN  FLIGHT_LEG AS FL
ON F.Flight_number = FL.Flight_number
GROUP BY F.Flight_number,F.Weekdays, FL.Departure_airport_code, FL.Arrival_airport_code
HAVING SUM(F.Weekdays)>=42;


-- Kalk�� airportu 2A9 ve var�� airportu 2A3 olan u�u�un ilgili bilgilerini yazd�rmaktad�r.
SELECT Flight_number, Leg_number, Departure_airport_code, Scheduled_departure_time, Arrival_airport_code, Scheduled_arrival_time
FROM FLIGHT_LEG
WHERE Departure_airport_code = '2A9' AND Arrival_airport_code = '2A3';

------------

-- 3). SORU

-- TRIGGER KOMUTLARIM..


--FARE Tablosuna u�u� �creti 10 dolar ve alt�nda bilgi girilemez.. �rnek varsay�ma g�re yap�lm��t�r..
CREATE TRIGGER FareAmountSinirlama
	ON FARE
	INSTEAD OF INSERT
AS
BEGIN
	SET NOCOUNT ON;
		IF EXISTS (SELECT Amount FROM inserted WHERE inserted.Amount <= 10) 
			BEGIN
				PRINT 'Ekleme i�lemi yap�lamad�. Inserted tablosuna 10 dolar ve alt�nda veri giri�i yap�lamaz..'
				ROLLBACK TRANSACTION
			END;
		ELSE
			BEGIN
			INSERT FARE SELECT * FROM inserted; 
			PRINT 'Ekleme i�lemi ba�ar�yla yap�ld�.';
			END;
	SET NOCOUNT OFF;
END;

-- �rnek veri ekleme komutu..
insert into FARE VALUES('DSFG56', '1RT', 9, 'U�a�a; yiyecek ve i�ecek al�nmayacakt�r.'); 
-- �rnek veri silme komutu..
delete from FARE WHERE Flight_number = 'DSFG56' AND Fare_code = '1RT';
--t�m verileri listeleme komutu..
select * from FARE;
--Airport Insert Trigger'�n� silme komutu
DROP TRIGGER FareAmountSinirlama;
-- Do�ru veriyi tekrar ekleme komutu
insert into FARE VALUES('DSFG56', '1RT', 1000.30, 'U�a�a; yiyecek ve i�ecek al�nmayacakt�r.'); 



-- SEAT_RESERVATION tablosundaki Seat_Number, AIRPLANE tablosundaki Total_number_of_seats de�erinden daha fazla olamaz.
CREATE TRIGGER TotalNumberOfSeatsCheck
	ON SEAT_RESERVATION
	INSTEAD OF INSERT
AS
BEGIN
	SET NOCOUNT ON;
		IF EXISTS (Select SR.Seat_number
			FROM inserted AS SR 
			JOIN LEG_INSTANCE AS LI 
			ON SR.Flight_number=LI.Flight_number 
			AND SR.Leg_number= LI.Leg_number
			AND SR.Leg_instance_date = LI.Leg_instance_date
			JOIN AIRPLANE AS AP
			ON LI.Airplane_id = AP.Airplane_id
			WHERE SR.Seat_number <= AP.Total_number_of_seats)
				BEGIN
					INSERT SEAT_RESERVATION SELECT * FROM inserted;
					PRINT 'Ekleme i�lemi ba�ar�yla yap�ld�.';
				END;
		ELSE
			BEGIN
				PRINT 'Ekleme yap�lamad�.. Seat Number de�eri Total_number_of_seats de�erinden fazla olamaz..'
				ROLLBACK TRANSACTION
			END;
	SET NOCOUNT OFF;
END;


-- �rnek veri ekleme komutu.. seat_number 14 girilince almakta, 75 �zerinde girilince al�nmamaktad�r.
insert into SEAT_RESERVATION VALUES('BDGT78', 1, CAST('2017-09-23' AS Date), 14, 'Franklin M. Marshall', '555-5555555');
-- �rnek veri silme komutu..
delete from SEAT_RESERVATION WHERE Flight_number = 'BDGT78' AND Leg_number = 1 AND Seat_number = 14;
--t�m verileri listeleme komutu..
select * from SEAT_RESERVATION;
--Airport Insert Trigger'�n� silme komutu
DROP TRIGGER TotalNumberOfSeatsCheck;



-- FLIGHT tablosundaki bir u�u� 60 defadan fazla u�u� yapamaz..
CREATE TRIGGER FlightWeekdays
	ON FLIGHT
	INSTEAD OF INSERT
AS
BEGIN
	SET NOCOUNT ON;
		IF (Select SUM(I.Weekdays)+SUM(FLIGHT.Weekdays) 
		FROM inserted AS I 
		join FLIGHT 
		on I.Flight_number = FLIGHT.Flight_number ) < 60
			BEGIN
			INSERT FLIGHT SELECT * FROM inserted;
			PRINT 'Ekleme i�lemi ba�ar�yla yap�ld�.';
			END;
		ELSE
			BEGIN
				PRINT 'Ekleme yap�lamad�.. Bir u�u� 60 defadan fazla u�u� yapamaz..'
				ROLLBACK TRANSACTION
			END;
	SET NOCOUNT OFF;
END;

-- FLIGHT tablosundaki bir u�u� 60 defadan fazla u�u� yapamaz.. Buradaki 65 de�eri 42 yap�l�rsa ilgili trigger ekleme yapacakt�r..
insert into FLIGHT VALUES('ABCD','Qatar Airlines', 65);
-- �rnek veri silme komutu..
delete from FLIGHT WHERE Flight_number = 'ABCD' AND Weekdays = 65
--t�m verileri listeleme komutu..
select * from FLIGHT;
--Airport Insert Trigger'�n� silme komutu
DROP TRIGGER FlightWeekdays;

-- 4). SORU
-- CHECK CONSTRA�NTS KISIMLARI..

-- SEAT_RESERVATION tablosundaki Seat_Number de�eri Airplane tablosundaki max Total_number_of_seats de�erinden yani 75 den
-- b�y�k olamaz..
-- CONSTRAINT CHK_SeatNo CHECK ( Seat_Number <= 75)
ALTER TABLE SEAT_RESERVATION ADD CONSTRAINT CHK_SeatNo CHECK ( Seat_Number <= 75);
-- Drop etmek i�in..
ALTER TABLE SEAT_RESERVATION DROP CONSTRAINT CHK_SeatNo;
-- Kontrol i�in insert methodu..
-- �lk ba�ta delete ile tablodaki de�er silinir..
delete from SEAT_RESERVATION WHERE Flight_number = 'BDGT78' AND Leg_number = 1;
insert into SEAT_RESERVATION VALUES('BDGT78',1 , CAST('2017-09-23' AS Date), 76, 'Franklin M. Marshall', '555-5555555');


-- FLIGHT_LEG tablosundaki Scheduled_departure_time de�eri Scheduled_arrival_time de�erinden sonra olamaz.
-- CONSTRAINT CHK_Times CHECK (Scheduled_departure_time <= Scheduled_arrival_time)
ALTER TABLE FLIGHT_LEG ADD CONSTRAINT CHK_Times CHECK (Scheduled_departure_time <= Scheduled_arrival_time);
-- Drop etmek i�in..
ALTER TABLE FLIGHT_LEG DROP CONSTRAINT CHK_Times;
--Kontrol i�in veri insert edilmeye �al���ld�.. ve hata verdi..
insert into FLIGHT_LEG VALUES('abcd23', 2, '16A', '12:40:00', '1G4', '05:25:00'); 


--LEG_INSTANCE tablosundaki number_of_available_seats k�sm� AIRPLANE tablosundaki Total_number_of_seats k�sm�n�n maximum de�erinden 
-- yani 75 ten b�y�k olamaz..
ALTER TABLE LEG_INSTANCE ADD CONSTRAINT CHK_Seats CHECK (Number_of_available_seats <= 75);
-- Drop etmek i�in..
ALTER TABLE LEG_INSTANCE DROP CONSTRAINT CHK_Seats;
--Kontrol i�in veri insert edilmeye �al���ld�.. ve hata verdi..
insert into LEG_INSTANCE VALUES('BB200',2 , CAST('2016-03-02' AS Date), 76,'BO717', '2A9', '06:45:00', '2A9', '07:35:00');


-- ASSERTION KISIMLARI..

-- Create Assertion komutu MSSQL 2016 ve �o�u dbms taraf�ndan desteklenmemektedir. 
-- Bunun sebebi maliyetli bir i�lem olmas�ndan dolay�d�r. Bununla birlikte bu y�ntem yerine
-- Check veya Trigger i�lemi tavsiye edilmektedir. Trigger Komutuyla yapma gere�i duyuldu..


--FARE tablosunda k�s�tlamas� olmayan u�u� bilgisi girilemez..
CREATE TRIGGER FareRestrictions
	ON FARE
	INSTEAD OF INSERT
AS
BEGIN
	SET NOCOUNT ON;
		IF EXISTS (SELECT Restrictions FROM inserted WHERE Restrictions IS NULL) 
			BEGIN
				PRINT 'Ekleme i�lemi yap�lamad�. K�s�tlamas� olamayan u�u� bilgisi girilemez..'
				ROLLBACK TRANSACTION
			END;
		ELSE
			BEGIN
			INSERT FARE SELECT * FROM inserted; 
			PRINT 'Ekleme i�lemi ba�ar�yla yap�ld�.';
			END;
	SET NOCOUNT OFF;
END;

-- �rnek veri ekleme komutu..
insert into FARE VALUES('DSFG56', '34Y', 1000.30, NULL); 
insert into FARE VALUES('DSFG56', '34Y', 1000.30, 'U�a�a; yiyecek ve i�ecek al�nmayacakt�r.'); 
-- �rnek veri silme komutu..
delete from FARE WHERE Flight_number = 'DSFG56' AND Fare_code = '34Y';
--t�m verileri listeleme komutu..
select * from FARE;
--Airport Insert Trigger'�n� silme komutu
DROP TRIGGER FareRestrictions;



--AIRPLANE tablosundaki Total_number_of_seats de�eri AIRPLANE_TYPE tablosundaki Max_seats de�erinden fazla olamaz..
CREATE TRIGGER SeatNumberKorumasi
	ON AIRPLANE
	INSTEAD OF INSERT
AS
BEGIN
	SET NOCOUNT ON;
		IF EXISTS (SELECT Total_number_of_seats FROM inserted, AIRPLANE_TYPE  
		WHERE inserted.Airplane_type = AIRPLANE_TYPE.Airplane_type_name
		AND AIRPLANE_TYPE.Max_seats < inserted.Total_number_of_seats) 
			BEGIN
				PRINT 'Ekleme i�lemi yap�lamad�.. Total_number_of_seats de�eri AIRPLANE_TYPE tablosundaki Max_seats de�erinden b�y�k olamaz..' 
				ROLLBACK TRANSACTION
			END;
		ELSE
			BEGIN
			INSERT AIRPLANE SELECT * FROM inserted; 
			PRINT 'Ekleme i�lemi ba�ar�yla yap�ld�.';
			END;
	SET NOCOUNT OFF;
END;

-- �rnek veri ekleme komutu..
insert into AIRPLANE VALUES('ASD56', 85, 'Boeing777-300'); -- Max_Seats say�s� 85 olan veri girmeye �al���yoruz..
insert into AIRPLANE_TYPE VALUES('Boeing777-300', 80, 'Boeing');  -- Max_Seats say�s� 80.
-- �rnek veri silme komutu..
delete from AIRPLANE WHERE Airplane_id = 'ASD56' AND Airplane_type = 'Boeing777-300';
--t�m verileri listeleme komutu..
select * from AIRPLANE;
--Airport Insert Trigger'�n� silme komutu
DROP TRIGGER SeatNumberKorumasi;


--LEG_INSTANCE tablosundaki departure_time de�eri arrival_time de�erinden sonra gelen (zaman olarak) bir de�er olamaz..
CREATE TRIGGER LegInstanceTimeKorumasi
	ON LEG_INSTANCE
	INSTEAD OF INSERT
AS
BEGIN
	SET NOCOUNT ON;
		IF EXISTS (SELECT Flight_number FROM inserted WHERE Departure_time > Arrival_time) 
			BEGIN
				PRINT 'Ekleme i�lemi yap�lamad�.. Arrival_time de�eri Departure_time de�erinden �nce gelen bir de�er olamaz..' 
				ROLLBACK TRANSACTION
			END;
		ELSE
			BEGIN
			INSERT LEG_INSTANCE SELECT * FROM inserted; 
			PRINT 'Ekleme i�lemi ba�ar�yla yap�ld�.';
			END;
	SET NOCOUNT OFF;
END;

-- �rnek hatal� veri ekleme komutu..
insert into LEG_INSTANCE VALUES('BDGT78',1 , CAST('2017-09-23' AS Date), 65, 'BO7730', '0AK', '11:55:00', '16A', '09:35:00');
--Do�rusu..
insert into LEG_INSTANCE VALUES('BDGT78',1 , CAST('2017-09-23' AS Date), 65, 'BO7730', '0AK', '09:35:00', '16A', '11:55:00');
-- �rnek veri silme komutu.. Ama veri b�t�nl���n� sa�layamad��� i�in silmek istemiyor..
delete from LEG_INSTANCE WHERE Flight_number = 'BDGT78' AND Leg_number = 1;
--t�m verileri listeleme komutu..
select * from LEG_INSTANCE;
--Airport Insert Trigger'�n� silme komutu
DROP TRIGGER LegInstanceTimeKorumasi;


-- 5). SORU
-- a). ��kk�

-- 3 adet delete statement
delete from SEAT_RESERVATION WHERE Flight_number = 'BDGT78' AND Leg_number = 1;
delete from FLIGHT WHERE Weekdays = 42;
delete from AIRPORT WHERE State = 'AZ';

-- 3 adet insert statement
insert into SEAT_RESERVATION VALUES('BDGT78',1 , CAST('2017-09-23' AS Date), 2, 'Franklin M. Marshall', '555-5555555');
insert into FLIGHT VALUES('DSFG56','Qatar Airlines', 42);
insert into FLIGHT VALUES('BDGT78','American Airlines', 42);
insert into AIRPORT VALUES('1G4', 'Grand Canyon West Airport', 'Peach Springs', 'AZ');

-- 3 adet update statement
UPDATE FARE SET Flight_number = 'OUYC87', Fare_code= 'AQWE23' WHERE Amount = 2253.65;
UPDATE AIRPORT SET Name = 'Larsen Bay Airport', State= 'TR' WHERE Airport_code = '2A9';
UPDATE AIRPLANE_TYPE SET Max_seats = 80, Company = 'Beriev be' WHERE Airplane_type_name = 'Beriev be-200';

-- b). ��kk�
-- i). ��k
--�lgili Havalan�nda (Airport_code) hangi �irkette maximum 82 ve �zeri koltuk oldu�u bilgisini getirmektedir.
SELECT Airport_code, Company, Max_seats
FROM CAN_LAND
JOIN AIRPLANE_TYPE ON CAN_LAND.Airplane_type_name = AIRPLANE_TYPE.Airplane_type_name
WHERE Max_seats >= 82;

--Olas� u�u� tarihinin g�n�n�, o u�u�un a��lan koltuk say�s�n� ve u�ulan u�a��n tipini yazd�rmaktad�r.
SELECT Leg_instance_date, Number_of_available_seats, Airplane_type 
FROM LEG_INSTANCE
JOIN AIRPLANE
ON LEG_INSTANCE.Airplane_id = AIRPLANE.Airplane_id;

--Kesinle�en u�u�un hangi numarayla ve havaalan�n�n bilgisiyle beraber o havaalan�n�n �ehrini getiren sorgu.
SELECT Flight_number, Name, City
FROM FLIGHT_LEG
JOIN AIRPORT
ON FLIGHT_LEG.Arrival_airport_code = AIRPORT.Airport_code
WHERE Airport_code = '2A3'

-- ii). ��k
--�lgili u�a��n (type_name); Company isminin i�inde bir yerlerde 'urkis' kelimesi ge�en, bununla birlikte bu u�a��n max seats
--bulundu�u airport ve city bilgilerini ekrana yazd�ran bir sorgu yap�ld�.
SELECT CL.Airplane_type_name, AT.Max_seats, AT.Company, AP.Name, AP.City
FROM CAN_LAND AS CL
JOIN AIRPLANE_TYPE AS AT
ON CL.Airplane_type_name = AT.Airplane_type_name
JOIN AIRPORT AS AP
ON CL.Airport_code = AP.Airport_code
WHERE Company LIKE '%irb%';

-- Hangi m��terinin u�u�unun ne kadar zamanla gecikmeye u�rad���n�n bilgisini veren sorgu.
SELECT SR.Seat_number, SR.Customer_name, SR.Customer_phone, LI.Departure_time AS kesinlesmemis_kalkis_zamani, 
LI.Arrival_time AS kesinlesmemis_varis_zamani, FL.Scheduled_departure_time AS kesinlesmis_kalkis_zamani, 
FL.Scheduled_arrival_time AS kesinlesmis_varis_zamani
FROM FLIGHT_LEG AS FL
JOIN LEG_INSTANCE AS LI
ON FL.Flight_number = LI.Flight_number
AND FL.Leg_number = LI.Leg_number
JOIN SEAT_RESERVATION AS SR
ON LI.Flight_number = SR.Flight_number
AND LI.Leg_number = SR.Leg_number
WHERE LI.Departure_time != FL.Scheduled_departure_time
AND LI.Arrival_time != FL.Scheduled_arrival_time;

-- U�u�u olan u�a��n tip ismiyle beraber, eri�ilebilir koltuk say�lar�n�n total number of seats ve max seats ile ekrana listelenerek kar��la�t�r�lmas� sorgusu.
-- Bu veritaban� eri�ilebilir koltuk say�s�n�n (number_of_available) toplam koltuk say�s�ndan k�c�k oldu�unu varsayan triggerla
-- tasarlanm��t�r.
SELECT Airplane_type_name, Number_of_available_seats, Total_number_of_seats, Max_seats
FROM LEG_INSTANCE AS LI
JOIN AIRPLANE AS AP
ON LI.Airplane_id = AP.Airplane_id
JOIN AIRPLANE_TYPE AS AT
ON AP.Airplane_type = AT.Airplane_type_name;

--Kesinle�memi� u�u�un hangi m��teri taraf�ndan hangi g�n ne kadar �cretle ve ne k�s�tlar alt�nda al�nd���n� g�steren bir sorgu.
SELECT Customer_name, SR.Leg_instance_date, FARE.Amount, FARE.Restrictions
FROM SEAT_RESERVATION AS SR
JOIN LEG_INSTANCE AS LI
ON SR.Flight_number = LI.Flight_number
AND SR.Leg_number = LI.Leg_number
AND SR.Leg_instance_date = LI.Leg_instance_date
JOIN FARE
ON LI.Flight_number = FARE.Flight_number


-- iii). ��kk�
--Kesinle�memi� u�u� tarihi, bu u�u�lar�n �cretlerinin k�yaslanmas� ve o u�u�un 42 den fazla yap�lanlar�n�
--ayr�ca bunlar�n nereye gittigini donduren bir sorgu.
SELECT SEAT_RESERVATION.Leg_instance_date, FARE.Amount, FLIGHT.Weekdays, AIRPORT.City
FROM SEAT_RESERVATION
JOIN LEG_INSTANCE 
ON SEAT_RESERVATION.Flight_number = LEG_INSTANCE.Flight_number
AND SEAT_RESERVATION.Leg_number = LEG_INSTANCE.Leg_number
AND SEAT_RESERVATION.Leg_instance_date = LEG_INSTANCE.Leg_instance_date
JOIN FARE 
ON LEG_INSTANCE.Flight_number = FARE.Flight_number
JOIN FLIGHT
ON FARE.Flight_number = FLIGHT.Flight_number
JOIN  AIRPORT
ON LEG_INSTANCE.Arrival_airport_code = AIRPORT.Airport_code
WHERE FLIGHT.Weekdays >= 42;


--Hangi m��terinin nereye, hangi tip u�akla ve hangi u�ak markas�n�n sahip oldu�u u�akla gitti�i d�nd�ren bir sorgudur.
SELECT SR.Customer_name, AP.City, AT.Airplane_type_name, AT.Company
FROM SEAT_RESERVATION AS SR
JOIN FLIGHT_LEG AS FL
ON SR.Flight_number = FL.Flight_number
AND SR.Leg_number = FL.Leg_number
JOIN AIRPORT AS AP
ON FL.Arrival_airport_code = AP.Airport_code
JOIN CAN_LAND AS CL
ON CL.Airport_code = FL.Arrival_airport_code
JOIN AIRPLANE_TYPE AS AT
ON CL.Airplane_type_name = AT.Airplane_type_name

--Gecikmi� u�u�lar� olan herbir m��terinin toplam maliyetini hesaplayan bir sorgudur.

SELECT ST.Customer_name, SUM(FARE.Amount) AS [Toplam Maliyet]
FROM SEAT_RESERVATION AS ST
JOIN LEG_INSTANCE AS LI
ON ST.Flight_number = LI.Flight_number AND ST.Leg_number= LI.Leg_number
JOIN FLIGHT_LEG AS FL
ON LI.Flight_number = FL.Flight_number AND LI.Leg_number = FL.Leg_number
JOIN FARE
ON FL.Flight_number = FARE.Flight_number
WHERE FL.Scheduled_departure_time > LI.Departure_time
GROUP BY ST.Customer_name

-- c). ��kk�

-- Kesinle�memi� u�u� zaman�, kesinle�mi� u�u� zaman�na e�it olan u�u�lar�n bulunmas� i�lemini yapan sorgu..
SELECT LI.Flight_number AS Ucus_No, LI.Leg_number AS Leg_No,FL.Scheduled_departure_time AS Kesinlesmis_Ucus_Kalkis_Zamani, LI.Departure_time AS Kesinlesmemis_Ucus_Kalkis_Zamani,
FL.Scheduled_arrival_time AS Kesinlesmis_Ucus_Kalkis_Zamani, LI.Arrival_time AS Kesinlesmemis_Ucus_Kalkis_Zamani 
FROM LEG_INSTANCE AS LI
JOIN FLIGHT_LEG AS FL
ON FL.Flight_number = LI.Flight_number
AND FL.Leg_number = LI.Leg_number
WHERE LI.Departure_time IN (SELECT Scheduled_departure_time FROM FLIGHT_LEG) 
	  AND LI.Arrival_time IN (SELECT Scheduled_arrival_time FROM FLIGHT_LEG) 
	  AND FL.Departure_airport_code = LI.Departure_airport_code
	  AND FL.Arrival_airport_code = LI.Arrival_airport_code;
	  
	  

--Ortalama koltuk say�s�ndan b�y�k u�aklar�n, �irket ismi ve modellerinin bulunma i�lemi..

SELECT Company, Airplane_type
FROM AIRPLANE AS AP
JOIN AIRPLANE_TYPE AS AT
ON AP.Airplane_type = AT.Airplane_type_name
WHERE AP.Total_number_of_seats > ( SELECT AVG(AP.Total_number_of_seats) 
								   FROM AIRPLANE AS AP)


--Var�� havaliman� Larsen Bay veya Kalk�� havaliman� Peach Springs �ehrinde olmayan u�u�un Flight Leg bilgilerinin listelenmesi.
--Yani var�� Arrival Airport Code 1G4 ve Departure Airport Code 2A3 olamaz..
SELECT * 
FROM FLIGHT_LEG AS FL
WHERE FL.Arrival_airport_code != (SELECT AP.Airport_code 
										FROM AIRPORT AS AP
										WHERE AP.City = 'Peach Springs')
	 AND FL.Departure_airport_code != (SELECT AP.Airport_code
										FROM AIRPORT AS AP
										WHERE AP.City = 'Larsen Bay')


--Ortalama u�u� �cretinden az olan ve k�s�tlamas� olan u�u�lar�n listelenmesi..

SELECT Amount, Restrictions
FROM FARE AS FR
WHERE Amount < (SELECT AVG(Amount) 
				FROM FARE)  
				AND FR.Restrictions IS NOT NULL;
 
-- d). ��kk�

-- Kesinle�en kalk�� zaman�, kesinle�memi� kalk�� zaman�na e�it u�u� varsa bunu listele..

SELECT *
FROM FLIGHT_LEG AS FL
WHERE EXISTS (SELECT LI.Departure_time FROM LEG_INSTANCE AS LI
				WHERE LI.Flight_number = FL.Flight_number 
				AND LI.Leg_number = FL.Leg_number
				AND LI.Departure_time = FL.Scheduled_departure_time)


-- Haftada 42 saat ve daha fazla u�u�u olan u�u� varsa bunun bilgilerini listele..

SELECT Flight_number, Fare_code, Amount, Restrictions
FROM FARE AS FR
WHERE EXISTS (SELECT FL.Flight_number, FL.Weekdays FROM FLIGHT AS FL WHERE FR.Flight_number = FL.Flight_number
				GROUP BY Flight_number, Weekdays HAVING Weekdays >= 42);
				
 
-- e). ��kk�	
	
		--Hangi havaalan�nda ve hangi �irkette maximum koltuk say�s� 79 olan u�ak oldu�unu g�sterir.
		SELECT AP.Name, AIRPLANE_TYPE.Company
		FROM CAN_LAND
		LEFT JOIN AIRPLANE_TYPE ON CAN_LAND.Airplane_type_name = AIRPLANE_TYPE.Airplane_type_name
		LEFT JOIN AIRPORT AS AP ON CAN_LAND.Airport_code = AP.Airport_code
		WHERE Max_seats < 80;
		
		--Kesinle�mi� u�u�u olan u�a��n toplam weekdays bilgisi gruplanarak hesaplanm��t�r.
		SELECT F.Flight_number, SUM(F.Weekdays) AS Weekdays
		FROM FLIGHT_LEG AS FL
		RIGHT JOIN FLIGHT AS F
		ON FL.Flight_number = F.Flight_number
		GROUP BY F.Flight_number;


		-- Kesinle�memi� u�u� zaman�, kesinle�mi� u�u� zaman�na e�it olmayan u�u�larla beraber kalk�� ve var�� havalimanlar�n�n kodlar�n�n 
		-- listelenmesi yap�lm��t�r..
		SELECT FL.Flight_number, FL.Leg_number, FL.Departure_airport_code, FL.Arrival_airport_code
		FROM FLIGHT_LEG AS FL
		FULL OUTER JOIN LEG_INSTANCE AS LI
		ON FL.Flight_number = LI.Flight_number AND 
		FL.Leg_number = LI.Leg_number
		WHERE FL.Scheduled_departure_time != LI.Departure_time AND FL.Scheduled_arrival_time != LI.Departure_time
		

-- 6). SORU 	
	
--Kesinle�mi� u�u�un hangi m��teri taraf�ndan hangi g�n ne kadar �cretle ve ne k�s�tlar alt�nda al�nd���n� g�steren haz�r bir view..
CREATE VIEW KesinlesmisUcusBilgileri AS
SELECT Customer_name, SR.Leg_instance_date, FARE.Amount, FARE.Restrictions
FROM SEAT_RESERVATION AS SR
JOIN FLIGHT_LEG AS FL
ON SR.Flight_number = FL.Flight_number
AND SR.Leg_number = FL.Leg_number
JOIN FARE
ON FL.Flight_number = FARE.Flight_number;

-- View'i kontrol etmeye yarayan komut..
SELECT * FROM KesinlesmisUcusBilgileri;

--View'i drop etmeye yarayan komut..
DROP VIEW KesinlesmisUcusBilgileri;

----------------------




-- Hangi m��terinin u�u�unun ne kadar zamanla gecikmeye u�rad���n�n bilgisini veren bir view..
CREATE VIEW GecikmeGoster AS
SELECT SR.Seat_number, SR.Customer_name, SR.Customer_phone, LI.Departure_time AS kesinlesmemis_kalkis_zamani, 
LI.Arrival_time AS kesinlesmemis_varis_zamani, FL.Scheduled_departure_time AS kesinlesmis_kalkis_zamani, 
FL.Scheduled_arrival_time AS kesinlesmis_varis_zamani
FROM FLIGHT_LEG AS FL
JOIN LEG_INSTANCE AS LI
ON FL.Flight_number = LI.Flight_number
AND FL.Leg_number = LI.Leg_number
JOIN SEAT_RESERVATION AS SR
ON LI.Flight_number = SR.Flight_number
AND LI.Leg_number = SR.Leg_number
WHERE LI.Departure_time != FL.Scheduled_departure_time
AND LI.Arrival_time != FL.Scheduled_arrival_time;

-- View'i kontrol etmeye yarayan komut..
SELECT * FROM GecikmeGoster;

--View'i drop etmeye yarayan komut..
DROP VIEW GecikmeGoster;

----------------------



--Ortalama koltuk say�s�ndan b�y�k u�aklar�n, �irket ismi ve modellerinin bulunma i�lemin� yapan bir view..
CREATE VIEW UcakBilgileriniBul AS
SELECT Company, Airplane_type
FROM AIRPLANE AS AP
JOIN AIRPLANE_TYPE AS AT
ON AP.Airplane_type = AT.Airplane_type_name
WHERE AP.Total_number_of_seats > ( SELECT AVG(AP.Total_number_of_seats) 
								   FROM AIRPLANE AS AP);

-- View'i kontrol etmeye yarayan komut..
SELECT * FROM UcakBilgileriniBul;

--View'i drop etmeye yarayan komut..
DROP VIEW UcakBilgileriniBul;