*! version 1 (March 2016)

	*------  PART 1: SINGLE STAGE INDICES
cap prog drop igmobil_1
prog def igmobil_1, rclass byable(recall) 
syntax varlist(min=2 max=2)  [if] [in] [, noSINGLE  noTRANS noINEQUAL DISCrete CLAsses(string) ///
MATrix(string) FAMily(string) ge(numlist) atk(numlist) USERWRitten(string)]

	scalar drop _all
	marksample touse
	tokenize `varlist'
	
	/*intermediate variables */
	tempvar y x
	qui gen `y' = `1'
	qui gen `x' = `2'
	

	if ("`single'" != "nosingle") { 
		
		/*intermediate variables  and scalars */
		tempname cdf_y cdf_x lny lnx mu_y sd_y mu_x sd_x pearson spearman
		
		cumul `y' if `touse', gen(`cdf_y') equal  
		cumul `x' if `touse', gen(`cdf_x') equal 
		gen `lny'  if `touse'= ln(`y')
		gen `lnx' = ln(`x')
				
		sum `y' if `touse'
		scalar `mu_y' = r(mean) 
		scalar `sd_y' = r(sd) 

		sum `x' if `touse'
		scalar `mu_x' = r(mean) 
		scalar `sd_x' = r(sd)

		corr `lny' `lnx' if `touse'
		scalar `pearson' = r(rho)

		spearman `lny' `lnx' if `touse'
		scalar `spearman' = r(rho)
		

		/* compute distance from f(y) and g(x)*/ 
		tempvar simpledif absdif quadif absldif share quacdf abscdf
	
		gen `simpledif' = `y'-`x' 
		gen `absdif'  = abs(`y'-`x')  /*for M1*/
		gen `quadif'  = (`y'-`x')^2   /*for M2*/
		gen `absldif' = abs(`lny'-`lnx')  /*for M3*/
		gen `share'   = abs(`y'/`mu_y' - `x'/`mu_x')  /*for M4*/
		gen `abscdf'  = abs(`cdf_y'-`cdf_x')   /*for M7*/
		gen `quacdf'  = (`cdf_y'-`cdf_x')^2   /*for M8*/
		

		/* compute indices */ 
		
		sum `absdif' if `touse', meanonly
		ret scalar SS1 = r(mean)

		sum `quadif' if `touse', meanonly
		ret scalar SS2 = r(mean)

		sum `absldif' if `touse', meanonly
		ret scalar SS3 = r(mean)

		sum `share' if `touse', meanonly
		ret scalar SS4 = r(mean)

		ret scalar SS5 = 1-`pearson'
		ret scalar SS6 = 1-`spearman'

		sum `abscdf' if `touse', meanonly
		ret scalar SS7 = r(mean)

		sum `quacdf' if `touse', meanonly
		ret scalar SS8 = r(mean)


		reg `y' `x'  if `touse'
		ret scalar SS9 = 1-_b[`x']
	
		reg `lny' `lnx'  if `touse'
		ret scalar SS10 = 1-_b[`lnx']
				
	} 
		
* ------  PART 2: INDICES FROM TRANSITION MATRIX
	if ("`trans'" != "notrans") {
			* unless variables are discrete, we need to discetize them in k quantiles (default: 5 quintiles)
		tempvar qx qy
		tempname mod  im  re  Z  P  ni TM

		if ("`discrete'" != "discrete") { 
			xtile `qx' = `x' if `touse', nquantiles(`classes')
			xtile `qy' = `y' if `touse', nquantiles(`classes')
			qui tab `qx' if `touse', matcell(`ni')
			qui tab `qx' `qy' if `touse' , matcell(`P')
			loc k = rowsof(`P')	
		}

		else {
			gen `qx' = `x'
			gen `qy' = `y'
			*qui tab `qx' if `touse', matcell(`ni')
			qui tab `qx' `qy' if `touse' , matcell(`P')
			mata : st_matrix("`ni'", rowsum(st_matrix("`P'")))
			loc k = rowsof(`P')
		}

		matrix `TM' = J(`k',`k',0) // Transition Matrix
		matrix `Z' = J(`k',`k',0) // Matrix for Bartholomew Index

		forvalues i = 1/`k' {
		forvalues j = 1/`k' {
			 matrix `TM'[`i',`j']= `P'[`i',`j']/`ni'[`i',1]
			 matrix `Z'[`i',`j']= `TM'[`i',`j']*abs(`i'- `j')
		} 
		} 

		ret scalar TM1 = (`k' - trace(`TM'))/(`k'-1)
		loc somma = 0
		forval i = 1/`=colsof(`Z')' {
			forval j = 1/`=rowsof(`Z')' {
				loc somma = `somma' + `Z'[`j', `i']
			}
		}

		ret scalar TM2 = `somma'/(`k'*`=`k'-1')
				
		* computing eigenvalues
		matrix eigenvalues `re' `im' = `TM'
		mat `mod' = J(1,`k',0)
		forvalues i = 1/`k' {
			mat `mod'[1,`i'] = sqrt(`re'[1,`i']^2 + `im'[1,`i']^2)
		}
		
		ret scalar TM3 = 1-`mod'[1,2]
		ret scalar TM4 = 1-abs(det(`TM'))
		
		* saving matrix 
		if ("`matrix'" != "") {
		matrix define `matrix' = `TM'
		return matrix `matrix' = `matrix'
		}
		
		
}	
	
	* ------  PART 3: INDICES BASED ON INEQUALITY AND WELFARE MEASURES
	if ("`inequal'" != "noinequal") {
	
	count if `touse' & `x' > 0 & `y' > 0
	loc n = r(N)
	
	* fields - Gini
	
	tempvar xy  cdf_xy
	qui gen `xy' = (`x' + `y')/2
	sum `xy', meanonly
	cumul `xy', g(`cdf_xy') equal
	
	foreach var of varlist `x' `y' `xy' {
	tempname avg_`var'
	sum `var' if `touse', meanonly
	scalar `avg_`var'' = r(mean)


	tempname avg gini
	qui sum `var' if `touse', meanonly
	scalar `avg' = r(mean)
	
	tempvar rank rankvar 
	egen `rank' = rank(`var')
	gen `rankvar' = `rank'*`var'
	
	qui sum `rankvar' if `touse', meanonly
		
	scalar `gini' = 2*r(mean)/(`n'*`avg') - (`n'+1)/`n'
	
	
	tempvar temp
	gen `temp' = .
	
	
	* Generalized entropy measure	
	
	if "`ge'" != ""   {
	loc i = 1
	foreach v of numlist `ge'{
		tempname ge_`i' _ge_`i'
		if `v' != 0 & `v' != 1 {
			qui replace `temp' = (`var'/`avg')^(`v') 
			sum `temp' if `touse', meanonly 
			scalar `ge_`i'' = 1/(`v'*(`v'-1))*(r(mean)- 1)
			scalar `_ge_`i'' = `v'
			loc i = `i'+1
		}
		
		else if `v' == 1 {
			qui replace `temp' = 	(`var'/`avg')*log(`var'/`avg') 
			sum `temp' if `touse', meanonly 
			scalar `ge_`i'' = r(mean)
			scalar `_ge_`i'' = `v'
			loc i = `i'+1
		}
		else {
			
			qui replace `temp' = log(`avg'/`var') 
			qui sum `temp' if `touse', meanonly 
			scalar `ge_`i'' = r(mean)
			scalar `_ge_`i'' = `v'
			loc i = `i'+1
		}
	}
	}
	

	* atkinson indices
	if "`atk'" != ""   {	
	loc i = 1
	foreach v of numlist `atk' {
		if `v' < 0 {
			di in red "Parameters of Atkinson index must be non-negative"
			exit
		}
		
		else if `v' == 1 {
		tempname atk_`i' _atk_`i'
			qui replace `temp' = log(`var'/`avg') 
			qui sum `temp' if `touse', meanonly 
			scalar `atk_`i'' = 1- exp(r(mean))
			scalar `_atk_`i'' = `v'
			loc i = `i'+1
		}
		
		else {
			tempname atk_`i' _atk_`i'
			qui replace `temp' = (`var'/`avg')^(1-`v') 
			qui sum `temp' if `touse', meanonly 
			scalar `atk_`i'' = 1- (r(mean))^(1/(1-`v'))
			scalar `_atk_`i'' = `v'
			loc i = `i'+1
		}
	}
	}
		

	
	
	tempname gini_`var' gem1_`var'  ge2_`var' atkhalf_`var' atk2_`var'
	scalar `gini_`var''      = `gini'
	scalar `gem1_`var''      = `ge_1'  // Generalized Entropy indices GE(first)
	scalar `ge2_`var''       = `ge_2'   // Generalized Entropy indices GE(second)
	scalar `atkhalf_`var''   = `atk_1'    // Atkinson indices, A(first)
	scalar `atk2_`var''      = `atk_2'    // Atkinson indices, A(second)
	}
	
	
	if  "`family'" == "fields" {
	ret scalar IN1 = 1 -  `gini_`xy''/`gini_`x''
	ret scalar IN2 = 1 -  `gem1_`xy''/`gem1_`x''
	ret scalar IN3 = 1 -  `ge2_`xy''/`ge2_`x''
	ret scalar IN4 = 1 -  `atkhalf_`xy''/`atkhalf_`x''
	ret scalar IN5 = 1 -  `atk2_`xy''/`atk2_`x''
	}
	
	else if  "`family'" == "shorrocks" {
	tempname wx wy 
	scalar `wx' = `avg_`x''*`avg_`xy''
	scalar `wy' = 1-`wx'
	
	ret scalar IN1 = 1 -  `gini_`xy''    /(`wx'*`gini_`x''	 + `wy'*`gini_`y'') 
	ret scalar IN2 = 1 -  `gem1_`xy''    /(`wx'*`gem1_`x'' 	 + `wy'*`gem1_`y'')
	ret scalar IN3 = 1 -  `ge2_`xy''     /(`wx'*`ge2_`x'' 	 + `wy'*`ge2_`y'')
	ret scalar IN4 = 1 -  `atkhalf_`xy'' /(`wx'*`atkhalf_`x''+ `wy'*`atkhalf_`y'')
	ret scalar IN5 = 1 -  `atk2_`xy''    /(`wx'*`atk2_`x''   + `wy'*`atk2_`y'')
	
	}
	
}

	* ------  PART 4: USER WRITTEN PROGRAM
	if ("`userwritten'" != "") {
	
	qui  `userwritten'
	ret scalar UW=r(UW)
	}
	

end

	
