-- create tables
create table collegas (
    id                             number not null constraint collegas_id_pk primary key,
    voornaam                       varchar2(100),
    achternaam                     varchar2(100),
    bedrijf                        varchar2(100),
    registratie_datum              timestamp default on null SYSTIMESTAMP
)
;

create table sessions (
    id                             number not null constraint sessions_id_pk primary key,
    titel                          varchar2(200),
    sprekers                       varchar2(200),
    beschrijving                   varchar2(4000)
)
;

create table likes (
    id                             number not null constraint likes_id_pk primary key,
    collegas_id                    number
                                   constraint likes_collegas_id_fk
                                   references collegas on delete cascade,
    sessions_id                    number
                                   constraint likes_sessions_id_fk
                                   references sessions on delete cascade,
    the_like                       varchar2(2)
)
;


-- triggers
create or replace trigger collegas_biu
    before insert or update 
    on collegas
    for each row
begin
    if :new.id is null then
        :new.id := to_number(sys_guid(), 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');
    end if;
end collegas_biu;
/

create or replace trigger sessions_biu
    before insert or update 
    on sessions
    for each row
begin
    if :new.id is null then
        :new.id := to_number(sys_guid(), 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');
    end if;
end sessions_biu;
/

create or replace trigger likes_biu
    before insert or update 
    on likes
    for each row
begin
    if :new.id is null then
        :new.id := to_number(sys_guid(), 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');
    end if;
end likes_biu;
/


-- indexes
create index likes_i1 on likes (collegas_id);
create index likes_i2 on likes (sessions_id);
-- load data
 
-- Generated by Quick SQL Sunday February 03, 2019  16:06:12
 
/*
collegas
   voornaam vc100
   achternaam vc100
   bedrijf vc100
   registratie_datum ts /default systimestamp

sessions
  id  /pk
  titel vc200
  sprekers vc200
  beschrijving vc4000

likes
  collegas id
  like vc2
  sessions id

# settings = { PK: "TRIG", language: "EN", APEX: true }
*/


create or replace 
view v_sessie_likes
as
select l.id
,      l.the_like
,      case l.the_like when 'Y' then 'fa fa-thumbs-up fa-3x' 
       else 'fa fa-thumbs-o-up fa-2x'  end like_icon
,      s.titel titel
,      s.beschrijving
,      s.vorm 
,      s.lengte
,      s.tags
,      s.sprekers
,      s.bedrijf
from   likes l  join sessions s on l.sessions_id = s.id 
where  s.GESELECTEERD is null
and    l.collegas_id = APEX_UTIL.GET_SESSION_STATE ('P4_COLLEGA_ID')
order by substr(l.id,25,32)
/


create or replace
view  like_summary
as
select count(l.id) like_count
,      s.titel titel
,      s.beschrijving
,      s.sprekers
from   likes l  join sessions s on l.sessions_id = s.id 
join collegas c on l.collegas_id = c.id
where s.GESELECTEERD is null
and   l.the_like = 'Y'
group
by   titel, beschrijving, sprekers
order by like_count desc

