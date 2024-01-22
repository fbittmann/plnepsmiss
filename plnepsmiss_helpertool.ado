*! version 1.0.0	Felix Bittmann	12/2023


cap program drop plnepsmiss_helpertool
program define plnepsmiss_helpertool, rclass
	***Runs Nepsmiss for all threads***
	syntax, [nepsmissoptions(string)]
	use "pl__datapart$pll_instance.dta", clear
	nepsmiss, `nepsmissoptions'
	save, replace
end
