
/*********************************************************************************************************
Paper:    "Unpacking the determinants of life satisfaction: a survey experiment"

Journal of the Royal Statistical Society - Series A

Authors:    Viola Angelini, Marco Bertoni, Luca Corazzini

Input Data:    data_to_jrss.dta

This version: 9 January 2016
**********************************************************************************************************/

clear all
set more off
capture log close

global today 	"160109"
set seed 123456

log using unpacking_log_${today}.txt, text replace

use data_to_jrss, clear

global X "female young partner children goodhealth highedu income2 income3 income4 friendsoften association north"

*********
*FIGURE 2
*********

preserve
keep if tornata==1
gen LS1  = lifesatisfaction==1 
gen LS2  = lifesatisfaction==2
gen LS3  = lifesatisfaction==3
gen LS4  = lifesatisfaction==4
gen LS5  = lifesatisfaction==5
gen LS6  = lifesatisfaction==6
gen LS7  = lifesatisfaction==7
gen LS8  = lifesatisfaction==8
gen LS9  = lifesatisfaction==9
gen LS10 = lifesatisfaction==10
gen h = 1
collapse (sum) LS* h , by(trattamento)

reshape long LS, i(trattamento) j(lifesatisfaction)
gen LS_ = LS/h

gen country_order = 	0 if lifesatisfaction==1 & trattamento==1
replace country_order = 1 if lifesatisfaction==1 & trattamento==2
replace country_order = 2 if lifesatisfaction==1 & trattamento==3
replace country_order = 4 if lifesatisfaction==2 & trattamento==1
replace country_order = 5 if lifesatisfaction==2 & trattamento==2
replace country_order = 6 if lifesatisfaction==2 & trattamento==3
replace country_order = 8 if lifesatisfaction==3 & trattamento==1
replace country_order = 9 if lifesatisfaction==3 & trattamento==2
replace country_order = 10 if lifesatisfaction==3 & trattamento==3
replace country_order = 12 if lifesatisfaction==4 & trattamento==1
replace country_order = 13 if lifesatisfaction==4 & trattamento==2
replace country_order = 14 if lifesatisfaction==4 & trattamento==3
replace country_order = 16 if lifesatisfaction==5 & trattamento==1
replace country_order = 17 if lifesatisfaction==5 & trattamento==2
replace country_order = 18 if lifesatisfaction==5 & trattamento==3
replace country_order = 20 if lifesatisfaction==6 & trattamento==1
replace country_order = 21 if lifesatisfaction==6 & trattamento==2
replace country_order = 22 if lifesatisfaction==6 & trattamento==3
replace country_order = 24 if lifesatisfaction==7 & trattamento==1
replace country_order = 25 if lifesatisfaction==7 & trattamento==2
replace country_order = 26 if lifesatisfaction==7 & trattamento==3
replace country_order = 28 if lifesatisfaction==8 & trattamento==1
replace country_order = 29 if lifesatisfaction==8 & trattamento==2
replace country_order = 30 if lifesatisfaction==8 & trattamento==3
replace country_order = 32 if lifesatisfaction==9 & trattamento==1
replace country_order = 33 if lifesatisfaction==9 & trattamento==2
replace country_order = 34 if lifesatisfaction==9 & trattamento==3
replace country_order = 36 if lifesatisfaction==10 & trattamento==1
replace country_order = 37 if lifesatisfaction==10 & trattamento==2
replace country_order = 38 if lifesatisfaction==10 & trattamento==3
			
#delimit ;
	tw 	(bar LS_ country_order if trattamento==1 & country_order <=38 , color(black)) 
		(bar LS_ country_order if trattamento==2 & country_order <=38 , color(gs8)) 
		(bar LS_ country_order if trattamento==3 & country_order <=38 , color(white) lcolor(black)) ,
	graphregion(color(white))
	xlabel(1 "1" 5 "2" 9 "3" 13 "4" 17 "5" 21 "6" 25 "7" 29 "8" 33 "9" 37 "10", noticks) xtitle("Life Satisfaction") ytitle("Fraction")	
	legend(order(1 "T1 - Packed" 2 "T2 - Information" 3 "T3 - Unpacked")  rows(1) region(lwidth(none) style(none))) ;
	#delimit cr
	graph save "hist.gph", replace
	graph export "hist.pdf", replace
restore


********
*Table 1
********

preserve
keep if tornata==1
sum female young partner children goodhealth highedu ///
	income2 income3 income4 friendsoften association north
restore

preserve
drop if tornata==2 & risposta==0
sum lifesatisfaction
restore

preserve
keep if ((tornata==2&(trattamento==1|trattamento==2))|(tornata==1&trattamento==3))& risposta==1
sum lsreddito lsfamiglia lslavorostudio lsamici lsrelsentimentali lssalute
restore

********
*TABLE 2
********

preserve

keep if tornata==1

foreach i in $X {
	reg `i' packedsidom unpacked, robust
}

restore

*****************************
*Generalized Propensity Score
*****************************

preserve
keep if tornata == 1
*mlogit
mlogit trattamento $X, robust base(1)
*pscore
predict prob0 prob1 prob2
sum prob0 prob1 prob2
*weights
gen dose_w=1/prob0 if trattamento==1
replace dose_w=1/prob1 if trattamento==2
replace dose_w=1/prob2 if trattamento==3
*balancing
foreach i in $X {
	reg `i' packedsidom unpacked, robust
	reg `i' packedsidom unpacked [pw=dose_w], robust
}
*IPW regression
regress lifesatisfaction packedsidom unpacked if tornata==1 , robust
regress lifesatisfaction packedsidom unpacked if tornata==1 [pweight=dose_w], robust
*exclude extremes
su dose_w, d
drop if dose_w<r(p5)|dose_w>r(p95)
regress lifesatisfaction packedsidom unpacked if tornata==1 [pweight=dose_w], robust
restore 


********
*TABLE 3
********

sum lifesatisfaction if tornata==1 & trattamento==1 
sum lifesatisfaction if tornata==1 & trattamento==2 
sum lifesatisfaction if tornata==1 & trattamento==3 
sum lifesatisfaction if tornata==2 & trattamento==1 & risposta==1
sum lifesatisfaction if tornata==2 & trattamento==2 & risposta==1

*********************
*EPPS SINGLETON TESTS
*********************

escftest lifesatisfaction if (trattamento==1 | trattamento==2) & tornata==1, group(trattamento)
escftest lifesatisfaction if tornata==1, group(unpacked)

********
*TABLE 4
********

preserve

keep if trattamento==1|trattamento==2
drop if tornata==2 & risposta==0
bys id: gen dropout = _N==1
keep if tornata==1
expand 2 if dropout==0, gen(stayer)

foreach i in lifesatisfaction $X  {
	*T1 & T2
	qui reg `i' stayer, robust
	lincom _cons
	lincom _cons + stayer
	lincom -stayer
	*T1
	qui reg `i' stayer if trattamento==1, robust 
	lincom _cons
	lincom _cons + stayer
	lincom -stayer
	*T2
	qui reg `i' stayer if trattamento==2, robust 
	lincom _cons
	lincom _cons + stayer
	lincom -stayer
}

restore

********
*TABLE 5
********

preserve
keep if tornata == 1
regress lifesatisfaction packedsidom unpacked $X if tornata==1, robust
regress lifesatisfaction packedsidom unpacked if tornata==1, robust
rifreg lifesatisfaction packedsidom unpacked $X if tornata==1, variance
rifreg lifesatisfaction packedsidom unpacked if tornata==1, variance
restore

********
*TABLE 6
********

tsset id tornata

gen tornata2 = tornata==2

reg lifesatisfaction tornata2 packedsidom $X if risposta==1 & (trattamento==1|trattamento==2), cluster(id)
reg lifesatisfaction tornata2 packedsidom if risposta==1 & (trattamento==1|trattamento==2), cluster(id)
rifreg lifesatisfaction tornata2 packedsidom $X if risposta==1 & (trattamento==1|trattamento==2), variance
rifreg lifesatisfaction tornata2 packedsidom if risposta==1 & (trattamento==1|trattamento==2), variance

********
*TABLE 7
********

preserve
drop if trattamento==3 & tornata==2
drop if trattamento==1 & tornata==1
drop if trattamento==2 & tornata==1

regress lifesatisfaction packedsidom unpacked $X if risposta==1, robust
regress lifesatisfaction packedsidom unpacked if risposta==1, robust
rifreg lifesatisfaction packedsidom unpacked $X if risposta==1, variance
rifreg lifesatisfaction packedsidom unpacked if risposta==1, variance

restore

********
*TABLE 8
********

global X1 "female young north"
global ls_dom "lsreddito lsfamiglia lslavorostudio lsamici lsrelsentimentali lssalute"

preserve 
drop if trattamento==3 & tornata==2
drop if risposta!=1 & tornata==2
keep if (trattamento==1|trattamento==2) & risposta==1
sort id tornata
foreach i in $ls_dom{
	by id: replace `i' = `i'[_n+1] if tornata==1 & trattamento!=3
}
qui reg lifesatisfaction $ls_dom $X1
keep if e(sample)

reg lifesatisfaction $ls_dom $X1 if tornata==1, robust
reg lifesatisfaction $ls_dom if tornata==1, robust
reg lifesatisfaction $ls_dom $X1 if tornata==2, robust
reg lifesatisfaction $ls_dom if tornata==2, robust
restore
reg lifesatisfaction $ls_dom $X1 if trattamento==3 & tornata==1, robust
reg lifesatisfaction $ls_dom  if trattamento==3 & tornata==1, robust

**********
*CHOW TEST
**********

*Phase 1 vs. Phase 2
preserve
drop if trattamento==3 & tornata==2
drop if risposta!=1 & tornata==2
keep if (trattamento==1|trattamento==2) & risposta==1
sort id tornata
foreach i in $ls_dom{
by id: replace `i' = `i'[_n+1] if tornata==1 & trattamento!=3
}

foreach var in $ls_dom {
	gen tornata2_`var'=`var'*tornata2
}
foreach var in $X1 {
	gen tornata2X_`var'=`var'*tornata2
}
reg lifesatisfaction $ls_dom $X1 tornata2 tornata2_* tornata2X_* if trattamento!=3, robust
testparm tornata2 tornata2_* tornata2X_*
reg lifesatisfaction $ls_dom tornata2 tornata2_* if trattamento!=3, robust
testparm tornata2 tornata2_*
restore

********
*TABLE 9
********

preserve 

drop if risposta!=1 & tornata==2
sort id tornata

foreach var of global X {
 cap gen tornata2_`var'=tornata2*`var'
 }
 

reg lifesatisfaction tornata2* packedsidom $X if risposta==1 & (trattamento==1|trattamento==2), cluster(id)
testparm tornata2_*

restore

log close
