--- БЛОК ФОРМИРОВАНИЯ ПРЕДСТАВЛЕНИЙ


-- ПРЕДСТАВОЕНИЕ "Подбор для каждого пассажира 5 новых водителей такси с рейтингомдля выше 4"

create or replace view report_new_drivers
as
    WITH
        -- Формирование списка пассажиров (неанонимных), к которым будут подбираться водители
        s_list_passenger AS
            (SELECT passenger_id
             FROM   passenger
             WHERE  is_anonymous = 0),
        
        -- Формирование списка водитлей, имеющих рейтинг более 4
        s_list_driver_good_rating AS
            (SELECT d.driver_id             as driver_id,
                    dr.rating               as rating
             FROM  (SELECT *
                    FROM driver_rating
                    WHERE  rating > 4) dr
             INNER JOIN driver d
                    ON d.driver_id = dr.driver_id),
        
        -- Формирование множества полного соответсвия соответсвия перечня неананимных пассажиров и водителей с рейтингом более 4
        s_set_cross_passenger_driver AS
            (SELECT lp.passenger_id         as passenger_id,
                    lpd.driver_id           as driver_id
             FROM   s_list_passenger lp
             CROSS JOIN s_list_driver_good_rating lpd),
        
        -- Формирование множества соответсвия перечня пассажиров и водителей на выполненных заказах
        s_set_real_passenger_driver AS
            (SELECT ot.passenger_id         as passenger_id,
                    ot.driver_id            as driver_id
             FROM   order_taxi ot
             LEFT OUTER JOIN passenger p
                          ON ot.passenger_id = p.passenger_id
             WHERE ot.driver_id is not null AND p.is_anonymous = 0),
             
        -- Формирование перечня пассажиров и соответвующих водителей с рейтингом более 4, с которыми эти пассажиры ещё не ездили
        s_list_passenger_driver_good_rating AS
            (SELECT lpd_id.passenger_id     as passenger_id,
                    p.name_passenger        as name_passenger,
                    lpd_id.driver_id        as driver_id,
                    d.name_driver           as name_driver
             FROM (SELECT *
                   FROM s_set_cross_passenger_driver
                        MINUS
                   SELECT *
                   FROM s_set_real_passenger_driver) lpd_id
             LEFT OUTER JOIN passenger p
                         ON lpd_id.passenger_id = p.passenger_id
             LEFT OUTER JOIN driver d
                         ON lpd_id.driver_id = d.driver_id
             ORDER BY name_passenger DESC),
            
        -- Формирование перечня с порядковыми номерами возможных к рекоменжации водителей с порядковыми номерами для каждого посажира
        s_list_passenger_driver_good_rating_less_then_five AS
            (SELECT passenger_id,
                    name_passenger,
                    driver_id,
                    name_driver,
                    dense_rank() over (partition by name_passenger order by name_driver) as rang
             FROM s_list_passenger_driver_good_rating),
        
        -- Формирования списка рекомендаций каждому пассажиру по 5 новых водителей с рейтингом более 4
        s_list_recommendations AS
            (SELECT passenger_id            as ИД_Пассажира,
                    name_passenger          as Имя_Пассажира,
                    listagg(name_driver, '; ') within group (order by name_driver) "РЕКОМЕНДОВАННЫЕ   ВОДИТЕЛИ"
             FROM s_list_passenger_driver_good_rating_less_then_five
             WHERE rang <= 5
             GROUP BY name_passenger, passenger_id)
           
     SELECT *
     FROM s_list_recommendations;

select *  from report_new_drivers;



-- ПРЕДСТАВЛЕНГИЕ "Для каждого пассажира, у которого более 10 поездок,
--                в порядке убывания подбераем 5 самых частых мест начала или окончания поездки"

create or replace view report_frequently_visited_places
as
    WITH
        -- Формирование списка пассажиров (неанонимных), к которым будут подбираться водители
        s_list_passenger_more_than_ten_trips AS
            (SELECT *
             FROM (SELECT passenger_id          as passenger_id,
                          count(passenger_id)   as count_order
                   FROM  order_taxi
                   GROUP BY passenger_id)
             WHERE count_order > 10),
        
        -- Формирование списка посещаемых пассажтрами мест начала и окончания поездок
        s_list_frequently_visited_places AS
            (SELECT passenger_id        as passenger_id,
                    end_trip_address_id as address_id
             FROM order_taxi
                UNION ALL
             SELECT ot.passenger_id     as passenger_id,
                    w.from_address      as address_id
             FROM order_taxi ot
             LEFT OUTER JOIN way w
                          ON ot.order_taxi_id = w.order_taxi_id),
        
        
        -- Формирование списка пассажиров, у которых более 10 поездок и посещаемых ими мест
        s_list_passenger_frequently_visited_places AS
            (SELECT lpmttt.passenger_id as passenger_id,
                    lfvp.address_id     as address_id
             FROM s_list_passenger_more_than_ten_trips lpmttt
             LEFT OUTER JOIN s_list_frequently_visited_places lfvp
                          ON lfvp.passenger_id = lpmttt.passenger_id),
        
        -- Формирование списка наиболее популяных адресов для каждого выбранного пассажира
        s_list_cont_frequently_visited_places AS
            (SELECT passenger_id         as passenger_id,
                    address_id           as address_id,
                    count(address_id)    as count_address
             FROM s_list_passenger_frequently_visited_places
             GROUP BY address_id, passenger_id),
        
        -- Формирование спска имён пассажиров и рангов посещаемых ими адресов
        s_list_name_passenger_rang_frequently_visited_places AS
            (SELECT lcrfvp.passenger_id  as ИД_Пассажира,
                    p.name_passenger     as Имя_Пассажира,
                    lcrfvp.address_id    as ИД_Адреса,
                    coun.name_country||', г.'||c.name_city||', ул.'||s.name_street||', д.'||a.house_number   as Адрес,
                    lcrfvp.count_address as count_address,
                    rank() over (partition by lcrfvp.passenger_id order by lcrfvp.count_address desc) as rang
             FROM s_list_cont_frequently_visited_places lcrfvp
             LEFT OUTER JOIN passenger p
                          ON lcrfvp.passenger_id = p.passenger_id
             LEFT OUTER JOIN address a
                          ON lcrfvp.address_id = a.address_id             
             LEFT OUTER JOIN street s
                          ON a.street_id = s.street_id
             LEFT OUTER JOIN city c
                          ON s.city_id = c.city_id
             LEFT OUTER JOIN country coun
                          ON c.country_id = coun.country_id)
        
        -- Формирование перечня 5 наиболее популярных адресов для каждого выбранного пассажира;
        SELECT *
        FROM s_list_name_passenger_rang_frequently_visited_places
        WHERE rang <= 5;
           
select * from report_frequently_visited_places;      
        
        
        

-- ПРЕДСТАВЛЕНГИЕ "В каких городах самые дорогие тарифы на бензин в рублях
--                с учётом курса валюты на тот момент, когда была оплата за бензин"

create or replace view report_most_expensive_gasoline_prices
as
    WITH
        -- Формируем список заправок автомобилей и курсов валют, которые по времени были известны ранее заправки автомобиля
        s_list_refuelling_and_all_earlier_exchange_rates AS
            (SELECT rf.refuelling_id        as refuelling_id,
                    rf.address_id           as address_id,
                    rf.amount_of_gasoline   as amount_of_gasoline,
                    rf.payment_id           as payment_id,
                    p.amount_to_paid        as amount_to_paid,
                    p.currency_id           as currency_id,
                    r.time_creat            as rate_time
             FROM   refuelling rf
             LEFT OUTER JOIN payment p
                         ON rf.payment_id = p.payment_id
             LEFT OUTER JOIN currency c
                         ON p.currency_id = c.currency_id
             LEFT OUTER JOIN rate r
                         ON c.currency_id = r.currency2_id and p.time_creat > r.time_creat),
        
        -- Формируем список заправок автомобилей с подходящим каждой заправке врменем регистрации курса валют
        s_list_refuelling_and_timely_rate AS
            (SELECT refuelling_id,
                    address_id,
                    amount_of_gasoline,
                    payment_id,
                    amount_to_paid,
                    currency_id,
                    max(rate_time) as time_timely_rate
             FROM s_list_refuelling_and_all_earlier_exchange_rates
             GROUP BY refuelling_id, address_id, amount_of_gasoline, payment_id, amount_to_paid, currency_id),
             
        -- Формируем список городов, в которых осуществлялась заправка автомобилей с указанием цен заправки
        s_list_refueling_price AS
            (SELECT c.name_city                                              as name_city,
                    lratr.amount_to_paid * r.rate / lratr.amount_of_gasoline as price
             FROM   s_list_refuelling_and_timely_rate lratr
             INNER JOIN rate r
                     ON r.time_creat = lratr.time_timely_rate
             LEFT OUTER JOIN address a
                          ON lratr.address_id = a.address_id
             LEFT OUTER JOIN street s
                          ON a.street_id = s.street_id
             LEFT OUTER JOIN city c
                          ON s.city_id = c.city_id),
        
        -- Формируем перечень городов со среднегородскими тарифами
        s_city_avg_price AS
            (SELECT name_city       as name_city,
                    avg(price)      as avg_city_price
             FROM s_list_refueling_price
             GROUP BY name_city
             ORDER BY avg_city_price DESC)
              
        SELECT name_city        as Город,
               avg_city_price   as Цена_на_бензин
        FROM s_city_avg_price;

select * from report_most_expensive_gasoline_prices;     




-- ПРЕДСТАВЛЕНГИЕ "Средний чек в рублях в разных странах"

create or replace view report_avg_country_order_prices
as
    WITH
        -- Формируем список заказов и курсов валют, которые по времени были известны ранее конкретного заказа
        s_list_order_and_all_earlier_exchange_rates AS
            (SELECT ot.order_taxi_id        as order_taxi_id,
                    ot.end_trip_address_id  as address_id,
                    ot.payment_id           as payment_id,
                    p.amount_to_paid        as amount_to_paid,
                    p.currency_id           as currency_id,
                    r.time_creat            as rate_time
             FROM   order_taxi ot
             LEFT OUTER JOIN payment p
                         ON ot.payment_id = p.payment_id
             LEFT OUTER JOIN currency c
                         ON p.currency_id = c.currency_id
             LEFT OUTER JOIN rate r
                         ON c.currency_id = r.currency2_id and p.time_creat > r.time_creat),
        
        -- Формируем список заказов автомобилей с подходящим каждой заправке врменем регистрации курса валют
        s_list_order_and_timely_rate AS
            (SELECT order_taxi_id,
                    address_id,
                    payment_id,
                    amount_to_paid,
                    currency_id,
                    max(rate_time) as time_timely_rate
             FROM s_list_order_and_all_earlier_exchange_rates
             GROUP BY order_taxi_id, address_id, payment_id, amount_to_paid, currency_id),
             
        -- Формируем список городов, в которых осуществлялась заправка автомобилей с указанием цен заправки
        s_list_order_price AS
            (SELECT coun.name_country                as name_country,
                    loatr.amount_to_paid * r.rate as price
             FROM   s_list_order_and_timely_rate loatr
             INNER JOIN rate r
                     ON r.time_creat = loatr.time_timely_rate
             LEFT OUTER JOIN address a
                          ON loatr.address_id = a.address_id
             LEFT OUTER JOIN street s
                          ON a.street_id = s.street_id
             LEFT OUTER JOIN city c
                          ON s.city_id = c.city_id
             LEFT OUTER JOIN country coun
                          ON c.country_id = coun.country_id),
        
        -- Формируем перечень средних цен за поездку в странах
        s_country_avg_price AS
            (SELECT name_country    as name_country,
                    avg(price)      as avg_country_price
             FROM s_list_order_price
             GROUP BY name_country
             ORDER BY avg_country_price DESC)
                
        SELECT name_country         as Страна,
               avg_country_price    as Срeдний_чек_в_руб
        FROM s_country_avg_price;

select * from report_avg_country_order_prices;     





-- ПРЕДСТАВЛЕНГИЕ "Месячная динамика цен на проезд за 1 километр в городах России"
create or replace view report_monthly_dynamics_fares
as
    WITH
        -- Формируем список заказов в городах России с подключением возможных курсов валют
        s_list_order_all_city_russia AS
            (SELECT  c.name_city                    as name_city,
                     ot.order_taxi_id               as order_taxi_id,
                     ot.end_trip_address_id         as address_id,
                     p.payment_id                   as payment_id,
                     p.time_creat                   as payment_time,
                     p.currency_id                  as currency_id,
                     p.amount_to_paid               as amount_to_paid,
                     r.time_creat                   as rate_time
                    
             FROM    order_taxi ot
             LEFT OUTER JOIN payment p
                          ON ot.payment_id = p.payment_id
             LEFT OUTER JOIN address a
                          ON ot.end_trip_address_id = a.address_id
             LEFT OUTER JOIN street s
                          ON a.street_id = s.street_id
             LEFT OUTER JOIN city c
                          ON s.city_id = c.city_id
             LEFT OUTER JOIN country coun
                          ON c.country_id = coun.country_id
             LEFT OUTER JOIN currency cr
                          ON p.currency_id = cr.currency_id
             LEFT OUTER JOIN rate r
                          ON cr.currency_id = r.currency2_id and p.time_creat > r.time_creat
             WHERE   coun.name_country = 'russia'
             ORDER BY c.name_city),
  
        --Формируем список заказов со стоимостью, соответсвующей максимамаксимальному рейтингу
        s_list_order_all_city_russia_max_rate AS
            (SELECT name_city,
                            order_taxi_id,
                            address_id,
                            payment_id,
                            amount_to_paid,
                            payment_time,
                            currency_id,
                            max(rate_time)          as time_timely_rate
                     FROM   s_list_order_all_city_russia
                     GROUP BY name_city, order_taxi_id, address_id, payment_id, amount_to_paid, payment_time, currency_id
                     ORDER BY name_city),
        
        -- Формируем список заказов в городах Росии с учётом курсов валют, соответвующих заказам
        -- (основной алгоритм выбора курса валют принят из предыдущего представления)
        s_list_order_all_city_russia_rate AS
            (SELECT loacrmx.name_city                 as name_city,
                    loacrmx.amount_to_paid * r.rate   as price,
                    loacrmx.payment_time              as payment_time,
                    loacrmx.order_taxi_id             as order_taxi_id
             FROM   (s_list_order_all_city_russia_max_rate) loacrmx
             LEFT OUTER JOIN rate r
                          ON r.time_creat = loacrmx.time_timely_rate AND loacrmx.currency_id = r.currency2_id
             ORDER BY   name_city, payment_time),

        -- Формируем список пройденных отрезков пути по каждому выбранному заказу
        s_list_of_traveled_all_paths AS
            (SELECT loacrr.name_city                as name_city,
                    loacrr.price                    as price,
                    loacrr.payment_time             as payment_time,
                    loacrr.order_taxi_id            as order_taxi_id,
                    w.way_id                        as way_id,
                    w.distance                      as distance
             FROM   s_list_order_all_city_russia_rate loacrr
             LEFT OUTER JOIN way w
                          ON loacrr.order_taxi_id = w.order_taxi_id
             ORDER BY w.order_taxi_id),
        
        -- Формируем список заказов с их стоимостями и пройденными путями
        s_list_of_traveled_paths AS
            (SELECT order_taxi_id                   as order_taxi_id,
                    name_city                       as name_city,
                    price                           as price,
                    sum(distance)                   as way,
                    trunc(payment_time, 'MONTH')    as mm_yy_payment
             FROM   s_list_of_traveled_all_paths lotap
             GROUP BY order_taxi_id, name_city, price, payment_time, trunc(payment_time, 'MONTH')
             ORDER BY name_city, payment_time),

        -- Формируем помесячный список цен каждого километра в каждом городе России
        s_list_of_monthly_price_city AS
            (SELECT name_city                       as name_city,
                    sum(price) / sum(way)           as all_month_price,
                    mm_yy_payment                   as mm_yy_payment
             FROM   s_list_of_traveled_paths
             GROUP BY name_city||mm_yy_payment, name_city, mm_yy_payment)

             SELECT  name_city                          as Город,
                     all_month_price                    as Цена,
                     mm_yy_payment                      as Период
             FROM    s_list_of_monthly_price_city
             ORDER BY name_city, mm_yy_payment;
        
select * from report_monthly_dynamics_fares
where Город = 'Lipetsk';    