USE FlightSystem;

GO

-- Insert Airports;

insert into AIRPORT VALUES('0AK', 'Pilot Station Airport', 'Pilot Station', 'AK');

insert into AIRPORT VALUES('16A', 'Nunapitchuk Airport', 'Nunapitchuk', 'AK');

insert into AIRPORT VALUES('1G4', 'Grand Canyon West Airport', 'Peach Springs', 'AZ');

insert into AIRPORT VALUES('2A3', 'Larsen Bay Airport', 'Larsen Bay', 'AK');

insert into AIRPORT VALUES('2A9', 'Kotlik Airport', 'Kotlik', 'AK');

insert into AIRPORT VALUES('3A5', 'Marshall Don Hunter Sr', 'Marshall', 'AK');



-- Insert Flights;

insert into FLIGHT VALUES('BDGT78','American Airlines', 42);

insert into FLIGHT VALUES('AJDK23','Southwest Airlines', 33);

insert into FLIGHT VALUES('KSLE35','United Airlines', 25);

insert into FLIGHT VALUES('DSFG56','Qatar Airlines', 42);

insert into FLIGHT VALUES('AQWE23','Turkish Airlines', 56);

insert into FLIGHT VALUES('OUYC87','Egypt Airlines', 33);



-- Insert Flight Legs;

insert into FLIGHT_LEG VALUES('BDGT78', 1, '0AK', '10:35:00', '16A', '12:55:00'); 

insert into FLIGHT_LEG VALUES('DSFG56', 2, '16A', '12:40:00', '1G4', '15:25:00'); 

insert into FLIGHT_LEG VALUES('BDGT78', 3, '1G4', '16:40:00', '2A3', '20:20:00'); 

insert into FLIGHT_LEG VALUES('AJDK23', 1, '0AK', '11:40:00', '2A9', '16:05:00'); 

insert into FLIGHT_LEG VALUES('OUYC87', 2, '2A9', '16:45:00', '2A3', '19:55:00'); 

insert into FLIGHT_LEG VALUES('AQWE23', 1, '2A9', '06:58:00', '2A3', '07:15:00'); 


-- insert Airplanes

insert into AIRPLANE VALUES('BO7730', 75, 'Boeing777-300'); 

insert into AIRPLANE VALUES('AB3450', 68, 'Airbus340-500'); 

insert into AIRPLANE VALUES('BO707', 74, 'Boeing707'); 

insert into AIRPLANE VALUES('BB200', 65, 'Beriev be-200'); 

insert into AIRPLANE VALUES('BO717', 75, 'Boeing717');
 
insert into AIRPLANE VALUES('AB320', 73, 'Airbus320s');


-- insert Leg Instances

insert into LEG_INSTANCE VALUES('BDGT78',1 , CAST('2017-09-23' AS Date), 65, 'BO7730', '0AK', '09:35:00', '16A', '11:55:00');

insert into LEG_INSTANCE VALUES('DSFG56',2 , CAST('2017-05-07' AS Date), 63, 'AB3450', '16A', '12:40:00', '1G4', '15:15:00');

insert into LEG_INSTANCE VALUES('BDGT78',3 , CAST('2016-10-01' AS Date), 63, 'BO707', '1G4', '16:30:00', '2A3', '20:05:00');

insert into LEG_INSTANCE VALUES('AJDK23',1 , CAST('2015-09-10' AS Date), 62, 'BB200', '0AK', '11:35:00', '2A9', '15:55:00');

insert into LEG_INSTANCE VALUES('OUYC87',2 , CAST('2015-10-14' AS Date), 73, 'BO717', '2A9', '16:45:00', '2A3', '19:55:00');

insert into LEG_INSTANCE VALUES('AQWE23',1 , CAST('2016-02-25' AS Date), 70, 'AB320', '2A9', '06:45:00', '2A3', '07:35:00');


-- Insert Fares

insert into FARE VALUES('DSFG56', '1RT', 1000.30, 'Uçaða; yiyecek ve içecek alýnmayacaktýr.'); 

insert into FARE VALUES('AJDK23', '2YU', 3000.75, 'Küçük çocuklar ailelerinden ayrýlmamalýdýr.'); 

insert into FARE VALUES('DSFG56', '3IO', 770.75, 'Kokan ve dökülen gýdalar uçaða alýnmaz.'); 

insert into FARE VALUES('OUYC87', '4PL', 5060.75, 'Kokan ve dökülen gýdalar uçaða alýnmaz.'); 

insert into FARE VALUES('KSLE35', '5SA', 3000.75, 'Uçaða; yiyecek ve içecek alýnmayacaktýr.'); 

insert into FARE VALUES('AQWE23', '6GF', 2253.65, 'Küçük çocuklar ailelerinden ayrýlmamalýdýr.'); 


-- Insert Airplane Types

insert into AIRPLANE_TYPE VALUES('Airbus340-500', 78, 'Airbus'); 

insert into AIRPLANE_TYPE VALUES('Boeing707', 83, 'Boeing'); 

insert into AIRPLANE_TYPE VALUES('Airbus320s',83, 'Airbus'); 

insert into AIRPLANE_TYPE VALUES('Beriev be-200', 72, 'Beriev be'); 

insert into AIRPLANE_TYPE VALUES('Boeing717', 82, 'Boeing'); 

insert into AIRPLANE_TYPE VALUES('Boeing777-300', 80, 'Boeing'); 


-- insert Can Lands

insert into CAN_LAND VALUES('Airbus340-500', '1G4');

insert into CAN_LAND VALUES('Boeing707', '2A3');

insert into CAN_LAND VALUES('Airbus320s', '16A');

insert into CAN_LAND VALUES('Beriev be-200', '2A9');

insert into CAN_LAND VALUES('Boeing717', '0AK');

insert into CAN_LAND VALUES('Boeing777-300', '3A5');


-- insert Seat Reservations

insert into SEAT_RESERVATION VALUES('BDGT78',1 , CAST('2017-09-23' AS Date), 2, 'Franklin M. Marshall', '555-5555555');

insert into SEAT_RESERVATION VALUES('DSFG56',2 , CAST('2017-05-07' AS Date),4, 'Bob C. Macdonald', '555-5555444');

insert into SEAT_RESERVATION VALUES('BDGT78',3 , CAST('2016-10-01' AS Date), 7, 'Brenda M. Debolt', '555-5555333');

insert into SEAT_RESERVATION VALUES('AJDK23',1  , CAST('2015-09-10' AS Date), 7, 'Nada P. Haynes', '555-5555222');

insert into SEAT_RESERVATION VALUES('OUYC87',2 , CAST('2015-10-14' AS Date), 12, 'Nada P. Haynes', '555-5555111');

insert into SEAT_RESERVATION VALUES('AQWE23',2 , CAST('2016-02-25' AS Date), 15, 'William M. Ahrens', '555-5555000');






