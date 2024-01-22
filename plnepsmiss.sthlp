{smcl}
{* *! version 1.0 January 2024}{...}
{vieweralsosee "nepsmiss" "help nepsmiss"}{...}
{vieweralsosee "nepstools" "help NEPStools"}{...}
{vieweralsosee "parallel" "help parallel"}{...}
{viewerjumpto "Syntax" "plnepsmiss##syntax"}{...}
{viewerjumpto "Description" "plnepsmiss##description"}{...}
{viewerjumpto "Options" "plnepsmiss##options"}{...}
{viewerjumpto "Examples" "plnepsmiss##examples"}{...}
{viewerjumpto "Author" "plnepsmiss##author"}{...}
{viewerjumpto "Also see" "plnepsmiss##alsosee"}{...}
help for {cmd:plnepsmiss}{right:version 1.0 (January 2024)}
{hline}


{title:Title}

{phang}
{bf:plnepsmiss} {hline 2} run nepsmiss with multiple threads


{marker syntax}
{title:Syntax}

{p 8 17 2}
{cmd:plnepsmiss} [, {it:options}]
{p_end}



{marker description}
{title:Description}

{pstd}
{cmd:plnepsmiss} runs the NEPStools program {cmd:nepsmiss} with multiple threads, reducing total runtime.
Note that it is not possible to run plnepsmiss for a list of variables as it affects all variables in the dataset.
For more details refer to {cmd:nepsmiss}. Most options of the original program can be passed down. This program
requires nepstools and parallel, which can be installed from:
{browse "https://www.neps-data.de/Data-Center/Overview-and-Assistance/Stata-Tools"}
and
{browse "https://github.com/gvegayon/parallel"}.
This program splits the current dataset up and saves the newly created parts to your disk during runtime, so make
sure that enough space is available.
{p_end}


{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt threads} specifies the number of threads to use, the default is 2. How many threads can be set depends on your CPU. Currently,
the program supports between 2 and 9 threads. Using more threads than your system provides can lead to crashes.

{phang}
{opt nepsmissoptions(string)} allows passing arguments of the original program, see {cmd:nepsmiss}  for a list of valid arguments.

{phang}
{opt timer} displays the total runtime of the program after successful completion.
{p_end}

{marker examples}
{title:Examples}

{phang}Run plnepsmiss with 3 threads on NEPS SC3 data:{p_end}
{phang}{cmd:. use "SC3_D_12-1-0/Stata\SC3_pTarget_D_12-1-0.dta", clear}{p_end}
{phang}{cmd:. plnepsmiss, threads(3)}{p_end}


{phang}Reverse the process:{p_end}
{phang}{cmd:. plnepsmiss, threads(3) nepsmissoptions(reverse)}{p_end}



{marker author}
{title:Author}

{pstd}
Felix Bittmann ({browse "mailto:felix.bittmannlifbi.de":felix.bittmann@lifbi.de}), Leibniz Institute for Educational Trajectories (LIfBi), Germany.{break}
{p_end}




{marker alsosee}
{title:Also see}

{psee}
{help NEPStools}, {help nepsmiss}, {help parallel}
{p_end}
