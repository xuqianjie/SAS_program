/*indsn �������ݼ�*/
/*y �����*/
/*p ��ֵ*/
/*out ������ݼ�*/

%let indsn=logdat;
%let y=progg;
%let p=0.1;
%let out=logout;
%let i=1;


%macro log(indsn=,y=,p=,out=);
/*���Ա�������������*/
data argu;
	set &indsn.;
	drop &y.;
run;
proc contents data=argu out=t1;run;
proc sql noprint;
	select count(NAME) into :n from t1;
quit;
%let n=%sysfunc(strip(&n));
proc sql noprint;
	select NAME into :x1-:x&n. from t1;
quit;

/*������logistic�ع鼰���(�������ơ�OR)*/
%do i=1 %to &n.;
ods output ParameterEstimates=paes&i. CLoddsWald=c&i.;
proc logistic data=&indsn. descending ;
	model &y.(event="1")= &&x&i. / clodds=wald; 
run;
ods output close;
%end;

data t2(keep=Variable Estimate StdErr WaldChiSq ProbChiSq);
	length Variable $ 20.;
	set paes1-paes&n.;
	if Variable^="Intercept" then output;
run;

data t3(keep=OddsRatioEst LowerCL UpperCL);
	set c1-c&n.;
run;

data &out._1;
	merge t2 t3;
	if ProbChiSq<0.001 then p=strip(put(ProbChiSq,PVALUE6.4))||"***";
	else if ProbChiSq>=0.001 and ProbChiSq<0.01 then p=strip(put(ProbChiSq,PVALUE6.4))||"**";
	else if ProbChiSq>=0.01 and ProbChiSq<0.05 then p=strip(put(ProbChiSq,PVALUE6.4))||"*";
	else if ProbChiSq>0.05 then p=strip(put(ProbChiSq,PVALUE6.4));
run;
/*���ݵ����ؽ��ɸѡ�����ط�������*/
proc sql noprint;
	select Variable into :fac separated by " " from t2 where ProbChiSq<&p.;
quit;
%put &fac.;
/*�ҳ�ɸѡ����еĶ�������*/
%do i=1 %to &n.;
proc sql noprint;
	create table v&i. as 
		select &&x&i. from &indsn. having count(distinct(&&x&i.))>2;
quit;
%end;

data t4;
	merge v1-v&n.;
run;

proc transpose data=t4 out=t5;run;

proc sql noprint;
	select _NAME_ into :cla separated by "(ref='0') " from t5 where COL1<>. 
		and _NAME_ in (select Variable from t2 where ProbChiSq<&p.);
quit;
%put &cla.;

/*������logistic�ع鼰���(�������ơ�OR)*/
ods output ParameterEstimates=pest CLoddsWald=cw;
proc logistic data=&indsn. descending plots(only)=roc;
	class &cla.(ref='0')/param=reference;
	model &y.(event="1")=&fac. / clodds=wald; 
run;
ods output close;
data est;
	set pest;
	obs=_N_-1;
	if Variable="Intercept" then delete;
run;
data or;
	set cw;
	obs=_N_;
run;
proc sort data=est;by obs;run;
proc sort data=or;by obs;run;
data &out.(drop=obs);
	merge est or;
	by obs;
	if ProbChiSq<0.001 then p=strip(put(ProbChiSq,PVALUE6.4))||"***";
	else if ProbChiSq>=0.001 and ProbChiSq<0.01 then p=strip(put(ProbChiSq,PVALUE6.4))||"**";
	else if ProbChiSq>=0.01 and ProbChiSq<0.05 then p=strip(put(ProbChiSq,PVALUE6.4))||"*";
	else if ProbChiSq>0.05 then p=strip(put(ProbChiSq,PVALUE6.4));
run;
/*�������߱��ʽ*/
%style;
/*����logistic�ع������*/
ods listing close;
option nodate nonumber ;
ods rtf file="&nowpath.output\������logistic�ع���.rtf" style=styles.myrtf startpage=yes bodytitle;  
title justify=left "������logistic�ع���" ;
proc report data=&out._1 nowd;
	column Variable Estimate StdErr WaldChiSq p OddsRatioEst LowerCL UpperCL;
	define Variable/display '����' left style(header)={just=left} style(column)={width=50pt};
	define Estimate/display '����ֵ' left style(header)={just=left} style(column)={width=50pt};
	define StdErr/display '��׼���' left style(header)={just=left} style(column)={width=50pt};
	define WaldChiSq/display 'Wald����' left style(header)={just=left} style(column)={width=50pt};
	define p/display 'Pֵ' left style(header)={just=left} style(column)={width=50pt};
	define OddsRatioEst/display 'OR' left style(header)={just=left} style(column)={width=50pt};
	define LowerCL/display '95%CI����' left style(header)={just=left} style(column)={width=50pt};
	define UpperCL/display '95%CI����' left style(header)={just=left} style(column)={width=50pt};
	compute after _page_/ style=[asis=on just=L NOBREAKSPACE=off borderbottomcolor=white fontsize=10.5pt FONT_FACE="Times New Roman"] ;
	line "ע��*��ʾPֵ<0.05 **��ʾPֵ<0.01 ***��ʾPֵ<0.001";
	endcomp;
quit;
ods rtf close;


ods listing close;
option nodate nonumber ;
ods rtf file="&nowpath.output\������logistic�ع���.rtf" style=styles.myrtf startpage=yes bodytitle;  
title justify=left "������logistic�ع���" ;
proc report data=&out. nowd split="/";
	column Effect Estimate StdErr WaldChiSq p OddsRatioEst LowerCL UpperCL;
	define Effect/display '����' left style(header)={just=left} style(column)={width=80pt};
	define Estimate/display '����ֵ' left style(header)={just=left} style(column)={width=50pt};
	define StdErr/display '��׼���' left style(header)={just=left} style(column)={width=50pt};
	define WaldChiSq/display 'Wald����' left style(header)={just=left} style(column)={width=50pt};
	define p/display 'Pֵ' left style(header)={just=left} style(column)={width=50pt};
	define OddsRatioEst/display 'OR' left style(header)={just=left} style(column)={width=50pt};
	define LowerCL/display '95%CI����' left style(header)={just=left} style(column)={width=50pt};
	define UpperCL/display '95%CI����' left style(header)={just=left} style(column)={width=50pt};
	compute after _page_/ style=[asis=on just=L NOBREAKSPACE=off borderbottomcolor=white fontsize=10.5pt FONT_FACE="Times New Roman"] ;
	line "ע��*��ʾPֵ<0.05 **��ʾPֵ<0.01 ***��ʾPֵ<0.001";
	endcomp;
quit;
ods rtf close;

proc datasets nodetails library=work nolist kill;
run;quit;

%mend log;
