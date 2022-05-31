/*indsn �������ݼ�*/
/*y �����*/
/*p ��ֵ*/
/*out ������ݼ�*/
/*var ���������� �ÿո���,û����д0*/
/*�����������Ϊ���գ������������С������Ϊ���գ�����1��2��3...����*/
/*�����н���һ����Ϊlog�������߼���*/
libname rd "D:\Project\SAS\rawdata";
libname log "D:\Project\SAS\log";

/*%let indsn=rawdata.d3;*/
/*%let y=fufa;*/
/*%let p=0.1;*/
/*%let out=out;*/
/*%let i=1;*/
/*%let var=0;*/

%log(indsn=rawdata.d4,y=v27,var=age v1 v2 v7 v8 ,p=0.1,out=out);

%macro log(indsn=,y=,var=,p=,out=);


/*�������߱��ʽ*/
%inc "E:\program\m_style.sas";
%style;


/*ȷ����������������*/
%if &var. = 0 %then %do;
%let n=0;
%put &n.����������;
data argu2;
	set &indsn.;
	drop &y.;
run;
proc contents data=argu2 out=t2;run;
proc sql noprint;
	select count(NAME) into :m from t2;
quit;
%let m=%sysfunc(strip(&m));
%put &m.���������;
proc sql noprint;
	select NAME into :y1-:y&m. from t2;
quit;
%end;

%else %do;
data argu1;
	set &indsn.;
	keep &var.;
run;
proc contents data=argu1 out=t1;run;
proc sql noprint;
	select count(NAME) into :n from t1;
quit;
%let n=%sysfunc(strip(&n));
%put &n.����������;
proc sql noprint;
	select NAME into :x1-:x&n. from t1;
quit;
data argu2;
	set &indsn.;
	drop &var. &y.;
run;
proc contents data=argu2 out=t2;run;
proc sql noprint;
	select count(NAME) into :m from t2;
quit;
%let m=%sysfunc(strip(&m));
%put &m.���������;
proc sql noprint;
	select NAME into :y1-:y&m. from t2;
quit;
%end;


/*log*/
%if &n. = 0 %then %do;
%put ����������;

%do i=1 %to &m.;
ods output ParameterEstimates=pea&i. CLoddsWald=cwa&i.;
proc logistic data=&indsn. descending ;
	class &&y&i. (ref='1') / param=reference;
	model &y.(event="1")= &&y&i. / clodds=wald; 
run;
ods output close;
%end;
data log.est1(keep=Variable Estimate StdErr WaldChiSq ProbChiSq);
	length Variable $ 20.;
	set pea1-pea&m.;
	if Variable^="Intercept" then output;
run;
data log.or1(keep=OddsRatioEst ci);
	set cwa1-cwa&m.;
	ci=strip(put(LowerCL,5.3))||"-"||strip(put(UpperCL,5.3));
run;
%end;

%if &m. = 0 %then %do;
%put �޷������;

%do i=1 %to &n.;
ods output ParameterEstimates=pe&i. CLoddsWald=cw&i.;
proc logistic data=&indsn. descending ;
	model &y.(event="1")= &&x&i. / clodds=wald; 
run;
ods output close;
%end;
data log.est1(keep=Variable Estimate StdErr WaldChiSq ProbChiSq);
	length Variable $ 20.;
	set pe1-pe&n.;
	if Variable^="Intercept" then output;
run;
data log.or1(keep=OddsRatioEst ci);
	set cw1-cw&n.;
	ci=strip(put(LowerCL,5.3))||"-"||strip(put(UpperCL,5.3));
run;
%end;

%if &m. ne 0 and &n. ne 0 %then %do;
%do i=1 %to &n.;
ods output ParameterEstimates=pe&i. CLoddsWald=cw&i.;
proc logistic data=&indsn. descending ;
	model &y.(event="1")= &&x&i. / clodds=wald; 
run;
ods output close;
%end;
%do i=1 %to &m.;
ods output ParameterEstimates=pea&i. CLoddsWald=cwa&i.;
proc logistic data=&indsn. descending ;
	class &&y&i. (ref='1') / param=reference;
	model &y.(event="1")= &&y&i. / clodds=wald; 
run;
ods output close;
%end;
data log.est1(keep=Variable Estimate StdErr WaldChiSq ProbChiSq);
	length Variable $ 20.;
	set pe1-pe&n. pea1-pea&m.;
	if Variable^="Intercept" then output;
run;
data log.or1(keep=OddsRatioEst ci);
	set cw1-cw&n. cwa1-cwa&m.;
	ci=strip(put(LowerCL,5.3))||"-"||strip(put(UpperCL,5.3));
run;
%end;


/*�ϲ�������log������������*/
data log.&out._1;
	merge log.est1 log.or1;
	if ProbChiSq<0.001 then p=strip(put(ProbChiSq,PVALUE6.4))||"***";
	else if ProbChiSq>=0.001 and ProbChiSq<0.01 then p=strip(put(ProbChiSq,PVALUE6.4))||"**";
	else if ProbChiSq>=0.01 and ProbChiSq<0.05 then p=strip(put(ProbChiSq,PVALUE6.4))||"*";
	else if ProbChiSq>0.05 then p=strip(put(ProbChiSq,PVALUE6.4));
run;

ods listing close;
option nodate nonumber ;
ods rtf file="D:\Desktop\������logistic�ع���.rtf" style=styles.myrtf startpage=yes bodytitle;  
title justify=left "������logistic�ع���" ;
proc report data=log.&out._1 nowd;
	column Variable Estimate StdErr WaldChiSq p OddsRatioEst ci;
	define Variable/display '����' left style(header)={just=left} style(column)={width=50pt};
	define Estimate/display '����ֵ' left style(header)={just=left} style(column)={width=50pt};
	define StdErr/display '��׼���' left style(header)={just=left} style(column)={width=50pt};
	define WaldChiSq/display 'Wald����' left style(header)={just=left} style(column)={width=50pt};
	define p/display 'Pֵ' left style(header)={just=left} style(column)={width=50pt};
	define OddsRatioEst/display 'OR' left style(header)={just=left} style(column)={width=50pt};
	define ci/display '95%CI' left style(header)={just=left} style(column)={width=50pt};
	compute after _page_/ style=[asis=on just=L NOBREAKSPACE=off borderbottomcolor=white fontsize=10.5pt FONT_FACE="Times New Roman"] ;
	line "ע��*��ʾPֵ<0.05 **��ʾPֵ<0.01 ***��ʾPֵ<0.001";
	endcomp;
quit;
ods rtf close;


/*���ݵ����ؽ��ɸѡ�����ط�������*/
proc sql noprint;
	select count(Variable) into :facnum from log.est1 where ProbChiSq<&p.;
quit;

%if &facnum.  = 0 %then %do;
%put û�н��������logistic�ع�ı���;
%end;
%else %do;
proc sql noprint;
	select Variable into :fac separated by " " from log.est1 where ProbChiSq<&p.;
quit;
%put &fac.���������logistic�ع�;
%end;

proc sql;
	select count(a.Variable) into :clanum
	from log.est1 as a,t2 as b
	where a.ProbChiSq<&p. and b.NAME=a.Variable;
quit;

%if &clanum. = 0 %then %do;
%put ���������logistic�ع��еı������޷������;
%end;
%else %do;
proc sql noprint;
	select a.Variable into :cla separated by "(ref='1') " 
	from log.est1 as a,t2 as b
	where a.ProbChiSq<&p. and b.NAME=a.Variable;
quit;
%put &cla.�Ƿ������;
%end;


/*������logistic�ع�*/
%if &clanum. = 0 %then %do;
ods output ParameterEstimates=paes CLoddsWald=clwa;
proc logistic data=&indsn. descending plots(only)=roc;
	model &y.(event="1")=&fac. / clodds=wald; 
run;
ods output close;
%end;
%else %do;
ods output ParameterEstimates=paes CLoddsWald=clwa;
proc logistic data=&indsn. descending plots(only)=roc;
	class &cla.(ref='1')/param=reference;
	model &y.(event="1")=&fac. / clodds=wald; 
run;
ods output close;
%end;

/*�ϲ�������log������������*/
data log.est2;
	set paes;
	obs=_N_-1;
	if Variable="Intercept" then delete;
run;
data log.or2;
	set clwa;
	obs=_N_;
	ci=strip(put(LowerCL,5.3))||"-"||strip(put(UpperCL,5.3));
run;
proc sort data=log.est2;by obs;run;
proc sort data=log.or2;by obs;run;
data log.&out.(drop=obs);
	merge log.est2 log.or2;
	by obs;
	if ProbChiSq<0.001 then p=strip(put(ProbChiSq,PVALUE6.4))||"***";
	else if ProbChiSq>=0.001 and ProbChiSq<0.01 then p=strip(put(ProbChiSq,PVALUE6.4))||"**";
	else if ProbChiSq>=0.01 and ProbChiSq<0.05 then p=strip(put(ProbChiSq,PVALUE6.4))||"*";
	else if ProbChiSq>0.05 then p=strip(put(ProbChiSq,PVALUE6.4));
run;

ods listing close;
option nodate nonumber ;
ods rtf file="D:\Desktop\������logistic�ع���.rtf" style=styles.myrtf startpage=yes bodytitle;  
title justify=left "������logistic�ع���" ;
proc report data=log.&out. nowd split="/";
	column Effect Estimate StdErr WaldChiSq p OddsRatioEst ci;
	define Effect/display '����' left style(header)={just=left} style(column)={width=80pt};
	define Estimate/display '����ֵ' left style(header)={just=left} style(column)={width=50pt};
	define StdErr/display '��׼���' left style(header)={just=left} style(column)={width=50pt};
	define WaldChiSq/display 'Wald����' left style(header)={just=left} style(column)={width=50pt};
	define p/display 'Pֵ' left style(header)={just=left} style(column)={width=50pt};
	define OddsRatioEst/display 'OR' left style(header)={just=left} style(column)={width=50pt};
	define ci/display '95%CI' left style(header)={just=left} style(column)={width=50pt};
	compute after _page_/ style=[asis=on just=L NOBREAKSPACE=off borderbottomcolor=white fontsize=10.5pt FONT_FACE="Times New Roman"] ;
	line "ע��*��ʾPֵ<0.05 **��ʾPֵ<0.01 ***��ʾPֵ<0.001";
	endcomp;
quit;
ods rtf close;


/*��մ���work�߼����е��м����ݼ�*/
/*proc datasets nodetails library=work nolist kill;*/
/*run;quit;*/

%mend;
