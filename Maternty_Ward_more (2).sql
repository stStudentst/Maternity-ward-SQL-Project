
--שאילתה שתציג את רשימת כל היולדות שילדו החודש הזה 
select m_id, m_name from Maternity inner join Birth on B_id_maternity= M_id 
where datepart(month,B_date_of_birth)=datepart(month,getdate())
--

--שאילתה המציגה פרטי היולדת כלומר: ת.ז. , שם, תאריך בו ילדה, מן הולד, תאריך שחרור, עיר מגוריה
select M_id, M_name,B_date_of_birth,B_fatel_gender,D_date,C_name
from Birth left join (Maternity left join City on C_Code=M_code_city)
left join Discharge on D_id_maternity=M_id on M_id = B_id_maternity
--

--(trigger) מזניק שמעדכן באופן אוטומטי את כמות המיטות הפנויות בחדר בעת שחרור יולדת
create trigger Update_available_beds on [dbo].[Discharge] for insert
as begin
update [dbo].[Rooms] set [R_num_available_beds]=[R_num_available_beds]+1 
from [dbo].[Rooms] inner join Maternity ab on M_code_room=R_code, inserted
where ab.[M_id]=inserted.[D_id_maternity]
end
--

--רציתי למחוק ממסד הנתונים מזניק שנמחק לי מהטופס ושכחתי איך קוראים לו אז זו הפקודה להצגת שמות המזניקים שבמערכת 
SELECT * FROM sys.triggers;
--וזו הפקודה למחיקת המזניק
drop trigger Update_maternity_when_she_go
--

--שאילתה שמציגה את כל היולדות שכרגע באשפוז
select M_id,M_name,M_code_room 
from Maternity left join Birth on B_id_maternity like M_id where
(M_id not in (select M_id from Maternity inner join Birth on B_id_maternity= M_id))or
(M_id like B_id_maternity and  DATEdiff(day,B_date_of_birth ,GETDATE())<7)
--

--טבלה מדומה של חדרי אשפוז (לשימוש בפרוצדורה
go
alter view Inpatient_rooms
as
select * from Rooms where R_code_type=4 and R_num_available_beds>0
--בדיקה אם זה עובד
select * from Inpatient_rooms
--

--טבלה מדומה של חדרי לידה (לשימוש בפרוצדורה
go
alter view Birth_rooms
as
select * from Rooms where R_code_type=1 and R_num_available_beds>0
--בדיקה אם זה עובד
select * from Birth_rooms
--


--פרוצדורה שמקבלת פרטים על יולדת ומכניסה אותה למאגר. משבצת אותה בחדר(בתחילה יולדת תכנס לחדר אשפוז
--ומשם יעבירו אותה לחדר ע"פ מצבה הרפואי. אם עיר מגוריה לא קיימת במאגר עיר זו תתוסף למאגר הערים 
go
alter procedure Add_Maternity(@m_id varchar(9), @m_name varchar(20), @m_city varchar(20))
as 
	declare @code_city int, @min_room int
	begin

	--מציאת קוד העיר או הכנסת עיר נוספת למאגר
	set @code_city= (select C_code from City where C_name like @m_city)
	if (@code_city=null)
	begin
		insert into City values (@m_city)
		select @code_city=MAX(C_code)from City
	end
	
	--חיפוש חדר
	select @min_room = min(R_code)from Inpatient_rooms
	--אם אין מקום בחדרי אשפוז יכניסו את היולדת לחדר לידה קלאסי עד לאבחון רופא
	if (@min_room=null)
		select @min_room=min(R_code)from Birth_rooms
	
	update Rooms set R_num_available_beds=R_num_available_beds-1 
	from Rooms
	where R_code=@min_room
	
	
	--הוספת היולדת למאגר
	insert into [dbo].[Maternity] values(@m_id,@m_name,@code_city,@min_room)
	print 'enter the clients to room'+cast(@min_room as varchar(2))
end	
exec Add_Maternity '326443744','shoshi fridman','Rechasim'
	



--פרוצדורה להעברת יולדת חדר (על פי סוג החדר המבוקש) מחזירה את מספר החדר שייבחר על פי הסוג המבוקש
--בעיה רצינית כשאני מריצה את הפרוצדורה התגובה היא ש3 שורות הושפעו + ההדפסה מצויינת אך כשאני הולכת לטבלת החדרים בשביל לראות את השינוי אין שום שינוי :(
alter procedure Code_room(@id_maternity varchar(9), @type_room varchar(20))
as
	declare @room_move int, @code_type int,@last_room int

begin
	--מציאת קוד של סוג החדר + בדיקת תקינות
	select @code_type = RT_code from Room_Types where RT_type like @type_room
    if(@code_type is null)
		print 'There is no such type of room. The room types are: "classic_birth", "urgent_operating",
				"Recovery",	"Inpatient", "surgery". Retry this function with correct values'
	else
	begin
		--מציאת קוד חדר למעבר
		set @room_move =(select top 1 R_code from Rooms where R_code_type = @code_type and R_num_available_beds > 0)
		--עדכון מיקום היולדת
		update Maternity set M_code_room=@room_move
		from Maternity where M_id like @id_maternity

		--עדכון כמות מיטות בחדר החדש
		update Rooms set R_num_available_beds=R_num_available_beds-1 
		from Rooms
		where R_code=@room_move
		
		
		--עדכון כמות מיטות בחדר הקודם
		set @last_room=(select M_code_room from Maternity where M_id like @id_maternity)
		update Rooms set R_num_available_beds=R_num_available_beds+1 
		from Rooms where R_code = @last_room

		print 'you have place for the maternity in room:'+ CAST(@room_move AS VARCHAR(2))
		end
end
exec Code_room '326334844','classic_birth'
select * from Rooms
--

--טבלה מדומה של המציגה רשימה של אנשי צוות פנויים
go
alter view Staff_members_are_available 
as
	select T_id, T_name,AP_name as 'specialization'  from Team inner join Placement on P_id_staff=T_id inner join Shifts on S_code=P_code_Shift left join Access_Permission on AP_code= T_code_AP
where cast(GETDATE() as date) = P_date and (DATEPART(hh,GETDATE())< DATEPART(hh,S_end_time)) and T_id  
not in (select TDC_id_team from Teame_at_during_childbirth inner join Birth on B_code=TDC_code_birth 
where (DATEPART(hh,GETDATE())> DATEPART(hh,B_start_birth_time)) AND cast(GETDATE() as date)=B_date_of_birth) 

select * from Staff_members_are_available
--

--האם להשאיר את הטבלה מדומ או את הטריגר??

--מזניק  ברגע שנוצרת לידה יוצרת טבלה של אנשי הצוות הזמינים כעת 
create trigger Staff_available_for_this_birth on [dbo].[Birth] for insert
as begin
	declare @type_room int
	set @type_room=(select R_code_type from Rooms inner join (Maternity  inner join Birth  on M_id =B_id_maternity)on M_code_room=R_code,inserted
										where M_id like inserted.[B_id_maternity])
	if (@type_room like 'classic_birth')
	select T_id, T_name,AP_name as 'specialization'  from Team inner join Placement on P_id_staff=T_id inner join Shifts on S_code=P_code_Shift left join Access_Permission on AP_code= T_code_AP
	where cast(GETDATE() as date) = P_date and (DATEPART(hh,GETDATE())< DATEPART(hh,S_end_time)) and T_id  
	not in (select TDC_id_team from Teame_at_during_childbirth inner join Birth on B_code=TDC_code_birth 
	where (DATEPART(hh,GETDATE())> DATEPART(hh,B_start_birth_time)) AND cast(GETDATE() as date)=B_date_of_birth) and AP_name not like 'Manager' and AP_name not like 'Medical Secretary' AND AP_name not like 'Medical Secretary'

	if(@type_room like 'surgery')
		select T_id, T_name,AP_name as 'specialization'  from Team inner join Placement on P_id_staff=T_id inner join Shifts on S_code=P_code_Shift left join Access_Permission on AP_code= T_code_AP
	where cast(GETDATE() as date) = P_date and (DATEPART(hh,GETDATE())< DATEPART(hh,S_end_time)) and T_id  
	not in (select TDC_id_team from Teame_at_during_childbirth inner join Birth on B_code=TDC_code_birth 
	where (DATEPART(hh,GETDATE())> DATEPART(hh,B_start_birth_time)) AND cast(GETDATE() as date)=B_date_of_birth) and AP_name not like 'Manager' and AP_name not like 'Medical Secretary'
end
--


--פונקציה לבדיקת תקינות סוג הלידה
create function Num_Type(@birth_type varchar(20))
returns int
as begin
	declare @code_type int
	if (@birth_type like 'classic_birth')
		set @code_type=1
	else
	begin
		if(@birth_type like 'surgery')
			set @code_type= 5
		else
			set @code_type= 0
	end
	return @code_type
end
print [dbo].Num_Type('')

--פרוצדורה ללידה
create procedure New_birth (@id_maternity varchar(9), @type_birth varchar(20),@fatel_gender varchar(6))
as begin
	--איך מזמנים פרוצדורה?????
		exec [dbo].Code_room @id_maternity, @type_birth
		insert into [dbo].[Birth] values(@id_maternity,0,@fatel_gender,cast(getdate() as date),datepart(HH,GETDATE()),CONVERT(time, CONCAT(DATEPART(HH,GETDATE()),':00')),NULL)
end
--


--פרוצדורה שמעדכנת את זמן סיום הלידה (כך יעבוד זימון אנשי צוות ללידה הבאה) או ללידה חופפת בשביל שלא יהיו שגיאות
create procedure Update_end_Birth (@id_matenity varchar(9))
as begin

	update Birth set B_end_of_birth_time= CONVERT(time, CONCAT(DATEPART(HH,GETDATE()),':00'))
		from Birth inner join Maternity on M_id = B_id_maternity
		where B_id_maternity = @id_matenity and cast(GETDATE() as date)=B_date_of_birth
end
--


--שאילתה המציגה את כמות הלקוחות, כמות הלידות, ממוצע של אנשי צוות בלידה
select  
count(distinct M_id)as 'amount maternities',
count(distinct B_code)as 'amount birth',
avg(TDC_code)as 'Average_anount_team_at_birth'
from Maternity left join Birth on B_id_maternity like M_id
left join Teame_at_during_childbirth on TDC_code_birth =B_code
--

--שאילתה המציגה ממוצע של לידות בחודש
select 
datePart(month , B_date_of_birth) as _month_, 
count(*) as 'total birth', 
avg(count(*)) over () as 'average_birth_per_month'
from Birth group by datePart(month , B_date_of_birth) order by _month_
--

--מציאת מספר השעות שעבד איש צוות מסויים בחודש זה
create function Number_of_hours_this_month(@id_team varchar (9))
returns int
as begin
	return((select count(P_code_Shift) from Placement
	where datepart(month,P_date)=datepart(month,getdate())
		and P_id_staff=@id_team)*6)
end
print [dbo].Number_of_hours_this_month('328185038')
--

--שכר חודשי של עובד מסויים
create function Salary_per_month(@id_staff varchar(9))
returns int
as begin
	return(([dbo].Number_of_hours_this_month(@id_staff))*(select T_hourly_wage from Team where T_id like @id_staff))
end
print [dbo].Salary_per_month('328185038')