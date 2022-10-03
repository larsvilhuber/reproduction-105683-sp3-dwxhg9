local sample = "$sample"
use "$Path/data/randHIE_clean`sample'.dta", clear

* This file produces table 2 in the main document.

local demos="sexage_d* tinc"
local controls="calyear_d* siteenrdate_d*"

eststo clear
foreach cat in "rtotspend"  {

eststo: quietly: xi: regress `cat' 	i.plan_aef  							 			`controls', cluster(fam_id)
eststo: quietly: xi: regress `cat' 	i.plan_aef  lastyr		 				 			`controls', cluster(fam_id)
eststo: quietly: xi: regress `cat' 	i.plan_aef  lastyr	i.plan_aefT			 			`controls', cluster(fam_id)
eststo: quietly: xi: regress `cat' 	i.plan_aef  					enrterm `demos' 	`controls', cluster(fam_id)
eststo: quietly: xi: regress `cat' 	i.plan_aef  lastyr		 		enrterm `demos' 	`controls', cluster(fam_id)
eststo: quietly: xi: regress `cat' 	i.plan_aef  lastyr	i.plan_aefT	enrterm `demos' 	`controls', cluster(fam_id)

}



********************************************
*make labels for tables******* must repeat *
	
label var lastyr 			"D.year"

label var _Iplan_aef_2 "25/% plan"
label var _Iplan_aef_3 "Mixed coins."
label var _Iplan_aef_4 "50/% plan"
label var _Iplan_aef_5 "Indiv. deductible"
label var _Iplan_aef_6 "95/% plan"

local tag=substr("aefT",1,6)

label var _Iplan_`tag'_2 "D.year$/times$25/% plan"
label var _Iplan_`tag'_3 "D.year$/times$ Mixed c."
label var _Iplan_`tag'_4 "D.year$/times$50/% plan"
label var _Iplan_`tag'_5 "D.year$/times$ Indiv. d."
label var _Iplan_`tag'_6 "D.year$/times$95/% plan"

*label var _Ienrterm_2  "Enrol. term = 5"
label var enrterm "Enrol. term = 5"

********************************************

estout, style(tex) ///
		cells(b(star fmt(%7.2f)) se(par)) stats(N r2, labels ("N" "R$^2$") fmt(%7.0f %7.2f)) /// 
		label varlabels(_cons "Constant (free care)") ///
		order(_cons) ///
		starlevels(* .1 ** .05 *** .01) ///
		mlabels("Model (/ref{eq:aef})" "Model (/ref{eq:flatdeadline})" "Model (/ref{eq:deadline})" "Model (/ref{eq:aef})" "Model (/ref{eq:flatdeadline})" "Model (/ref{eq:deadline})" ) ///
indicate("Site $/times$ enrol.=siteenrdate_d*" "Cal. years=calyear_d*" "Demographics=sexage_d* tinc")
*
estout using "$Path/output/Table_02.txt", replace style(tex) ///
		cells(b(star fmt(%7.2f)) se(par)) stats(N r2, labels ("N" "R$^2$") fmt(%7.0f %7.2f)) /// 
		label varlabels(_cons "Constant (free care)") ///
		order(_cons) ///
		starlevels(* .1 ** .05 *** .01) ///
		mlabels("Model (/ref{eq:aef})" "Model (/ref{eq:flatdeadline})" "Model (/ref{eq:deadline})" "Model (/ref{eq:aef})" "Model (/ref{eq:flatdeadline})" "Model (/ref{eq:deadline})" ) ///
indicate("Site $/times$ enrol.=siteenrdate_d*" "Cal. years=calyear_d*" "Demographics=sexage_d* tinc")


* test coefs for footnotes
eststo clear
foreach cat in "rtotspend"  {

eststo: quietly: xi: regress `cat' 	i.plan_aef  							 			`controls'
eststo: quietly: xi: regress `cat' 	i.plan_aef  lastyr		 				 			`controls'
eststo: quietly: xi: regress `cat' 	i.plan_aef  lastyr	i.plan_aefT			 			`controls'
eststo: quietly: xi: regress `cat' 	i.plan_aef  					enrterm `demos' 	`controls'
eststo: quietly: xi: regress `cat' 	i.plan_aef  lastyr		 		enrterm `demos' 	`controls'
eststo: quietly: xi: regress `cat' 	i.plan_aef  lastyr	i.plan_aefT	enrterm `demos' 	`controls'

* testing difference in constant between baseline and deadline models
quietly suest est1 est2, cluster(fam_id)

test _b[est1_mean:_cons]=_b[est2_mean:_cons]
local test_cons = r(p)
di "`test_cons'"

quietly suest est4 est5, cluster(fam_id)

test _b[est4_mean:_cons]=_b[est5_mean:_cons]
local test_cons = r(p)
di "`test_cons'"


* testing difference in constant between deadline and deadline-interactive models
quietly suest est2 est3, cluster(fam_id)

test _b[est2_mean:_cons]=_b[est3_mean:_cons]
local test_cons = r(p)
di "`test_cons'"

quietly suest est5 est6, cluster(fam_id)

test _b[est5_mean:_cons]=_b[est6_mean:_cons]
local test_cons = r(p)
di "`test_cons'"

* test inclusion of enrollment dummy and demographics


* testing JOINT difference in plan effects when demos & enrterm introduced
quietly suest est1 est4, cluster(fam_id)

test (_b[est1_mean:_cons]=_b[est4_mean:_cons]) ///
	 (_b[est1_mean:_Iplan_aef_2]=_b[est4_mean:_Iplan_aef_2]) ///
	 (_b[est1_mean:_Iplan_aef_3]=_b[est4_mean:_Iplan_aef_3]) ///
	 (_b[est1_mean:_Iplan_aef_3]=_b[est4_mean:_Iplan_aef_4]) ///
	 (_b[est1_mean:_Iplan_aef_3]=_b[est4_mean:_Iplan_aef_5]) ///
	 (_b[est1_mean:_Iplan_aef_3]=_b[est4_mean:_Iplan_aef_6])
local test_cons = r(p)
di "`test_cons'"

quietly suest est2 est5, cluster(fam_id)

test (_b[est2_mean:_cons]=_b[est5_mean:_cons]) ///
	 (_b[est2_mean:_Iplan_aef_2]=_b[est5_mean:_Iplan_aef_2]) ///
	 (_b[est2_mean:_Iplan_aef_3]=_b[est5_mean:_Iplan_aef_3]) ///
	 (_b[est2_mean:_Iplan_aef_3]=_b[est5_mean:_Iplan_aef_4]) ///
	 (_b[est2_mean:_Iplan_aef_3]=_b[est5_mean:_Iplan_aef_5]) ///
	 (_b[est2_mean:_Iplan_aef_3]=_b[est5_mean:_Iplan_aef_6])
local test_cons = r(p)
di "`test_cons'"

quietly suest est3 est6, cluster(fam_id)

test (_b[est3_mean:_cons]=_b[est6_mean:_cons]) ///
	 (_b[est3_mean:_Iplan_aef_2]=_b[est6_mean:_Iplan_aef_2]) ///
	 (_b[est3_mean:_Iplan_aef_3]=_b[est6_mean:_Iplan_aef_3]) ///
	 (_b[est3_mean:_Iplan_aef_3]=_b[est6_mean:_Iplan_aef_4]) ///
	 (_b[est3_mean:_Iplan_aef_3]=_b[est6_mean:_Iplan_aef_5]) ///
	 (_b[est3_mean:_Iplan_aef_3]=_b[est6_mean:_Iplan_aef_6])
local test_cons = r(p)
di "`test_cons'"


}
