-- РАЗДЕЛ УДАЛЕНИЯ ТАБЛИЦ ## для перезаписи таблиц во время первичной разработки

--- Таблицы СПРАВОЧНОЙ ИНФОРМАЦИИ
drop table address;
drop table street;
drop table city;
drop table country;
drop table currency2country;
drop table rate;
drop table currency;


--- Таблицы ПАССАЖИРА
drop table passenger_image;
drop table passenger_rating;
drop table passenger_phone;
drop table passenger;

--- Таблицы ВОДИТЕЛЯ и АВТОМОБИЛЯ
drop table driver_image;
drop table driver_rating;
drop table driver_phone;
drop table driver;
drop table refuelling;
drop table rent;
drop table car;
drop table parking;

--- Таблицы ЗАКАЗА
drop table rating_driver2passenger;
drop table rating_passenger2driver;
drop table status;
drop table way;
drop table order_taxi;
drop table payment;






-- РАЗДЕЛ СОЗДАНИЯ ТАБЛИЦ ## конструирования полей и связей таблиц

--- Создание таблиц БЛОКА СПРАВОЧНОЙ ИНФОРМАЦИИ

create table country(
                     country_id     INT NOT NULL,
                     name_country   VARCHAR2(255),
                     time_creat     TIMESTAMP NOT NULL,
                     PRIMARY KEY (country_id)
                     );
create or replace trigger trigger_country
    before insert on country
    for each row
    begin
        :new.time_creat := SYSDATE;
    end;

create table city(
                     city_id     INT NOT NULL,
                     country_id  INT NOT NULL,
                     name_city   VARCHAR2(255),
                     time_creat  TIMESTAMP NOT NULL,
                     PRIMARY KEY (city_id),
                     FOREIGN KEY (country_id) REFERENCES country
                     );
create or replace trigger trigger_city
    before insert on city
    for each row
    begin
        :new.time_creat := SYSDATE;
    end;

create table street(
                     street_id   INT NOT NULL,
                     city_id     INT NOT NULL,
                     name_street VARCHAR2(255),
                     time_creat  TIMESTAMP NOT NULL,
                     PRIMARY KEY (street_id),
                     FOREIGN KEY (city_id) REFERENCES city
                     );
create or replace trigger trigger_street
    before insert on street
    for each row
    begin
        :new.time_creat := SYSDATE;
    end;
                     
create table address(
                     address_id     INT NOT NULL,
                     street_id      INT NOT NULL,
                     house_number   INT NOT NULL,
                     time_creat     TIMESTAMP NOT NULL,
                     PRIMARY KEY (address_id),
                     FOREIGN KEY (street_id) REFERENCES street
                     );
create or replace trigger trigger_address
    before insert on address
    for each row
    begin
        :new.time_creat := SYSDATE;
    end;

create table currency(
                     currency_id    INT NOT NULL,
                     name_currency  VARCHAR2(50) NOT NULL,
                     abbreviation   VARCHAR2(8) NOT NULL,
                     time_creat     TIMESTAMP NOT NULL,
                     PRIMARY KEY (currency_id)
                     );
create or replace trigger trigger_currency_1
    before insert on currency
    for each row
    begin
        :new.time_creat := SYSDATE;
    end;

create table rate(
                     rate_id        INT NOT NULL,
                     currency1_id   INT NOT NULL,
                     currency2_id   INT NOT NULL,
                     rate           DECIMAL(9,2) NOT NULL,
                     time_creat     TIMESTAMP NOT NULL,
                     PRIMARY KEY (rate_id),
                     FOREIGN KEY (currency1_id) REFERENCES currency,
                     FOREIGN KEY (currency2_id) REFERENCES currency
                     );
create or replace trigger trigger_rate
    before insert on rate
    for each row
    begin
        :new.time_creat := SYSDATE;
    end;
                     
create table currency2country(
                     currency2country_id INT NOT NULL,
                     currency_id         INT NOT NULL,
                     country_id          INT NOT NULL,
                     time_creat          TIMESTAMP NOT NULL,
                     PRIMARY KEY (currency2country_id),
                     FOREIGN KEY (currency2_id) REFERENCES currency,
                     FOREIGN KEY (country_id) REFERENCES country
                     );
create or replace trigger trigger_currency2country
    before insert on currency2country
    for each row
    begin
        :new.time_creat := SYSDATE;
    end;




--- Создание таблиц  БЛОКА информации о ПАССАЖИРЕ

create table passenger(
                       passenger_id     INT NOT NULL,
                       is_anonymous      CHAR(1) CHECK(is_ananymus in (0,1)),
                       name_passenger   VARCHAR2(255) /*данный подтип преобразуется в VARCHAR2(255)*/,
                       age              SMALLINT     /*данный подтип преобразуется в NUMBER(38,0)*/,
                       home_address_id  INT          /*данный подтип преобразуется в NUMBER(38,0)*/,
                       is_male          CHAR(1) CHECK(is_male in (0,1)),
                       time_creat       TIMESTAMP NOT NULL,
                       PRIMARY KEY (passenger_id),
                       FOREIGN KEY (home_address_id) REFERENCES address
                       );
create or replace trigger trigger_passenger
    before insert on passenger
    for each row
    begin
        :new.time_creat := SYSDATE;
    end;
create sequence passenger_sequence
    increment by 1
    start with 100; -- Множжество автоидентификаторов создаётся со значениями 100 и более
                    -- для отделения от мнеожества идентификаторов тестовых данных  
create or replace trigger trigger_passenger_id_sequence
    before insert on passenger
    for each row
    begin
        :new.passenger_id := passenger_sequence.nextval;
    end;
                       
create table passenger_image(
                             passenger_id     INT NOT NULL,
                             image            CLOB,
                             time_creat       TIMESTAMP NOT NULL,
                             PRIMARY KEY (passenger_id),
                             FOREIGN KEY (passenger_id) REFERENCES passenger
                             );
create or replace trigger trigger_passenger_image
    before insert on passenger_image
    for each row
    begin
        :new.time_creat := SYSDATE;
    end;
                             
create table passenger_rating(
                             passenger_id     INT NOT NULL,
                             rating           DECIMAL(3,2),
                             time_creat       TIMESTAMP NOT NULL,
                             PRIMARY KEY (passenger_id),
                             FOREIGN KEY (passenger_id) REFERENCES passenger
                             );
create or replace trigger trigger_passenger_rating
    before insert on passenger_rating
    for each row
    begin
        :new.time_creat := SYSDATE;
    end;
                             
create table passenger_phone(
                             passenger_id     INT NOT NULL,
                             phone_number     VARCHAR2(50),
                             time_creat       TIMESTAMP NOT NULL,
                             PRIMARY KEY (passenger_id),
                             FOREIGN KEY (passenger_id) REFERENCES passenger
                             );
create or replace trigger trigger_passenger_phone
    before insert on passenger_phone
    for each row
    begin
        :new.time_creat := SYSDATE;
    end;


--- Создание таблиц БЛОКА информации о ВОДИТЕЛЕ и АВТОМОБИЛЕ

create table driver(
                       driver_id            INT NOT NULL,
                       name_driver          VARCHAR2(255) /*данный подтип преобразуется в VARCHAR2(255)*/,
                       age                  SMALLINT     /*данный подтип преобразуется в NUMBER(38,0)*/,
                       percent_of_payment    DECIMAL      /*данный подтип преобразуется в NUMBER(38,0)*/,
                       rigistration_data    DATE NOT NULL,
                       time_creat           TIMESTAMP NOT NULL,
                       PRIMARY KEY (driver_id)
                       );
create or replace trigger trigger_driver
    before insert on driver
    for each row
    begin
        :new.time_creat := SYSDATE;
    end;
                       

create table driver_image(
                             driver_id        INT NOT NULL,
                             image            CLOB,
                             time_creat       TIMESTAMP NOT NULL,
                             PRIMARY KEY (driver_id),
                             FOREIGN KEY (driver_id) REFERENCES driver
                             );
create or replace trigger trigger_driver_image
    before insert on driver_image
    for each row
    begin
        :new.time_creat := SYSDATE;
    end;
                             
create table driver_rating(
                             driver_id        INT NOT NULL,
                             rating           DECIMAL(3,2),
                             time_creat       TIMESTAMP NOT NULL,
                             PRIMARY KEY (driver_id),
                             FOREIGN KEY (driver_id) REFERENCES driver
                             );
create or replace trigger trigger_driver_rating
    before insert on driver_rating
    for each row
    begin
        :new.time_creat := SYSDATE;
    end;

                             
create table driver_phone(
                             driver_id        INT NOT NULL,
                             phone_number     VARCHAR2(50),
                             time_creat       TIMESTAMP NOT NULL,
                             PRIMARY KEY (driver_id),
                             FOREIGN KEY (driver_id) REFERENCES driver
                             );
create or replace trigger trigger_driver_phone
    before insert on driver_phone
    for each row
    begin
        :new.time_creat := SYSDATE;
    end;

create table parking(
                             parking_id       INT NOT NULL,
                             number_parking   INT NOT NULL,
                             address_id       INT NOT NULL,
                             time_creat       TIMESTAMP NOT NULL,
                             PRIMARY KEY (parking_id),
                             CONSTRAINT number_parking_unique UNIQUE (number_parking),
                             FOREIGN KEY (address_id) REFERENCES address,
                             CONSTRAINT address_parking_unique UNIQUE (address_id)
                             );
create or replace trigger trigger_parking
    before insert on parking
    for each row
    begin
        :new.time_creat := SYSDATE;
    end;
                             
create table car(
                             car_id           INT NOT NULL,
                             brand            VARCHAR2(50) NOT NULL,
                             model_car        VARCHAR2(50) NOT NULL,
                             color            VARCHAR2(6) CHECK (color in('White', 'Black', 'Gray',
                                                                           'Red', 'Blue', 'Yellow', 'Green')),
                             is_reservd       CHAR(5) NOT NULL CHECK (is_reservd in('False', 'True')),
                             state_number     VARCHAR2(50) NOT NULL,
                             parking_id       INT NOT NULL,
                             millage          NUMBER NOT NULL,
                             time_creat       TIMESTAMP NOT NULL,
                             PRIMARY KEY (car_id),
                             FOREIGN KEY (parking_id) REFERENCES parking,
                             CONSTRAINT state_number_unique UNIQUE (state_number)
                             );
create or replace trigger trigger_car
    before insert on car
    for each row
    begin
        :new.time_creat := SYSDATE;
    end;

create table rent(
                             rent_id          INT NOT NULL,
                             driver_id        INT NOT NULL,
                             car_id           INT NOT NULL,
                             data_start       DATE NOT NULL,
                             data_stop        DATE,
                             gas_mileage      DECIMAL,
                             distance         NUMBER,
                             time_creat       TIMESTAMP NOT NULL,
                             PRIMARY KEY (rent_id),
                             FOREIGN KEY (driver_id) REFERENCES driver,
                             FOREIGN KEY (car_id) REFERENCES car
                             );
create or replace trigger trigger_rent_1
    before insert on rent
    for each row
    begin
        :new.time_creat := SYSDATE;
    end;

create table refuelling(
                             refuelling_id      INT NOT NULL,
                             driver_id          INT NOT NULL,
                             address_id         INT NOT NULL,
                             car_id             INT NOT NULL,
                             payment_id         INT NOT NULL,
                             amount_of_gasoline DECIMAL NOT NULL,
                             time_creat         TIMESTAMP NOT NULL,
                             PRIMARY KEY (refuelling_id),
                             FOREIGN KEY (driver_id) REFERENCES driver,
                             FOREIGN KEY (address_id) REFERENCES address,
                             CONSTRAINT address_refuelling_unique UNIQUE (address_id),
                             FOREIGN KEY (car_id) REFERENCES car,
                             FOREIGN KEY (payment_id) REFERENCES payment, -- для ссылки предварительно создана таблица payment, см.ниже в блоке создания таблица ЗАКАЗА
                             CONSTRAINT payment_unique UNIQUE (payment_id)
                             );
create or replace trigger trigger_refuelling
    before insert on refuelling
    for each row
    begin
        :new.time_creat := SYSDATE;
    end;
 
 
                         
--- Создание таблиц БЛОКА информации о ЗАКАЗ
create table payment(
                             payment_id      INT NOT NULL,
                             currency_id     INT NOT NULL,
                             amount_to_paid  DECIMAL(9,2) NOT NULL,
                             type_payment    CHAR(4) CHECK (type_payment in('CARD','CASH')) NOT NULL,
                             time_creat      TIMESTAMP NOT NULL,
                             PRIMARY KEY (payment_id),
                             FOREIGN KEY (currency_id) REFERENCES currency
                             );
create or replace trigger trigger_payment
    before insert on payment
    for each row
    begin
        :new.time_creat := SYSDATE;
    end;

create table order_taxi(
                   order_taxi_id        INT NOT NULL,
                   passenger_id         INT NOT NULL,
                   driver_id            INT,
                   time_start           TIMESTAMP,
                   time_end             TIMESTAMP,
                   payment_id           INT NULL,
                   end_trip_address_id  INT,  
                   time_creat           TIMESTAMP NOT NULL,
                   PRIMARY KEY (order_taxi_id),
                   FOREIGN KEY (passenger_id) REFERENCES passenger,
                   FOREIGN KEY (driver_id) REFERENCES driver,
                   FOREIGN KEY (payment_id) REFERENCES payment,
                   CONSTRAINT order_payment_unique UNIQUE (payment_id),
                   FOREIGN KEY (end_trip_address_id) REFERENCES address
                   );
create or replace trigger trigger_order_taxi
    before insert on order_taxi
    for each row
    begin
        :new.time_creat := SYSDATE;
    end;

create table way(
                   way_id               INT NOT NULL,
                   order_taxi_id        INT NOT NULL,
                   from_address         INT NOT NULL,
                   to_address           INT NOT NULL,
                   distance             DECIMAL NOT NULL,
                   preview_way_id       INT,  
                   time_creat           TIMESTAMP NOT NULL,
                   PRIMARY KEY (way_id),
                   FOREIGN KEY (order_taxi_id) REFERENCES order_taxi,
                   FOREIGN KEY (from_address) REFERENCES address,
                   FOREIGN KEY (to_address) REFERENCES address,
                   FOREIGN KEY (preview_way_id) REFERENCES way,
                   CONSTRAINT preview_way_unique UNIQUE (preview_way_id)
                   );
create or replace trigger trigger_way
    before insert on way
    for each row
    begin
        :new.time_creat := SYSDATE;
    end;
                   
create table status(
                             order_taxi_id    INT NOT NULL,
                             status           CHAR(14) CHECK (status in('SEARTH_DRIVER', 'WAIT_DRIVER', 'WAIT_PASSENGER',
                                                                        'TRIP_STARTED', 'WAIT_PAYMENT', 'TRIP_COMPLETED', 'CANCELD')),
                             time_creat       TIMESTAMP NOT NULL,
                             PRIMARY KEY (order_taxi_id),
                             FOREIGN KEY (order_taxi_id) REFERENCES order_taxi
                             );
create or replace trigger trigger_status
    before insert on status
    for each row
    begin
        :new.time_creat := SYSDATE;
    end;

create table rating_passenger2driver(
                                     rating_id        INT NOT NULL,
                                     passenger_id     INT NOT NULL,
                                     driver_id        INT NOT NULL,
                                     order_taxi_id    INT NOT NULL,
                                     rating           DECIMAL,
                                     time_creat       TIMESTAMP NOT NULL,
                                     PRIMARY KEY (rating_id),
                                     FOREIGN KEY (passenger_id) REFERENCES passenger,
                                     FOREIGN KEY (driver_id) REFERENCES driver,
                                     FOREIGN KEY (order_taxi_id) REFERENCES order_taxi,
                                     CONSTRAINT order_taxi_passenger_unique UNIQUE (order_taxi_id)
                                     );
create or replace trigger trigger_rating_passenger2driver
    before insert on rating_passenger2driver
    for each row
    begin
        :new.time_creat := SYSDATE;
    end;

create table rating_driver2passenger(
                                     rating_id        INT NOT NULL,
                                     passenger_id     INT NOT NULL,
                                     driver_id        INT NOT NULL,
                                     order_taxi_id    INT NOT NULL,
                                     rating           DECIMAL,
                                     time_creat       TIMESTAMP NOT NULL,
                                     PRIMARY KEY (rating_id),
                                     FOREIGN KEY (passenger_id) REFERENCES passenger,
                                     FOREIGN KEY (driver_id) REFERENCES driver,
                                     FOREIGN KEY (order_taxi_id) REFERENCES order_taxi,
                                     CONSTRAINT order_taxi_driver_unique UNIQUE (order_taxi_id)
                                     );
create or replace trigger trigger_rating_driver2passenger
    before insert on trigger_rating_driver2passenger
    for each row
    begin
        :new.time_creat := SYSDATE;
    end;
drop trigger trigger_rating_driver2passenger;


       
-- РАЗДЕЛ ЗАПОЛНЕНИЯ ТАБЛИЦ ##

--- блок адресов
delete from currency;

insert into country
                (country_id, name_country)
       values   
                (5, 'China');
                
insert into city
                (city_id, name_city, country_id)
       values   
                (7, 'Москва', 1);
                
insert into street
                (street_id, name_street, city_id)
       values   
                (12, 'Ильина', 6);
commit;
                
insert into address
                (address_id, house_number, street_id)
       values   
                (21, 33, 12);
                                     
insert into currency
                (currency_id, name_currency, abbreviation)
       values   
                (5, 'Китайский юань', 'CNY');

insert into rate
                (rate_id, currency1_id, currency2_id, rate)
       values   
                (8, 1, 4, 18.3);
insert into currency2country
                (currency2country_id, currency2_id, country_id)
       values   
                (5, 5, 5);

insert into passenger
                (passenger_id, is_anonymous, home_address_id)
       values   
                (5, 1, 5);

insert into passenger_rating
                (passenger_id, rating)
       values   
                (5, 3);

insert into passenger_phone
                (passenger_id, phone_number)
       values   
                (5, '+86143423479');

declare
    image_clob clob;
    image_clob1 clob;
begin
    image_clob := 'data:image/jpeg;base64,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';
    image_clob1 := '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';
    update passenger_image
           set image = image_clob||image_clob1
           where passenger_id = 5;                                     
end;                                                                                                    

insert into driver
                (driver_id, name_driver, age, percent_of_payment, rigistration_data)
       values   
                (5, 'Свердлов Павел', 33, 63, '01.09.2021');

insert into driver_rating
                (driver_id, rating)
       values   
                (5, 4);

insert into driver_phone
                (driver_id, phone_number)
       values   
                (5, '+9243568746');

declare
    image_clob clob;
begin
    image_clob := 'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAkGBxMTEhUSExMVFhUXGBgVGBgWGBgXGRgXFRgXFx0aFxcYHSggGB0lGxYXIjEhJSorLi4uGB8zODMtNygtLisBCgoKDg0OGxAQGyslICUtNS8rLzI1KystLTctLS0tLS0tLS0tLS01Ky0tLy0tLS0tLS0tKy0uLS0tLS0tLS0tK//AABEIAQ4AuwMBIgACEQEDEQH/xAAcAAAABwEBAAAAAAAAAAAAAAAAAQIEBQYHAwj/xABJEAABAwICBgcGBAMHAwIHAQABAgMRAAQhQQUSMTJRYQYTIkJScfAHYoGRocEUI4LhFbHRJENTY3KSojM0woOzNUR0k6Oy8Rf/xAAaAQEAAwEBAQAAAAAAAAAAAAAAAQIEAwUG/8QALhEAAgIBAwEGBgIDAQAAAAAAAAECAxESITEEBRMyQVFhFIGRobHBIvBx4fEj/9oADAMBAAIRAxEAPwDZiTMnfyGRHqaAzI2neHChGMEyclcPX3oAZDAjafFQBQIjuZnOfUUDlOW5z8/p86E4THZ8P3ocJxnd931h8qAOTM9/hlFEM4xB3uXlRxjE9rxfaiHLADaPFQAIEQdzI5k+poyTMnBWQ4+saInCSJTknhz/AJ/OjIxgmSdiuFAATJIxUd4cKIARA3MznPqKMDIYEbTxrLvaj01WHP4dZr6tRTrXLoMdSg4wk5LIxnIERiZTDeFllZSUU5S4RN9KvaG1brNuwg3NwjCEkJbbx/vnMYVHdSCcCDFUDS2mtI3Zl68U0P8ADtJZSP1yVq+JpI0F+Ft21OBbSXsGGWm+tu7gxipLRgIAGqoqVO2CkEgG3dH+hNrdWouU3V+0Drgh4WyCgtqUlWunqYEFJzyri+8lxsedZ8ZdvXiC9+fw8GffwkE6ynrhavEp5ZPzBFdiw8BDd7et/wCm4cj5TVh6T9G3rGFOKS4wohKXkjVAUrYl1MnVnYFAlJPhJAMRWeUrIvdnjXXdZRPE5PP2Hdj0w0tbKSrrkXiEwOreSlC491xMEnmonyNaT0T6cW16SlEt3Pft3oSscSjJxPMZbQKyum15ZocgmQpJBQtJ1VoUDIUhQxBBAPwq8Ooa8Rp6btecXi3devmeggBEA9jM5g+ooHKcAN3n5/Ssx6CdPnA6my0goFSsGXwAlLxyQ4BglzZB70Rtgq0888Z2Dw+vtWtNNZR9DCcZxUovKYJMz3+GUUQzjEHf5eX1o4xie14vtRcYwjb73r71JYBAiDuZHOfU0ZJkE4KG6ONFOEx2fDw5+uNGRkcSdh4UAATMjFWY4esKR1bfiPr4UsDIGCNquNJ6xPgoAxEQNzM5z6igYwnd7vPzoTnEe5x5x+2VDnEzl4aAPGZ7+Qyj1NEM4/Xy8vrQjKf18OU/vnQ+kf8AP+v120AMIjucc5ozlO3u8/OinOP0feP2oR8Zz8FAGJmRv5jKPUUQiMNzM5+tlNNKaRZt2y4+6lpCdrqjAPujieQkmKpVz7WbXW/KtrpxIzCEIQvmOsWFR5pGyobS5KynGPieC2dKNMos7R25cxQ0nWQPEo9lKfiogfGsv9j+gzcvLurntrUfxDmtjrLWSUTOQgqjIkUy9pvTM6QtBbs21w3LqVr1ggjUSFYJCFkntFJ2DdqX9lXSi3bfuGyoiWUrSgpIXLGuVJCSJUopWmANsGqNptIzTsjZZCK3XL8+OM/n5HL2k6OOkrtNzo/qr1dsHLV+1WY1FArGuEKUgrGstXaBiUJjWAMcOlbOkbLQDLF24ohbwTcKDiVON26jIZCie2TjsJAA1d2qGLxLrn4m264aVeu1LQ0wkIQwiSdWNX8xRmPIHWz1rDpfTF4td+t5CNIaNZuTr9cerSlajq6tq5ra6SJgBBOBB1e1j0NZovsmQm90Y71yusZdWplNuSVJt2W0paQ0CcSdRKVa2cg70k0EMqbK2lyVNOLaJOJV1aikKMZlIB+Nbrou6bNq28hHVNqbS6EqAQUBadeFAYA4485rDri9D7rr6RCXXFrTzRMJV8UgK+NZ+p8KPI7ZUe5TfOf0xFIXS6QqsaPnI8jO+tg4goVnsI2gjYQciDWoey3pYq6aXbvGbpjsuk/3jfddHMiAecHvVmqqLQ94bXSFpdJmC4Ld2M23jq4+RM+YFaaJ4eD2+zOo0T7t8P8AJ6DwiO5xzmgcp29zn5/Shzj9H3j9qH1n/h/T6bK1nvhiZkb+Yyj1FEIgxu97l5UIymPf48p/fKhziI7vioAGIx3O6c/W2l6znAevjSJzifd8Pr70fV/5v1/egAZnHfy4R6mgM43u9+1FGUyD3uHL1xocpiNh8VADCPcz4z6igcp/R+/0o5zjHwcefrhRfWdvuevtQB4z7/0iiGcbO9+1CMpw8f2mj57I2DxUBhntlWr+JI1pLaWEFkGdUSteuUjZrSBJ2xq8qpo0gobIrefaN0QGkbcBBCbhslTJOwEiFIVnqrAEnI6pyg+fH2ltrW06gtuoOqtCtqT9xmCMCMaq4p8nGymM3mSyOk6ZeT3ULHASg/OSKfsaTtriG3UgK2BLoGeHZV/TGoBx8AhOJUdiUiSfICnCdCXLw/7YhPFwhJH6d4VzlVH/AAZrOzqrN45i/VF90Tp68tFSy6l1MR1dzKjqkiQi4H5iMNgJUAcqiLBjRDRT+Ib0gE6/WJs1LbUwp0iJDspCgBh2tVUATOwwluxfWg7aC61mEnWUnyz+3lU3Y3rVwg6pCx3kkYifEk1z1zhzujJO/quj2s/lH1/v7+paOk3S24vUlopDFucC2k6y3E8HFjBKTmlO3xRIqEAqIdtXGO0wdZGbKjl/lqO75bKfWN6l1OsmdsEEQpJG0KGRrjNylueV1Vll3/o3lfTHy/7n1HBpBpZrma5oyxRzVUdptEsOQSCBrgjaCghWHyqRVTK/xbcHFCh80mukeTZQ8TT90eh9G3PWtNu99baF8oUkK+9OBnGzv/t9arfs2uut0VZmf7lKdec25biePZirIflGz3/X3r0D60BiMdzLjPqaMzIne7v70JziT4OHP1xooymQdqvDQBiZw3+9w9bKRLfP60qMpgDvcfX2o+sP+H6+VAECIkbmYzJ9RnQOwTundHDzoyTMkQobE8fWNAHMYk7w4UAIMx38jlHqcqIZxlv8/L68KECIns+LnQOU4Ru+96w+dACRE9zhnPrnRnKdp3eXnQkzMdrw8qIZgYg7x4UAYBmBv5nKPUZVR/ah0Vtbm1cu1HqnLdtSg6BKiEgq6tQntpJwAJkE4bSDdyBEE9nJXE+p+VUT20XBOjwxOqu5eZt08MVhcnl2I+NAZR0P6ALumw++taUOdoJbgKKciVEGByjhV/6PdE02gKEOuLbOIS5qq1T7pSBAOY/ljL/of0PYvLZN1d65YI/szGutpDTDfZQtXVqGstSU68k4BQiIrtoNsM3TtklzrWtQXVssr6w9StZQpvXM6wbcEAyTChOys1injJ3rcc4OV1owRIE8jWfaT6BuvOqd/EIbUrDVbbIEcCdYFXma1rS77du2p106qE7Tt2mAABiSSQABxqDQxpB0dYzo0pQcQLh9DThEZthKtQ8lGeVc69b8JexQ4kZU2w/YL6u5JU0sgIcklKVY4GcUyP5eZp1d26tbrWiA5nO64Bkr7HKr/qovG3rd5otuoht9hZBU2VCRChgpJGKVjbE1nr1s5Zui1eJKTJYcPeSO6TkoYfTiJl7v3PE6/odL76r5r+/ckLC8DqdYYEGFJO1KhtBrqahXyW19egSYhxI76B/5DI/CpZDoUApJkESDxBrnKOODwbadL1R4f29g1bKaP8KdLpk+amBehbmg+yrpzZiztbJ1wtOpSUhLiShK1FaiNRzdMyMCRJrUFZTtO5y8/pxry6m0BbDahICQk/ARNbP7Juka7i3XbPHWettVClEklbKh+W4SdqoCgduKQc62p5Pp67dZewDMDfzOUeoyohEEjd7w4+VCBET2clcT6n5UZOZwI2DjVjqESIBO5kMx6xpeo54h6+FJBMyMVHaOFJ6tHjNAKIMwcVHYrh6xoAbQMCN48aIARA3MzmD6jKmmltJM27ReuHEtMoxC1Z8BG0k5ACTlQDuREx2fDzoHKcZ3fd9YfKqi10rvbgh2z0Y443GDr7qLYKGRQ2oKWoGSZMUatP6TaJLmiCpBxWpi6adUB7rZSkqOJzoC3QZie14uVEMyMAN4cahdA9Jre71mkFxtbYBWy8hTTyJ8SFDEThIkc6bdPOkS7O3SW0a9y6tLFs3kpxeasdgGOWQwmaAX0n6Y2tlqpdUVuLjq7Zoa7yicAQgbASDiYnKdlUbpJaaW0othwWjdqhkuKQLl3WKy4kJClJbTrIKcSAcznVp6J9Fm7QF1Z668clT1wvFalKxISTuo2CBtjHlYtas8rvJHaNfqZ1pXo9ptzRydHdbo8NJbbaJQbhLhQ0AAkqIKTOqJwE48agugWgrrRd0k3oDbAQ8kPa2u1LpZISVD/pCWyZXqifMTsM0SjVJWtrDLqtJ5Mw9q3SQ277RASo26UvNpUAUm5eK0NLUMw2ht5YxHaKNtL9i3tFu7y6ctbxwOayC42rVQghSCJRCAAQQSeWrzqK9sfQwdULy3kJaSlC2RupbCjqqbSN0JKzKdgBkQAarXsItivTDKhsbQ6s+RbU3/ADWK71NadjjZnVubH0wt0t6UtHRgbll+3Xtg9RqvIMbJA6wTwMVH9JNAtXTRacGG1KhgpChsUk5ETU50ytiu/wBGkdz8Ws+RZSj+ax86O4bwrhc8T2O1SzHcwi9Llo71Fz+h3uuJGZ4HZPolei3OrX1PcXK2+R2qR/5D41qOm9EtXKC26gKB47QeKTtB51mHSLoiuzSXWnypCFJUlC09oKkADWGBknIDbUpqSweb1PZykno8yUcpg8a7NXYcQlwbFCY4HMfAyPhTZ01SCPCog08MDQqy9Aros6WtiN19t1hfA6qetT8SUx8arjIqb6Oj+32HH8QI/wDtuf0rVE9uhYN5JETHZyTwPqfnRkYwcSdh4UATMjfzGUeozogBBA3e8eHlVzWGAZgYKG08aR1iPBSiBAB3MjmfWNL13PCPXxoBlpPSLVuy5cOkIabSVLBzA4DMkkADMwKrvRnQKrxSdJX6NZau1bW6xLdq0SCg6hwLxAClLOIMARFN9Pn8bpJqzcEsWqU3VwO6t1RIYaUJxG84QZBgTV0F1OAMHI7YPlQA0ml8o/IW0hU7XW1OJj/SlxBn41WL3TOk7SXHrdm7YGKjaBbb6ExirqHVKDg5JXNdr3oy+e0NK36VH/6Yp/2JZSKrGn9K6WtC3Zlxp43RDbN4Gw2tpQMuda0CUqIbkpIjEZ5AP+lelrZStGaUt3G1az6GJmOst7klC0qG3sLAMHdIVsNculRB0zY6xlLdvcOt5jXWUoMeSYPypzob2f6ObRCrZDytqnHx1i1qO1SirM8oFUXp5oNzRt9aPWaFKYPXOIYklKF6svttnuhbfaCTPaCo4VWabi0i0Wk02akl3Ol9dULoXSrb7SXWlayFiQf5gjIg4EZVJBdebwbsDjrjSVOGuU0CoDaaDAm6tkuoW2oSlaVIUOKVAg/Q006A9CLPReuttS3HljVU4sAHVkHVSBgkSATtJIGOAqRs1hRwyp7XSuxx4Oc4KXIq7KVuJcKRrJSpCTmErKSofEoR/tFR163Tt95KEla1JSkYlSiEpA4knAVB6J6YWV0+q2YeDjiUlRgK1SAQDqrIhUSNnHDOoeZbkrEdiI09pdi1SFPqMqnUQkay1kDYlPyxMASJIms16S9Il3agAktspOslBIKlK2BSyMMBMJGydpwi+e1vQQNum7SSFMHVUIkFt1SAonhqkBU+c8RlbTalrS22krcWYQhOKlHkPvsFWXGxDHGhGXlKW0yy47/eANidXWwOsTgkSMPM07v7W5ZBW9avIQNqtUKSnmooJgc60novon8C0WG0dfdq1V3C9bUabJEobU5BMAHBKUqV2tYgBQqVaS9J61TRB2BtChHmtSzrZ90VZ2aTL8DVOTl5syazIUApJBB2EVb/AGcaOL+kEuR+XaoKicuueSUIHmEa6uUpqKuuirg0gm2s+rQm5SpxIXOq0pv/AKmoEg4QQQnASYwArY+jOgWrK3DDGIEqdUrecWreWo5qP0AA2CtUGmso5KrRLDJWMpg+Pjy9cKLnEAbU+KgYjHcy4z6mjMyJ3u7+9XLhTnEg93h6+9K6s/4nr50QmcN/vcPWykQ3z+tAZn0dv9a50g6cVOXbiAdst24DKJP6VfOrYi4dKYZLYV4nNZQHPUSQVf7k1nuhSW7i7aVgpu6emc0uLLiFeRSoGrYjSaWQlxRAQVpQonLrOwn/AJlA8iaEDy9vtLMfmFu0vGUiShgOMXEZlCVrWlcCTqzJ2CozprpRD1nbaVtiFt2rvXKQo6hKFJLTiDO66CqIOfHCbKHSDtxqo9GOjrF5e3zyypds3dJKGQqLdVyGmy64tAwcUFgbcMTgZoSSrBvrxKmPwirVpxOqt55xBWELwUGm2ySVlJIlRSEzOMRT3p7/ANfRaQMfxoVHJDLpNWwGs6vdOh7TFu4tCvwjSnbO3eEair9xPantSUhCVNgwRra2O2AMZvNKXeib+5ZbOqEuqltYlC0kyhRSNkoKTIIOzyq3aM9rbBAD7LjauKCFp88Skj61p3TboDa6TA60FFwkQHkYK1fCQcFpxGBGGMESZxR72XqTfOWSrkDVbQ82stn81tXZUQnX7JSrCJPGuVkIPeR0rnNbIuC/alYgSFOnkG8fqYqtad9rClDVtWiknvuwSPJAkTzJPlT5HskY1CDcOlcYEJSEhXEpxJHLWHnVB6RdE7mzJ6xslucHUdpB8z3TyVFcoRqb2Os5Wpbi7bpxpFskpvHu0ZMq1hjwCpCRyFd1+0PSZEfjHfhqg/MCRVYijitGmPoZ9T9R1pDSr78dc+67GzrFqXHlrE1ZvZGFfxRhQ2JDpV/p6pacfioD41BaD6PXF2rVYaUoTBXsQnZvLOAwMxt4Cto6FdEW7BBMhb6xC3IiBt1EDJOyeJHIAc7bIxjg61QcnkvpeSsFKgCkgghQBBBwIIOBBGVMrTRttapWq2t2m1EEnq0JSVQJCZGMctlcA7FRrfSS3Lq2OuQHUEJUlRCTJAPZne25bKxLJqaRIWTfVNBudZWKlrzW4s6y1HzUThkIAwAolqrk7cpA1iQBxJEfOq+90j65ZYsUG7f4N4tIme067upTgc8dmE1aMJTZEpxgiS6PD8RpiUmEWlurXVOx25I1Un9CCa0f6R/z/r9dtV7oR0d/BW2q4rrHHVF24WO+8qJ1eCUgADZsmBNWE5Tt7nLz+lb4x0rBilLU8gnOJ9zhzj9s6HKZnveGjEzA38zlHqKIRBjd737VYqCMpj3vF688qPrP8r6ftRGIx3O6M/W2l6rnEevhQGce0jQbiHf4mwgkhIRdNJ3lto3XUjNSBIPujKKYaMum32wYQ62obFAKSocwcK1QgzB38jkB6mqHpnoCpLi39GrSy4cXGHB/Z3FZqTq4sqPEYHDAY0Aytuh7Kxqpur5lrD8lp8hsDwpCkkpSRhAMVedCWzFu0i3YQENoEJSMvOcSScSTiSZNZroXpktRcaXZPJdaWW3EpWyQlQ5rWjDnEc6umjbgqSFKGqeGsFR5kYT5T50ILSFVlftN6U26LqytUoKmrK4aurgtCAyESlCQAMSAoqKRkAOMPOmfT8WyFW9soLvFDVEQoMA7VuZAgHBPGJEYHOrBCUJKZKiolS1KxUtSt5SidpNc7LNJj6zq+4Swss9DMupWhKkqBbUApLgMhQUJBBzBBqs9P9AuXDaLi3ATeWxLjI/xEkdto8lpw8wMRjWe9EelbmjiGlhT1iTOqJLluScSjNbe2U5TIznXdD6ZYukBbDzb07FIIOryUNqTyInGrRkpLY0UXwtjqg/9FB0Rp5u4aDiMDsUk7yFjalQyIp8m8FOulfQAPuKubNwW95HbMfkvn/NSBt98CcTgTEUC+009aLDV8wphRnVXvNLjNDgwPGDiJE1mlR6G6N3qWS40HZOnWXbME5nUSCfMgSaDPR2xSQU2rEjZ+Wk/zFQlt0hbVilaT5EH+VOhpdJ7wqmiRbWiyF5IEDYNgFcHLyqve9I2WwSt5I5Tj8AMTVZ0h02UslFu2daCdZzDAeFEyeUxUxpbErS5dJulaLVrWkKdVg2jirifdGZrJlpk67g61Wt1i5wKyVay8do1sR8atnR66W0HHdW0vOvTCl3LbhVqeBML1UCRsCZnyEMbjR7ZIKbdbYzS1dSmPc65hSh8VGui0rhmBdoUSbzL9fk2XRfs/wBDOttXDVmgtuIS4lSlOHBYCgFJUsiYIwPGrdZWTTSA202hptO6ltIQk/BIAx+9Z10c9otqwy1bLtbppptCUA9h8QkRKi2dacAcE/KrvoXpLaXf/QuG3eCAYWj/AFtqhSfiMq0Jp8FozjLwtMlpzjteH70XljO33fX2o4Mx3+OUeuVEM42Df5+X1qSwIwiez4uPL1woyczgRsHGiJESdzIZz6nOjMyAd47p4UAAcwJJ2p4Unq0+OlAGYGCszx9YUjrG/CfXxoBQAiBuZngfUUCNgOwbp40AcJAhOaePr7UDxOIOweGgK70i6FWl4suuIW3ckavWsLLTkYDFScFQAN4HYKiV+zdJTqjSOkY70PNiPiGgf6xV5gzE9rxfaiGcYRve96x+dAeZtKaFd0fcKtnhjipDgEJfR4wT3uIyNdm3MxW+9JejtvfM9XcIlPcKey42rxNq7pw8jmDWG9LOi1zoxf5ku2xI1LhIwE911Inq1c9hyzjnOGTF1PTa90E0/SF2TalBwJ1XBiFoJQsHZOskg0yauAacJeiszi09jx5UzhLMdmO3FPEQbu8I4G4dj/8AaoDTuj06vWHWUrWRKlqUtRBUBiVE8al/xE0z00v8hfIoPyWmrRlLKyztTbcrI6pPlDD+CIXgEAHI4j+VRiLFbv5aQvWGC9YnVSpOBknDbkKvdtaY1HMph64T/mA/7m0GtNj0rKPX6m11VuSIJjo+4k60tggQN4g85wiuStHPAqcKQFIgpgzrRJPPEYY8atZri6K4K2R5kOvtb3wRNndaigof9N2P0rOw8p2HnFSwdqEt2AW3GjsStSRyBhQ+U/Srd0f6CXd1aNXTD7C9bWSttwLbUhaFFKk6ydYHEbSBgQa6Tr1bo139IrXrj5kelyg60hca6QSMQdigRmlQxB8qPS2iLuz/AO6t1tJ/xMHGtsD8xBITOQVBrm0uuEoOJ5lvTyqeeDQfZ10sdDybG6dLjbgJYdXi4FoElpxfflMlKjjgRjhWnHKcI3Ofn9K85voUU9g6riSHG1eFxB1kH5gVvfR3Sybq1YuRseQFAf4atik/pVI/TXeqepbnrdDe7YYlyiSBMyN/MZR6iiAEEDdO8eFHBmJ7WauPL+XyogcxgBtHGuptAQIg4JGw8fWNL6xzwj18aQTmRIOxPCldWrx0ARmZO/kMo9TQGcb3e5eVFGUz7/DlP750Iy2Rn4qAGER3MznPqKBynLc5+f0oTnH6OPOP2yofWf8Ah/T6bKAPGZ7/AAyiubrSVJUgpCkKBDgUAQQcCIO0RPGlxlP6/tP70PpGXjoDM9N+x5hSy5aXK7VCjOqUdcifcSpQUjGcyPKo7/8Axl/YdJ45D8KnH49bhWuznE+5w5x+2dCMpme94fj621GEVcIvlGTsex1SdYuaQcXAJ1W2UNEQD3ipQ4ZVlSl/2QnEkoBJJJJOBma9J9Nbws6Pu3AdVSGHYVxUUEJ+pFeb7lEMag2lKW0jMqMAAc6rJGe+KWlJeZfAKrsfn3H+tP8A7SKd3elnOsLbDCntSOsIMBJ8IJ2qio20S7cOOrbBbQpYlawNZJShKSkI8QIzwHOk8SWlPct1VUrK9K8x0pdNXL5oYFxAPNSf61LNaAYGKklw8XSV/wDE9kfAU8RZNAQG0AcAlIHyAqio9zJDs5LmRTbZxJceIUCCEKkEETik4/AVqPsK0kZu7URIUi4SOSx1a8ORQj/dVJudCC8uupA1W20hStURrKXMbOAA+ZqT6IaNXozS1sQshl8qtjORcEpTPNaUH4VX4mtW9zn+R6kamoJm53lo260tpaQplaSlYOYUII/lXnW6sFWz71qskllZQFHapBAU2o8yhSTW49N9LuW9qVsgB5xbduylW71ryghKlCMYkq2GdWKyHppogWt/q9e4+py3Q4t11WspTiXHW1R4QNUAJyECutizEydXFSqfsNGTWiex/SqQ2/ZFaddt1TiUkgKLLoCyUpmSErU4CQMJHxzdk41P9DOjyLy6uUgrbebZZcZuEbWHQp4AkzBChAKDvCeEjhVtM8zs9uN7XqjbTEQdzI5z6mjMyJ3u7z86g+humVXVql1xIDqVLZdbG6HWlFCykcCRP6qm4ymZ73hrUe6GJmRv94ZetlI1W+J+v9KVGUxHe8Xx9bKHWD/C+n7UABEYbmfGfUUDGE7vd/ejnOII7vHn64UJz2ztHhoAYz7+XCPU0Qzj9f7fWhGU4ePhyn1tofSNnv8A9f3oAYR7n1mjOU7e7+9Cc4x8H3ouW2dp8NAGJnDfz4R6iiERhuZ8fWyhGUwPHx5euFHOcQR3ePr7UBQvbXclOjOrBgPvNMp8pLhniIbNZRo2yS1LyyXFpSpQKtiQBPZTsGzbtrSfbgPybMz/APMHs8Pyl1nxRrIUnxJKfmCPvQhl36FWIbs281LGus8VKxV9ZqAuGOrvLlAwCg07HNQWgn/8afrVh6J36V2bSpiEwQcII21AXLwcuX3Ru9hoc+rCiSOOLkfCvmOyu8+OscvfP1Nl2NB0oUmaE19SYxz0VAF2+DtU22tPPeQflqp+dPunaYtFujBbJQ8g8FtrSofyqAecUhaH2xK0SI8SFRrJ88ARzEYSab9OelSXLVaEBUqACpSREkA60jDbs21851nQ3Pr42w4bXyxya65ru8MtPT3pcL0Jt7FBdcadae6/W1WULaOuEA/3pyMQBIxpP8MtNKj8SnWaf3FqRAcSpOBbeQoEEiIxEwBBij6N6NS0020kYJAHmcz5kyfjVusdEMhYe6tIcGGuOyojZCimNccjIr6ExvfZkHo32VN4F27fUnwoDbU+agkqHwIq5OC00VZrWlCWmkDWITipxZgASTrOOKISkEkk4V3auYp04W1KQtSElSZ1FEAqTrbdUkSJjLhUJJcERrjHwpIzv2TaZShCrR/XY0g869dKaebW0VB1RMt6+9gmeOB2wTWjCIMbveqle08ofsVPtYP2pF204AdZstyThtIISoEHZEkdmKtujb0PstPpwDjaHEjxBaQofzqS44MRjud3j620v8zlSZziSe7w9fei6sf4n1/egDIMwd/I5AepyoDON4bx4+VEAIgGU5q4esPnQOQOAGw8aAEiJG5mM59RnQOU57nLz+nGjkzMdrw8qIZxjO97vrH5UAcGY7/HKPXKiGcbBvc/KhAiJ7Pi50ZyJwI3RxoAjESdzIZz6nOjIMwd/I5D1jQBMyBKs08B6j50QAiAZSdp4UBSPbDolT+j1rQCXLZabk+8lAUlY8tRalfprJrJ8KSFDYQDXo9aQRqq3cveHA15qurdNvdv2zJ61lDhDa0qCkhB7WqVT2imdUxmKAkbe2ViEOlCVElSYBxO0pndnbnjUiy0lCQlOwf/ANJJzJMn41HWq6kNeojCKbaXJOW1udZpKlVxU/XBb9WIOrrtQmm9VbSknMbeBGI+opzc3FQml3jqmNuwcycABQgueiOlCmmG1XLLjaloBbUULLbxKZTqLQlW3MQSMcDFaN0Y0sm5tW7hIKQsHsq2gpUUqB8lJI+FV7pfYG2tdDsr/uloaV/rFuoTHNWt8qlNCLS2jq04CVKHmtRWrb7yiagE5cOK1F6m9qq1f9UGPrFMXdI65Kme3qpaeSmYnW61BGJwUUSADABSJjGuF5fBI3gPPDbhTI36U62olIKjrK1QBrKMDWVG0wBjyqQRfSi8WbW7UklvWQ8IWkglstQQUzIJX1igffOGNXzoUgp0fYpVgv8ACsRlH5SMCKzTSCFXz6dHtSpThSbhSf7q3BBWVHJSgNUDOeYrY0IAGqnd2H3YyFQEKAMwN/M5H1hSNdvwn18aUQIgmEjYeNK6xfgoSJBESBCRtHH1hQOROIO6OFGZmTv5DIj1OdATJjeO8OHlQAgzHf8AFyohnGEb3vesfnQgRHczOc+oyoHKctzn5/ThQAkRMdnw86M5A4k7p4UJMz3+GUeudEM42He5eVAGAZgHtZq4j1HyprpHSDTDK7h1QQy2Cpc8uHEnAAbScKcECIO5kc59TlWL+3HpCp59GjkmA3Dr8ZqUJbQccknW4dpPCgITpX07udJFTaSpizkhLSTC3E7PzlDbPgGGOcTUXaNBICUiAK427cART5AipIHjagBFJXcc6hNIvhMq1lJPEH+YMpPyqZ6KdFdI35Cm0BDBEh54FGsMNxMy55gAYbaA4Luhxriu54VbV+ya+Mw9a4bTrO4fDq6pjtk5bXTltcABxB2idVaTilaSdoI9TQBNtOLOyBz210cshBBxqQaVQcRQEronSjukbdWin3P7Ukh+xfcMlS2ceqWo460FQCscFGZiCLDpglJLNyksXCDqrQvs9rkTkfXGqzf25wUklK0ELQobUqSZCh5EVsXQ+9tdMWqXbu2YW+z+S4FtoWQsCeyVAkIUIIy2jKoJM9u71y/dRZ2ywXHFJKlDtBpCFJUpxcbAIAjMkDaRVzZ9mtwogXOkVlB7tu0lonzcKlEDyFXzRujGbcarDLTR8DaEoSeZ1Yk/GnQzjYd/l5fXjQEb0e6PW9k31Fq2G8dZSsVKWTmpapUo457MqkgdpGCRtHGgQIg7mRzn1OVGZkE7w3Rx86AIkRJEpOwcKX1a/EKSJmRv5jIesKRqN+I+vhQC4ymT4uHr70AMthG0+KiERhuZ8Z9RQMYTu9396AE5xh4OPP1wofWdnuevtR4z7+XCPU0Qzj9f7fWgDjKcfF9qLnsjaPFQwj3PrNGcp29396AIqAGsd3w+Hn9PrXlq7vzc3T9yST1zq1idoQTCB8EgCvRvTLSAt7G6eUoJWlhzEmBrFBCAJzKigAcTXmnRSOykch/KgJq3bwro6cK6tI7NM75ZCFEbYMecVJBbvZN0VRdOrvbhAW00otMoUJSp0AazikkQoJkAbRM5pragO7OPi+1VX2XuMfwy3TbLSsIbCXonsuka7gIMEHWWo4jMVacI9z6zUEg+kbR4vX3rN/bP0YLzCb5hH5tvOskDtKYxKhz1T2gOCl1pJynb3P3+lDGTG/nwj1FAeZ9G3gWAQak6HtF6Nfw68LjKSLR8y3A7LbkSprlmpIwwMCdU1wtHwpINSiBLwpz0L09/D75LqjDD0MvzEJBPYdx2aijifCTXN1NR99a66SniIoD0zGU4+L7UX0jb73r71nHsy6fJfDej7pJQ+hASlU6wf6tOJB2hcCSDtgmcq0c5Tt7n7/SoJBOcSPDw5+uNHGUyTsV4aAmcN/PhHqKIRBjd737UAcZTBHe40XWJ/wAP6UDEY7nd4+ttLlzgKAROcR7nHnH7ZUJziZy8NGZnHfyOUepoDON7vftQBRlP6+HKf3zofSP+f9frtoYRhuZjOfUUDlP6OXn9KAE5x+j7x+1D6zn4PXwo8Z9/jlFQvSXpPbWSAXVKKlkhLKAVuuqG0NoH8zAEjGgKh7ctCvv2ba2QVpYcLjiQJK0lMa44lEnDgScqyDQxCsQZFbBc9MtJuYs2lqwgGQm5cccXGOJ6mAknbEmOdZXprondKfduE/h0FaisobW7GscTqlQnEyYJzrk760+S/dy9CWQnA1GXuAM1CKdukdhReTOyXQR5BRSflNH+F1hDqlqJHeWpUHlNW72LI7tmwewayUGbq4khDjjaEbQlfUpVrFPHFzVkTuRlWpTnH6PvH7Vnnsi6UpeZFg6kJetm0dWU4JcaHYC42hQOqFczI2wNExn3+OUVcqF9Zz8H9PpsoRlMe/x5T++VAZxs7/Py+tAxGO5kM59TQEF07DR0fdKeaStCWVq6pUgLKUkpMiCIVBkYiKwDo6odUkTJjGvTbiJ7KwCSCBOIg4QRsOdZD7Vui+jbVpK2WyzdOuJCUtKWlKkpILh1ArVQkIzSBiU8aAgG2dYUwvtVvFakpHvED5TVcuEwY691I2QXCB8J20TWi7fFS1E/6lgfURXOd0Y8l41uRYuiF+0rSdm4rWS0l2Os1TCnCClCeISVEAqOFej/AKz/AMP6fTZXl+3vGddpMkMh1vXWlBUlCUrSrsgDtKMQAONbBcdJr+5k24bsmVd51PW3Kp73VE9W1ngrWP8AKqwtysy2JlXh4juaBGUx7/HlP75UJziI7virMnk3IH/xK8n/ANCJ/wBPVYeVHY9N7q1M3h/EsDa8hAQ80PE42nsuIGZSARiYNSr4N4yHVJLJpk5xPu+H15Z0Or/zfr+9ItXw4lK2lJVrJCgsGUqSoAgpOwggg0es3wP1/rXU5igMpkZq4evvQ5HADYfFQBESNzMZk+ooE4AnYd0cPOgDnOMfDx50Q5Yzt931j8qODMd/I5R6nKiGcZb/AD8vrwoBLqwlJkwhIKivyxNY9oV8vqXpB3F64JKZx6pify2kcBqwTG0nGa2B9tKkKCh+WoFJTniIP3zrz/Z6TFotVjcOJS5bqLWtMIUlB7KgqYHZKcCZFZer1aP4/M7UY1blxdeqHv3q4q0ik4haT8QaYXN2DmPnXl7m1DK8QFSCJBqHeRFSN5pBtG8tI+In5bagrm8UvcGqPGvARxAO341p6eMs+xzsksFy9l90E6Wt06wBU2+kidoKAQPmkn4VvpUIjW7Pi+1eZOhTf9paeRJS0ouLcPeVqqSEpJ27Ts2AVqZ6TEj3eHOvUXBhfJoqrhOZiNg8Xr70n8WJkYnw8Of8vnWejTyszj3eVd29NmdvazPL1FSVL2LhOwGQdquFZT7aVS/Znu9W+kHInWZVt4wD8qsbemhlu5jjVY9pz5esgQTqtuocMYqSgayVEYHZrSeQNAZs7txpdvat7dRH+0f0pm4VjtBSXByABI5EGCaeaPeC90+YzHmMqxXprLNlTTLNoi1TKXCJ1R2RklR2q84wHDHjVlt707DVVsLrVEGpVi7TWHLNGCeVc4U2UZ20zF4K5P6QCQSSAAJPIDM0zkjBefZS6TZuMkwm3uXWWzOOp2XEpk8A6R5AVdesV4Kpfsvty3YpdcH/AHLi7mMx1pGpP/ppRV16tzxD18K9mOcLJ5z52EkmZO/kOI9TQGZGJO8OFAgg6pMqOw8PWPzoATIGBG8eNWICgRHczPP1FA5Tlue95/T50JEa0dnw86Bwicdbd931I+VAHJme/wAOVYn0s9nt42++6w0m7YddW8QCkOtlwlSgpC8FwcAUmfKtsgzqz2vFyogZkjADeHGqygpLDLRk4vKPMT+h9Q/mWL7Z4Kt3B8oTB+FcV2bIwNs4PNlwf+NeoyoAaxHZOATw9QfnXN21BMKxUdh4Vx+HXq/qX75+iPMtvo9ajFvZrnxKR1aRPvKxPwp/a9EXFELf7fupBCAec4q+NehP4agkgASNp40n+GtRrao1c08/RFdIVRjuVlZKRjidGrw7MAbvr5V2TYuTsM8K1w6KawlIOtu+76kfKi/g7c6sdrxcq6FDKUWaxkefKj6hWyDGR9fGtU/hDZkgQBvc6SdDtRrFPZOwcPUH50IMvCV5gzkKWkr4Y5itOOhGwdUiSdh4UX8DbJgCCNp40BjOluirb3abHVLEnXQkQSclpEaw2c6ql/olbJm5bUjIPInUPksbu3YqK9IJ0M1GsE9kbRxPoj5UpWhmoxSCFbBwnj86pOCkXjNxPObankjsqQ6Mp7Cv9wlJ84FPLfSChtt3Z5dWofPWrX9IezDR7kpS2WXD32FFuP0DsH4pqtueya4BV1V+kpGTrAkfqQvtbOArJLpZeWH9jQr17/kpi9LuR2bZc++ptA/mT9Kkehmi1X12pu4ALTbYd6tBOqtRWEpS6oiVDBRgQOyJmp8+yu7jWN6zB4MrJ/8Acq7dDOhzej0rSHFOvPFJW6oBO4CEhKBuJEqMST2jjVqencZZkkVstTWE2TdmyU4gdrMcB6iu3Vt+I+vhSwCTqjBQ2njSOuR4K2Gc/9k=';
    insert into driver_image
                (driver_id, image)
           values   
                (5, image_clob);                                    
end;

insert into parking
                (parking_id, number_parking, address_id)
       values   
                (5, 999, 1);

insert into car
                (car_id, brand, model_car, color, is_reservd, state_number, parking_id, millage)
       values   
                (5, 'Ниссан', 'Альмеко', 'Gray', 'False', 'в333от48rus', 3, 666333);
                
insert into rent
                (rent_id, driver_id, car_id, data_start, data_stop, gas_mileage, distance)
       values   
                (3, 4, 3, '01.01.22', '10.02.22', 345, 3456);

insert into refuelling
                (refuelling_id, driver_id, address_id, car_id, payment_id, amount_of_gasoline)
       values   
                (3, 3, 1, 5, 7, 342);

insert into payment
                (payment_id, currency_id, amount_to_paid, type_payment)
       values   
                (10, 1, 36, 'CARD');

insert into order_taxi
                (order_taxi_id, passenger_id, driver_id, time_start, time_end, payment_id, end_trip_address_id)
       values   
                (48, 2, 2, '20.12.21', '21.12.21', 241, 21);
commit;

insert into rating_passenger2driver
                (rating_id, passenger_id, driver_id, order_taxi_id, rating)
       values   
                (22, 2, 52, 316, 5);
              
insert into rating_driver2passenger
                (rating_id, passenger_id, driver_id, order_taxi_id, rating, time_creat)
       values   (81, 181, 1, 310, 5, '15.11.21');             
insert into rating_driver2passenger
                (rating_id, passenger_id, driver_id, order_taxi_id, rating, time_creat)
       values   (82, 181, 1, 312, 4, '15.12.21');
insert into rating_driver2passenger
                (rating_id, passenger_id, driver_id, order_taxi_id, rating, time_creat)
       values   (83, 182, 1, 313, 3, '15.11.21');             
insert into rating_driver2passenger
                (rating_id, passenger_id, driver_id, order_taxi_id, rating, time_creat)
       values   (84, 182, 1, 314, 3, '15.12.21');
insert into rating_driver2passenger
                (rating_id, passenger_id, driver_id, order_taxi_id, rating, time_creat)
       values   (85, 182, 1, 315, 2, '15.01.22');             
insert into rating_driver2passenger
                (rating_id, passenger_id, driver_id, order_taxi_id, rating, time_creat)
       values   (86, 185, 1, 316, 4, '15.11.21'); 
insert into rating_driver2passenger
                (rating_id, passenger_id, driver_id, order_taxi_id, rating, time_creat)
       values   (87, 185, 1, 317, 5, '15.12.21');             
insert into rating_driver2passenger
                (rating_id, passenger_id, driver_id, order_taxi_id, rating, time_creat)
       values   (88, 185, 1, 318, 4, '15.01.22');
insert into rating_driver2passenger
                (rating_id, passenger_id, driver_id, order_taxi_id, rating, time_creat)
       values   (89, 185, 1, 319, 2, '15.02.22');
commit;               





insert into status
                (order_taxi_id, status)
       values   
                (5, 'TRIP_COMPLETED');

insert into way
                (way_id, order_taxi_id, from_address, to_address, distance, preview_way_id)
       values   
                (9, 5, 5, 2, 33333, 8);

--- БЛОК исправлений названий, типов и ограничений колонок и таблиц
alter table driver rename column pesent_of_payment to percent_of_payment;

alter table car drop column is_reservd;  
alter table car modify is_reservd CHAR(5) CHECK (is_reservd in('False', 'True'));
alter table car add is_reservd CHAR(5) NOT NULL CHECK (is_reservd in('False', 'True'));
update car set state_number = 'к348нп48rus' where car_id = 1;
delete from status;                                     
alter table status drop column status;
alter table status add status CHAR(14) CHECK (status in('SEARTH_DRIVER', 'WAIT_DRIVER', 'WAIT_PASSENGER',
                                                        'TRIP_STARTED', 'WAIT_PAYMENT', 'TRIP_COMPLETED', 'CANCELD'));
delete from way;
alter table way drop column order_taxi_id;
alter table way add (order_taxi_id INT NOT NULL, FOREIGN KEY (order_taxi_id) REFERENCES order_taxi);
delete from way;

alter table order_taxi modify payment_id INT NULL;
alter table order_taxi modify time_start TIMESTAMP NULL; -- Обеспечивает создание заказа с условием что его выполнение ещё не началось и соответвенно время начала выполнения заказа ещё не зафиксировано

alter table refuelling add CONSTRAINT payment_unique UNIQUE (payment_id);
alter table refuelling drop CONSTRAINT address_refuelling_unique;