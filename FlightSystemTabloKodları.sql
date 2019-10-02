USE FlightSystemModify;


GO

CREATE TABLE COMPANY (

    Company_ID NVARCHAR(10) PRIMARY KEY,

	CompanyName NVARCHAR(25) NOT NULL

);



CREATE TABLE AIRPORT (

    Airport_code NVARCHAR(10) PRIMARY KEY,

	Name NVARCHAR(25) NOT NULL,

    City NVARCHAR(25) NOT NULL,

    State NVARCHAR(25) NOT NULL

);

CREATE TABLE AIRLINE_COMPANYID (

	Airline_Company_ID NVARCHAR(10) NOT NULL PRIMARY KEY,

    Airline NVARCHAR(25) NOT NULL UNIQUE,

	Company_ID NVARCHAR(10) NOT NULL,

	CONSTRAINT Fk_Airline_Company FOREIGN KEY (Company_ID) REFERENCES COMPANY (Company_ID)
	
	ON UPDATE CASCADE ON DELETE CASCADE
);



CREATE TABLE FLIGHT (

    Flight_number NVARCHAR(15) PRIMARY KEY,

	Airline_Company_ID NVARCHAR(10) NOT NULL,

    Weekdays INTEGER DEFAULT 0,

	CONSTRAINT Fk_Airline_CompanyID FOREIGN KEY (Airline_Company_ID) REFERENCES AIRLINE_COMPANYID (Airline_Company_ID)
	
	ON UPDATE CASCADE ON DELETE CASCADE

);





CREATE TABLE FLIGHT_LEG (

    Flight_number NVARCHAR(15) NOT NULL,

    Leg_number INTEGER NOT NULL,

    Departure_airport_code NVARCHAR(10) NOT NULL,

    Scheduled_departure_time TIME NOT NULL,

    Arrival_airport_code NVARCHAR(10) NOT NULL,

    Scheduled_arrival_time TIME NOT NULL,

    CONSTRAINT Pk_Flight_Leg PRIMARY KEY (Flight_number, Leg_number),

    CONSTRAINT  Fk_Flight_Leg_Flight FOREIGN KEY (Flight_number) REFERENCES FLIGHT (Flight_number)
	
	ON UPDATE CASCADE ON DELETE CASCADE,

	CONSTRAINT  Fk_Flight_Airport_Dep_Code FOREIGN KEY (Departure_airport_code) REFERENCES AIRPORT (Airport_code),

	CONSTRAINT  Fk_Flight_Airport_Arrival_Code FOREIGN KEY (Arrival_airport_code) REFERENCES AIRPORT (Airport_code)

);



CREATE TABLE FARE (

    Flight_number NVARCHAR(15) NOT NULL,

    Fare_code NVARCHAR(15) NOT NULL,

    Amount DECIMAL(10,2) NOT NULL,

    Restrictions NVARCHAR(50),

    CONSTRAINT KEYPk_Fare PRIMARY KEY (Flight_number, Fare_code),

    CONSTRAINT Fk_Fare_Flight FOREIGN KEY (Flight_number) REFERENCES FLIGHT (Flight_number)

    ON UPDATE CASCADE ON DELETE CASCADE

);



CREATE TABLE AIRPLANE_TYPE (

    Airplane_type_name NVARCHAR(25) PRIMARY KEY,

    Max_seats INTEGER NOT NULL,

	Company NVARCHAR(25)

);



CREATE TABLE AIRPLANE (

    Airplane_id NVARCHAR(25) PRIMARY KEY,

    Total_number_of_seats INTEGER NOT NULL,

    Airplane_type NVARCHAR(25) NOT NULL,

	Company_ID NVARCHAR(10) NOT NULL,

	CONSTRAINT Fk_Airplane_Airplane_Type FOREIGN KEY (Airplane_type) REFERENCES AIRPLANE_TYPE (Airplane_type_name)

    ON UPDATE CASCADE ON DELETE CASCADE,

	CONSTRAINT Fk_Airplane_Company FOREIGN KEY (Company_ID) REFERENCES COMPANY (Company_ID)
	
	ON UPDATE CASCADE ON DELETE CASCADE

);


CREATE TABLE LEG_INSTANCE (

    Flight_number NVARCHAR(15) NOT NULL,

    Leg_number INTEGER NOT NULL,

    Leg_instance_date Date NOT NULL,

    Number_of_available_seats INTEGER,

    Airplane_id NVARCHAR(25) NOT NULL,

    Departure_airport_code NVARCHAR(10) NOT NULL,

    Departure_time TIME NOT NULL,

    Arrival_airport_code NVARCHAR(10) NOT NULL,

    Arrival_time TIME NOT NULL,

    CONSTRAINT Pk_Leg_Instance PRIMARY KEY (Flight_number, Leg_number, Leg_instance_date),

    CONSTRAINT Fk_Leg_Instance_Flight_Leg FOREIGN KEY (Flight_number, Leg_number) REFERENCES FLIGHT_LEG (Flight_number, Leg_number)

    ON UPDATE CASCADE ON DELETE CASCADE,

    CONSTRAINT Fk_Leg_Instance_Airplane FOREIGN KEY (Airplane_id) REFERENCES AIRPLANE (Airplane_id),

	CONSTRAINT  Fk_Leg_Airport_Dep_Code FOREIGN KEY (Departure_airport_code) REFERENCES AIRPORT (Airport_code),
	
	CONSTRAINT  Fk_Leg_Airport_Arrival_Code FOREIGN KEY (Arrival_airport_code) REFERENCES AIRPORT (Airport_code)

);


CREATE TABLE FFC (

    Flight_number NVARCHAR(15) NOT NULL,

    Leg_number INTEGER NOT NULL,

	Leg_instance_date Date NOT NULL,

    Kilometer INTEGER NOT NULL,

    CONSTRAINT Pk_FFC PRIMARY KEY (Flight_number, Leg_number, Leg_instance_date),

    CONSTRAINT Fk_FFC_LegInstance FOREIGN KEY (Flight_number, Leg_number, Leg_instance_date) REFERENCES LEG_INSTANCE (Flight_number, Leg_number, Leg_instance_date)

    ON UPDATE CASCADE ON DELETE CASCADE

);






CREATE TABLE CAN_LAND (

    Airplane_type_name NVARCHAR(25) NOT NULL,

    Airport_code NVARCHAR(10) NOT NULL,

    CONSTRAINT Pk_Can_Land PRIMARY KEY (Airplane_type_name, Airport_code),

    CONSTRAINT Fk_Can_Land_Airplane_Type FOREIGN KEY (Airplane_type_name) REFERENCES AIRPLANE_TYPE (Airplane_type_name)

    ON UPDATE CASCADE ON DELETE CASCADE,

    CONSTRAINT Fk_Can_Land_Airport FOREIGN KEY (Airport_code) REFERENCES AIRPORT (Airport_code)

    ON UPDATE CASCADE ON DELETE CASCADE

);

CREATE TABLE CUSTOMER (

	PassportNumber NVARCHAR(25) PRIMARY KEY,

	Customer_name NVARCHAR(50) NOT NULL,

    Customer_phone NVARCHAR(20),

    Customer_email NVARCHAR(30),

	Customer_adress NVARCHAR(100),

	Customer_country NVARCHAR(20) NOT NULL
        
);


CREATE TABLE CUSTOMER_SEGMENTATION (

    PassportNumber NVARCHAR(25) PRIMARY KEY,

    Seg_Type CHAR DEFAULT NULL,

    CONSTRAINT Fk_CustomerSegmentation_Customer FOREIGN KEY (PassportNumber) REFERENCES CUSTOMER (PassportNumber)

    ON UPDATE CASCADE ON DELETE CASCADE

);



CREATE TABLE SEAT_RESERVATION (

    Flight_number NVARCHAR(15) NOT NULL,

	Leg_number INTEGER NOT NULL,

    Leg_instance_date Date NOT NULL,

    Seat_number INTEGER NOT NULL,

	PassportNumber NVARCHAR(25) NOT NULL,

    CONSTRAINT Pk_Seat_Reservation PRIMARY KEY (Flight_number, Leg_number, Leg_instance_date, Seat_number),

    CONSTRAINT Fk_Seat_Reservation_Leg_Instance FOREIGN KEY (Flight_number, Leg_number, Leg_instance_date) REFERENCES LEG_INSTANCE (Flight_number, Leg_number, Leg_instance_date),
	
	CONSTRAINT Fk_Seat_Reservation_Customer FOREIGN KEY (PassportNumber) REFERENCES CUSTOMER (PassportNumber)

    ON UPDATE CASCADE ON DELETE CASCADE        
);