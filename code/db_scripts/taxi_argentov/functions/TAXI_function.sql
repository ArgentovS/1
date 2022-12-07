------ БЛОК СОЗДАНИЯ КОНВЕЙЕРНОЙ ТАБЛИЧНОЙ ФУНКЦИИ

--- Функция РАСЧЁТА ЗАРПЛАТЫ ВОДИТЕЛЯ, созданная в пакете
create or replace package salary_driver
is

    -- Создаём типы данных, возвращаемых функцией строки (таблицы)
    type type_salary is record
            (driver_id     int,
             name_driver   varchar2(255),
             driver_salary number(38,2));

    type type_tab_salary is table of type_salary;
        
    -- Дикларируем ковейерную функцию
    function get_calculation_salary (month_salary in number,
                                     yea_salary in number) return type_tab_salary pipelined;
end salary_driver;
   
create or replace package body salary_driver   
is
    
    function get_calculation_salary (month_salary in number,
                                     yea_salary in number) return type_tab_salary pipelined
    is
    -- Создаём строку, возвращакемую конвейерной функцией 
    row_salary type_salary;
        
    -- Создаём курсор для выбора из базы данных: заказов, заправок, валют и их курса для водителей, выполнявших заказы в заданном месяце года
    cursor cur_timesheet_order_refueling
    is
    WITH
        -- Подзапрос выбора курсов валют для месяца от заданного месяца расчёта зарплаты водителей
        s_period_rate AS
            (SELECT *
             FROM   rate r
             WHERE  to_char(r.time_creat, 'mm') <= month_salary AND to_char(r.time_creat, 'yy') <= yea_salary),       
        -- Поздзапрос выбора времени регистрации наиболее актуального курса для каждой валюты
        s_most_rate AS
            (SELECT     max(time_creat)     as most_up2date_rating,
                        currency2_id
             FROM       s_period_rate       
             GROUP BY   currency2_id),        
        -- Поздзапрос выбора платежей за последний месяц
        s_payment_month AS
            (SELECT p.payment_id            as payment_id,
                    p.currency_id           as currency_id,
                    p.amount_to_paid        as amount_to_paid,
                    p.time_creat            as time_creat,
                    r.rate                  as rate,
                    mr.most_up2date_rating  as most_up2date_rating      
             FROM   payment p
             LEFT OUTER JOIN s_most_rate mr -- присоединнеие врмени регистрации наиболее актуального курса валют (см. выше)
                     ON mr.currency2_id = p.currency_id
             LEFT OUTER JOIN rate r -- присоединнеие наиболее актуального курса валют (см. выше)
                     ON r.currency2_id = mr.currency2_id AND r.time_creat = mr.most_up2date_rating       
             WHERE  to_char((p.time_creat), 'mm') = month_salary AND to_char((p.time_creat), 'yy') = yea_salary),         
         -- Подзапрос выбора информации о водителе    
         s_driver AS
            (SELECT driver_id,
                    name_driver,
                    percent_of_payment
             FROM   driver),      
        -- Подзапрос формирования списка водителей, выполнявших заказы в заданном месяце    
        s_driver_order AS
            (SELECT d.driver_id                       as driver_id,
                    d.name_driver                     as name_driver,
                    d.percent_of_payment              as percent_of_payment,
                    sum(pm.amount_to_paid * pm.rate)  as driver_income
             FROM   s_payment_month pm
             LEFT OUTER JOIN order_taxi ot
                     ON pm.payment_id = ot.payment_id -- опредление платежей за заказы
             INNER JOIN s_driver d
                     ON d.driver_id = ot.driver_id -- присоединение данных о водителях, выполнявших заказы
             GROUP BY d.driver_id, d.name_driver, d.percent_of_payment),
        -- Подзапрос формирования списка водителей, заправивших автомобиль в заданном месяце    
        s_driver_refulling AS
            (SELECT d.driver_id                      as driver_id,
                    d.name_driver                    as name_driver,
                    d.percent_of_payment             as percent_of_payment,
                    sum(pm.amount_to_paid * pm.rate) as driver_expenses
             FROM   s_payment_month pm
             LEFT OUTER JOIN refuelling rf
                     ON pm.payment_id = rf.payment_id -- опредление платежей за заправку
             INNER JOIN s_driver d
                     ON d.driver_id = rf.driver_id -- присоединение данных о водителях, выполнявших заказы
             GROUP BY d.driver_id, d.name_driver, d.percent_of_payment),
        -- Табель для расчёта заработной платы водителя
        s_driver_salary AS
            (SELECT sdo.driver_id           as order_driver_id,
                    sdo.name_driver         as order_name_driver,
                    sdo.driver_income       as driver_income,
                    sdo.percent_of_payment  as order_percent_of_payment,
                    sdr.driver_id           as refueling_driver_id,
                    sdr.name_driver         as refueling_name_driver,
                    sdr.driver_expenses     as driver_expenses,
                    sdr.percent_of_payment  as refueling_percent_of_payment        
             FROM s_driver_order sdo
             FULL OUTER JOIN s_driver_refulling sdr
                     ON sdo.driver_id = sdr.driver_id)
                    
             SELECT *
             FROM s_driver_salary;
 
    begin
        -- Заполняем коллекцию из базы данных для конвейерной функции с неявным курсором
        for rec in cur_timesheet_order_refueling
        loop
            row_salary := null;
            
            -- Считаем зарплату для трёх возможных ситуаций
                if
                    rec.order_driver_id is not null
                    AND rec.refueling_driver_id is not null
                then -- Расчёт зарплаты в ситуации когда у водителя в текущем месяце были и оплаченные заказы и оплаченные заправки
                    row_salary.driver_id := rec.order_driver_id;
                    row_salary.name_driver := rec.order_name_driver;
                    row_salary.driver_salary := rec.order_driver_id * (rec.driver_income - rec.driver_expenses);
                elsif -- Расчёт зарплаты в ситуации когда у водителя в текущем месяце были только оплаченные заказы, но не было оплаченных заправок
                    rec.order_driver_id is not null then
                    row_salary.driver_id := rec.order_driver_id;
                    row_salary.name_driver := rec.order_name_driver;
                    row_salary.driver_salary := rec.order_driver_id * (rec.driver_income);
                else -- Расчёт зарплаты в ситуации когда у водителя в текущем месяце не было оплаченных заказов,но были оплаченные заправки
                    row_salary.driver_id := rec.refueling_driver_id;
                    row_salary.name_driver := rec.refueling_name_driver;
                    row_salary.driver_salary := rec.refueling_driver_id * (- rec.driver_expenses);
                end if;
            
            pipe row (row_salary);
            
        end loop;
        return;
    end get_calculation_salary;     
end salary_driver;
    

select *
from table(salary_driver.get_calculation_salary('01', '22'));
-- where driver_salary > 0;


