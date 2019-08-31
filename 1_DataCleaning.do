	clear all
	set more off
	cd "C:\Users\eirik\OneDrive\Documents\2. Eikonomics\Reykjavikur Marathon\Results Analysis" 
	* import Raw data
	import delimited using "1_CompiledData\DATA.csv", varnames(1) case(lower) clear 
	
	* Standardise Origin of runners
	replace staður = "I_SR" if staður == "ISR"
	replace staður = "IS" if strpos(staður,"IS")>0
	replace staður = trim(staður)
	replace staður = "GBR" if staður == "UK"
	replace staður = "GER" if staður == "DEU"
	replace staður = "RUS" if staður == "RUSS"

	* convert birth year of runners from string to numeric
	destring(fæðár), replace force
	* gen age of runners
	gen agenum = year - fæðár

	* generate age brackets
	gen agegroup = ""
	replace agegroup = "0-19" if agenum <20
	replace agegroup = "20 - 29" if agenum >19
	replace agegroup = "30 - 39" if agenum >29
	replace agegroup = "40 - 49" if agenum >39
	replace agegroup = "50 - 59" if agenum >49
	replace agegroup = "60 - 69" if agenum >59
	replace agegroup = "70+" if agenum >69

	* Generate a dummy varible for Iceland
	gen ISL = 0
	replace ISL = 1 if staður=="IS"
	gen mfnum = 0
	replace mfnum = 1 if mf =="Konur"
	
	* Drop group wheelchair runners
	drop if group == "Hjólastólaflokkur"	

	* Create a panel varible for runners
		* assumptions: no two runners with the same name from the same place born in the same year
	gen panel = nafn + string(fæðár) + staður
	egen panel_id = group(panel)
	bysort panel_id: gen panel_N = _N

	* Drop duplicates
		* assumptions: only one name born in same year from same place 
	sort panel_id year
	bysort panel_id year: gen panel_n = _n
	keep if panel_n < 2
	
	* generate a varible with each year fastes and slowest times
	bysort year: egen max = max(brutto)
	bysort year: egen min = min(brutto)

	* summary stats for time and age
	tabstat brutto_sec, by(year) stats(mean sd p50 p90 p10 N)
	tabstat agenum, by(year) stats(mean sd p50 p90 p10 N)
	
	* export data
	save "1_CompiledData\\CleanData.dta", replace
	export delimited "1_CompiledData\CleanRvkMarathonData.csv", replace 
