LIBNAME FRAUDE  "/dados/RISCO/Modelagem_Nas/Risco_de_Credito/Fraude";
OPTIONS COMPRESS=YES;


/*--------------------------------------------------------------------------------*/
/*---  signos                                                                  ---*/
/*--------------------------------------------------------------------------------*/

proc format lib=work;
  value sign
  '21Mar2000'd - '19Apr2000'd = 'Aries'
  '20Apr2000'd - '20May2000'd = 'Taurus'
  '21May2000'd - '20Jun2000'd = 'Gemini'
  '21Jun2000'd - '22Jul2000'd = 'Cancer'
  '23Jul2000'd - '22Aug2000'd = 'Leo'
  '23Aug2000'd - '22Sep2000'd = 'Virgo'
  '23Sep2000'd - '22Oct2000'd = 'Libra'
  '23Oct2000'd - '21Nov2000'd = 'Scorpio'
  '22Nov2000'd - '21Dec2000'd = 'Sagittarious'
  '22Dec2000'd - '31Dec2000'd = 'Capricorn'
  '01Jan2000'd - '19Jan2000'd = 'Capricorn'
  '20Jan2000'd - '18Feb2000'd = 'Aquarius'
  '19Feb2000'd - '20Mar2000'd = 'Pisces'
  other = 'Unknown';
run;


/*--------------------------------------------------------------------------------*/
/*--- Worst Match: https://www.yourchineseastrology.com/zodiac/compatibility/  ---*/
/*--- LUCKY DAYS AND MONTHS: http://www.chinesezodiac.com/calculator.php       ---*/
/*--------------------------------------------------------------------------------*/

OPTIONS COMPRESS=YES;
PROC SQL;
CREATE TABLE CHINESE AS 
SELECT *,DAY(DATASORT) AS DIA,MONTH(DATASORT) AS MES,
       CASE WHEN DATASORT BETWEEN '16FEB1999'd AND '04FEB2000'd THEN 'Rabbit'
            WHEN DATASORT BETWEEN '05FEB2000'd AND '23JAN2001'd THEN 'Dragon'
			WHEN DATASORT BETWEEN '24JAN2001'd AND '11FEB2002'd THEN 'Snake'
            WHEN DATASORT BETWEEN '12FEB2002'd AND '31JAN2003'd THEN 'Horse'
			WHEN DATASORT BETWEEN '01FEB2003'd AND '21JAN2004'd THEN 'Goat'
            WHEN DATASORT BETWEEN '22JAN2004'd AND '08FEB2005'd THEN 'Monkey'
            WHEN DATASORT BETWEEN '02FEB2005'd AND '28JAN2006'd THEN 'Rooster'
            WHEN DATASORT BETWEEN '29JAN2006'd AND '17JAN2007'd THEN 'Dog'
            WHEN DATASORT BETWEEN '18FEB2007'd AND '06FEB2008'd THEN 'Pig'
            WHEN DATASORT BETWEEN '07FEB2008'd AND '25JAN2009'd THEN 'Rat'


            WHEN DATASORT BETWEEN '2009-01-26' AND '2010-02-13' THEN 'Ox'
            WHEN DATASORT BETWEEN '2010-02-14' AND '2011-02-02' THEN 'Tiger'
            WHEN DATASORT BETWEEN '2011-02-03' AND '2012-01-22' THEN 'Rabbit'
            WHEN DATASORT BETWEEN '2012-01-23' AND '2013-02-09' THEN 'Dragon'
            WHEN DATASORT BETWEEN '2013-02-10' AND '2014-01-30' THEN 'Snake'
            WHEN DATASORT BETWEEN '2014-01-31' AND '2015-02-18' THEN 'Horse'
            WHEN DATASORT BETWEEN '2015-02-19' AND '2016-02-07' THEN 'Goat'
            WHEN DATASORT BETWEEN '2016-02-08' AND '2017-01-27' THEN 'Monkey'
            WHEN DATASORT BETWEEN '2017-01-28' AND '2018-02-15' THEN 'Rooster'
            WHEN DATASORT BETWEEN '2018-02-16' AND '2019-02-04' THEN 'Dog'
            WHEN DATASORT BETWEEN '2019-02-05' AND '2020-01-24' THEN 'Pig'
            WHEN DATASORT BETWEEN '2020-01-25' AND '2021-02-11' THEN 'Rat'
            WHEN DATASORT BETWEEN '2021-02-12' AND '2022-01-31' THEN 'Ox'
            WHEN DATASORT BETWEEN '2022-02-01' AND '2023-01-21' THEN 'Tiger'
            WHEN DATASORT BETWEEN '2023-01-22' AND '2024-02-09' THEN 'Rabbit'
            WHEN DATASORT BETWEEN '2024-02-10' AND '2025-01-28' THEN 'Dragon'
            WHEN DATASORT BETWEEN '2025-01-29' AND '2026-02-16' THEN 'Snake'
            WHEN DATASORT BETWEEN '2026-02-17' AND '2027-02-05' THEN 'Horse'
            WHEN DATASORT BETWEEN '2027-02-06' AND '2028-01-25' THEN 'Goat'
            WHEN DATASORT BETWEEN '2028-01-26' AND '2029-02-12' THEN 'Monkey'
            WHEN DATASORT BETWEEN '2029-02-13' AND '2030-02-02' THEN 'Rooster'
            WHEN DATASORT BETWEEN '2030-02-03' AND '2031-01-22' THEN 'Dog'
            WHEN DATASORT BETWEEN '2031-01-23' AND '2032-02-10' THEN 'Pig'
            WHEN DATASORT BETWEEN '2032-02-11' AND '2033-01-30' THEN 'Rat'
            WHEN DATASORT BETWEEN '2033-01-31' AND '2034-02-18' THEN 'Ox'
            WHEN DATASORT BETWEEN '2034-02-19' AND '2035-02-07' THEN 'Tiger'
            WHEN DATASORT BETWEEN '2035-02-08' AND '2036-01-27' THEN 'Rabbit'
            WHEN DATASORT BETWEEN '2036-01-28' AND '2037-02-14' THEN 'Dragon'
            WHEN DATASORT BETWEEN '2037-02-15' AND '2038-02-03' THEN 'Snake'
            WHEN DATASORT BETWEEN '2038-02-04' AND '2039-01-23' THEN 'Horse'
            WHEN DATASORT BETWEEN '2039-01-24' AND '2040-02-11' THEN 'Goat'
            WHEN DATASORT BETWEEN '2040-02-12' AND '2041-01-31' THEN 'Monkey'
            WHEN DATASORT BETWEEN '2041-02-01' AND '2042-01-21' THEN 'Rooster'
            WHEN DATASORT BETWEEN '2042-01-22' AND '2043-02-09' THEN 'Dog'
            WHEN DATASORT BETWEEN '2043-02-10' AND '2044-01-29' THEN 'Pig'
            ELSE '-2' END AS CHINA_ZODIAC 

FROM FRAUDE.QUINA
WHERE DataSort BETWEEN '01JAN2000'd AND '22JUN2023'd;
QUIT;

PROC SQL;
    SELECT A.* ,
    MDY(MONTH(DataSort),DAY(DataSort),2000) as SIGNO FORMAT=sign. ,
    CASE WHEN (CHINA_ZODIAC='Ox'      AND MES IN (4,11)     ) OR
		      (CHINA_ZODIAC='Tiger'   AND MES IN (1,4,5,11) ) OR
			  (CHINA_ZODIAC='Rabbit'  AND MES IN (2,6,9,12) ) OR
              (CHINA_ZODIAC='Dragon'  AND MES IN (5,6)      ) OR 
              (CHINA_ZODIAC='Snake'   AND MES IN (3,9,12)   ) OR
              (CHINA_ZODIAC='Horse'   AND MES IN (5,7,11)   ) OR
              (CHINA_ZODIAC='Monkey'  AND MES IN (7,11)     ) OR
			  (CHINA_ZODIAC='Goat'    AND MES IN (3,6,10)   ) OR
			  (CHINA_ZODIAC='Rooster' AND MES IN (3,9,12)   ) OR
			  (CHINA_ZODIAC='Dog'     AND MES IN (5,8)      ) OR
			  (CHINA_ZODIAC='Pig'     AND MES IN (4,9,12)   ) OR
			  (CHINA_ZODIAC='Rat'     AND MES IN (4,10,12)  ) THEN 1 
              ELSE 0 END AS UNLUCKY_MONTH ,
    CASE WHEN (CHINA_ZODIAC='Ox'      AND DIA IN (13,27)    ) OR
		      (CHINA_ZODIAC='Tiger'   AND DIA IN (16,27)    ) OR
			  (CHINA_ZODIAC='Rabbit'  AND DIA IN (26,27,29) ) OR
              (CHINA_ZODIAC='Dragon'  AND DIA IN (1,16)     ) OR 
              (CHINA_ZODIAC='Snake'   AND DIA IN (1,23)     ) OR
              (CHINA_ZODIAC='Horse'   AND DIA IN (5,20)     ) OR
              (CHINA_ZODIAC='Monkey'  AND DIA IN (14,28)    ) OR
			  (CHINA_ZODIAC='Goat'    AND DIA IN (7,30)     ) OR
			  (CHINA_ZODIAC='Rooster' AND DIA IN (4,26)     ) OR
			  (CHINA_ZODIAC='Dog'     AND DIA IN (7,28)     ) OR
			  (CHINA_ZODIAC='Pig'     AND DIA IN (17,24)    ) OR
			  (CHINA_ZODIAC='Rat'     AND DIA IN (4,13)     ) THEN 1 
              ELSE 0 END AS LUCKY_DAY ,
	CASE WHEN CHINA_ZODIAC IN ('Snake','Monkey') THEN 1 ELSE 0 END AS UNLUCKY_YEAR
FROM;
QUIT;

DATA CHINESEZODIAC;set CHINESEZODIAC;
IF LUCKY_DAY=0 AND UNLUCKY_MONTH=1 AND UNLUCKY_YEAR=1 THEN UNLUCKY=1;
ELSE UNLUCKY=0;
RUN;


PROC FREQ DATA=CHINESEZODIAC;
TABLE FRAUDE * LUCKY_DAY;
TABLE FRAUDE * UNLUCKY_YEAR;
TABLE FRAUDE * UNLUCKY_MONTH;
RUN;




/*0 'Dragon'*/
/*1 'Snake'*/
/*2 'Horse'*/
/*3 'sheep'*/
/*4 'Monkey'*/
/*5 'Rooster'*/
/*6 'Dog'*/
/*7 'Pig'*/
/*8 'Rat'*/
/*9 'Ox'*/
/*10 'Tiger'*/
/*11 'Hare'*/


/*
Feb 5, 1924 – Jan 23, 1925 Rat
Jan 24, 1925 – Feb 12, 1926 Ox
Feb 13, 1926 – Feb 1, 1927 Tiger
Feb 2, 1927 – Jan 22, 1928 Rabbit
Jan 23, 1928 – Feb 9, 1929 Dragon
Feb 10, 1929 – Jan 29, 1930 Snake
Jan 30, 1930 – Feb 16, 1931 Horse
Feb 17, 1931 – Feb 5, 1932 Goat
Feb 6, 1932 – Jan 25, 1933 Monkey
Jan 26, 1933 – Feb 13, 1934 Rooster
Feb 14, 1934 – Feb 3, 1935 Dog
Feb 4, 1935 – Jan 23, 1936 Pig
Jan 24, 1936 – Feb 10, 1937 Rat
Feb 11, 1937 – Jan 30, 1938 Ox
Jan 31, 1938 – Feb 18, 1939 Tiger
Feb 19, 1939 – Feb 7, 1940 Rabbit
Feb 8, 1940 – Jan 26, 1941 Dragon
Jan 27, 1941 – Feb 14, 1942 Snake
Feb 15, 1942 – Feb 4, 1943 Horse
Feb 5, 1943 – Jan 24, 1944 Goat
Jan 25, 1944 – Feb 12, 1945 Monkey
Feb 13, 1945 – Feb 1, 1946 Rooster
Feb 2, 1946 – Jan 21, 1947 Dog
Jan 22, 1947 – Feb 9, 1948 Pig
Feb 10, 1948 – Jan 28, 1949 Rat
Jan 29, 1949 – Feb 16, 1950 Ox
Feb 17, 1950 – Feb 5, 1951 Tiger
Feb 6, 1951 – Jan 26, 1952 Rabbit
Jan 27, 1952 – Feb 13, 1953 Dragon
Feb 14, 1953 – Feb 2, 1954 Snake
Feb 3, 1954 – Jan 23, 1955 Horse
Jan 24, 1955 – Feb 11, 1956 Goat
Feb 12, 1956 – Jan 30, 1957 Monkey
Jan 31, 1957 – Feb 17, 1958 Rooster
Feb 18, 1958 – Feb 7, 1959 Dog
Feb 8, 1959 – Jan 27, 1960 Pig
Jan 28, 1960 – Feb 14, 1961 Rat
Feb 15, 1961 – Feb 4, 1962 Ox
Feb 5, 1962 – Jan 24, 1963 Tiger
Jan 25, 1963 – Feb 12, 1964 Rabbit
Feb 13, 1964 – Feb 1, 1965 Dragon
Feb 2, 1965 – Jan 20, 1966 Snake
Jan 21, 1966 – Feb 8, 1967 Horse
Feb 9, 1967 – Jan 29, 1968 Goat
Jan 30, 1968 – Feb 16, 1969 Monkey
Feb 17, 1969 – Feb 5, 1970 Rooster
Feb 6, 1970 – Jan 26, 1971 Dog
Jan 27, 1971 – Feb 14, 1972 Pig
Feb 15, 1972 – Feb 2, 1973 Rat
Feb 3, 1973 – Jan 22, 1974 Ox
Jan 23, 1974 – Feb 10, 1975 Tiger
Feb 11, 1975 – Jan 30, 1976 Rabbit
Jan 31, 1976 – Feb 17, 1977 Dragon
Feb 18, 1977 – Feb 6, 1978 Snake
Feb 7, 1978 – Jan 27, 1979 Horse
Jan 28, 1979 – Feb 15, 1980 Goat
Feb 16, 1980 – Feb 4, 1981 Monkey
Feb 5, 1981 – Jan 24, 1982 Rooster
Jan 25, 1982 – Feb 12, 1983 Dog
Feb 13, 1983 – Feb 1, 1984 Pig
Feb 2, 1984 – Feb 19, 1985 Rat
Feb 20, 1985 – Feb 8, 1986 Ox
Feb 9, 1986 – Jan 28, 1987 Tiger
Jan 29, 1987 – Feb 16, 1988 Rabbit
Feb 17, 1988 – Feb 5, 1989 Dragon
Feb 6, 1989 – Jan 26, 1990 Snake
Jan 27, 1990 – Feb 14, 1991 Horse
Feb 15, 1991 – Feb 3, 1992 Goat
Feb 4, 1992 – Jan 22, 1993 Monkey
Jan 23, 1993 – Feb 9, 1994 Rooster
Feb 10, 1994 – Jan 30, 1995 Dog
Jan 31, 1995 – Feb 18, 1996 Pig
Feb 19, 1996 – Feb 6, 1997 Rat
Feb 7, 1997 – Jan 27, 1998 Ox
Jan 28, 1998 – Feb 15, 1999 Tiger
Feb 16, 1999 – Feb 4, 2000 Rabbit
Feb 5, 2000 – Jan 23, 2001 Dragon
Jan 24, 2001 – Feb 11, 2002 Snake
Feb 12, 2002 – Jan 31, 2003 Horse
Feb 1, 2003 – Jan 21, 2004 Goat
Jan 22, 2004 – Feb 8, 2005 Monkey
Feb 9, 2005 – Jan 28, 2006 Rooster
Jan 29, 2006 – Feb 17, 2007 Dog
Feb 18, 2007 – Feb 6, 2008 Pig
Feb 7, 2008 – Jan 25, 2009 Rat
Jan 26, 2009 – Feb 13, 2010 Ox
Feb 14, 2010 – Feb 2, 2011 Tiger
Feb 3, 2011 – Jan 22, 2012 Rabbit
Jan 23, 2012 – Feb 9, 2013 Dragon
Feb 10, 2013 – Jan 30, 2014 Snake
Jan 31, 2014 – Feb 18, 2015 Horse
Feb 19, 2015 – Feb 7, 2016 Goat
Feb 8, 2016 – Jan 27, 2017 Monkey
Jan 28, 2017 – Feb 15, 2018 Rooster
Feb 16, 2018 – Feb 4, 2019 Dog
Feb 5, 2019 – Jan 24, 2020 Pig
Jan 25, 2020 – Feb 11, 2021 Rat
Feb 12, 2021 – Jan 31, 2022 Ox
Feb 1, 2022 – Jan 21, 2023 Tiger
Jan 22, 2023 – Feb 9, 2024 Rabbit
Feb 10, 2024 – Jan 28, 2025 Dragon
Jan 29, 2025 – Feb 16, 2026 Snake
Feb 17, 2026 – Feb 5, 2027 Horse
Feb 6, 2027 – Jan 25, 2028 Goat
Jan 26, 2028 – Feb 12, 2029 Monkey
Feb 13, 2029 – Feb 2, 2030 Rooster
Feb 3, 2030 – Jan 22, 2031 Dog
Jan 23, 2031 – Feb 10, 2032 Pig
Feb 11, 2032 – Jan 30, 2033 Rat
Jan 31, 2033 – Feb 18, 2034 Ox
Feb 19, 2034 – Feb 7, 2035 Tiger
Feb 8, 2035 – Jan 27, 2036 Rabbit
Jan 28, 2036 – Feb 14, 2037 Dragon
Feb 15, 2037 – Feb 3, 2038 Snake
Feb 4, 2038 – Jan 23, 2039 Horse
Jan 24, 2039 – Feb 11, 2040 Goat
Feb 12, 2040 – Jan 31, 2041 Monkey
Feb 1, 2041 – Jan 21, 2042 Rooster
Jan 22, 2042 – Feb 9, 2043 Dog
Feb 10, 2043 – Jan 29, 2044 Pig
*/



/*-------------------------------------------------------------------------*/
/* LEI DE BENFORD                                                          */
/* https://www.lexjansen.com/pharmasug/2001/Proceed/Posters/P10_smith.pdf  */
/*-------------------------------------------------------------------------*/

OPTIONS COMPRESS=YES;
PROC SQL;
CONNECT TO NETEZZA AS CON1(DATABASE=PRD_DWM SERVER=NTZP110 AUTHDOMAIN=NTZP110AUTH SQL_FUNCTIONS=ALL);
CREATE TABLE TESTE AS 
SELECT * , LOG10(1+1/FIRSTDGT) AS PROBFIRST
FROM CONNECTION TO CON1
  (SELECT FRAUDE,FIRSTDGT,
		  COUNT(*) AS FREQ,
		  CAST(COUNT(*) AS FLOAT)/SUM(COUNT(*)) OVER(PARTITION BY FRAUDE) AS PCT_EMPIRICA
    FROM
        (  SELECT DISTINCT NR_CPF_CNPJ,DH_TRN,NR_CPR_CNA,VR_TRN,
                  CAST(SUBSTRING(VR_TRN,1,1) AS INT) AS FIRSTDGT,
	              CAST(SUBSTRING(VR_TRN,2,1) AS INT) AS SECONDDGT,
				  CASE WHEN NR_CPF_CNPJ IN (&CPF_CNPJX.) AND NUMCPFCNPJENVOLVIDO IN (&CPF_CNPJS.) THEN 1
				  ELSE 0 END AS FRAUDE

           FROM TRANSACAO_PRODUTO
           WHERE DH_TRN BETWEEN '2019-06-01' AND '2019-12-01' 
                AND NUMCPFCNPJENVOLVIDO<>NR_CPF_CNPJ AND NUMCPFCNPJENVOLVIDO<>'-2'
                AND CD_NTZ_OPR='D' AND CD_MDL_PRD=1 AND CD_PRD=3 
                AND NR_CPR_CNA IN (&COOP.) AND VR_TRN>=10
                AND CD_TRN IN (232,233,5237,5238,5240,5472,5473,5239,5241,5242)
       ) AS A

	GROUP BY FRAUDE,FIRSTDGT
	ORDER BY FRAUDE,FIRSTDGT
   );
DISCONNECT FROM CON1;
QUIT;


PROC SQL;
CREATE TABLE TESTE2 AS
SELECT FIRSTDGT,FRAUDE,
       AVG(PROBFIRST) AS PROBFIRST,
       COUNT(*) AS TOTAL
FROM TESTE
GROUP BY FIRSTDGT,FRAUDE;
QUIT;











OPTIONS COMPRESS=YES;
PROC SQL;
CONNECT TO NETEZZA AS CON1(DATABASE=PRD_DWM SERVER=NTZP107 AUTHDOMAIN=NTZP107AUTH SQL_FUNCTIONS=ALL);
CREATE TABLE TEMP AS 
SELECT * 
FROM CONNECTION TO CON1
( SELECT DISTINCT AN_MM_CTB,CD_ATD_PSS_FSC,CD_CNG,CD_CTE,CD_GRP_TRN,CD_MDA_TRN,CD_NCN,
         CD_NVL_RCO_CLI,CD_PAS_CNA_EVD,CD_PPE,CD_PTF,CD_RCO_PAC_TRN,CD_RLC_CNA,
         CD_STC_CNA,CD_TPO_CNA,CD_TPO_CNA_EVD,CD_TPO_PSS_CLI,CD_USR_RSP,CD_VRF,
         CODNEGOCIALTRANSACAO,DESCCOMPLEMENTAR,DESCORIGEMFINALIDADE,DH_TRN,IC_CLI_RSD_CDD_AGN,
         IC_EXL,IC_PRC,NM_BAI,NM_CDD,NM_EMB,NM_PSS,NR_AGN_EVD,NR_BNC_EVD,NR_CHQ,NR_CMA_CMP,NR_CNA,NR_CNA_EVD,
         NR_CPF_CNPJ,NR_CPR,NR_CPR_CNA,NR_CPR_TRN,NR_EXC_PRJ,NR_PAC,NR_PAC_CNA,NR_SQN_LNC,
         NUMCPFCNPJENVOLVIDO,VR_TRN

FROM TRANSACAO_PRODUTO
  WHERE DH_TRN BETWEEN '2022-06-01' AND '2022-08-15' AND CD_NTZ_OPR='D' AND VR_TRN>800 AND CD_TRN IN (240,203)

) ORDER BY DH_TRN;
DISCONNECT FROM CON1;
QUIT;


LIBNAME AVL NETEZZA SERVER=NTZP107 AUTHDOMAIN=NTZP107AUTH DATABASE=PRD_DWM SQL_FUNCTIONS=ALL;
PROC CONTENTS DATA=AVL.TRANSACAO_PRODUTO NOPRINT OUT=C(KEEP=NAME);
RUN;









/*------------------------------------------------------------------------------------------------*/
OPTIONS COMPRESS=YES;
PROC SQL;
CONNECT TO NETEZZA AS CON1(DATABASE=PRD_DWM SERVER=NTZP107 AUTHDOMAIN=NTZP107AUTH SQL_FUNCTIONS=ALL);
CREATE TABLE TEMP AS 
SELECT * 
FROM CONNECTION TO CON1
( SELECT *
     FROM TRANSACAO_PRODUTO
     WHERE DH_TRN BETWEEN '2021-06-01' AND '2021-06-05' AND CD_NTZ_OPR='D' AND VR_TRN>500 AND CD_TRN IN (240,207,208,203)
 )   ORDER BY DH_TRN;
DISCONNECT FROM CON1;
QUIT;
/*AND NR_CPF_CNPJ='79378242120'CODNEGOCIALTRANSACAO<>'' and */
