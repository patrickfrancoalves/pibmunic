LIBNAME RECEITA "/dados/RISCO/Modelagem_Nas/Risco_de_Credito/Fraude/Receita";



/*- Passo 01: Recupera��o do CNPJ 8 d�gitos do BNDES indireta autom�tica -*/
DATA AUTO(COMPRESS=YES);SET RECEITA.INDIRETAS_AUTOMATICAS;
    EMPRESA5=substr(compress(cnpj,'*.-/ '),1,5);
	NOME=LOWCASE(COMPRESS(CLIENTE,'+"/.-�` "&@*,_&%#()[]{}������'));
	NOME=LOWCASE(COMPRESS(NOME,"'"));
	NOME = TRANWRD(NOME,'�','o');
    NOME = TRANWRD(NOME,'�','o');
	NOME = TRANWRD(NOME,'�','e');
	NOME = TRANWRD(NOME,'�','a');
	NOME = TRANWRD(NOME,'�','a');
	NOME = TRANWRD(NOME,'�','i');
	NOME = TRANWRD(NOME,'�','o');
	NOME = TRANWRD(NOME,'�','a');
	NOME = TRANWRD(NOME,'�','u');
	NOME = TRANWRD(NOME,'�','c');
	NOME = SUBSTR(NOME,1,15); * 10 primeiros algarismos do nome;
run;


PROC SQL NOPRINT;
CREATE TABLE AUTOC AS 
SELECT DISTINCT CLIENTE,CNPJ,EMPRESA5,NOME
FROM AUTO
WHERE CNPJ NE ''
ORDER BY CNPJ;
QUIT;



/*- PASSO 02 - NOMES E CNPJ PELA RECEITA - 2010 A 2015 -*/
PROC SQL NOPRINT;
CREATE TABLE RECEITA AS
SELECT DISTINCT NUMCNPJ_RAIZ AS EMPRESA,
     CASE WHEN NUMCNPJ_RAIZ='34028316' THEN 'Correios e telegrafos'
	      WHEN NUMCNPJ_RAIZ='00000000' THEN 'BANCO DO BRASIL SA'
          ELSE RZA_SOC END AS RAZAO_SOCIAL2
FROM RECEITA.TB_RFB_EMPRESA
WHERE NUMCNPJ_RAIZ NE ''
UNION
SELECT DISTINCT SUBSTR(CNPJ,1,8) AS EMPRESA,
     CASE WHEN SUBSTR(CNPJ,1,8)='34028316' THEN 'Correios e telegrafos'
	      WHEN SUBSTR(CNPJ,1,8)='00000000' THEN 'BANCO DO BRASIL SA'
          ELSE Cliente END AS RAZAO_SOCIAL2
FROM RECEITA.NAOAUTOMATICAS
WHERE CNPJ NE '';
QUIT;


DATA RECEITA(COMPRESS=YES);SET RECEITA;
	NOME = LOWCASE(COMPRESS(RAZAO_SOCIAL2,'+"/.-�` "&@*,_&%#()[]{}������'));
	NOME = LOWCASE(COMPRESS(NOME,"'"));
	NOME = TRANWRD(NOME,'�','o');
    NOME = TRANWRD(NOME,'�','o');
	NOME = TRANWRD(NOME,'�','e');
	NOME = TRANWRD(nome,'�','a');
	NOME = TRANWRD(nome,'�','a');
	NOME = TRANWRD(nome,'�','i');
	NOME = TRANWRD(nome,'�','o');
	NOME = TRANWRD(nome,'�','a');
	NOME = TRANWRD(nome,'�','u');
	NOME = TRANWRD(nome,'�','c');
	NOME = SUBSTR(NOME,1,15); * 10 primeiros algarismos do nome;
EMPRESA5 =SUBSTR(EMPRESA,4,5);
RUN;



/*- PASSO 03 - TRATAMENTO E UNIFICA��O RAIS E EMPRESAS DO BNDES -*/
PROC SORT DATA=RECEITA PRESORTED SORTSIZE=MAX;BY NOME EMPRESA5;RUN;
PROC SORT DATA=AUTOC   PRESORTED SORTSIZE=MAX;BY NOME EMPRESA5;RUN;

/* unificando as bases no BNDES - TRADUTOR */
DATA UNIR(COMPRESS=YES);
RETAIN EMPRESA5 NOME; 
MERGE AUTOC(IN=A) RECEITA;
BY NOME EMPRESA5;
IF A;
RUN;

/* tirando algumas repeti��o */
PROC SORT DATA=UNIR NODUPKEY PRESORTED SORTSIZE=MAX;BY NOME EMPRESA5;RUN;





/*- PASSO 05 - Consultas na base recuperada -*/
PROC SQL NOPRINT; 
CREATE TABLE TEMPO AS
SELECT 'CNPJ recuperado' AS TIPO,
       COUNT(*) AS CONTAGEM,
	   SUM(VALOR_CONTRATO) AS VR_CONTRATO_REC,
	   SUM(VALOR_DESEMBOLSO) AS VR_DESEMBOLSO_REC
FROM RECEITA.BNDES
UNION
SELECT 'Total de empresas' AS TIPO,
       COUNT(*) AS CONTAGEM,
       SUM(VALOR_CONTRATO) AS VR_CONTRATO_REC,
	   SUM(VALOR_DESEMBOLSO) AS VR_DESEMBOLSO_REC
FROM RECEITA.BNDES
WHERE EMPRESA NE '';
QUIT;





/*- Passo 03: Renomeando vari�veis para nomes mais intuit�vos -*/
/*- OBS: 'Transparente' cont�m opera��es contratadas na forma -*/
/*-      direta e indireta n�o-autom�tica (de 2002 at� 30.06.2016)    -*/


/*- PASSO 04 - RECUPERANDO CNPJ8 DO BNDES -*/
PROC SORT DATA=UNIR PRESORTED;BY CLIENTE EMPRESA5;RUN;
PROC SORT DATA=AUTO PRESORTED;BY CLIENTE EMPRESA5;RUN;

*Base recuperada;
DATA RECEITA.BNDES(COMPRESS=YES); 
RETAIN EMPRESA;
MERGE UNIR AUTO(in=a);
BY CLIENTE EMPRESA5;
IF A;
RUN;





*Por ano;
PROC SQL NOPRINT; 
CREATE TABLE A AS 
SELECT YEAR(DATA_CONTRATO) AS ANO,
       COUNT(DISTINCT EMPRESA) as TOTAL_REC,
	   SUM(VALOR_CONTRATO) AS VR_CONTRATO_REC,
	   SUM(VALOR_DESEMBOLSO) AS VR_DESEMBOLSO_REC
FROM RECEITA.BNDES
WHERE EMPRESA NE ''
GROUP BY ANO;

CREATE TABLE B AS 
SELECT YEAR(DATA_CONTRATO) AS ANO,
       COUNT(DISTINCT cliente) AS TOTAL,
	   SUM(VALOR_CONTRATO) AS VR_CONTRATO_TOTAL,
	   SUM(VALOR_DESEMBOLSO) AS VR_DESEMBOLSO_TOTAL
FROM RECEITA.BNDES 
WHERE CLIENTE NE ''
GROUP BY ANO;
CREATE TABLE C AS 
SELECT DISTINCT A.ANO,A.TOTAL_REC,B.TOTAL,VR_CONTRATO_REC,
       VR_CONTRATO_TOTAL,VR_DESEMBOLSO_REC,VR_DESEMBOLSO_TOTAL
       
FROM A,B
WHERE A.ANO=b.ANO;
QUIT;
