------ БЛОК СОЗДАНИЯ ПРОЦЕДУР

--- Процедура БРОНИРОВАНИЯ АВТОМОБИЛЯ
drop sequence rent_sequence_1;
-- Добавление последовательности и соответствующего тригера автоинкрементируемого первичного ключа
create sequence rent_sequence_1
    increment by 1
    start with 700; -- Множжество автоидентификаторов создаётся со значениями 100 и более
                    -- для отделения от мнеожества идентификаторов тестовых данных    
create or replace trigger trigger_rent_id_sequence_1
    before insert on rent
    for each row
    begin
        :new.rent_id := rent_sequence_1.nextval;
    end; 

-- Добавление процедуры бронирования автомобиля
create or replace procedure car_booking (var_id_driver int, var_id_car int)
    is
        var_is_reservd char(5);
    begin
        SELECT  is_reservd
        INTO    var_is_reservd
        FROM    car c
        WHERE   c.car_id = var_id_car;
        
        if var_is_reservd = 'False' then
            insert into rent (driver_id, car_id, data_start)
                values (var_id_driver, var_id_car, to_date(SYSDATE));
            update car
                set is_reservd = 'True'
                where car_id = var_id_car;
            commit;
        end if;
    end;
    
begin
    car_booking (1, 3);
end;



--- Процедура СНЯТИЯ АВТОМОБИЛЯ С БРОНИРОВАНИЯ
 
-- Добавление процедуры снятия автомобиля с бронирования
create or replace procedure car_unbooking (var_id_car int, var_gas_mileage number, var_distance number)
    is
    begin
        update rent
            set data_stop = to_date(SYSDATE), gas_mileage = var_gas_mileage, distance = var_distance
            where car_id = var_id_car;
        update car
            set is_reservd = 'False'
            where car_id = var_id_car;
        commit;
    end;
    
begin
    car_unbooking (1, 111, 222);
end;
SELECT *
FROM RENT;


--- Процедура ЗАПРАВКИ АВТОМОБИЛЯ

-- Добавление последовательностей и соответствующих тригеров автоинкрементируемого первичного ключа
create sequence refuelling_sequence
    increment by 1
    start with 100; -- Множжество автоидентификаторов создаётся со значениями 100 и более
                    -- для отделения от мнеожества идентификаторов тестовых данных    
create or replace trigger trigger_refuelling_id_sequence
    before insert on refuelling
    for each row
    begin
        :new.refuelling_id := refuelling_sequence.nextval;
    end;

create sequence payment_sequence
    increment by 1
    start with 100; -- Множжество автоидентификаторов создаётся со значениями 100 и более
                    -- для отделения от мнеожества идентификаторов тестовых данных    
create or replace trigger trigger_payment_id_sequence
    before insert on payment
    for each row
    begin
        :new.payment_id := payment_sequence.nextval;
    end;

-- Добавление процедуры заправки автомобиля
-- (добавлен дополнительный входной параметр для возможности указания адреса заправочной станции,
--  на которой заправляется автомобиль: var_address_id)
create or replace procedure car_refuelling (var_address_id  int, var_car_id int, var_amount_to_paid number,
                                            var_abbreviation varchar2, var_type_payment char,
                                            var_amount_of_gasoline number)
    is
        var_driver_id   int;
        var_currency_id int;
        var_payment_id  int;
    begin
        SELECT  driver_id
        INTO    var_driver_id
        FROM    rent r
        WHERE   r.car_id = var_car_id AND r.data_stop is NULL;
        
        SELECT  currency_id
        INTO    var_currency_id
        FROM    currency c
        WHERE   c.abbreviation = var_abbreviation;
        
        dbms_output.put_line('ИД_Машины: '||var_car_id);
        dbms_output.put_line('ИД_Водителя: '||var_driver_id);
        dbms_output.put_line('Сумма платежа: '||var_amount_to_paid);
        dbms_output.put_line('Валюта платежа: '||var_abbreviation);
        dbms_output.put_line('ИД_Валюты: '||var_currency_id);
        dbms_output.put_line('Тип платежа: '||var_type_payment);
        dbms_output.put_line('Количест во бензина: '||var_amount_of_gasoline);
        
        insert into payment (amount_to_paid, currency_id, type_payment)
            values (var_amount_to_paid, var_currency_id, var_type_payment)
            returning payment_id into var_payment_id;
        
        dbms_output.put_line('ИД_Платежа: '||var_payment_id);
        dbms_output.put_line('ИД_Адреса заправочной станции: '||var_address_id);
        
        insert into refuelling (driver_id, payment_id, address_id, amount_of_gasoline, car_id)
            values (var_driver_id, var_payment_id, var_address_id, var_amount_of_gasoline, var_car_id);
        commit;
    end;
    
begin
    car_refuelling (1, 5, 72.36, 'CAD', 'CARD', 54.36);
end;


--- Процедура СОЗДАНИЯ ЗАКАЗА

-- Добавление последовательностей и соответствующих тригеров автоинкрементируемого первичного ключа
create sequence order_taxi_sequence
    increment by 1
    start with 100; -- Множжество автоидентификаторов создаётся со значениями 100 и более
                    -- для отделения от мнеожества идентификаторов тестовых данных    
create or replace trigger trigger_order_taxi_id_sequence
    before insert on order_taxi
    for each row
    begin
        :new.order_taxi_id := order_taxi_sequence.nextval;
    end;

create sequence way_sequence
    increment by 1
    start with 100; -- Множжество автоидентификаторов создаётся со значениями 100 и более
                    -- для отделения от мнеожества идентификаторов тестовых данных    
create or replace trigger trigger_way_id_sequence
    before insert on way
    for each row
    begin
        :new.way_id := way_sequence.nextval;
    end;
    

-- Добавление процедуры создания заказа

create or replace type mytype_varray is varray(21) of number;

create or replace procedure create_order_taxi (var_passenger_id int, var_from_address int,
                                               var_way_varray mytype_varray, var_distance_varray mytype_varray,
                                               var_amount_to_paid number, var_abbreviation varchar2, var_type_payment char)
    is
        var_status char(14) default 'SEARTH_DRIVER'; -- Стартовый статус созданного заказа
        var_currency_id int;
        var_payment_id int;
        var_order_taxi_id int;
        var_to_address int;
        var_distance number;
        var_point_order int;
        var_preview_way_id int;
   
    begin
        
        SELECT  currency_id
        INTO    var_currency_id
        FROM    currency c
        WHERE   c.abbreviation = var_abbreviation;
        insert into payment (amount_to_paid, currency_id, type_payment)
            values (var_amount_to_paid, var_currency_id, var_type_payment)
            returning payment_id into var_payment_id;     
        dbms_output.put_line('ИД_Платежа: '||var_payment_id);
        dbms_output.put_line('Сумма платежа: '||var_amount_to_paid);
        dbms_output.put_line('Валюта платежа: '||var_abbreviation);
        dbms_output.put_line('ИД_Валюты: '||var_currency_id);
        dbms_output.put_line('Тип платежа: '||var_type_payment);
 
        insert into order_taxi (passenger_id, payment_id, end_trip_address_id)
            values (var_passenger_id, var_payment_id, var_way_varray(var_way_varray.count))
            returning order_taxi_id into var_order_taxi_id;    
        dbms_output.put_line('ИД_Пассажира: '||var_passenger_id);
        dbms_output.put_line('ИД_Адреса: '||var_from_address); 
        dbms_output.put_line('Точка окончания заказа: '||var_way_varray(var_way_varray.count));
        
        insert into way (order_taxi_id, from_address, to_address, distance)
            values (var_order_taxi_id, var_from_address, var_way_varray(1), var_distance_varray(1));
        dbms_output.put_line('Начальная точка: '||var_from_address);
        dbms_output.put_line('Следующая точка: '||var_way_varray(1));
        dbms_output.put_line('Расстояние до точки: '||var_distance_varray(1));
        for var_point_order in 1..(var_way_varray.count - 1) loop
            var_preview_way_id := way_sequence.currval;
            insert into way (order_taxi_id,
                        from_address,
                        to_address,
                        distance,
                        preview_way_id)
                values (var_order_taxi_id,
                        var_way_varray(var_point_order),
                        var_way_varray(var_point_order + 1),
                        var_distance_varray(var_point_order + 1),
                        var_preview_way_id);
            dbms_output.put_line('Следующая точка: '||var_way_varray(var_point_order + 1));
            dbms_output.put_line('Расстояние до точки: '||var_distance_varray(var_point_order + 1));
        end loop;
          
        insert into status (order_taxi_id, status)
            values (var_order_taxi_id, var_status);
        dbms_output.put_line('ИД_Статуса заказа: '||var_order_taxi_id);
        dbms_output.put_line('Статус заказа: '||var_status);
        
    end;

begin
    create_order_taxi (4, 2, mytype_varray(2, 5, 3, 4, 5, 2), mytype_varray (4, 6, 9, 34, 345, 333), 54, 'CAD', 'CASH');
end;


--- Процедуры РАСЧЁТА РЕЙТИНГОВ

-- Добавление процедуры расчёта рейтинга пассажира

create or replace procedure calculation_rating_passenger (var_day int)
    is
        cursor cur_list_avg_rating
            is
            SELECT passenger_id as passenger_id,
                   avg(rating)  as avg_rating
            FROM   rating_driver2passenger
            WHERE  time_creat > SYSDATE - var_day
            GROUP BY passenger_id;
    begin
        delete from passenger_rating;
        for another_passenger in cur_list_avg_rating
        loop
            insert into passenger_rating (passenger_id, rating)
                 values (another_passenger.passenger_id, another_passenger.avg_rating);
            commit;
        end loop;
    end;
begin
    calculation_rating_passenger (180);
end;


-- Добавление процедуры расчёта рейтинга водителя

create or replace procedure calculation_rating_driver (var_day int)
    is
        cursor cur_list_avg_rating
            is
            SELECT driver_id as driver_id,
                   avg(rating)  as avg_rating
            FROM   rating_passenger2driver
            WHERE  time_creat > SYSDATE - var_day
            GROUP BY driver_id;
    begin
        delete from driver_rating;
        for another_driver in cur_list_avg_rating
        loop
            insert into driver_rating (driver_id, rating)
                 values (another_driver.driver_id, another_driver.avg_rating);
            commit;
        end loop;
    end;

begin
    calculation_rating_driver (180);
end;


