Use FlightSystem

GO

--Öylesine yazýlmýþ örnek sorgular..

------------

-- Tüm flight numberlarýn varýþ ve kalkýþ airport id lerini ve haftalýk 42 ve 42 den fazla uçuþ alanlarýný sorgulamaktadýr.
SELECT F.Flight_number, SUM(F.Weekdays) AS U_Sayisi, FL.Departure_airport_code, FL.Arrival_airport_code
FROM FLIGHT AS F
JOIN  FLIGHT_LEG AS FL
ON F.Flight_number = FL.Flight_number
GROUP BY F.Flight_number,F.Weekdays, FL.Departure_airport_code, FL.Arrival_airport_code
HAVING SUM(F.Weekdays)>=42;


-- Kalkýþ airportu 2A9 ve varýþ airportu 2A3 olan uçuþun ilgili bilgilerini yazdýrmaktadýr.
SELECT Flight_number, Leg_number, Departure_airport_code, Scheduled_departure_time, Arrival_airport_code, Scheduled_arrival_time
FROM FLIGHT_LEG
WHERE Departure_airport_code = '2A9' AND Arrival_airport_code = '2A3';

------------

-- 3). SORU

-- TRIGGER KOMUTLARIM..


--FARE Tablosuna uçuþ ücreti 10 dolar ve altýnda bilgi girilemez.. Örnek varsayýma göre yapýlmýþtýr..
CREATE TRIGGER FareAmountSinirlama
	ON FARE
	INSTEAD OF INSERT
AS
BEGIN
	SET NOCOUNT ON;
		IF EXISTS (SELECT Amount FROM inserted WHERE inserted.Amount <= 10) 
			BEGIN
				PRINT 'Ekleme iþlemi yapýlamadý. Inserted tablosuna 10 dolar ve altýnda veri giriþi yapýlamaz..'
				ROLLBACK TRANSACTION
			END;
		ELSE
			BEGIN
			INSERT FARE SELECT * FROM inserted; 
			PRINT 'Ekleme iþlemi baþarýyla yapýldý.';
			END;
	SET NOCOUNT OFF;
END;

-- örnek veri ekleme komutu..
insert into FARE VALUES('DSFG56', '1RT', 9, 'Uçaða; yiyecek ve içecek alýnmayacaktýr.'); 
-- örnek veri silme komutu..
delete from FARE WHERE Flight_number = 'DSFG56' AND Fare_code = '1RT';
--tüm verileri listeleme komutu..
select * from FARE;
--Airport Insert Trigger'ýný silme komutu
DROP TRIGGER FareAmountSinirlama;
-- Doðru veriyi tekrar ekleme komutu
insert into FARE VALUES('DSFG56', '1RT', 1000.30, 'Uçaða; yiyecek ve içecek alýnmayacaktýr.'); 



-- SEAT_RESERVATION tablosundaki Seat_Number, AIRPLANE tablosundaki Total_number_of_seats deðerinden daha fazla olamaz.
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
					PRINT 'Ekleme iþlemi baþarýyla yapýldý.';
				END;
		ELSE
			BEGIN
				PRINT 'Ekleme yapýlamadý.. Seat Number deðeri Total_number_of_seats deðerinden fazla olamaz..'
				ROLLBACK TRANSACTION
			END;
	SET NOCOUNT OFF;
END;


-- örnek veri ekleme komutu.. seat_number 14 girilince almakta, 75 üzerinde girilince alýnmamaktadýr.
insert into SEAT_RESERVATION VALUES('BDGT78', 1, CAST('2017-09-23' AS Date), 14, 'Franklin M. Marshall', '555-5555555');
-- örnek veri silme komutu..
delete from SEAT_RESERVATION WHERE Flight_number = 'BDGT78' AND Leg_number = 1 AND Seat_number = 14;
--tüm verileri listeleme komutu..
select * from SEAT_RESERVATION;
--Airport Insert Trigger'ýný silme komutu
DROP TRIGGER TotalNumberOfSeatsCheck;



-- FLIGHT tablosundaki bir uçuþ 60 defadan fazla uçuþ yapamaz..
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
			PRINT 'Ekleme iþlemi baþarýyla yapýldý.';
			END;
		ELSE
			BEGIN
				PRINT 'Ekleme yapýlamadý.. Bir uçuþ 60 defadan fazla uçuþ yapamaz..'
				ROLLBACK TRANSACTION
			END;
	SET NOCOUNT OFF;
END;

-- FLIGHT tablosundaki bir uçuþ 60 defadan fazla uçuþ yapamaz.. Buradaki 65 deðeri 42 yapýlýrsa ilgili trigger ekleme yapacaktýr..
insert into FLIGHT VALUES('ABCD','Qatar Airlines', 65);
-- örnek veri silme komutu..
delete from FLIGHT WHERE Flight_number = 'ABCD' AND Weekdays = 65
--tüm verileri listeleme komutu..
select * from FLIGHT;
--Airport Insert Trigger'ýný silme komutu
DROP TRIGGER FlightWeekdays;

-- 4). SORU
-- CHECK CONSTRAÝNTS KISIMLARI..

-- SEAT_RESERVATION tablosundaki Seat_Number deðeri Airplane tablosundaki max Total_number_of_seats deðerinden yani 75 den
-- büyük olamaz..
-- CONSTRAINT CHK_SeatNo CHECK ( Seat_Number <= 75)
ALTER TABLE SEAT_RESERVATION ADD CONSTRAINT CHK_SeatNo CHECK ( Seat_Number <= 75);
-- Drop etmek için..
ALTER TABLE SEAT_RESERVATION DROP CONSTRAINT CHK_SeatNo;
-- Kontrol için insert methodu..
-- Ýlk baþta delete ile tablodaki deðer silinir..
delete from SEAT_RESERVATION WHERE Flight_number = 'BDGT78' AND Leg_number = 1;
insert into SEAT_RESERVATION VALUES('BDGT78',1 , CAST('2017-09-23' AS Date), 76, 'Franklin M. Marshall', '555-5555555');


-- FLIGHT_LEG tablosundaki Scheduled_departure_time deðeri Scheduled_arrival_time deðerinden sonra olamaz.
-- CONSTRAINT CHK_Times CHECK (Scheduled_departure_time <= Scheduled_arrival_time)
ALTER TABLE FLIGHT_LEG ADD CONSTRAINT CHK_Times CHECK (Scheduled_departure_time <= Scheduled_arrival_time);
-- Drop etmek için..
ALTER TABLE FLIGHT_LEG DROP CONSTRAINT CHK_Times;
--Kontrol için veri insert edilmeye çalýþýldý.. ve hata verdi..
insert into FLIGHT_LEG VALUES('abcd23', 2, '16A', '12:40:00', '1G4', '05:25:00'); 


--LEG_INSTANCE tablosundaki number_of_available_seats kýsmý AIRPLANE tablosundaki Total_number_of_seats kýsmýnýn maximum deðerinden 
-- yani 75 ten büyük olamaz..
ALTER TABLE LEG_INSTANCE ADD CONSTRAINT CHK_Seats CHECK (Number_of_available_seats <= 75);
-- Drop etmek için..
ALTER TABLE LEG_INSTANCE DROP CONSTRAINT CHK_Seats;
--Kontrol için veri insert edilmeye çalýþýldý.. ve hata verdi..
insert into LEG_INSTANCE VALUES('BB200',2 , CAST('2016-03-02' AS Date), 76,'BO717', '2A9', '06:45:00', '2A9', '07:35:00');


-- ASSERTION KISIMLARI..

-- Create Assertion komutu MSSQL 2016 ve çoðu dbms tarafýndan desteklenmemektedir. 
-- Bunun sebebi maliyetli bir iþlem olmasýndan dolayýdýr. Bununla birlikte bu yöntem yerine
-- Check veya Trigger iþlemi tavsiye edilmektedir. Trigger Komutuyla yapma gereði duyuldu..


--FARE tablosunda kýsýtlamasý olmayan uçuþ bilgisi girilemez..
CREATE TRIGGER FareRestrictions
	ON FARE
	INSTEAD OF INSERT
AS
BEGIN
	SET NOCOUNT ON;
		IF EXISTS (SELECT Restrictions FROM inserted WHERE Restrictions IS NULL) 
			BEGIN
				PRINT 'Ekleme iþlemi yapýlamadý. Kýsýtlamasý olamayan uçuþ bilgisi girilemez..'
				ROLLBACK TRANSACTION
			END;
		ELSE
			BEGIN
			INSERT FARE SELECT * FROM inserted; 
			PRINT 'Ekleme iþlemi baþarýyla yapýldý.';
			END;
	SET NOCOUNT OFF;
END;

-- örnek veri ekleme komutu..
insert into FARE VALUES('DSFG56', '34Y', 1000.30, NULL); 
insert into FARE VALUES('DSFG56', '34Y', 1000.30, 'Uçaða; yiyecek ve içecek alýnmayacaktýr.'); 
-- örnek veri silme komutu..
delete from FARE WHERE Flight_number = 'DSFG56' AND Fare_code = '34Y';
--tüm verileri listeleme komutu..
select * from FARE;
--Airport Insert Trigger'ýný silme komutu
DROP TRIGGER FareRestrictions;



--AIRPLANE tablosundaki Total_number_of_seats deðeri AIRPLANE_TYPE tablosundaki Max_seats deðerinden fazla olamaz..
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
				PRINT 'Ekleme iþlemi yapýlamadý.. Total_number_of_seats deðeri AIRPLANE_TYPE tablosundaki Max_seats deðerinden büyük olamaz..' 
				ROLLBACK TRANSACTION
			END;
		ELSE
			BEGIN
			INSERT AIRPLANE SELECT * FROM inserted; 
			PRINT 'Ekleme iþlemi baþarýyla yapýldý.';
			END;
	SET NOCOUNT OFF;
END;

-- örnek veri ekleme komutu..
insert into AIRPLANE VALUES('ASD56', 85, 'Boeing777-300'); -- Max_Seats sayýsý 85 olan veri girmeye çalýþýyoruz..
insert into AIRPLANE_TYPE VALUES('Boeing777-300', 80, 'Boeing');  -- Max_Seats sayýsý 80.
-- örnek veri silme komutu..
delete from AIRPLANE WHERE Airplane_id = 'ASD56' AND Airplane_type = 'Boeing777-300';
--tüm verileri listeleme komutu..
select * from AIRPLANE;
--Airport Insert Trigger'ýný silme komutu
DROP TRIGGER SeatNumberKorumasi;


--LEG_INSTANCE tablosundaki departure_time deðeri arrival_time deðerinden sonra gelen (zaman olarak) bir deðer olamaz..
CREATE TRIGGER LegInstanceTimeKorumasi
	ON LEG_INSTANCE
	INSTEAD OF INSERT
AS
BEGIN
	SET NOCOUNT ON;
		IF EXISTS (SELECT Flight_number FROM inserted WHERE Departure_time > Arrival_time) 
			BEGIN
				PRINT 'Ekleme iþlemi yapýlamadý.. Arrival_time deðeri Departure_time deðerinden önce gelen bir deðer olamaz..' 
				ROLLBACK TRANSACTION
			END;
		ELSE
			BEGIN
			INSERT LEG_INSTANCE SELECT * FROM inserted; 
			PRINT 'Ekleme iþlemi baþarýyla yapýldý.';
			END;
	SET NOCOUNT OFF;
END;

-- örnek hatalý veri ekleme komutu..
insert into LEG_INSTANCE VALUES('BDGT78',1 , CAST('2017-09-23' AS Date), 65, 'BO7730', '0AK', '11:55:00', '16A', '09:35:00');
--Doðrusu..
insert into LEG_INSTANCE VALUES('BDGT78',1 , CAST('2017-09-23' AS Date), 65, 'BO7730', '0AK', '09:35:00', '16A', '11:55:00');
-- örnek veri silme komutu.. Ama veri bütünlüðünü saðlayamadýðý için silmek istemiyor..
delete from LEG_INSTANCE WHERE Flight_number = 'BDGT78' AND Leg_number = 1;
--tüm verileri listeleme komutu..
select * from LEG_INSTANCE;
--Airport Insert Trigger'ýný silme komutu
DROP TRIGGER LegInstanceTimeKorumasi;


-- 5). SORU
-- a). þýkký

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

-- b). þýkký
-- i). þýk
--Ýlgili Havalanýnda (Airport_code) hangi þirkette maximum 82 ve üzeri koltuk olduðu bilgisini getirmektedir.
SELECT Airport_code, Company, Max_seats
FROM CAN_LAND
JOIN AIRPLANE_TYPE ON CAN_LAND.Airplane_type_name = AIRPLANE_TYPE.Airplane_type_name
WHERE Max_seats >= 82;

--Olasý uçuþ tarihinin gününü, o uçuþun açýlan koltuk sayýsýný ve uçulan uçaðýn tipini yazdýrmaktadýr.
SELECT Leg_instance_date, Number_of_available_seats, Airplane_type 
FROM LEG_INSTANCE
JOIN AIRPLANE
ON LEG_INSTANCE.Airplane_id = AIRPLANE.Airplane_id;

--Kesinleþen uçuþun hangi numarayla ve havaalanýnýn bilgisiyle beraber o havaalanýnýn þehrini getiren sorgu.
SELECT Flight_number, Name, City
FROM FLIGHT_LEG
JOIN AIRPORT
ON FLIGHT_LEG.Arrival_airport_code = AIRPORT.Airport_code
WHERE Airport_code = '2A3'

-- ii). þýk
--Ýlgili uçaðýn (type_name); Company isminin içinde bir yerlerde 'urkis' kelimesi geçen, bununla birlikte bu uçaðýn max seats
--bulunduðu airport ve city bilgilerini ekrana yazdýran bir sorgu yapýldý.
SELECT CL.Airplane_type_name, AT.Max_seats, AT.Company, AP.Name, AP.City
FROM CAN_LAND AS CL
JOIN AIRPLANE_TYPE AS AT
ON CL.Airplane_type_name = AT.Airplane_type_name
JOIN AIRPORT AS AP
ON CL.Airport_code = AP.Airport_code
WHERE Company LIKE '%irb%';

-- Hangi müþterinin uçuþunun ne kadar zamanla gecikmeye uðradýðýnýn bilgisini veren sorgu.
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

-- Uçuþu olan uçaðýn tip ismiyle beraber, eriþilebilir koltuk sayýlarýnýn total number of seats ve max seats ile ekrana listelenerek karþýlaþtýrýlmasý sorgusu.
-- Bu veritabaný eriþilebilir koltuk sayýsýnýn (number_of_available) toplam koltuk sayýsýndan kücük olduðunu varsayan triggerla
-- tasarlanmýþtýr.
SELECT Airplane_type_name, Number_of_available_seats, Total_number_of_seats, Max_seats
FROM LEG_INSTANCE AS LI
JOIN AIRPLANE AS AP
ON LI.Airplane_id = AP.Airplane_id
JOIN AIRPLANE_TYPE AS AT
ON AP.Airplane_type = AT.Airplane_type_name;

--Kesinleþmemiþ uçuþun hangi müþteri tarafýndan hangi gün ne kadar ücretle ve ne kýsýtlar altýnda alýndýðýný gösteren bir sorgu.
SELECT Customer_name, SR.Leg_instance_date, FARE.Amount, FARE.Restrictions
FROM SEAT_RESERVATION AS SR
JOIN LEG_INSTANCE AS LI
ON SR.Flight_number = LI.Flight_number
AND SR.Leg_number = LI.Leg_number
AND SR.Leg_instance_date = LI.Leg_instance_date
JOIN FARE
ON LI.Flight_number = FARE.Flight_number


-- iii). þýkký
--Kesinleþmemiþ uçuþ tarihi, bu uçuþlarýn ücretlerinin kýyaslanmasý ve o uçuþun 42 den fazla yapýlanlarýný
--ayrýca bunlarýn nereye gittigini donduren bir sorgu.
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


--Hangi müþterinin nereye, hangi tip uçakla ve hangi uçak markasýnýn sahip olduðu uçakla gittiði döndüren bir sorgudur.
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

--Gecikmiþ uçuþlarý olan herbir müþterinin toplam maliyetini hesaplayan bir sorgudur.

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

-- c). þýkký

-- Kesinleþmemiþ uçuþ zamaný, kesinleþmiþ uçuþ zamanýna eþit olan uçuþlarýn bulunmasý iþlemini yapan sorgu..
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
	  
	  

--Ortalama koltuk sayýsýndan büyük uçaklarýn, þirket ismi ve modellerinin bulunma iþlemi..

SELECT Company, Airplane_type
FROM AIRPLANE AS AP
JOIN AIRPLANE_TYPE AS AT
ON AP.Airplane_type = AT.Airplane_type_name
WHERE AP.Total_number_of_seats > ( SELECT AVG(AP.Total_number_of_seats) 
								   FROM AIRPLANE AS AP)


--Varýþ havalimaný Larsen Bay veya Kalkýþ havalimaný Peach Springs þehrinde olmayan uçuþun Flight Leg bilgilerinin listelenmesi.
--Yani varýþ Arrival Airport Code 1G4 ve Departure Airport Code 2A3 olamaz..
SELECT * 
FROM FLIGHT_LEG AS FL
WHERE FL.Arrival_airport_code != (SELECT AP.Airport_code 
										FROM AIRPORT AS AP
										WHERE AP.City = 'Peach Springs')
	 AND FL.Departure_airport_code != (SELECT AP.Airport_code
										FROM AIRPORT AS AP
										WHERE AP.City = 'Larsen Bay')


--Ortalama uçuþ ücretinden az olan ve kýsýtlamasý olan uçuþlarýn listelenmesi..

SELECT Amount, Restrictions
FROM FARE AS FR
WHERE Amount < (SELECT AVG(Amount) 
				FROM FARE)  
				AND FR.Restrictions IS NOT NULL;
 
-- d). þýkký

-- Kesinleþen kalkýþ zamaný, kesinleþmemiþ kalkýþ zamanýna eþit uçuþ varsa bunu listele..

SELECT *
FROM FLIGHT_LEG AS FL
WHERE EXISTS (SELECT LI.Departure_time FROM LEG_INSTANCE AS LI
				WHERE LI.Flight_number = FL.Flight_number 
				AND LI.Leg_number = FL.Leg_number
				AND LI.Departure_time = FL.Scheduled_departure_time)


-- Haftada 42 saat ve daha fazla uçuþu olan uçuþ varsa bunun bilgilerini listele..

SELECT Flight_number, Fare_code, Amount, Restrictions
FROM FARE AS FR
WHERE EXISTS (SELECT FL.Flight_number, FL.Weekdays FROM FLIGHT AS FL WHERE FR.Flight_number = FL.Flight_number
				GROUP BY Flight_number, Weekdays HAVING Weekdays >= 42);
				
 
-- e). þýkký	
	
		--Hangi havaalanýnda ve hangi þirkette maximum koltuk sayýsý 79 olan uçak olduðunu gösterir.
		SELECT AP.Name, AIRPLANE_TYPE.Company
		FROM CAN_LAND
		LEFT JOIN AIRPLANE_TYPE ON CAN_LAND.Airplane_type_name = AIRPLANE_TYPE.Airplane_type_name
		LEFT JOIN AIRPORT AS AP ON CAN_LAND.Airport_code = AP.Airport_code
		WHERE Max_seats < 80;
		
		--Kesinleþmiþ uçuþu olan uçaðýn toplam weekdays bilgisi gruplanarak hesaplanmýþtýr.
		SELECT F.Flight_number, SUM(F.Weekdays) AS Weekdays
		FROM FLIGHT_LEG AS FL
		RIGHT JOIN FLIGHT AS F
		ON FL.Flight_number = F.Flight_number
		GROUP BY F.Flight_number;


		-- Kesinleþmemiþ uçuþ zamaný, kesinleþmiþ uçuþ zamanýna eþit olmayan uçuþlarla beraber kalkýþ ve varýþ havalimanlarýnýn kodlarýnýn 
		-- listelenmesi yapýlmýþtýr..
		SELECT FL.Flight_number, FL.Leg_number, FL.Departure_airport_code, FL.Arrival_airport_code
		FROM FLIGHT_LEG AS FL
		FULL OUTER JOIN LEG_INSTANCE AS LI
		ON FL.Flight_number = LI.Flight_number AND 
		FL.Leg_number = LI.Leg_number
		WHERE FL.Scheduled_departure_time != LI.Departure_time AND FL.Scheduled_arrival_time != LI.Departure_time
		

-- 6). SORU 	
	
--Kesinleþmiþ uçuþun hangi müþteri tarafýndan hangi gün ne kadar ücretle ve ne kýsýtlar altýnda alýndýðýný gösteren hazýr bir view..
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




-- Hangi müþterinin uçuþunun ne kadar zamanla gecikmeye uðradýðýnýn bilgisini veren bir view..
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



--Ortalama koltuk sayýsýndan büyük uçaklarýn, þirket ismi ve modellerinin bulunma iþleminý yapan bir view..
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