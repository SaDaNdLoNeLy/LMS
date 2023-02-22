-- 1.1.ADDING
-- student

CREATE OR REPLACE PROCEDURE add_student(idn char(8),first_namen varchar(35),last_namen varchar(35),gendern char(1),birthdayn date,statusn boolean,join_daten date,addressn varchar(70),emailn varchar(35),phonen varchar(25),program_idn char(6))
language plpgsql
as $$
begin 
INSERT INTO student(id,first_name,last_name,gender,birthday,status,join_date,address,email,phone,program_id) VALUES (idn,first_namen,last_namen,gendern,birthdayn,statusn,join_daten,addressn,emailn,phonen,program_idn);
end
$$;

call add_student('20205147','Tong Tran Minh','Duc','M','3-9-2002',TRUE,'4-2-2022','67 Le Thanh Nghi','duc.ttm205147@sis.hust.edu.vn','0902112042','ICT');

-- lecturer

CREATE OR REPLACE PROCEDURE add_lecturer(idn char(12),first_namen varchar(35),last_namen varchar(35),gendern char(1),birthdayn date,statusn boolean,join_daten date,addressn varchar(70),emailn varchar(35),phonen varchar(25),faculty_id varchar(8))
language plpgsql
as $$
begin 
INSERT INTO lecturer(id,first_name,last_name,gender,birthday,status,join_date,address,email,phone,faculty_id) VALUES (idn,first_namen,last_namen,gendern,birthdayn,statusn,join_daten,addressn,emailn,phonen,faculty_idn);
end
$$;

call add_lecturer('20205147','Tong Tran Minh','Duc','M','3-9-2002',TRUE,'4-2-2022','67 Le Thanh Nghi','duc.ttm205147@sis.hust.edu.vn','0902112042','CS');



-- subject

CREATE OR REPLACE PROCEDURE add_subject(idn varchar(7),namen varchar(100),study_creditsn integer,tuition_creditsn integer,final_weightn numeric(3,2),prerequiste_idn varchar(7),faculty_idn varchar(8))
language plpgsql
as $$
begin 
INSERT INTO subject(id,name,study_credits,tuition_credits,final_weight,prerequiste_id,faculty_name) VALUES (idn,namen,study_creditsn,tuition_creditsn,final_weightn,prerequiste_idn,faculty_idn) ;
end
$$;

call add_subject('IT3289','Data Structure and Algorithm',3,4,0.7,'IT8943','CS');


-- classes

CREATE OR REPLACE PROCEDURE add_class(idn char(6),typen varchar(5),semestern char(5),current_capn integer,max_capn integer,subject_idn varchar(7))
language plpgsql
as $$
begin 
INSERT INTO class(id,type,semester,current_cap,max_cap,subject_id) VALUES (idn,typen,semestern,current_capn,max_capn,subject_idn);
end
$$;

call add_class('438952','TN','20201',0,80,'AC2010');


-- 1.2.Altering
-- student

-- 1.3.create timetable

-- insert into timetable

create or replace procedure add_timetable(idin char(6),weekdayin char(1),start_timein char(4),end_timein char(4),locationin varchar(20))
language plpgsql
as $$
begin 
insert into timetable(class_id,weekday,start_time,end_time,location) values (idin,weekdayin, start_timein,end_timein, locationin);
end 
$$;

call add_timetable('438943','3','2030','2130','D9-502');

-- trigger to check time conflict

create or replace function check_class_time_conflict()
returns trigger
language plpgsql
as $$
begin 
if exists 
(
    select * from timetable A
    where A.location = new.location
    AND A.weekday = new.weekday
    and (
        (new.end_time>A.start_time AND new.end_time<A.end_time)
        OR
        (new.start_time>A.start_time AND new.start_time<A.end_time) 
    )
    )
    then raise exception 'This class time is overlapse with another class';
else return new;
end if;
end $$;

create trigger class_time_insert_trigger before insert on timetable
for each row 
execute procedure check_class_time_conflict();

-- 1.4.update timetable

create or replace procedure update_timetable(idin char(6),weekdayin char(1),start_timein char(4),end_timein char(4),locationin varchar(20))
language plpgsql
as  $$
begin 
update timetable 
set start_time=start_timein
,end_time=end_timein
,location=locationin
where class_id=idin and weekday= weekdayin;
end $$;

call update_timetable('438952','4','2200','2300','D5-403');

-- update trigger
create or replace function check_time_conflict_update()
returns trigger 
language plpgsql
as $$
begin 
if exists 
(
    select * from timetable A
    where A.location = new.location
    AND A.weekday = old.weekday
    and (
        (new.end_time>A.start_time AND new.end_time<A.end_time)
        OR
        (new.start_time>A.start_time AND new.start_time<A.end_time) 
    )
    )
    then raise exception 'This update is overlapse with another class';
    else return new;
    end if;
end $$;

create or replace trigger check_time_trigger_update before update on timetable 
for each row
execute procedure check_time_conflict_update();

-- 1.5.assign lecturer
create or replace procedure assign_lecturer(lecid char(12),idin char(6))
language plpgsql 
as $$
begin 
update class
set lecturer_id= lecid
where id= idin;
end $$;

call assign_lecturer('vosfZuXAhWTV','438952')

-- lecturer time conflict trigger

create or replace function lec_update_trigger_function() 
returns trigger 
language plpgsql 
as $$
begin 
if exists(
    select A.* 
    from(select * from timetable where class_id=old.id) A
    join 
    (
        select B.lecturer_id,A.* 
        from timetable A 
        join class B on A.class_id =B.id
        where B.lecturer_id= new.lecturer_id
    ) B on (B.end_time>A.start_time AND B.end_time<=A.end_time)
        OR (B.start_time>=A.start_time AND B.start_time<A.end_time)
    where A.weekday =B.weekday
)
then raise exception 'This class time conflicts with this schedule';
else return new;
end if;
end $$;

create trigger lecturer_time_trigger before update on class
for each row
execute procedure lec_update_trigger_function();


-- 1.6.getting reports 

-- reset GPA of all students
create or replace procedure reset_GPA()
language plpgsql
as $$
begin 
    Update student
    set gpa_total_score_product=0,
    gpa_total_study_credits=0;
    where status= true
end $$;

call reset_GPA()


-- number of enrollment
create or replace function enroll_Report()
returns table (id char(6),type varchar(5),semester char(5),current_cap integer,max_cap integer,comppany_id char(9),lecturer_id char(12),subject_id varchar(7),class_status text)
language plpgsql
as $$
begin 
return query(
    select *,
    case 
    when A.current_cap =A.max_cap then 'Full'
    when A.current_cap <=5 then 'Not eligible to open'
    when A.current_cap >5 and A.current_cap <=19  then 'In consideration'
    when A.current_cap >=20 and A.current_cap <=A.max_cap then 'Eligible to open'
    end as class_status
    from class A
);
end $$;

select * from enroll_Report();

-- Credit debt reports
create or replace function debt_report()
returns table(id char(8),first_name varchar(35),last_name varchar(35),status boolean,credit_debt integer,warning_level text)
language plpgsql
as $$
begin 
return query 
SELECT A.id,A.first_name,A.last_name,A.status,A.credit_debt,
CASE
WHEN A.credit_debt>0 AND A.credit_debt<5 THEN 'Warning level 1'
WHEN A.credit_debt>4 AND A.credit_debt<10 THEN 'Warning level 2'
WHEN A.credit_debt>9 AND A.credit_debt<13 THEN 'Warning level 3'
WHEN A.credit_debt>12 THEN 'Expelled'
ELSE 'No warning'
END AS warning_level
FROM student A;
end $$;

select * from debt_report();


-- GPA reports


-- 2.student

-- enroll in classes
create or replace procedure enroll_class(std_id char(8),cl_id char(6))
language plpgsql
as $$
begin
insert into enrollment(student_id,class_id)values(std_id,cl_id);
end$$


call enroll_class('20200001','133729');

-- update the student's performance

create or replace procedure update_grade(std_id char(8),cl_id char(6),mid_score integer,fin_score integer)
language plpgsql
as $$
begin
update enrollment A
set midterm_score=mid_score,
final_score=fin_score
where student_id=std_id and class_id=cl_id;
end$$

call update_grade('20205147','133729',7,8);

-- view info abt subject
create or replace function view_subject(inid varchar(7))
returns table(id varchar(7), name varchar(100),study_credits integer,tuition_credit integer,final_weight numeric(3,2),prerequisite_id varchar(7),faculty_id varchar(8))
language plpgsql
as 
$$
begin 
if inid= '*' 
then return query(select * from subject);
else 
return query
(select * from subject
where subject.id = inid);
end if;
end
$$;

select * from view_subject('BF3501E');

-- view all self classes
create or replace function view_class(studentid char(8))
returns table(student_id char(8),id char(6),type varchar(5),semester char(5),current_cap integer,max_cap integer,company_id char(9),lecturer_id char(12),subject_id varchar(7))
language plpgsql
as $$
begin 
return query
(
    select B.student_id,A.* from class A
    join enrollment B on A.id=B.class_id
    where B.student_id=studentid;
)
end $$;

select * from view_class('20205147');

-- view self result
create or replace function view_result(studentid char(8))
returns table(student_id char(8),class_id char(6),midterm_score integer,final_score integer,absent_count integer)
as $$
begin 
return query
(
select A.* from enrollment A
where A.student_id=studentid
);
end $$;

select * from view_result('20205147');

-- view tentative timetable
create or replace function view_open_class()
returns table(classid char(6),weekday char(1),start_time char(4),end_time char(4),location varchar(20))
language plpgsql
as $$
begin 
return query
(
    select * from timetable
    order by class_id
);
end $$;

select * from view_open_class();

-- view self timetable
create or replace function view_self_timetable()
returns table(student_id char(8),class_id char(6),weekday char(1),start_time char(4),end_time char(4),location varchar(20))
language plpgsql
as $$
begin
return query
( 
    select A.student_id,B.* from enrollment A
    join timetable B on A.class_id=B.class_id
);
end $$;

select * from view_self_timetable();

-- view class enrolling info
create function show_class_info(classid char(6))
returns table (class_id char(6),subject_id varchar(7),subject_name varchar(100),type varchar(5),study_credit integer,
tuition_credit integer,current_cap integer,max_cap integer,weekday char(1),start_time char(4),end_time char(4),location varchar(20))
language plpgsql 
as $$
begin 
return query
(
select A.id,A.subject_id,B.name,A.type,B.tuition_credit,B.study_credits,A.current_cap,A.max_cap,C.weekday,C.start_time,C.end_time,C.location
from class A
join subject B on A.subject_id=B.id 
join timetable C on A.id= C.class_id
where A.id= classid);
end $$;

select * from show_class_info('136302')

-- check available slots
create or replace function check_cap_function()
returns trigger 
language plpgsql 
as $$
begin
if exists (select * from class 
where max_cap=current_cap and id=new.class_id)
then raise exception 'The class is already full';
else (
    update class
    set current_cap=current_cap+1
    where id=new.class_id;
    return new;
    )
end if;
end $$;

create trigger check_cap_trigger before insert on enrollment
for each row 
execute procedure check_cap_function();

insert into enrollment(student_id,class_id)values('20200001','137982')


CREATE OR REPLACE FUNCTION enroll_time_trigger_function() 
   RETURNS TRIGGER 
   LANGUAGE PLPGSQL
AS $$
BEGIN

-- enroll time trigger

create or replace function enroll_time_trigger_function()
returns trigger 
language plpgsql
as $$
begin 
    if exists(
        select * 
        from timetable B 
        join(
            select * from timetable where class_id= new.class_id   
        ) A on(
            (A.start_time >= B.start_time and A.start_time < B.end_time)
            or 
            (A.end_time > B.start_time and A.end_time <= B.end_time)
            and A.weekday=B.weekday
        )
        join enrollment C on C.class_id= B.class_id
        where C.student_id=new.student_id
    )
    then raise exception 'This class conflicts with your timetable';
    end if;
    return new;
end 
$$;

create trigger enroll_time_trigger before insert on enrollment
for each row 
execute procedure enroll_time_trigger_function()


-- calculate credits of enrollment
create or replace function credits_trigger_function()
returns trigger
language plpgsql
as $$
DECLARE
    add_credits numeric;
begin
    select  calculate_credits_func(new.class_id) into add_credits;
    if not exists (
        select A.* from enrollment A 
        join class B on A.class_id=B.id
        join (select * from enrollment A join class B on A.class_id=B.id 
            where student_id=new.student_id and A.class_id!=new.class_id) C on C.subject_id=B.subject_id
        where A.student_id=new.student_id
    ) then update student
    set cpa_total_study_credits =cpa_total_study_credits+ add_credits
    where id=new.student_id;
    end if;
    update student
    set gpa_total_study_credits =gpa_total_study_credits+ add_credits
    where id=new.student_id;
    return new;
end $$;

drop function credits_trigger_function()


create trigger credits_trigger before insert on enrollment 
for each row 
execute procedure credits_trigger_function();

drop trigger credits_trigger on enrollment


create or replace function calculate_credits_func(class_id char(6))
returns numeric
language plpgsql
as $$
declare 
    total_credits numeric;
begin 
    select A.study_credits into total_credits
    from subject A
    join class B on A.id=B.subject_id
    where B.id=class_id;
    return total_credits;
end
$$;

select calculate_credits_func('133725')

drop function calculate_credits_func(char(6))


-- trigger function to calculate gpa and cpa
create or replace function score_trigger_function()
returns trigger
language plpgsql
as $$
DECLARE
    add_product1 numeric;
    add_product2 numeric;
    enroll_hist boolean;
begin
    select calculate_product_func(new.midterm_score,new.final_score,new.class_id) into add_product1;
    select check_enroll_history(new.student_id,new.class_id) into enroll_hist;

    if enroll_hist=true
    then 
    select calculate_product_func(B.midterm_score,B.final_score,B.class_id) into add_product2
    from  (
        select A.subject_id from class A
        where A.id=new.class_id
    ) A
    join (
        select A.midterm_score,A.final_score,A.class_id,B.subject_id from enrollment A
        join class B on A.class_id = B.id
        where A.student_id = new.student_id
    ) B on B.subject_id=A.subject_id;

    if add_product1>add_product2
    then update student
        set cpa_total_score_product =cpa_total_score_product+ add_product1 -add_product2
        where id=new.student_id;
    end if; 

    else 
    update student
    set cpa_total_score_product =cpa_total_score_product+ add_product1
    where id=new.student_id; 
    end if;

    update student
    set gpa_total_score_product =gpa_total_score_product+ add_product1
    where id=new.student_id;
    return new;
end $$;

drop function score_trigger_function

-- cpa and gpa trigger

create trigger score_trigger before insert or update on enrollment
for each row 
execute procedure score_trigger_function();

drop trigger score_trigger on enrollment


-- check whether a student enrolled this subject before

create or replace function check_enroll_history(std_id char(8),class_id char(6))
returns boolean 
language plpgsql
as $$
begin
if exists (
    select * from  (
        select A.subject_id from class A
        where A.id=class_id
    ) A
    join (
        select B.subject_id from enrollment A
        join class B on A.class_id = B.id
        where A.student_id = std_id
    ) B on B.subject_id=A.subject_id
)then return true;
end if;
return false;
end
$$;

drop function check_enroll_history


-- function to convert grade to grade in scale of 4
create or replace function calculate_product_func(mid_score integer,fin_score integer,class_id char(6))
returns numeric
language plpgsql 
as $$
declare
    total_product numeric;
begin 
    SELECT
    A.study_credits* CASE 
    WHEN A.score >=4.0 AND A.score <=4.9 THEN 1
    WHEN A.score >=5.0 AND A.score <=5.4 THEN 1.5
    WHEN A.score >=5.5 AND A.score <=6.4 THEN 2
    WHEN A.score >=6.5 AND A.score <=6.9 THEN 2.5
    WHEN A.score >=7.0 AND A.score <=7.9 THEN 3
    WHEN A.score >=8.0 AND A.score <=8.4 THEN 3.5
    WHEN A.score >=8.5 AND A.score <=10 THEN 4
    ELSE 0
    END AS exchange_score into total_product
    from(
        select (mid_score*(1-C.final_weight)+fin_score*C.final_weight) score,C.study_credits
        from class B
        join subject C on B.subject_id=C.id
        where B.id= class_id
    ) A;
    return total_product;
end
$$;


-- check lab trigger

create or replace function check_lab_trigger_function()
returns trigger
language plpgsql
as $$
declare
    require char(1);
begin 
    select require_lab into require from class where id=new.class_id;
    if require='Y'
    then 
        if exists(
            select * from enrollment A
            join class B on A.class_id = B.id
            join (select A.subject_id,A.semester from class A where A.id=new.class_id ) C 
            on B.subject_id=C.subject_id and B.semester= C.semester
            where A.student_id=new.student_id and B.type='TN' 
        ) then return new;
        else raise exception 'You have to enroll a lab class first';
        end if;
    end if;
    return new;
end $$;


create trigger check_lab_trigger before insert on enrollment
for each row 
execute procedure check_lab_trigger_function();

-- enroll the company class via company_id
create or replace function enroll_company_trigger_function()
returns trigger 
language plpgsql
as $$
declare
comp_id char(9);
begin 
select company_id into comp_id from class where id= new.class_id;
if comp_id!='NULL'
then insert into enrollment(student_id,class_id)values(new.student_id,comp_id);
end if;
return new;
end$$;


create trigger company_id_trigger before insert on enrollment
for each row 
execute procedure enroll_company_trigger_function();


