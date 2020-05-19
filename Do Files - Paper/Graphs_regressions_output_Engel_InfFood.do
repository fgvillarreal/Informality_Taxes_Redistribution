	 				*************************************
					* 	INFORMAl/FORMAL ENGEL CURVES 	*
					* For Food and Non Food Separately	*
					*************************************		
*********************************************	
* Preliminaries
*********************************************	
	cap log close
	clear all 
	set more off

	global scenario "central"    // central , proba , robust: see definition in Master.do	
	
*********************************************	
* Load Data 
*********************************************		
	
	* Load GDP data 
	tempfile gdp_data	
	import excel using "$main/data/Country_information.xlsx" , clear firstrow	
	
	rename Year year
	
	rename CountryCode country_code
	keep CountryName country_code GDP_pc_currentUS GDP_pc_constantUS2010 PPP_current year	
	save `gdp_data'
	
	* Load Data of Regression Slopes 
	use "$main/proc/regressions_inffood_$scenario.dta", clear
	
	merge m:1 country_code year using `gdp_data'
	keep if _merge == 3 
	drop _m
	
	gen log_GDP = log(GDP_pc_constantUS2010)
	
	forvalues i = 1(1)4 {
		gen ci_low`i' = b`i' - 1.96*(se`i') 
		gen ci_high`i' = b`i' + 1.96*(se`i') 
		replace b`i' = 	b`i'*100 if iteration == 1
		}	
	
	gen ratio_inf_food = 100 * b1 / (b1+b2) 
	gen ratio_inf_nonfood = 100 * b3 / (b3+b4)			
	
*********************************************	
* Figures 
*********************************************	
		
 	*** Level Graph for paper
	local size med
	local graph_region_options "graphregion(color(white)) bgcolor(white) plotregion(color(white))"
	local xtitle "xtitle("Log GDP per capita, Constant 2010 USD", margin(medsmall) size(`size'))"
	local yaxis "ylabel(0(20)100, nogrid labsize(`size')) yscale(range(0 12)) yline(0(20)100, lstyle(minor_grid) lcolor(gs1))" 
	local xaxis "xlabel(5(1)10, labsize(`size'))"	
	
	local ytitle1 "ytitle("Informal Food Consumption (Share of Total)", margin(medsmall) size(`size'))"
	local ytitle2 "ytitle("Formal Food Consumption (Share of Total)", margin(medsmall) size(`size'))"
	local ytitle3 "ytitle("Informal Non-Food Consumption (Share of Total)", margin(medsmall) size(`size'))"
	local ytitle4 "ytitle("Formal Non-Food Consumption (Share of Total)", margin(medsmall) size(`size'))"


	forvalues i = 1(1)4 {	
		#delim ;	
		
		twoway (scatter b`i' log_GDP if iteration == 1 , msize(vsmall) color(blue) mlabel(country_code) mlabsize(2.5) legend(on pos(1) ring(0) col(1) col(1) label(1 "Core Sample"))),
		`xaxis' 
		`yaxis' 
		`xtitle' 
		`ytitle`i''
		`graph_region_options'
		// title("Level of Informal Consumption on GDP", margin(medsmall) size(med))	
		name(level_`i', replace) ; 
		
		graph export "$main/graphs/cross_country/level_`i'_$scenario.pdf", replace	;
		
		#delim cr	
		} 	
		
				
 	*** Level Graph for appendix
	local size med
	local graph_region_options "graphregion(color(white)) bgcolor(white) plotregion(color(white))"
	local xtitle "xtitle("Log GDP per capita, Constant 2010 USD", margin(medsmall) size(`size'))"
	local yaxis "ylabel(0(20)100, nogrid labsize(`size')) yscale(range(0 12)) yline(0(20)100, lstyle(minor_grid) lcolor(gs1))" 
	local xaxis "xlabel(5(1)10, labsize(`size'))"	
	
	local ytitle1 "ytitle("Informal Food Consumption (Share of Total)", margin(medsmall) size(`size'))"
	local ytitle2 "ytitle("Formal Food Consumption (Share of Total)", margin(medsmall) size(`size'))"
	local ytitle3 "ytitle("Informal Non-Food Consumption (Share of Total)", margin(medsmall) size(`size'))"
	local ytitle4 "ytitle("Formal Non-Food Consumption (Share of Total)", margin(medsmall) size(`size'))"

	forvalues i = 1(1)4 {	
		#delim ;	
		
		twoway (scatter b`i' log_GDP if iteration == 1 , msize(vsmall) color(gs1) mlabel(country_code) mlabsize(2.5) mlabcolor(gs10*1.5)),
		`xaxis' 
		`yaxis' 
		`xtitle' 
		legend(off)
		`ytitle`i''
		`graph_region_options'
		// title("Level of Informal Consumption on GDP", margin(medsmall) size(med))	
		name(level_`i', replace) ; 
		
		graph export "$main/graphs/cross_country/app_level_`i'_$scenario.pdf", replace	;
		
		#delim cr	
		} 	
	
	*** Slopes graphs 	
	
	local size med
	local graph_region_options "graphregion(color(white)) bgcolor(white) plotregion(color(white))"
	local xtitle "xtitle("Log GDP per capita, Constant 2010 USD", margin(medsmall) size(`size'))"
	local yaxis "ylabel(-25(5)5, nogrid labsize(`size')) yscale(range(-25 5)) yline(-25(5)5, lstyle(minor_grid) lcolor(gs1))" 
	local xaxis "xlabel(5(1)10, labsize(`size'))"	
	
	local ytitle1 "ytitle("Informal Food Consumption Slope ", margin(medsmall) size(`size'))"
	local ytitle2 "ytitle("Formal Food Consumption Slope", margin(medsmall) size(`size'))"
	local ytitle3 "ytitle("Informal Non-Food Consumption Slope", margin(medsmall) size(`size'))"
	local ytitle4 "ytitle("Formal Non-Food Consumption Slope", margin(medsmall) size(`size'))"
	
	forvalues i = 1(1)4 {	
		#delim ;		
		
		twoway (rspike ci_low`i' ci_high`i' log_GDP if iteration == 3, lstyle(ci) lcolor(gs6) ) 
		(scatter b`i' log_GDP if iteration == 3, msize(vsmall) color(blue) mlabel(country_code) mlabsize(2.5) mlabcolor(navy)) ,
		`xaxis' 
		`yaxis'
		legend(order(2 "β Core Sample") pos(5) ring(0) col(1) ) 
		`xtitle'		
		`ytitle`i''
		`graph_region_options'	
		name(b`i', replace)		; 
		
		graph export "$main/graphs/cross_country/slope_Engel`i'_ci_$scenario.pdf", replace	;
		
		#delim cr	
		} 		

	*** Slopes graphs for appendix 
	
	local size med
	local graph_region_options "graphregion(color(white)) bgcolor(white) plotregion(color(white))"
	local xtitle "xtitle("Log GDP per capita, Constant 2010 USD", margin(medsmall) size(`size'))"
	local yaxis "ylabel(-20(5)20, nogrid labsize(`size')) yscale(range(-20 20)) yline(-20(5)20, lstyle(minor_grid) lcolor(gs1))" 
	local xaxis "xlabel(5(1)10, labsize(`size'))"	
	
	local ytitle1 "ytitle("Informal Food Consumption Slope ", margin(medsmall) size(`size'))"
	local ytitle2 "ytitle("Formal Food Consumption Slope", margin(medsmall) size(`size'))"
	local ytitle3 "ytitle("Informal Non-Food Consumption Slope", margin(medsmall) size(`size'))"
	local ytitle4 "ytitle("Formal Non-Food Consumption Slope", margin(medsmall) size(`size'))"
	
	forvalues i = 1(1)4 {	
		#delim ;		
		
		twoway (rspike ci_low`i' ci_high`i' log_GDP if iteration == 3, lstyle(ci) lcolor(gs6) ) 
		(scatter b`i' log_GDP if iteration == 3, msize(vsmall) color(gs1) mlabel(country_code) mlabsize(2.5) mlabcolor(gs10*1.5)) ,
		`xaxis' 
		`yaxis'
		`xtitle'
		legend(off)
		`ytitle`i''
		`graph_region_options'	
		name(b`i', replace)		; 
		
		graph export "$main/graphs/cross_country/app_slope_Engel`i'_ci_$scenario.pdf", replace	;
		
		#delim cr	
		}

	** Ratio of levels Graphs:  total informal food consumption/total food consumption 

	local size med
	local graph_region_options "graphregion(color(white)) bgcolor(white) plotregion(color(white))"
	local xtitle "xtitle("Log GDP per capita, Constant 2010 USD", margin(medsmall) size(`size'))"
	local yaxis "ylabel(0(20)100, nogrid labsize(`size')) yscale(range(0 12)) yline(0(20)100, lstyle(minor_grid) lcolor(gs1))" 
	local xaxis "xlabel(5(1)10, labsize(`size'))"	
	
	local ytitle1 "ytitle("Share of Food Consumption in Inf. Sector", margin(medsmall) size(`size'))"
	local ytitle2 "ytitle("Share of Non Food Consumption in Inf. Sector", margin(medsmall) size(`size'))"
	
	#delim ; 
	
	twoway (scatter ratio_inf_food log_GDP	if iteration == 1, msize(vsmall) color(gs1) mlabel(country_code) mlabsize(2.5) mlabcolor(gs10*1.5) ) , 
		`xaxis' 
		`yaxis' 
		`xtitle' 
		`ytitle1'
		legend(off) 	
		`graph_region_options'
		// title("Level of Informal Consumption on GDP", margin(medsmall) size(med))	
		name(ratio_food, replace) ; 
		
		graph export "$main/graphs/cross_country/ratio_food_$scenario.pdf", replace	;
		
	#delim cr	
		
		
	#delim ; 
	
	twoway (scatter ratio_inf_nonfood log_GDP	if iteration == 1, msize(vsmall) color(gs1) mlabel(country_code) mlabsize(2.5) mlabcolor(gs10*1.5) ) , 
		`xaxis' 
		`yaxis' 
		`xtitle' 
		`ytitle2'
		legend(off) 	
		`graph_region_options'
		// title("Level of Informal Consumption on GDP", margin(medsmall) size(med))	
		name(ratio_nonfood, replace) ; 
		
		graph export "$main/graphs/cross_country/ratio_nonfood_$scenario.pdf", replace	;
		
	#delim cr		
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
		
		
		
