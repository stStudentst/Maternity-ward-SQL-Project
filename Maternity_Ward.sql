
--מחלקת יולדות
create database Maternity_Ward

--ערים  
create table City
(
	C_code int identity (1,1) primary key,
	C_name varchar (20) not null
)

insert into City values
	('Jerusalem'),('Bney_Brak'),('Haifa'),
	('Rechasim'),('Tel_Aviv'),('Ramat_Gan'),
	('Netanya'),('Beitar')
select * from City
--***

--סוגי חדרים
create table Room_Types
(
	RT_code int identity (1,1) primary key,
	RT_type varchar (20) not null
)
insert  into Room_types values
	--לידה קלאסית			ניתוח בהול- תןך כדי לידה		התאוששות
	('classic_birth'),		('urgent_operating '),			('Recovery'),
	--***
	-- אשפוז			ניתוח				
	('Inpatient'),	 ('surgery')
select * from Room_Types
--***

--חדרים
create table Rooms
(
	R_code int identity (1,1) primary key,
	R_code_type int foreign key references Room_Types(RT_code) not null,
	R_num_Beds int,
	R_num_available_beds int
)
insert into Rooms values
	(1,1,1),(1,1,1),(1,1,1),(1,1,1),(1,1,1),(1,1,1),(1,1,1),(1,1,1),(1,1,1),(1,1,1),
	(1,1,0),(1,1,0),(1,1,0),(1,1,0),(1,1,0),
	(5,1,1),(5,1,1),(5,1,1),(5,1,1),(5,1,1),(5,1,0),(5,1,0),(5,1,0),
	(2,1,1),(2,1,1),(2,1,1),(2,1,1),(2,1,0),
	(3,3,3),(3,3,3),(3,3,2),(3,3,1),
	(4,6,6),(4,6,6),(4,6,6),(4,6,6),(4,6,5),(4,6,4),
	(4,1,1),(4,1,1),(4,1,1),(4,1,1)
	
select * from Rooms
--***

--לידה
create table Birth
(
	B_code int identity (1,1) primary key,
	B_id_maternity varchar(9) foreign key references Maternity(M_id) not null,
	B_status_anethesia int,--מצב הרדמה
	B_fatel_gender varchar(6),--מין העובר
	B_date_of_birth date,
    B_start_birth_time time,                                                                                                                                                                         
	B_end_of_birth_time time
)
insert into Birth values
	('326443744',0,'female','2024/07/08','19:05'),
	('029612306',1,'male','2024/07/01','21:40','3:30'),('005837844',1,'male','2024/07/01','22:00','3:30'),
	('022852107',1,'female','2024/01/01','21:40','3:30'),('033807413',1,'female','2024/01/05','6:30','13:00'),
	('028004133',1,'male','2024/01/29','2:0','10:30'),('214824328',1,'female','2024/02/06','5:00','6:50'),
	('027109065',1,'male','2024/02/12','7:20','11:40'),('327866679',1,'female','2024/02/13','21:00','3:20'),
	('326334844',0,'male','2024/03/08','1:10','5:50'),('327698377',0,'female','2024/03/20','4:00','9:30'),
	('327812855',1,'female','2024/04/16','21:40','3:30'),('327709739',1,'male','2024/05/07','9:00','12:50'),
	('328265780',0,'female','2024/05/25','13:50','18:00'),('326709428',1,'male','2024/06/03','16:00','20:40'),
	('215500398',1,'male','2024/06/04','14:00','17:40'),('327772190',1,'female','2024/06/23','21:40','3:30'),
	('327753141',0,'female','2024/06/26','03:00','08:00')
select * from Birth
--***

--אנשי צוות
create table Team
(
	T_id varchar(9) primary key,
	T_name varchar(20) not null,
	T_code_AP int foreign key references Access_Permission(AP_code),
	T_phone varchar(10) not null,
	T_code_city int foreign key references City(C_code),
	--שכר לשעה
	T_hourly_wage int,
)
insert into Team values
	('066763667','Miri Shitrit',248,'0533135842',4,1500),
	('328185038','Ester Shitrit',1234,'0534162575',4,1500),
	('326762366','ayala Mualem',5678,'0583222568',4,300),
	('28796233','Ilana Maman',3456,'0583225109',4,500),
	('24341158','Michal Ochana',7890,'0527132544',4,400),
	('208096081','Judit Elizur',9012,'0504168888',4,600),
	('215262999','Miri Lavinski',13579,'0555563593',4,2000)
select * from Team
--***

--הרשאת גישה
create table Access_Permission
(
	AP_code int primary key,
	AP_name varchar(20)
)
insert into Access_Permission values
	--מזכירה רפואית			מנהל			 מנתח				מיילדת			אח/אחות			רופא מרדים				רופאת נשים		
	(248,'Medical Secretary'),(13579,'Manager'),(1234,'surgeon'),(3456,'midwife'),(5678,'nurse'),(7890,'Anesthesiologist'),(9012,'Gynecologist')
select * from Access_Permission
--***

create table Maternity
(
	M_id varchar(9) primary key,
	M_name varchar(20),
	M_code_city  int foreign key references City(C_code),
	M_code_room int foreign key references Rooms(R_code),
)
insert into Maternity values
	('029612306','rina aharon',2,null),('005837844','tava elumelech',2,null),
	('022852107','Yael Lev',2,12),('033807413','Miryam shraga',3,13),
	('028004133','Yeudit harel',4,14),('214824328','Avigail Stachi',5,15),
	('027109065','Isca Yosef',6,21),('327866679','Efrat Rachmani',7,22),
	('326334844','Ayala Nisan',8,23),('327698377','Tamar Maor',7,28),
	('327812855','Ruti Tikuthinski',6,31),('327709739','Tami Yanay',5,32),
	('328265780','Shoshi Mishkovski',4,32),('326709428','Dasi Aharon',3,37),
	('215500398','ayali  Zigler',2,38),('327772190','Lea Bayfus',1,38),
	('327753141','Batya Eshed',1,11)
select * from Maternity
--***

--שחרור
create table Discharge
(
	D_code int identity(1,1) primary key,
	D_id_team varchar(9) foreign key references Team(T_id),
	D_id_maternity varchar(9),
	D_status_baby int,
	D_code_doctor_signature int foreign key references Access_permission(AP_code),
	D_date date
)
insert into Discharge Values
	('066763667','022852107',1,13579,'2024/01/03'),
	('066763667','033807413',1,3456,'2024/01/08')
select * from Discharge
--***

--משמרות
create table Shifts
(
	S_code int identity(1,1) primary key,
	S_name varchar(10),
	S_start_time time,
	S_end_time time
)
insert into Shifts values
	('morning','6:00','12:00'),('noon','12:00','18:00'),
	('evening','18:00','00:00'),('night','00:00','6:00')
select * from Shifts
--***

--שיבוץ
create table Placement
(
	P_code int identity(1,1) primary key,
	P_date date,
	P_code_Shift int foreign key references Shifts(S_code), 
	P_id_staff varchar(9) foreign key references Team(T_id) 
)
insert into Placement values
	('2024/01/01',4,'328185038'),
	('2024/01/01',4,'326762366'),
	('2024/01/01',4,'28796233')
select * from Placement
--***

--צוות בלידה
create table Teame_at_during_childbirth
(
	TDC_code int identity(1,1) primary key,
	TDC_id_team varchar(9) foreign key references Team(T_id),
	TDC_code_birth int foreign key references Birth(B_code)
)
insert into Teame_at_during_childbirth values
	('328185038',1),
	('326762366',1),
	('28796233',1)
select * from Teame_at_during_childbirth
--***


-----אילוצי מערכת
alter table [dbo].[Rooms] add constraint available_beds Check ([R_num_available_beds] between 0 and R_num_beds)
alter table [dbo].[Birth] add constraint status_anethesia Check ([B_status_anethesia] in (0,1))
alter table [dbo].[Discharge] add constraint status_baby Check ([D_status_baby] in (0,1))
alter table [dbo].[Discharge] add constraint code_signature Check ([D_code_doctor_signature] in (13579,3456,9012))
alter table [dbo].[Shifts] add constraint name_shift check ([S_name] in('morning','noon','night','evening'))
--***




