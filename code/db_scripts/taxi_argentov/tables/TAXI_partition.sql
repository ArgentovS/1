-- БЛОК секционирования таблиц и индексирования полей

-- Секционирование таблиц с одним используемым полем
-- Индескация полей не требуется так как все поля первичного ключа уже имеют индексы

-- Позиции 1, 2, 3 таблицы 3
alter table car modify partition by hash (car_id)
(partition p1, partition p2, partition p3, partition p4);

alter table passenger_rating modify partition by hash (passenger_id)
(partition p1, partition p2, partition p3, partition p4);

alter table driver modify partition by hash (driver_id)
(partition p1, partition p2, partition p3, partition p4);



-- Секционирование таблиц с двумя используемыми полями (секция + подсекция)

-- Позиция 4 таблицы 3
create table a as select * from rent;
alter table a rename to rent;


ALTER TABLE rent MODIFY
PARTITION BY HASH (car_id)
subPARTITION BY RANGE (data_stop)
(
     PARTITION hp_1
        (
         subPARTITION sp_1 VALUES LESS THAN (TO_DATE('31.12.2021', 'DD.MM.YYYY')),
         subPARTITION sp_2 VALUES LESS THAN (TO_DATE('31.12.2022', 'DD.MM.YYYY'))
         ),
     PARTITION hp_2
        (
         subPARTITION sp_3 VALUES LESS THAN (TO_DATE('31.12.2021', 'DD.MM.YYYY')),
         subPARTITION sp_4 VALUES LESS THAN (TO_DATE('31.12.2022', 'DD.MM.YYYY'))
         )
);
CREATE INDEX data_stop_ix ON rent(data_stop) LOCAL;

-- позиция 5 таблицы 3
ALTER TABLE currency MODIFY
PARTITION BY HASH (currency_id)
subPARTITION BY LIST (abbreviation)
(
     PARTITION hp_1
        (
         subPARTITION sp1_1 VALUES ('RUB'),
         subPARTITION sp1_2 VALUES ('CAD'),
         subPARTITION sp1_3 VALUES ('BYN'),
         subPARTITION sp1_4 VALUES ('PLN'),
         subPARTITION sp1_5 VALUES ('CNY')
         ),
     PARTITION hp_2
        (
         subPARTITION sp2_1 VALUES ('RUB'),
         subPARTITION sp2_2 VALUES ('CAD'),
         subPARTITION sp2_3 VALUES ('BYN'),
         subPARTITION sp2_4 VALUES ('PLN'),
         subPARTITION sp2_5 VALUES ('CNY')
         )
);
CREATE INDEX abbreviation_ix ON currency(abbreviation) LOCAL;

-- позиция 6 таблицы 3
ALTER TABLE rating_driver2passenger MODIFY
PARTITION BY HASH (passenger_id)
subPARTITION BY RANGE (time_creat)
(
     PARTITION hp_1
        (
         subPARTITION sp_1 VALUES LESS THAN (TO_DATE('31.12.2021', 'DD.MM.YYYY')),
         subPARTITION sp_2 VALUES LESS THAN (TO_DATE('31.12.2022', 'DD.MM.YYYY'))
         ),
     PARTITION hp_2
        (
         subPARTITION sp_3 VALUES LESS THAN (TO_DATE('31.12.2021', 'DD.MM.YYYY')),
         subPARTITION sp_4 VALUES LESS THAN (TO_DATE('31.12.2022', 'DD.MM.YYYY'))
         )
);
CREATE INDEX time_creat_ix ON rating_driver2passenger(time_creat) LOCAL;

-- позиция 7 таблицы 3
ALTER TABLE rating_passenger2driver MODIFY
PARTITION BY RANGE (time_creat) INTERVAL (NUMTODSINTERVAL(1, 'DAY'))
subPARTITION BY HASH (driver_id) subPARTITIONS 8
(
    PARTITION sp0 VALUES LESS THAN (TO_DATE('31.12.2022', 'DD.MM.YYYY'))
);
CREATE INDEX time_creat_p2d__ix ON rating_passenger2driver(time_creat) LOCAL;


-- позиция 8 таблицы 3
ALTER TABLE driver_rating MODIFY
PARTITION BY HASH (driver_id)
subPARTITION BY HASH (rating) subPARTITIONS 16 PARTITIONS 8;
CREATE INDEX rating_driver_ix ON driver_rating(rating) LOCAL;


-- позиция 9 таблицы 3
ALTER TABLE rate MODIFY
PARTITION BY RANGE (time_creat) INTERVAL (NUMTODSINTERVAL(1, 'DAY'))
subPARTITION BY HASH (currency2_id) subPARTITIONS 8
(
    PARTITION sp0 VALUES LESS THAN (TO_DATE('31.12.2022', 'DD.MM.YYYY'))
);
CREATE INDEX time_creat_rate__ix ON rate(time_creat) LOCAL;


-- позиция 10 таблицы 3
ALTER TABLE way MODIFY
PARTITION BY HASH (order_taxi_id)
subPARTITION BY HASH (preview_way_id) subPARTITIONS 16 PARTITIONS 8;


-- позиция 11 таблицы 3
ALTER TABLE refuelling MODIFY
PARTITION BY HASH (payment_id)
subPARTITION BY HASH (driver_id) subPARTITIONS 16 PARTITIONS 8;


-- позиция 12 таблицы 3
ALTER TABLE passenger MODIFY
PARTITION BY HASH (passenger_id)
subPARTITION BY LIST (is_anonymous)
(
     PARTITION hp_1
        (
         subPARTITION sp1_1 VALUES ('0'),
         subPARTITION sp1_2 VALUES ('1')
         ),
     PARTITION hp_2
        (
         subPARTITION sp2_1 VALUES ('0'),
         subPARTITION sp2_2 VALUES ('1')
         )
);
CREATE INDEX is_anonymous_ix ON passenger(is_anonymous) LOCAL;


-- позиция 13 таблицы 3
ALTER TABLE address MODIFY
PARTITION BY HASH (address_id)
subPARTITION BY HASH (street_id) subPARTITIONS 16 PARTITIONS 8;


-- позиция 14 таблицы 3
ALTER TABLE street MODIFY
PARTITION BY HASH (street_id)
subPARTITION BY HASH (city_id) subPARTITIONS 16 PARTITIONS 8;


-- позиция 15 таблицы 3
ALTER TABLE payment MODIFY
PARTITION BY RANGE (time_creat) INTERVAL (NUMTODSINTERVAL(1, 'DAY'))
subPARTITION BY HASH (currency_id) subPARTITIONS 8
(
    PARTITION sp0 VALUES LESS THAN (TO_DATE('31.12.2022', 'DD.MM.YYYY'))
);
CREATE INDEX time_creat_payment_ix ON payment(time_creat) LOCAL;


-- позиция 16 таблицы 3
ALTER TABLE city MODIFY
PARTITION BY HASH (city_id)
subPARTITION BY HASH (country_id) subPARTITIONS 16 PARTITIONS 8;


-- позиция 17 таблицы 3
ALTER TABLE country MODIFY
PARTITION BY HASH (country_id)
subPARTITION BY HASH (name_country) subPARTITIONS 16 PARTITIONS 8;
CREATE INDEX time_creat_country_ix ON country(time_creat) LOCAL;


-- позиция 18 таблицы 3
ALTER TABLE order_taxi MODIFY
PARTITION BY HASH (driver_id)
subPARTITION BY HASH (payment_id) subPARTITIONS 16 PARTITIONS 8;




