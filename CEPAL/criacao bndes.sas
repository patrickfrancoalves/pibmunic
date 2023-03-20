LIBNAME RECEITA "/dados/RISCO/Modelagem_Nas/Risco_de_Credito/Fraude/Receita";
LIBNAME bndes "\\sbsb2\DPTI\Bases\BNDES\New";
LIBNAME rais "\\STORAGE2\FormatoSAS";

/*- Passo 01: Importação do banco de dados bndes transparentes -*/
proc import datafile= "\\sbsb2\DPTI\Bases\BNDES\New\Site Transparencia\novas bases\base-contratacoes.xlsx"
            out     = transparent replace
            dbms    = xlsx;
            getnames= yes;
run;

proc import datafile="\\sbsb2\DPTI\Bases\BNDES\New\Site Transparencia\2002+-+2008.xlsx" 
replace out=automatica1 dbms=xlsx ;range="2002_-_2008$A8:0"; run;

proc import datafile="\\sbsb2\DPTI\Bases\BNDES\New\Site Transparencia\2009+-+2010.xlsx" 
replace out=automatica2 dbms=xlsx ;range="2009_-_2010$A8:0";run;

proc import datafile="\\sbsb2\DPTI\Bases\BNDES\New\Site Transparencia\2011+-+2012.xlsx" 
replace out=automatica3 dbms=xlsx ;range="2011_-_2012$A8:0";run;

proc import datafile="\\sbsb2\DPTI\Bases\BNDES\New\Site Transparencia\2013+-+2014.xlsx" 
replace out=automatica4 dbms=xlsx ;range="2013_-_2014$A8:0";run;

proc import datafile="\\sbsb2\DPTI\Bases\BNDES\New\Site Transparencia\novas bases\operacoes+2015+a+2016.xlsx"
replace out=automatica5 dbms=xlsx ;range="operacoes 2015 a 2016$A8:0";run; 

/*- Passo 02: Recuperação do CNPJ 8 dígitos do BNDES indireta automática -*/
data auto; set automatica1-automatica5;
  cliente = Cliente_final;
  empresa5=substr(compress(cnpj,'*.-/ '),1,5);
  if Modalidade_de_apoio='' then Modalidade_de_apoio=_Modalidade_de_apoio;
  drop _Modalidade_de_apoio;
run;

* Empresas que ocorreram na base entre 2002 e jun/2016 - pelo nome ;
proc sql;
	create table autoc as
	   select distinct cliente as cliente, cnpj 
	from auto
	where cnpj ne ''
	group by cliente, cnpj
	order by cnpj;
quit;

/*- PASSO 02.01 - NOMES E CNPJ PELA RAIS - 2010 A 2015 -*/
%macro rais;
%do ano=2010 %to 2015;
proc sql; 
	 create table rais&ano. as
	 select distinct cnpj_raiz as empresa,
	  case
	    when cnpj_raiz = '34028316' then 'Correios e telegrafos'
	    when cnpj_raiz = '00000000' then 'BANCO DO BRASIL SA'
		else razao_social
	  end as razao_social2
	from rais.estab&ano.
	where empresa ne ''
	group by empresa
	order by empresa;
	%end;
quit;
%mend rais;
%rais;

/*- PASSO 02.02 - TRATAMENTO E UNIFICAÇÃO RAIS E EMPRESAS DO BNDES -*/
* tratando o campo nome, empresa e unificando os anos - RAIS;
data rais(compress=yes); merge rais:;
	nome=lowcase(compress(razao_social2,'/.-´` "&@*,_&%#()[]{}ºª¹²³£'));
	nome=lowcase(compress(nome,"'"));
	nome=tranwrd(nome,'ó','o');
    nome=tranwrd(nome,'ô','o');
	nome=tranwrd(nome,'é','e');
	nome=tranwrd(nome,'á','a');
	nome=tranwrd(nome,'à','a');
	nome=tranwrd(nome,'í','i');
	nome=tranwrd(nome,'õ','o');
	nome=tranwrd(nome,'ã','a');
	nome=tranwrd(nome,'ü','u');
	nome=tranwrd(nome,'ç','c');
	nome=substr(nome,1,10); * 10 primeiros algarismos do nome;
	empresa5=substr(empresa,4,5);
 by empresa;
run;

proc delete data=rais2002-rais2015; run; * CUIDADO ;
libname local "C:\Users\b2657804\Downloads\tradutor-nome-RAIS";
data local.raisnome(compress=YES); set rais; run;
 data rais; set local.raisnome;run;

* tratando o campo nome - BNDES;
data bndesc; set autoc;
	nome=lowcase(compress(Cliente,'/.-´` "&@*,_&%#()[]{}ºª¹²³£'));
	nome=lowcase(compress(nome,"'"));
	nome=tranwrd(nome,'ó','o');
    nome=tranwrd(nome,'ô','o');
	nome=tranwrd(nome,'é','e');
	nome=tranwrd(nome,'á','a');
	nome=tranwrd(nome,'à','a');
	nome=tranwrd(nome,'í','i');
	nome=tranwrd(nome,'õ','o');
	nome=tranwrd(nome,'ã','a');
	nome=tranwrd(nome,'ü','u');
	nome=tranwrd(nome,'ç','c');
	nome=substr(nome,1,10);
	empresa5=substr(compress(cnpj,'*.-/ '),1,5);
run;

proc sort data=rais presorted; by nome empresa5; run;
proc sort data=bndesc presorted; by nome empresa5; run;

/* unificando as bases no BNDES - TRADUTOR */
data unir; retain empresa5 nome; 
 merge bndesc(in=a) rais;
 by nome empresa5;
 if a;
run;

/* tirando algumas repetição */
proc sort data=unir nodupkey presorted;
  by  nome empresa5; 
run;

/*- PASSO 02.03 - RECUPERANDO CNPJ8 DO BNDES -*/
proc sort data=auto presorted; by cliente empresa5; run;
proc sort data=unir presorted; by cliente empresa5; run;

*Base recuperada;
data bndesi; retain empresa ano;
  merge unir auto(in=a);
  by cliente empresa5;
  if a;
run;

/*- PASSO 02.04 - Consultas na base recuperada *************************************/
proc sql; 
	select count(*) 'CNPJ recuperado'
	from bndesi
	where empresa ne '';

	select count(*) 'Total de empresas'
	from auto
	where cnpj ne '';

*Por ano;
create table a as
	select distinct ano, count(distinct empresa) as recuperado
	from bndesi
	where empresa ne ''
	group by ano;

create table b as
	select distinct ano , count(distinct cliente) as total
	from auto
	where cliente ne ''
	group by ano;

  select a.ano, a.recuperado, b.total, a.recuperado/b.total format= percent7.1 'Proporção recuperada'
  from a, b
  where a.ano=b.ano;
quit;


/*- Passo 03: Renomeando variáveis para nomes mais intuitívos -*/
/*- OBS: 'Transparente' contém operações contratadas na forma -*/
/*-      direta e indireta não-automática (de 2002 até 30.06.2016)    -*/
data transparente; set transparent;
rename Agente_Financeiro           = agente
       contrato                    = nu_contrato
       Data_da_Contrata__o         = data
       Descri__o_do_Projeto        = descricao
       Forma_de_Apoio              = apoio
       Modalidade_de_Apoio         = modalidade
       Prazo_Amortiza__o_Contrato  = Prazo_Amortiza
       Prazo_Car_ncia_Contrato     = prazo_carencia
       Ramo_G_nero_de_Atividade   = setor_bndes
       Tipo_de_Garantia            = garantia 
       Val_Contratado_R_           = Val_Contratado
       _rea_Operacional            = area           ;
  empresa=substr(CNPJ,1,8);
  ano=year(Data_da_Contrata__o);
  mes=month(Data_da_Contrata__o);
 drop Data_da_Contrata__o;
run;
 
data bndess; set bndesi;
rename  
  _Institui__o_Financeira_Credenci = agente
	    Forma_de_Apoio             = apoio
       _Modalidade_de_Apoio        = modalidade
       VAR10                       = Prazo_Amortiza
       VAR9                        = prazo_carencia
	   VAR8						   = Juros
       _Ramo_G_nero_de_atividade   = setor_bndes
       VAR6                        = Val_Contratado
	   _UF						   = UF;
  ano=input(compress(substr((compress(_Data_da_contrata__o,' /')),5,4)),4.);
  mes=input(compress(substr((compress(_Data_da_contrata__o,' /')),3,2)),2.);
 drop _Data_da_contrata__o;
run;

proc sort data=transparente presorted; by empresa; run;
proc sort data=bndess presorted; by empresa; run;

data bndes.bndes(compress=yes); set bndess transparente;
  where empresa ne '';
  drop empresa5 nome cliente CNPJ razao_social2 Cliente_final;
  UF=compress(UF);
run;

proc sql;
	create table bndes.bndespainel as
	select distinct empresa, ano, sum(Val_Contratado) as contratacao
	from bndes.bndes
	group by empresa, ano
	order by empresa, ano;
quit;
 
%macro bndesano;
%do ano = 2002 %to 2016;
	data bndes.bndes&ano; set bndes.bndespainel;
	 if ano=&ano;
	run;
%end;
%mend bndesano;
%bndesano;


