--- ���� ������������ �������������


-- ������������� "������ ��� ������� ��������� 5 ����� ��������� ����� � ������������ ���� 4"

create or replace view report_new_drivers
as
    WITH
        -- ������������ ������ ���������� (�����������), � ������� ����� ����������� ��������
        s_list_passenger AS
            (SELECT passenger_id
             FROM   passenger
             WHERE  is_anonymous = 0),
        
        -- ������������ ������ ��������, ������� ������� ����� 4
        s_list_driver_good_rating AS
            (SELECT d.driver_id             as driver_id,
                    dr.rating               as rating
             FROM  (SELECT *
                    FROM driver_rating
                    WHERE  rating > 4) dr
             INNER JOIN driver d
                    ON d.driver_id = dr.driver_id),
        
        -- ������������ ��������� ������� ����������� ����������� ������� ����������� ���������� � ��������� � ��������� ����� 4
        s_set_cross_passenger_driver AS
            (SELECT lp.passenger_id         as passenger_id,
                    lpd.driver_id           as driver_id
             FROM   s_list_passenger lp
             CROSS JOIN s_list_driver_good_rating lpd),
        
        -- ������������ ��������� ����������� ������� ���������� � ��������� �� ����������� �������
        s_set_real_passenger_driver AS
            (SELECT ot.passenger_id         as passenger_id,
                    ot.driver_id            as driver_id
             FROM   order_taxi ot
             LEFT OUTER JOIN passenger p
                          ON ot.passenger_id = p.passenger_id
             WHERE ot.driver_id is not null AND p.is_anonymous = 0),
             
        -- ������������ ������� ���������� � ������������� ��������� � ��������� ����� 4, � �������� ��� ��������� ��� �� ������
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
            
        -- ������������ ������� � ����������� �������� ��������� � ������������ ��������� � ����������� �������� ��� ������� ��������
        s_list_passenger_driver_good_rating_less_then_five AS
            (SELECT passenger_id,
                    name_passenger,
                    driver_id,
                    name_driver,
                    dense_rank() over (partition by name_passenger order by name_driver) as rang
             FROM s_list_passenger_driver_good_rating),
        
        -- ������������ ������ ������������ ������� ��������� �� 5 ����� ��������� � ��������� ����� 4
        s_list_recommendations AS
            (SELECT passenger_id            as ��_���������,
                    name_passenger          as ���_���������,
                    listagg(name_driver, '; ') within group (order by name_driver) "���������������   ��������"
             FROM s_list_passenger_driver_good_rating_less_then_five
             WHERE rang <= 5
             GROUP BY name_passenger, passenger_id)
           
     SELECT *
     FROM s_list_recommendations;

select *  from report_new_drivers;



-- �������������� "��� ������� ���������, � �������� ����� 10 �������,
--                � ������� �������� ��������� 5 ����� ������ ���� ������ ��� ��������� �������"

create or replace view report_frequently_visited_places
as
    WITH
        -- ������������ ������ ���������� (�����������), � ������� ����� ����������� ��������
        s_list_passenger_more_than_ten_trips AS
            (SELECT *
             FROM (SELECT passenger_id          as passenger_id,
                          count(passenger_id)   as count_order
                   FROM  order_taxi
                   GROUP BY passenger_id)
             WHERE count_order > 10),
        
        -- ������������ ������ ���������� ����������� ���� ������ � ��������� �������
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
        
        
        -- ������������ ������ ����������, � ������� ����� 10 ������� � ���������� ��� ����
        s_list_passenger_frequently_visited_places AS
            (SELECT lpmttt.passenger_id as passenger_id,
                    lfvp.address_id     as address_id
             FROM s_list_passenger_more_than_ten_trips lpmttt
             LEFT OUTER JOIN s_list_frequently_visited_places lfvp
                          ON lfvp.passenger_id = lpmttt.passenger_id),
        
        -- ������������ ������ �������� ��������� ������� ��� ������� ���������� ���������
        s_list_cont_frequently_visited_places AS
            (SELECT passenger_id         as passenger_id,
                    address_id           as address_id,
                    count(address_id)    as count_address
             FROM s_list_passenger_frequently_visited_places
             GROUP BY address_id, passenger_id),
        
        -- ������������ ����� ��� ���������� � ������ ���������� ��� �������
        s_list_name_passenger_rang_frequently_visited_places AS
            (SELECT lcrfvp.passenger_id  as ��_���������,
                    p.name_passenger     as ���_���������,
                    lcrfvp.address_id    as ��_������,
                    coun.name_country||', �.'||c.name_city||', ��.'||s.name_street||', �.'||a.house_number   as �����,
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
        
        -- ������������ ������� 5 �������� ���������� ������� ��� ������� ���������� ���������;
        SELECT *
        FROM s_list_name_passenger_rang_frequently_visited_places
        WHERE rang <= 5;
           
select * from report_frequently_visited_places;      
        
        
        

-- �������������� "� ����� ������� ����� ������� ������ �� ������ � ������
--                � ������ ����� ������ �� ��� ������, ����� ���� ������ �� ������"

create or replace view report_most_expensive_gasoline_prices
as
    WITH
        -- ��������� ������ �������� ����������� � ������ �����, ������� �� ������� ���� �������� ����� �������� ����������
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
        
        -- ��������� ������ �������� ����������� � ���������� ������ �������� ������� ����������� ����� �����
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
             
        -- ��������� ������ �������, � ������� �������������� �������� ����������� � ��������� ��� ��������
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
        
        -- ��������� �������� ������� �� ���������������� ��������
        s_city_avg_price AS
            (SELECT name_city       as name_city,
                    avg(price)      as avg_city_price
             FROM s_list_refueling_price
             GROUP BY name_city
             ORDER BY avg_city_price DESC)
              
        SELECT name_city        as �����,
               avg_city_price   as ����_��_������
        FROM s_city_avg_price;

select * from report_most_expensive_gasoline_prices;     




-- �������������� "������� ��� � ������ � ������ �������"

create or replace view report_avg_country_order_prices
as
    WITH
        -- ��������� ������ ������� � ������ �����, ������� �� ������� ���� �������� ����� ����������� ������
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
        
        -- ��������� ������ ������� ����������� � ���������� ������ �������� ������� ����������� ����� �����
        s_list_order_and_timely_rate AS
            (SELECT order_taxi_id,
                    address_id,
                    payment_id,
                    amount_to_paid,
                    currency_id,
                    max(rate_time) as time_timely_rate
             FROM s_list_order_and_all_earlier_exchange_rates
             GROUP BY order_taxi_id, address_id, payment_id, amount_to_paid, currency_id),
             
        -- ��������� ������ �������, � ������� �������������� �������� ����������� � ��������� ��� ��������
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
        
        -- ��������� �������� ������� ��� �� ������� � �������
        s_country_avg_price AS
            (SELECT name_country    as name_country,
                    avg(price)      as avg_country_price
             FROM s_list_order_price
             GROUP BY name_country
             ORDER BY avg_country_price DESC)
                
        SELECT name_country         as ������,
               avg_country_price    as ��e����_���_�_���
        FROM s_country_avg_price;

select * from report_avg_country_order_prices;     





-- �������������� "�������� �������� ��� �� ������ �� 1 �������� � ������� ������"
create or replace view report_monthly_dynamics_fares
as
    WITH
        -- ��������� ������ ������� � ������� ������ � ������������ ��������� ������ �����
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
  
        --��������� ������ ������� �� ����������, �������������� �������������������� ��������
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
        
        -- ��������� ������ ������� � ������� ����� � ������ ������ �����, ������������� �������
        -- (�������� �������� ������ ����� ����� ������ �� ����������� �������������)
        s_list_order_all_city_russia_rate AS
            (SELECT loacrmx.name_city                 as name_city,
                    loacrmx.amount_to_paid * r.rate   as price,
                    loacrmx.payment_time              as payment_time,
                    loacrmx.order_taxi_id             as order_taxi_id
             FROM   (s_list_order_all_city_russia_max_rate) loacrmx
             LEFT OUTER JOIN rate r
                          ON r.time_creat = loacrmx.time_timely_rate AND loacrmx.currency_id = r.currency2_id
             ORDER BY   name_city, payment_time),

        -- ��������� ������ ���������� �������� ���� �� ������� ���������� ������
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
        
        -- ��������� ������ ������� � �� ����������� � ����������� ������
        s_list_of_traveled_paths AS
            (SELECT order_taxi_id                   as order_taxi_id,
                    name_city                       as name_city,
                    price                           as price,
                    sum(distance)                   as way,
                    trunc(payment_time, 'MONTH')    as mm_yy_payment
             FROM   s_list_of_traveled_all_paths lotap
             GROUP BY order_taxi_id, name_city, price, payment_time, trunc(payment_time, 'MONTH')
             ORDER BY name_city, payment_time),

        -- ��������� ���������� ������ ��� ������� ��������� � ������ ������ ������
        s_list_of_monthly_price_city AS
            (SELECT name_city                       as name_city,
                    sum(price) / sum(way)           as all_month_price,
                    mm_yy_payment                   as mm_yy_payment
             FROM   s_list_of_traveled_paths
             GROUP BY name_city||mm_yy_payment, name_city, mm_yy_payment)

             SELECT  name_city                          as �����,
                     all_month_price                    as ����,
                     mm_yy_payment                      as ������
             FROM    s_list_of_monthly_price_city
             ORDER BY name_city, mm_yy_payment;
        
select * from report_monthly_dynamics_fares
where ����� = 'Lipetsk';    