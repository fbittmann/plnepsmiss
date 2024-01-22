*! version 1.0.0	Felix Bittmann	12/2023


cap program drop plnepsmiss
program define plnepsmiss, rclass
	syntax, [threads(integer 2) nepsmissoptions(string) timer]
	
	*** Options for Timer ***
	if "`timer'" == "timer" {
		timer clear 33
		timer on 33
	}
	
	
	*** Check for threads ***
	if !inrange(`threads', 2, 9) {
		di as error "Error! Specify between 2 and 9 threads!"
		error 9
		/*Theoretically, more than 9 cores are possible, but the REGEX used below
		does not work as planned with double digit numbers... sorry*/
		exit
	}
	
	*** Warning messages ***
	di as result "******************************************************************************"
	di as result "*** Caution! This program comes with ABSOLUTELY NO WARRANTY!"
	di as result "*** It is YOUR obligation to check the validity of all results!"
	di as result "*** This program requires nepstools, see:"
	di as result "*** https://www.neps-data.de/Data-Center/Overview-and-Assistance/Stata-Tools"
	di as result "*** and"
	di as result "*** parallel, see:"
	di as result "*** https://github.com/gvegayon/parallel"
	di as result "******************************************************************************"

	
	*** Store values for sanity checks ***
	qui describe				//Count variables
	local ntotalvars1 = `r(k)'
	local ntotalobs1 = _N
	di as result "Dataset: `ntotalvars1' variables / `ntotalobs1' rows"
	
	
	*** Rename all variables for further operations ***
	unab originalvars : _all	//Create macro with all variable names in dataset
	gen pl__newid = _n		//ID for merging later
	local counter = 0
	forvalues i = 1/`threads' {
		local lastvalue`i' = -1
	}
	foreach VAR of varlist `originalvars' {
		local group = mod(`counter', `threads') + 1
		rename `VAR' variable___`group'_`counter'
		forvalues i = 1/`threads' {
			if `group' == `i' {
				local lastvalue`i' = `counter'
			}		
		}
		local ++counter
	}
	

	*** Create separate datasets by group for parallel to use ***
	order _all, sequential
	order pl__newid			//First position for ID
	forvalues i = 1/`threads' {
		preserve
		local startvalue = `i' - 1
		keep pl__newid variable___`i'_`startvalue' - variable___`i'_`lastvalue`i''
		cap save "pl__datapart`i'.dta"
		if _rc != 0 {
			di as error "Warning! A file with the name pl__datapart`i'.dta already exists in"
			di as error "the current working directory! Please delete that file manually and"
			di as error "run plnepsmiss again!"
			error 602
			exit
		}
		restore
	}


	*** Run helper program ***
	parallel inititalize `threads'
	parallel, nodata: ///
		plnepsmiss_helpertool, nepsmissoptions(`nepsmissoptions')


	*** Recombine dataparts into a single file ***
	qui use "pl__datapart1.dta", clear
	forvalues i = 2/`threads' {
		qui merge 1:1 pl__newid using "pl__datapart`i'.dta", nogen assert(3)
	}
	
	
	*** Erase temporary datafiles ***
	forvalues i = 1/`threads'{
		erase "pl__datapart`i'.dta"
	}


	*** Remove group information to enable correct ordering ***
	drop pl__newid
	unab currentvars : _all
	foreach VAR of varlist `currentvars' {
		local finalname = regexr("`VAR'", "___[1-9]", "") 	//Only digits 1 to 9 possible!
		rename `VAR' `finalname'
	}
	order _all, sequential		//Order by original ordering


	*** Rename variables back to original names ***
	unab currentvars : _all
	local counter = 1
	foreach VAR of varlist `currentvars' {
		local x : word `counter' of `originalvars'
		rename `VAR' `x'
		local ++counter
	}
	
	
	*** Final sanity checks ***
	qui describe				//Count variables
	local ntotalvars2 = `r(k)'
	local ntotalobs2 = _N
	assert `ntotalvars1' == `ntotalvars2'
	assert `ntotalobs1' == `ntotalobs2'
	if "`timer'" == "timer" {
		timer off 33
		qui timer list 33
		local totaltime = round(`r(t33)')
		local runtime " Runtime: `totaltime' seconds."
		timer clear 33
	}
	di as result "******************************************************************************"
	di as result "*** Program finished. All checks passed.""`runtime'"
	di as result "******************************************************************************"
end
