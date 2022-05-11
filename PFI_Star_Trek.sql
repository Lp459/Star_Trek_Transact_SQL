-----1----- créer les 2 database 
create database dbdev;
create database dbges;


------2---- créer les tables de la database dbges
use dbges;

create table Classes(
classeno int IDENTITY(1,1),
nomClasse varchar(30),
SalaireMin money,
SalaireMax money,
constraint pk_classno PRIMARY KEY(classeno)
);

create table Équipages(
equipeno int IDENTITY(1,100),
nom varchar(30),
prenom varchar(30),
adresse varchar(30),
salaire money,
classeno int,
constraint pk_equipeno primary key(equipeno),
constraint fk_classeno foreign key(classeno) references Classes(classeno)
);

create table Missions(
idMission int Identity(1,1000),
nomMission varchar(30),
dateMission date,
niveauRisque varchar(30),
constraint pk_idMission primary key(idMission),
constraint check_niveauRisque CHECK (niveauRisque = 'élevé' or niveauRisque = 'moyen' or niveauRisque ='faible')
);

create table Explorations(
equipeno int,
idMission int,
nbPoints int,
constraint pk_equino_idMission primary key(equipeno, idMission),
constraint fk_equino foreign key(equipeno) references Équipages(equipeno),
constraint fk_idMission foreign key(idMission) references Missions(idMission)
);

--insertions initiales :
insert into Classes values('Commandant', 200000, 500000);
insert into Classes values('Ingénieurs',150000,300000);
insert into Classes values('Officiers tactiques',180000,350000);
insert into Classes values('Enseigne',50000,120000);
insert into Classes values('Médecin',200000,450000);
insert into Classes values('Cuisinier',45000,90000);

----3---- Inséré Explorations
go;
create procedure insererExploration(@pequipeno int , @pidMission int)
as
declare 
@pnbpoints int,
@pniveau varchar(30);

begin try
	select @pniveau = Missions.niveauRisque from Missions where Missions.idMission = @pidMission;
	select @pnbpoints = case @pniveau
						when 'élevé' 
							then 5000
						when 'moyen'
							then 1500
						when 'faible'
							then 1000
						else ''
						end

	begin transaction
			insert into Missions values(@pequipeno , @pidMission , @pnbpoints);	
	commit;
end try

begin catch
	rollback;
	print ERROR_MESSAGE();
	print ERROR_LINE();
end catch

----4--- Fonction TotalPoints une table contenant le total des points pour tous les membrer de l'équipage
go;
create function TotalePoints()returns table
as
Return(
select Équipages.nom , Équipages.prenom , SUM(Explorations.nbPoints) as PointsTotale from Équipages
	inner join Explorations on Équipages.equipeno = Explorations.equipeno
);

---5----
----Destruction des tabes
drop table Avoirs;
drop table Reponses;
drop table Joueurs;
drop table Questions;
drop table Categories;



----- Table Catégories
create table Categories
(
idCategorie char(1),
nomCategorie varchar(30) not null,
couleur varchar(30) not null,
constraint pk_categorieTrivia primary key (idCategorie)
);

----------------------------------
--Table Questions.
--Le flag désigne si la question est pigée ou non.Par défaut la question est non pigée. Falg =n
create table Questions
(
idQuestion smallint identity(100,1),
enonce varchar(100) not null,
flag char(1) not null default 'n',
difficulte smallint not null,
idCategorie char(1) not null,
constraint pk_QuestionTrivia primary key (idQuestion),
constraint ck_flagQuestion check(flag ='o' or flag ='n'),
constraint ck_difficulte check 
			(difficulte=1 or difficulte=2 or difficulte=3),
constraint fk_categorieTrivia foreign key (idCategorie)
			                  references Categories(idCategorie)
);

-----------------------------
---- Table réponses.
---estBonne nous renseigne si la réponse est bonne ou non 
create table Reponses
(
idReponse int identity (100,1),
laReponse varchar(100) not null,
estBonne char(1) not null,
idQuestion smallint not null,
constraint pk_reponse primary key(idReponse),
constraint ck_bonne check(estBonne='o' or estBonne ='n'),
constraint fk_question foreign key(idQuestion)
					  references Questions(idQuestion)
);
----------------------------------------
----- Table joueurs.
--- Cette table est liée à Avoirs
create table joueurs
(
idJoueur int identity,
alias varchar (20) unique not null,
nom varchar(30) not null,
prenom varchar(30),
constraint pk_joueur primary key (idJoueur)
);

----
create table Avoirs
( 
idJoueur int not null,
nbOr int default 0,
nbArgent int default 0,
nbBronze int default 0,
constraint fk_avoirs_joueurs foreign key(idJoueur) references joueurs(idJoueur),
constraint pk_avoirs primary key (idJoueur)
);
----------------------Insertions

insert into Joueurs values ('Tovok', 'Spoky', 'Spoke');
insert into Joueurs values ('Vulcain',  'Lanna','Tipole');
insert into Joueurs values ('Primogen', 'James','Kirk');
insert into Joueurs values ('Barakuda', 'Thomas', 'Trip');
insert into Joueurs values ('Klingon', 'Melinda', 'Tores');
--------------------------


insert into Categories values('s','sciences','vert');
insert into Categories values('a','art et lettres','orange');
insert into Categories values('h','histoire et geographie','bleu');
insert into Categories values('g','général','Jaune');

----------------------------------------------
insert into Questions(enonce,difficulte,idCategorie)
values('Quel élément dont le symbole est C, se retrouve dans toute forme de vie organique ?',1,'s'); 

insert into Questions(enonce,difficulte,idCategorie)
values('Quel élément chimique a comme symbole la lettre K ?',3,'s'); 

insert into Questions(enonce,difficulte,idCategorie)
values('Qui est l''inventeur du modèle relationnel en BD ?',1,'s'); 

insert into Questions(enonce,difficulte,idCategorie)
values('Quel est le double du quintuple de 248 ?',1,'s');

insert into Questions(enonce,difficulte,idCategorie)
values('Quel est le poids moyen d''un cerveau humain?',2,'s');

insert into Questions(enonce,difficulte,idCategorie)
values('Quelle est la couleur de Shrek',1,'g');

insert into Questions(enonce,difficulte,idCategorie)
values('Quel animal est le meilleu ami de Shrek',2,'g');

insert into Questions(enonce,difficulte,idCategorie)
values('Quelle phrase est souvent pronocée par Bart Simpson? ',3,'g');


-----------------------------------------


--Reponses question 100
insert into Reponses (laReponse,estBonne,idQuestion) values ('Le carbone','o',100);
insert into Reponses (laReponse,estBonne,idQuestion) values ('Le chlore','n',100);
insert into Reponses (laReponse,estBonne,idQuestion) values ('Le calcium','n',100);
insert into Reponses (laReponse,estBonne,idQuestion) values ('Le cobalte','n',100);
---reponses question 101
insert into Reponses (laReponse,estBonne,idQuestion) values ('Le phosphore','n',101);
insert into Reponses (laReponse,estBonne,idQuestion) values ('Le potassium','o',101);
insert into Reponses (laReponse,estBonne,idQuestion) values ('Le souffre','n',101);
insert into Reponses (laReponse,estBonne,idQuestion) values ('Le chlore','n',101);
--reponse question 102
insert into Reponses(laReponse,estBonne,idQuestion) values ('Ivar Jacobson','n',102);
insert into Reponses (laReponse,estBonne,idQuestion) values ('Tim Berners-Lee','n',102);
insert into Reponses (laReponse,estBonne,idQuestion) values ('Steve Jobs','n',102);
insert into Reponses (laReponse,estBonne,idQuestion) values ('Edgar Frank « Ted » Codd ','o',102);
--reponses question 103
insert into Reponses (laReponse,estBonne,idQuestion) values ('2480','o',103);
insert into Reponses (laReponse,estBonne,idQuestion) values ('2500','n',103);
insert into Reponses (laReponse,estBonne,idQuestion) values ('2487','n',103);
insert into Reponses (laReponse,estBonne,idQuestion) values ('2600','n',103);
--reponses question 104
insert into Reponses (laReponse,estBonne,idQuestion) values ('2,3 kg','n',104);
insert into Reponses (laReponse,estBonne,idQuestion) values ('2 kg','n',104);
insert into Reponses (laReponse,estBonne,idQuestion) values ('1,3 kg','o',104);
insert into Reponses (laReponse,estBonne,idQuestion) values ('1kg','n',104);
--reponses question 105
insert into Reponses (laReponse,estBonne,idQuestion) values ('vert','o',105);
insert into Reponses (laReponse,estBonne,idQuestion) values ('bleu','n',105);
insert into Reponses (laReponse,estBonne,idQuestion) values ('jaune','n',105);
insert into Reponses (laReponse,estBonne,idQuestion) values ('rouge','n',105);
--reponses question 106
insert into Reponses (laReponse,estBonne,idQuestion) values ('chien','n',106);
insert into Reponses (laReponse,estBonne,idQuestion) values ('chat','n',106);
insert into Reponses (laReponse,estBonne,idQuestion) values ('âne','o',106);
insert into Reponses (laReponse,estBonne,idQuestion) values ('cheval','n',106);
--- reponses question107
insert into Reponses (laReponse,estBonne,idQuestion) values ('oh mon dieu !','n',107);
insert into Reponses(laReponse,estBonne,idQuestion) values ('ah caramba !','o',107);
insert into Reponses(laReponse,estBonne,idQuestion) values ('oh seigneur ! ','n',107);
insert into Reponses (laReponse,estBonne,idQuestion) values ('oups','n',107);
-----------------


---6----
---Ingénieurs 

create login[James Kirk] with password=N'12345'
,default_database=[dbdev]
, DEFAULT_LANGUAGE=[us_english]
, CHECK_EXPIRATION=ON, CHECK_POLICY=ON
create user[James Kirk] for login[James Kirk];

create login[Thomas Trip] with password=N'12345'
,default_database=[dbdev]
, DEFAULT_LANGUAGE=[us_english]
, CHECK_EXPIRATION=ON, CHECK_POLICY=ON
create user[Thomas Trip] for login[Thomas Trip];

create login[Melinda Tores] with password=N'12345'
,default_database=[dbdev]
, DEFAULT_LANGUAGE=[us_english]
, CHECK_EXPIRATION=ON, CHECK_POLICY=ON
create user[Melinda Tores] for login[Melinda Tores];

--Officier Tactique
create login[Spoky Spoke] with password=N'12345'
,default_database=[dbdev]
, DEFAULT_LANGUAGE=[us_english]
, CHECK_EXPIRATION=ON, CHECK_POLICY=ON
create user[Spoky Spoke] for login[Spoky Spoke];

create login[Lanna Tipole] with password=N'12345'
,default_database=[dbdev]
, DEFAULT_LANGUAGE=[us_english]
, CHECK_EXPIRATION=ON, CHECK_POLICY=ON
create user[Lanna Tipole ] for login[Lanna Tipole];

--Enseigne
create login[Rachel Tilly] with password=N'12345'
,default_database=[dbges]
, DEFAULT_LANGUAGE=[us_english]
, CHECK_EXPIRATION=ON, CHECK_POLICY=ON
create user[Rachel Tilly] for login[Rachel Tilly];

create login[Samuel Wilky] with password=N'12345'
,default_database=[dbges]
, DEFAULT_LANGUAGE=[us_english]
, CHECK_EXPIRATION=ON, CHECK_POLICY=ON
create user[Samuel Wilky] for login[Samuel wilky];

create login[Saturne Lune] with password=N'12345'
,default_database=[dbges]
, DEFAULT_LANGUAGE=[us_english]
, CHECK_EXPIRATION=ON, CHECK_POLICY=ON
create user[Saturne Lune] for login[Saturne Lune];

create login[Legrand Sarru] with password=N'12345'
,default_database=[dbges]
, DEFAULT_LANGUAGE=[us_english]
, CHECK_EXPIRATION=ON, CHECK_POLICY=ON
create user[Legrand Sarru] for login[Legrand Sarru];

--Médecins
create login[Lapointe Hugh] with password=N'12345'
,default_database=[dbges]
, DEFAULT_LANGUAGE=[us_english]
, CHECK_EXPIRATION=ON, CHECK_POLICY=ON
create user[Lapointe Hugh] for login[Lapointe Hugh];
--Cuisinier
create login[Lewis Nellis] with password=N'12345'
,default_database=[dbges]
, DEFAULT_LANGUAGE=[us_english]
, CHECK_EXPIRATION=ON, CHECK_POLICY=ON
create user[Lewis Nellis] for login[Lewis Nellis];

---Trivial

create login[trivial] with password=N'12345'
,default_database=[dbdev]
, DEFAULT_LANGUAGE=[us_english]
, CHECK_EXPIRATION=ON, CHECK_POLICY=ON
create user[trivial] for login[trivial];
---7---Rôle serveur ou bd , tous public donc rien ? demander pour être sur


--8 - 9 -- Rôles j'ai add les membres directement après la création des rôles
--RoleTrivial
create role RoleTrivial;
grant select to RoleTrivial;
grant update to RoleTrivial;
grant insert to RoleTrivial;

alter Role[RoleTrivial] add member[trivial];
--RespQges 
create role RespQges;
grant select to RespQges;
grant update to RespQges;
grant insert to RespQges;
grant execute to RespQges;

alter role[RespQges] add member[Rachel Tilly];

--RoleEnseigne

create role RoleEnseigne;
grant select to RoleEnseigne;
grant update on Équipages to RoleEnseigne;
grant update on Missions(niveauRisque) to RoleEnseigne;
grant insert on Explorations to RoleEnseigne;
grant update on Explorations to RoleEnseigne;

alter role[RoleEnseigne] add member[Rachel Tilly];
alter role[RoleEnseigne] add member[Samuel Wilky];
alter role[RoleEnseigne] add member[Saturne Lune];
alter role[RoleEnseigne] add member[Legrand Sarru];

---RoleCuisinier

create role RoleCuisinier;
grant select to RoleCuisinier;

alter role[RoleCuisinier] add member[Lewis Nellis];

---db_owner
alter role[db_owner] add member[James Kirk];

--db_datawriter
alter role[db_datawriter] add member[James Kirk];
alter role[db_datawriter] add member[Thomas Trip];
alter role[db_datawriter] add member[Melinda Tores];
alter role[db_datawriter] add member[Spoky Spoke];
alter role[db_datawriter] add member[Lanna Tipole];

--db_datareader
alter role[db_datareader] add member[James Kirk];
alter role[db_datareader] add member[Thomas Trip];
alter role[db_datareader] add member[Melinda Tores];
alter role[db_datareader] add member[Spoky Spoke];
alter role[db_datareader] add member[Lanna Tipole];

--db_ddladmin
alter role[db_ddladmin] add member[James Kirk];
alter role[db_ddladmin] add member[Thomas Trip];
alter role[db_ddladmin] add member[Melinda Tores];
alter role[db_ddladmin] add member[Spoky Spoke];
alter role[db_ddladmin] add member[Lanna Tipole];

--10 --- Execute pour les officiers et les ingénieurs
create role execution;
grant execute to execution;
use dbdev;
alter role[execution] add member[James Kirk];
alter role[execution] add member[Thomas Trip];
alter role[execution] add member[Melinda Tores];
alter role[execution] add member[Spoky Spoke];
alter role[execution] add member[Lanna Tipole];
alter role[execution] add member[trivial];

--Trigger CTRLSalaire
go;
create trigger CTRLSalaire on Équipages after insert
as
declare
@psalaire money,
@psalaireMin money,
@psalaireMax money,
@pClasseno int;
select @psalaire = salaire from inserted;
select @pClasseno = Classeno from inserted;

select @psalaireMin = salaireMin from Classes where Classeno = @pClasseno;
select @psalaireMax = salaireMax from Classes where Classeno = @pClasseno;
begin
if(@psalaire < @psalaireMin or @psalaire > @psalaireMax)
	begin
	rollback
	raiserror(15600 , -1 , -1 , 'erreur , le salaire entrée nest pas dans les bornes de la classe du membre de léquipage !');
	end
end;

----Développement et sécurité des données au département EDEVgo;--A------
use dbdev;
select * from Questions;
select * from Avoirs;
select * from joueurs;
select * from Categories;
select * from Reponses;

---1--
go;


SELECT TOP 1 idQuestion FROM Questions where flag = 'n' ORDER BY NEWID();    


go;
---demander si il faut retourner le idQuestion au joueur , dont si oui transformer en function returns int
create or alter  procedure PigerQuestion(@pidJoueur int)
as
declare 
@pidQuestion int;
	select TOP 1 @pidQuestion = idQuestion FROM Questions where flag = 'n' ORDER BY NEWID(); 
begin try
	begin transaction
		update Questions set flag = 'o' where idQuestion = @pidQuestion;
	commit;
end try

begin catch
rollback;
print ERROR_MESSAGE();
print ERROR_LINE();
end catch;

---2---ValiderRéponse
go;
select * from Avoirs;
create procedure ValiderRéponse(@pidRéponse int , @pidJoueur int)
as
declare 
@pidQuestion int,
@pestBone char(1),
@pdifficulte smallint,
@pnbPoints int;

select @pidQuestion = idQuestion from Reponses where idReponse = @pidRéponse;
select @pestBone = estBonne from Reponses where idReponse = @pidRéponse;
select @pdifficulte = Questions.difficulte from Questions where idQuestion = @pidQuestion;
begin try
	begin transaction
		if(@pidJoueur not in (select idJoueur from Avoirs))
			insert into Avoirs values(@pidJoueur , 0 , 0 , 0);
		if(@pdifficulte = 1)
			update Avoirs set Avoirs.nbBronze += 5 where idJoueur = @pidJoueur;
			return;
		if(@pdifficulte = 2)
			update Avoirs set Avoirs.nbArgent += 10 where idJoueur = @pidJoueur;
			return;
		if(@pdifficulte =3)
			update Avoirs set Avoirs.nbOr += 15 where idJoueur = @pidJoueur;
			return
	commit;
end try

begin catch
rollback;
print ERROR_MESSAGE();
print ERROR_LINE();
end catch

----3----AjouterQuestionRéponses
go;


create or alter procedure AjouterQuestionRéponses( @enonce varchar(60), @idcategorie char(1), @difficulte char(1),
@rep1 varchar(60) , @estBonne char(1) ,
@rep2 varchar(60), @estBonneB char(1) ,
@rep3 varchar(60) , @estBonneC char(1) ,
@rep4 varchar(60) , @estBonneD char(1))

AS
BEGIN
declare @idquestion int;
begin try
	begin transaction
		insert into Questions(enonce , flag , difficulte , idCategorie) values (@enonce , 'n' , @difficulte , @idcategorie);

		select @idquestion = @@IDENTITY;

		
		insert into Reponses(laReponse , estBonne , idQuestion) values (@rep1 , @estBonne , @idquestion);
		insert into Reponses(laReponse , estBonne , idQuestion) values (@rep2 , @estBonneB , @idquestion);
		insert into Reponses(laReponse , estBonne , idQuestion) values (@rep3 , @estBonneC , @idquestion);
		insert into Reponses(laReponse , estBonne , idQuestion) values (@rep4 , @estBonneD , @idquestion);
		commit;
	end try
	begin catch
		rollback;
		print ERROR_MESSAGE();
		print ERROR_LINE();
	end catch
end


--execution AjouterQuestionRéponses
Execute AjouterQuestionRéponses
@enonce = 'allo',
@idCategorie = 's',
@difficulte = '1',
@rep1 = 'ok',
@estBonne = 'n',
@rep2 = 'aa',
@estBonneB = 'n',
@rep3 = 'gg',
@estBonneC = 'n',
@rep4 = 'hh',
@estBonneD= 'o';
---4---CTRLRéponse
go;
create trigger CTRLRéponse on Reponses after insert
as
declare
@pestBonne char(1),
@pidQuestion int,
@pnbBonneReponse int;
select @pidQuestion = idQuestion from inserted;

select @pnbBonneReponse = count(idReponse) from Reponses where idQuestion = @pidQuestion and estBonne = 'o';
begin 
if(@pnbBonneReponse >0)
	print 'erreur , il y a déja une bonne réponse pour cette question !'
	rollback;
end

---5 donner les droit juste au ligne de l'usager dans avoir (update et insert) page 114 transact sql
select * from joueurs;
go;
create or alter view AvoirKirk as
select * from Avoirs where Avoirs.idJoueur = 3
with check option;


grant insert on AvoirKirk to[James Kirk];
grant update on AvoirKirk to[James Kirk];

go;
create or alter view AvoirTipole as
select * from Avoirs where Avoirs.idJoueur =2
with check option;

grant insert , update on AvoirTipole to[LPR_dba] with grant option;

create role AvoirGrant1;
grant insert , update on AvoirTipole to AvoirGrant with grant option;

alter role[AvoirGrant1] add member[LPR_dba];


grant insert,update on AvoirTipole to[Lanna Tipole];

go;
create or alter view AvoirSpoke as
select * from Avoirs where Avoirs.idJoueur =1
with check option;


grant insert,update on AvoirSpoke to[Spoke Spoky];

go;

create or alter view AvoirTrip as
select * from Avoirs where Avoirs.idJoueur =4
with check option;

grant insert,update on AvoirTrip to[Trip Thomas];

go;

create or alter view AvoirTores as
select * from Avoirs where Avoirs.idJoueur =5
with check option;

grant insert,update on AvoirTores to[Melinda Tores];



---B----

alter table Joueurs add motDePasse varbinary(128),
carteDeCredit varbinary(128);

select * from Joueurs;
go;
---1---AjouterJoueur
create procedure AjouterJoueur(@palias varchar(20), @pnom varchar(30) , @pprenom varchar(30) , @pmotDePasse varchar(30))
as
declare 
@phash varbinary(128);
select @phash = HASHBYTES('SHA2_512' , @pmotDePasse);
begin try
	begin transaction
		insert into Joueurs values(@palias , @pnom , @pprenom  ,@phash , null);
	commit;
end try

begin catch
rollback;
print ERROR_MESSAGE();
print ERROR_LINE();
end catch

--execution AjouterJoueur
Execute AjouterJoueur
@palias = 'LP',
@pnom = 'Rousseau',
@pprenom ='louis-philippe',
@pmotDePasse = '12345';

execute AjouterJoueur
@palias = 'JB',
@pnom = 'Black',
@pprenom ='Jack',
@pmotDePasse = 'joueur123';

select * from joueurs;

---2---ModifierMotDePasse
go;
create or alter procedure ModifierMotDePasse(@palias varchar(20) ,@pmotDePasse varchar(30) , @pnouveauMotDePasse varchar(30))
as
declare
@pnewEncrypted varbinary(128),
@pMPasseActuelle varbinary(128);
select @pMPasseActuelle = motDePasse from Joueurs where Joueurs.alias = @palias;
begin try
	begin transaction
		if(HASHBYTES('SHA2_512' , @pmotDePasse) = @pMPasseActuelle)
			begin
				select @pnewEncrypted = HASHBYTES('SHA2_512' , @pnouveauMotDePasse);
				update Joueurs set motDePasse = @pnewEncrypted where Joueurs.alias = @palias;
			end
		else print'mot de passe incorrect';
	commit;
end try

begin catch
rollback;
print ERROR_MESSAGE();
print ERROR_LINE();
end catch

--execution ModifierMotDePasse
--à marcher 
execute ModifierMotDePasse
@palias = 'LP',
@pmotDePasse = '12345',
@pnouveauMotDePasse = '123456';
--marche pas
execute ModifierMotDePasse
@palias = 'LP',
@pmotDePasse = 'salut',
@pnouveauMotDePasse = '12345';

--remettre mot de passe 12345
execute ModifierMotDePasse
@palias = 'LP',
@pmotDePasse = '123456',
@pnouveauMotDePasse = '12345';



---3---ValiderIdentité
go;
select * from Joueurs;
create or alter function ValiderIdentité(@palias varchar(20) , @pmotDePasse varchar(30)) returns int
as
begin 
declare
@pMPasseActuelle varbinary(128),
@valide int;
select @pMPasseActuelle = motDePasse from Joueurs where Joueurs.alias = @palias;
	if(HASHBYTES('SHA2_512' , @pmotDePasse) = @pMPasseActuelle)
		return 0;

return 1
end
go;

--execution
--marche (retourne 0)
declare @valide int
set @valide = dbo.ValiderIdentité('LP' , '12345')
select @valide;
--marche pas (retourne 1)
declare @valide int
set @valide = dbo.ValiderIdentité('LP' , 'ceciEstLeMauvaisMotDePasse')
select @valide;

---4---AjouterInfoCrédit
go;

create or alter procedure AjouterInfoCrédit (@pid int, @pmotdepasse varchar(30),
@pcarteNonCrypte varchar(20)) as
begin try
	declare @pmotdepasseHash varbinary(128);
	select @pmotdepasseHash = motDePasse from joueurs where idJoueur =@pid;
		if(HASHBYTES('SHA2_512',@pmotdepasse ) = @pmotdepasseHash)
		begin transaction
			update joueurs set carteDeCredit =
			ENCRYPTBYPASSPHRASE(@pmotdepasse, @pcarteNonCrypte , 0)
			where joueurs.idJoueur =@pid;
		commit;
end trybegin catchrollback;print ERROR_MESSAGE();print ERROR_LINE();end catch--execution 6 est le id de LPselect * from joueurs;--marcheexecute AjouterInfoCrédit@pid = 6,@pmotdepasse  = '12345',@pcarteNonCrypte = '123123123';execute AjouterInfoCrédit@pid = 7,@pmotdepasse  = 'joueur123',@pcarteNonCrypte = '4514411';--marche pas execute AjouterInfoCrédit@pid = 6,@pmotdepasse  = 'ceciestlemauvaisMotDePasse',@pcarteNonCrypte = '123123123';----5--- ObtenirInfoCréditselect * from joueurs;go;create or alter function ObtenirInfoCrédit(@pid int , @pmotDePasse varchar(30)) returns tableasRETURN(	SELECT alias, nom,prenom ,  carteDeCredit AS 'carte encrypte',
	CONVERT(varchar, DECRYPTBYPASSPHRASE(@pmotDePasse, carteDeCredit , 0))
	AS 'carte decryptée' FROM joueurs where joueurs.idJoueur =@pid);---execution 6 est le id de LP--marchego;select * from ObtenirInfoCrédit(7,'joueur123');--marche pas select * from ObtenirInfoCrédit(7,'mauvaismotdepasse');select * from Joueurs;








	





