*! Version April 2015

cap prog drop igmobil
	program define igmobil, eclass byable(recall) 
    syntax varlist(min=2 max=2) [if] [in] [aweight fweight]  [, noSINGLE  noTRANS noINEQUAL DISCrete CLAsses(string) USERWRitten(string) ///
	MATrix(string) FAMily(string) ge(numlist sort max=2) atk(numlist>0 sort max=2)  ///
	BOOTstrap(string) CIType(string) Format(string) ]
	
	marksample touse
	qui count if `touse' 
	
	loc N = r(N)

*--- CONTROLS ON OPTIONS
* 1 Incompatibility between classes of IGM indices and specific options
	if ("`single'" == "nosingle") & ("`trans'" == "notrans") & ("`inequal'" == "noinequal") {
		disp as err "options nosingle, notrans and noinequal may not be combined"
		exit 198
		}
	if ("`trans'" == "notrans")  & ( "`classes'" != "" ) {
		disp as err "options notrans and classes may not be combined"
		exit 198
		} 

	if ("`discrete'" == "discrete")  & ( "`classes'" != "" ) {
		disp as err "options discrete and classes may not be combined"
		exit 198
		} 

	if ("`inequal'" == "noinequal")  & ///
		(( "`family'" != "" )  |  ( "`ge'" != "" ) | ( "`atk'" != "" )   ) {
		disp as err "option inequal may not be combined with any of options family, ge, atk"
		exit 198
		} 
	
	
	if ("`discrete'" == "discrete") {
		loc single   nosingle
		loc inequal  noinequal
		}
	
	loc nwb: word count `bootstrap' 
	if (`nwb' ==1  ) & regexm("`bootstrap'", "off") ==1 loc noboot noboot
	if (`nwb' > 1  ) & regexm("`bootstrap'", "off") ==1 {
	disp as err "subotions off may not be combined with other suboptions of bootstrap"
	exit 198
	}
	
	
	* - if discrete option not used and classes not specified, I assume classes = 5	
	if 	"`classes'" == "" & ("`discrete'" != "discrete") {
	loc classes 5
		}
	
* 2 Specific choice for Inequality related IGM Indices
	if "`family'" == "" | "`family'" == "fields" {
		loc family fields
		loc Family Fields   // Ca
		}
	
	else if "`family'" == "shorrocks"{
		loc Family Shorrocks
		}
	


* 3 Format
	
	if ("`format'" == "") {
	loc format %9.3f
	}


/* Parameters of GE and Atkinson: maximum two choices for each. If no choice,
	then default values; if only one choice, it is repeated twice.
*/
	if "`ge'" == "" {
		loc ge 0 1	
		}	
	
	else {
		local nge: word count `ge'
			if `nge' == 1 {
				loc ge `ge' `ge'
				}	
		}
	
	tokenize `ge'
	loc _ge_1 = `1'
	loc _ge_2 = `2'
	
	if "`atk'" == "" {
	loc atk 0.5 2	
	}

	else {
		local natk: word count `atk'
			if `natk' == 1 {
				loc atk `atk' `atk'
				}	
		}
	
	tokenize `atk'
	loc _atk_1 = `1'
	loc _atk_2 = `2'
	
*---------------------------------------------------------------------------
	
* defining parameters to estimate
loc param_a i1=r(SS1) i2=r(SS2) i3=r(SS3) i4=r(SS4) i5=r(SS5) i6=r(SS6) i7=r(SS7) i8=r(SS8) i9=r(SS9) i10=r(SS10)	
loc param_b i11=r(TM1) i12=r(TM2) i13=r(TM3) i14=r(TM4)  
loc param_c i15=r(IN1) i16=r(IN2) i17=r(IN3) i18=r(IN4) i19=r(IN5) 	
loc param_d i20=r(UW)

loc j = 0

	
if ("`single'" == "nosingle") {
loc param_a
loc j = -10
} 

if ("`single'" == "nosingle") &  ("`trans'" == "notrans"){
loc j = -14
} 


if ("`trans'" == "notrans") {
loc param_b
} 

if ("`inequal'" == "noinequal") {
loc param_c
} 

if ("`userwritten'" == "") {
loc param_d
} 


loc param `param_a' `param_b' `param_c' `param_d'


tokenize `varlist'

tempname b se cint

if "`noboot'" == "noboot" {

loc   `bootstrap' 

bootstrap `param', notable nolegend  nowarn nodots ///
	reps(2) : igmobil_1 	`1' `2'  if  `touse', ///
	`discrete' `single' `trans' `inequal' matrix(`matrix') ///
	classes(`classes') family(`family') ge(`ge') atk(`atk') userwr(`userwritten') 

mat def `b' =  e(b) 
mat def `se' = J(1,colsof(e(b)),.)
mat `cint' = J(2,colsof(`b'),.)

loc citype 

loc reps 
loc level = e(level)
loc k = r(k)	


if "`matrix'" != ""  & "`trans'" != "notrans" {
qui igmobil_1  `1' `2'  if  `touse', ///
	nosingle noinequal matrix(`matrix')  ///
	classes(`classes') 
matrix def `matrix' = r(`matrix') 
}
}


else {
loc bootstrap =	regexr("`bootstrap'"	d,"(notable|nolegend|nowarn)" , "")
bootstrap `param', notable nolegend  nowarn ///
	`bootstrap' : igmobil_1 	`1' `2'  if  `touse', ///
	`discrete' `single' `trans' `inequal' matrix(`matrix') ///
	classes(`classes') family(`family') ge(`ge') atk(`atk') userwr(`userwritten') 
	
loc reps =  e(N_reps)
loc level = e(level)
loc k = r(k)	

mat def `b' =  e(b) 
mat def `se' =  e(se)

 
if "`citype'" == "percentile" {
	mat def `cint' =  e(ci_percentile)
	loc citype percentile method
}
else if "`citype'" == "bc" {
	mat def `cint' =  e(ci_bc)
	loc citype bias-corrected
} 
else if "`citype'" == "" | "`citype'" == "normal"   {
	mat def `cint' =  e(ci_normal)
	loc citype normal approx.
}

if "`matrix'" != "" & "`trans'" != "notrans" {
qui igmobil_1  `1' `2'  if  `touse', ///
	nosingle noinequal matrix(`matrix')  ///
	classes(`classes') 
matrix def `matrix' = r(`matrix') 
}


}



	* ------  PART 4: DISPLAY RESULTS AND STORE MACROS
	
	* for convencience in writing tables
	loc c1 _col(38) in ye `format' // IGM
	loc c2 _col(48) in ye `format' // s.e.
	
	loc c5 _col(60) in ye `format' // lb
	loc c6 _col(70) in ye `format' // ub
	loc line di in green "{hline 80}" 
	
	* display results
	
	if ("`discrete'" != "discrete") {
	loc tipo continuous
	}
	else {
	loc tipo discrete
	}
	

	disp ""
	disp in gr "Child generation: " _col(24) in ye  "`1' = Y"  _col(49) in gr  "Type of variables: " in ye "`tipo'" 
	disp in gr "Parent generation: " _col(24)  in ye "`2' = X" // _col(49) in gr "N = "  in ye  `N'
	`line'  
	
		di in gr _col(5) " Type of indices"  	in gr	_col(43)  "IGM"        _col(50) "Bootstrap" _col(62)  "[`level'% Conf. Interv.]"
		di                                                  _col(40)  "estimate"   _col(50) "Std. Err."  _col(63) "`citype'"
	`line'  

	if ("`single'" != "nosingle") {
		di in wh _col(5) " Single-stage Indices" 
		disp in gr "(1)  1/N * sum |X - Y| " 	         	`c1' `b'[1,`=`j'+1'] `c2' `se'[1,`=`j'+1'] `c5' `cint'[1,`=`j'+1'] `c6' `cint'[2,`=`j'+1'] 
		disp in gr "(2)  1/N * sum (X - Y)^2 " 	        	`c1' `b'[1,`=`j'+2'] `c2' `se'[1,`=`j'+2'] `c5' `cint'[1,`=`j'+2'] `c6' `cint'[2,`=`j'+2']
		disp in gr "(3)  1/N * sum |ln X - ln Y| " 	     	`c1' `b'[1,`=`j'+3'] `c2' `se'[1,`=`j'+3'] `c5' `cint'[1,`=`j'+3'] `c6' `cint'[2,`=`j'+3']
		disp in gr "(4)  1/N * sum |X/mu(X) - Y/mu(Y)|"  	`c1' `b'[1,`=`j'+4'] `c2' `se'[1,`=`j'+4'] `c5' `cint'[1,`=`j'+4'] `c6' `cint'[2,`=`j'+4']
		disp in gr "(5)  1 - Pearson coef. (on logs)"       `c1' `b'[1,`=`j'+5'] `c2' `se'[1,`=`j'+5'] `c5' `cint'[1,`=`j'+5'] `c6' `cint'[2,`=`j'+5']
		disp in gr "(6)  1 - Spearman coef. (on logs)"      `c1' `b'[1,`=`j'+6'] `c2' `se'[1,`=`j'+6'] `c5' `cint'[1,`=`j'+6'] `c6' `cint'[2,`=`j'+6']
		disp in gr "(7)  1/N * sum |CDF X - CDF Y| "        `c1' `b'[1,`=`j'+7'] `c2' `se'[1,`=`j'+7'] `c5' `cint'[1,`=`j'+7'] `c6' `cint'[2,`=`j'+7']
		disp in gr "(8)  1/N * sum (CDF X - CDF Y)^2 "      `c1' `b'[1,`=`j'+8'] `c2' `se'[1,`=`j'+8'] `c5' `cint'[1,`=`j'+8'] `c6' `cint'[2,`=`j'+8']
		disp in gr "(9)  1 - OLS(Y,X)"             			`c1' `b'[1,`=`j'+9'] `c2' `se'[1,`=`j'+9'] `c5' `cint'[1,`=`j'+9'] `c6' `cint'[2,`=`j'+9']
		disp in gr "(10) 1 - OLS(ln Y,ln X)"                `c1' `b'[1,`=`j'+10'] `c2' `se'[1,`=`j'+10'] `c5' `cint'[1,`=`j'+10'] `c6' `cint'[2,`=`j'+10']
		`line'  
	}

	if ("`trans'" != "notrans") {
			if ("`discrete'" != "discrete") {
			loc based based on "  `classes'  " quantiles
			}
			else {
			loc based original categories of X,Y
			}
	
		di in  wh _col(5) "Transition matrix Indices (`based')"  	 
		disp in gr "(11)  Shorrock/Prais"          		`c1' `b'[1,`=`j'+11'] `c2' `se'[1,`=`j'+11'] `c5' `cint'[1,`=`j'+11']  `c6' `cint'[2,`=`j'+11']
		disp in gr "(12)  Bartholomew"           	    `c1' `b'[1,`=`j'+12'] `c2' `se'[1,`=`j'+12'] `c5' `cint'[1,`=`j'+12']  `c6' `cint'[2,`=`j'+12']
		disp in gr "(13)  1-Second largest eigenvalue"  `c1' `b'[1,`=`j'+13'] `c2' `se'[1,`=`j'+13'] `c5' `cint'[1,`=`j'+13']  `c6' `cint'[2,`=`j'+13']
		disp in gr "(14)  Determinant index"            `c1' `b'[1,`=`j'+14'] `c2' `se'[1,`=`j'+14'] `c5' `cint'[1,`=`j'+14']  `c6' `cint'[2,`=`j'+14']
		`line'
	} 
	
		
if ("`inequal'" != "noinequal") {
	if ("`trans'" == "notrans") & ("`single'" != "nosingle") { // ok if only transition matrix are deleted 
	loc j = -4
	}
		*di in  ye _col(5) "Inequality related Indices"  in gr	_col(43)  "IGM"     _col(50) "Bootstrap" _col(62)  "[`level'% Conf. Interv.]"
		*di                             in gr _col(40)  "estimate"  _col(50) "Std. Err." _col(65) "`citype'"
		di in  wh _col(5) "Inequality related Indices"
		disp in gr "(15) `Family' - Gini "               	 `c1'  `b'[1,`=`j'+15'] `c2' `se'[1,`=`j'+15'] `c5' `cint'[1,`=`j'+15'] `c6' `cint'[2,`=`j'+15']
		disp in gr "(16) `Family' - GE(" `_ge_1' ") "        `c1'  `b'[1,`=`j'+16'] `c2' `se'[1,`=`j'+16'] `c5' `cint'[1,`=`j'+16'] `c6' `cint'[2,`=`j'+16']
		disp in gr "(17) `Family' - GE(" `_ge_2' ") "        `c1'  `b'[1,`=`j'+17'] `c2' `se'[1,`=`j'+17'] `c5' `cint'[1,`=`j'+17'] `c6' `cint'[2,`=`j'+17']
		disp in gr "(18) `Family' - Atkinson(" `_atk_1' ") " `c1'  `b'[1,`=`j'+18'] `c2' `se'[1,`=`j'+18'] `c5' `cint'[1,`=`j'+18'] `c6' `cint'[2,`=`j'+18']
		disp in gr "(19) `Family' - Atkinson(" `_atk_2' ") " `c1'  `b'[1,`=`j'+19'] `c2' `se'[1,`=`j'+19'] `c5' `cint'[1,`=`j'+19'] `c6' `cint'[2,`=`j'+19']
	`line' 
	}


 
 ***
 
 if ("`userwritten'" != "") {
*	di in  ye _col(5) "User written "  in gr	_col(43)  "IGM"     _col(50) "Bootstrap" _col(62)  "[`level'% Conf. Interv.]"
*	di in  ye _col(5) "program  "         in gr _col(40)  "estimate"  _col(50) "Std. Err." _col(65) "`citype'"

 di in  wh  "(20) User written program"            `c1' `b'[1, e(k_exp)] `c2' `se'[1,e(k_exp)] `c5' `cint'[1,e(k_exp)]  `c6' `cint'[2,e(k_exp)]
`line'
 
 }
 
if  "`noboot'" == "noboot" {
eret post `b' , e(`touse')
}
 
 end
 
 
 
 
 
 
 
