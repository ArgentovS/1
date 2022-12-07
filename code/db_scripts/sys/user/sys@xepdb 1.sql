create user taxi_argentov
    identified by taxi
    default tablespace users
    quota 100M on users
    temporary tablespace temp;

grant create session to taxi_argentov;

grant create table to taxi_argentov;
grant create procedure to taxi_argentov;
grant create trigger to taxi_argentov;
grant create view to taxi_argentov;
grant create sequence to taxi_argentov;
grant create type to taxi_argentov;

grant alter any table to taxi_argentov;
grant alter any procedure to taxi_argentov;
grant alter any trigger to taxi_argentov;
grant alter any type to taxi_argentov;

grant delete any table to taxi_argentov;

grant drop any table to taxi_argentov;
grant drop any procedure to taxi_argentov;
grant drop any trigger to taxi_argentov;
grant drop any view to taxi_argentov;
grant drop any type to taxi_argentov;


grant insert any table to taxi_argentov;
grant update any table to taxi_argentov;
grant delete any table to taxi_argentov;

drop user taxi_argentov;

select * from ROLE_SYS_PRIVS
where PRIVILEGE LIKE '%INSERT%';