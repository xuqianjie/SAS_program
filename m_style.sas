libname mymacro "D:\project\SAS";
options mstored sasmstore = mymacro;

%macro style / store source;
proc template;
	define style styles.myrtf;
    parent=styles.journal;
	style parskip / fontsize = 1 pt;
	STYLE SystemTitle /
		FONT_FACE = "Times New Roman"
		FONT_SIZE =  10.5 pt
		FONT_WEIGHT = medium
		FONT_STYLE = roman
		FOREGROUND = black
		BACKGROUND = white
    	JUST=LEFT;
	STYLE SystemFooter /
		FONT_FACE = "Times New Roman"
		FONT_SIZE =  10.5 pt
		FONT_WEIGHT = medium
		FONT_STYLE = roman
		FOREGROUND = black
		BACKGROUND = white
		JUST=LEFT;
	STYLE Header /
		FONT_FACE = "Times New Roman"
		FONT_SIZE = 10.5 pt
		FONT_WEIGHT = medium
		FONT_STYLE = roman
		FOREGROUND = black
		BACKGROUND = white;
	STYLE RowHeader from header /
		BACKGROUND = white
		FONT_FACE = "Times New Roman"
		FONT_SIZE = 10.5 pt
		FONT_WEIGHT = medium;
	STYLE Data /
		FONT_FACE = "Times New Roman"
		FONT_SIZE = 10.5 pt
		FONT_WEIGHT = medium
		FONT_STYLE = roman
		FOREGROUND = black
		BACKGROUND = white;
	STYLE Table /
		FOREGROUND = black
		BACKGROUND = white
		CELLSPACING = 0
		CELLPADDING = 3
		FRAME = HSIDES
	RULES = groups
    	WIDTH=100 %;
	STYLE Body /
		FONT_FACE = "Times New Roman"
		FONT_SIZE = 10.5 pt
		FONT_WEIGHT = medium
		FONT_STYLE = roman
		FOREGROUND = black
		BACKGROUND = white;
    replace table from output /
    	frame = hsides  
        outputwidth = 100%
        protectspecialchars = off
        bottommargin = 2.5 cm
        topmargin = 2.5 cm
        rightmargin = 2.5 cm
        leftmargin = 2.5 cm;
    replace body from document / 
        bottommargin = 2.5 cm
        topmargin = 2.5 cm
        rightmargin = 2.5 cm
        leftmargin = 2.5 cm;
	end;
run;
%mend style;
