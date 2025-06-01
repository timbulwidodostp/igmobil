{smcl}
{* *! version 1.1.0  15Oct2013}{...}
{hi:help igmobil}{right: ({browse "http://www.stata-journal.com/article.html?article=st0437":SJ16-2: st0437})}
{hline}

{title:Title}

{p2colset 5 16 18 2}{...}
{p2col :{bf:igmobil} {hline 2}}Calculate intergenerational mobility indices
for continuous and discrete variables{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:igmobil:}
{it:{help varname:varname1}} {it:{help varname:varname2}} 
{ifin}
[{cmd:,}  {it:options}]


{synoptset 27}{...}
{synopthdr}
{synoptline}
{synopt:{opt nosingle}}do not calculate single-stage indices{p_end}
{synopt:{opt notrans}}do not calculate transition-matrix indices{p_end}
{synopt:{opt noinequal}}do not calculate indices based on inequality measures{p_end}
{synopt:{opth userwr:itten(igmobil##userwrittenstr:userwrittenstr)}}include a user-written program in the estimation output {p_end}
{synopt:{opt cla:sses(#)}}specify in how many quantiles {it:{help varname:varname1}} and {it:{help varname:varname2}} should be divided; default is {cmd:classes(5)}{p_end}
{synopt:{opt disc:rete}}specify that {it:{help varname:varname1}}
	and {it:{help varname:varname2}} are discrete (or already discretized)
	random variables{p_end}
{synopt:{opt mat:rix(matname)}}save the transition matrix in {it:matname}{p_end}
{synopt:{opth fam:ily(igmobil##familystr:familystr)}}specify how to compare
inequality measures across generations{p_end}
{synopt:{opt ge(# [#])}}specify values of the generalized entropy measure
parameter{p_end}
{synopt:{opt atk(# [#])}}specify values of the Atkinson index parameter{p_end}
{synopt:{opth boot:strap(igmobil##bootstrapstr:bootstrapstr)}}customize the bootstrap procedure{p_end}
{synopt:{opth cit:ype(igmobil##citypestr:citypestr)}}control how to compute
and display confidence intervals{p_end}
{synopt:{opth f:ormat(fmt:formatstr)}}specify a display format{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
{cmd:by} is allowed; see {manhelp by D}.{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:igmobil} calculates intergenerational mobility (IGM) indices and related
inferential measures for continuous and discrete variables, where
{it:{help varname:varname1}} represents the most recent observation (that is,
the child's generation) and {it:{help varname:varname2}} represents the least
recent observation (that is, the parent's generation). Three general classes
of indices are considered: 1) single-stage indices, calculated on
continuous variables; 2) transition-matrix indices, calculated on discrete
(or discretized) variables; and 3) indices based on inequality measures, which
capture the notion of mobility as a long-term equalizer.  The inequality
measures used for the third index class are the Gini index; the generalized
entropy measure, GE(a); and the Atkinson index, Atk(epsilon). A fourth class
may be added to let the users specify any possible IGM index not included in
{cmd:igmobil}.  The full list of indices is given in
{help igmobil##remarks:{it:Remarks}}, and it is based on Cowell and Schluter
(1998) and Checchi and Dardanoni (2002).  The inferential measures (the
standard errors and confidence intervals) are computed via the
{help bootstrap} procedure. 

{pstd} 
{cmd:igmobil} can also be used for repeated observations over time, where
{it:{help varname:varname1}} is t1 and {it:{help varname:varname2}} is t0.

{pstd}
Data must be in the wide format. Continuous variables are assumed to be in
levels (that is, not logs).


{marker options}{...}
{title:Options}

    {title:Main}

{phang}
{opt nosingle} specifies to not calculate single-stage indices. {opt nosingle}
is appropriate when {it:varname1} and {it:varname2} are discrete variables
(such as occupational status or income class).  This is the default option
when the option {opt discrete} is specified. 

{phang}
{opt notrans} specifies to not calculate transition-matrix indices.
{opt notrans} is appropriate when the variables are continuous and there is
no interest in calculating the transition matrices. {opt notrans} must not be
used with the option {opt classes()} or {opt discrete}.

{phang}
{opt noinequal} specifies to not calculate indices based on inequality measures.
{opt noinequal} must not be used with the option {opt family()}, {opt ge()},
or {opt atk()}.

{marker userwrittenstr}{...}
{phang}
{opt userwritten(userwrittenstr)} specifies that the output include any IGM
index defined in {it:userwrittenstr}. The program must be r-class and return
the IGM index in a scalar named {cmd:UW}. An example is provided below.

    {title:Indices based on a transition matrix}
 
{phang}
{opt classes(#)} specifies the size of the quantile transition matrix on
which transition-matrix indices are to be calculated.  The default is
{cmd:classes(5)}. Quantiles are computed using the {helpb xtile} command.
{opt classes(#)} can be used when {it:varname1} and {it:varname2} are
continuous and the user wants to specify a quantile transition matrix with
a size different from 5. {opt classes(#)} must not be used when variables are
discrete or when the option {opt discrete} or {opt notrans} is used.

{phang}
{opt discrete} specifies that {it:{help varname:varname1}} and
{it:{help varname:varname2}} are discrete (or already discretized) variables
(such as types of jobs, levels of education, or income categories).  When
{cmd:discrete} is used, single-stage and inequality-based indices will
not be computed because we are dealing with discrete random variables.
{opt discrete} must not be used with {opt classes()}.

{phang}
{opt matrix(matname)} saves the resulting transition matrix in {it:matname}.
If the option {opt notrans} is used, {opt matrix()} is ignored.

    {title:Indices based on inequality measures}

{marker familystr}{...}
{phang}
{opt family(familystr)} specifies what indices will be used to compare
inequality measures across generations. {it:familystr} can be {cmd:fields} or
{cmd:shorrocks} (see Fields [2010] and Shorrocks [1978]).  The default is
{cmd:family(fields)}.

{phang}
{opt ge(# [#])} specifies the values of the generalized entropy measure
parameter.  The maximum two values of {opt ge()} can be listed; if only one
value is chosen, it is repeated twice.  The default is {cmd:ge(0 1)}.

{phang}
{opt atk(# [#])} specifies the values of the Atkinson index parameter. The
maximum two values of {opt atk()} can be listed; if only one value is chosen,
it is repeated twice.  The default is {cmd:atk(0.5 2)}.

    {title:Inference and reporting}

{marker bootstrapstr}{...}
{phang}
{opt bootstrap(bootstrapstr)} allows the user to customize almost every
aspect of the bootstrap procedure.  {it:bootstrapstr} can be any valid
option of the {helpb bootstrap} command, including
{opt reps()},
{opt strata()},
{opt size()},
{opt saving()},
{opt level()}, or
{opt seed()}.
The options {opt notable}, {opt nolegend}, and {opt nowarn}
are already "built-in".  The computation of the bootstrapped standard errors
can be avoided using the option {cmd:bootstrap(off)}.

{marker citypestr}{...}
{phang}
{opt citype(citypestr)} specifies how confidence intervals are
to be computed and displayed.  {it:citypestr} can be {cmd:normal},
{cmd:percentile}, or {cmd:bc}, which stand, respectively, for normal
approximation, percentile method, and bias-corrected confidence intervals. 

{phang}
{opt format(formatstr)} displays results accordingly; see {helpb format}.


{marker remarks}{...}
{title:Remarks: List of IGM indices considered}

{phang} Single-stage indices

       1.  Absdif        : 1/N * sum |X - Y| 
       2.  Sqdif         : 1/N * sum (X - Y)^2 
       3.  Fields/Ok     : 1/N * sum |ln X - ln Y|  
       4.  Share         : 1/N * sum (X/mu(X) - Y/mu(Y))^2  
       5.  Hart          : 1 - Pearson coef. (on logs)
       6.  Spearman      : 1 - Spearman coef. (on logs)
       7.  AbsCDF        : 1/N * sum |CDF X - CDF Y|   
       8.  SqCDF         : 1/N * sum (CDF X - CDF Y)^2 
       9.  1-OLS(levels) : 1 - OLS(Y,X)  
      10.  1-OLS(logs)   : 1 - OLS(ln Y,ln X) 

{phang} Indices based on a (K x K) transition matrix P, with generic element p_ij

      11. Shorrocks/Prais : 1/(K-1) * (K-trace(M))  
      12. Bartholomew     : 1/(K*(K-1)) * sum_i sum_j p_ij |i-j| 
      13. Eigenvalue2     : 1 - |lambda_2|
      14. Determinant     : 1 - |det(M)|

{phang} Indices based on cross-sectional inequality measures I(.) and family F,
with F = {Fields, Shorrocks}. {p_end}
{phang} For the Fields family, F = 1 - I(Z)/I(X). For the Shorrocks family,
F = 1 - I(Z)/(mu_X/mu_Z*I(X) + mu_Y/mu_Z*I(Y)), where Z = 0.5*(Y+X).
 		
      15. F - Gini        : F = {Fields, Shorrocks}, I = Gini
      16. F - GE(a_1)     : F = {Fields, Shorrocks}, I = generalized entropy
                                                           with parameter a_1
      17. F - GE(a_2)     : F = {Fields, Shorrocks}, I = generalized entropy
                                                           with parameter a_2
      18. F - Atk(epsilon_1)  : F = {Fields, Shorrocks}, I = Atkinson index with
                                                           parameter epsilon_1
      19. F - Atk(epsilon_2)  : F = {Fields, Shorrocks}, I = Atkinson index with
                                                           parameter epsilon_2

{phang} User-written program (optional)

      20. user-written program


{marker examples}{...}
{title:Examples}

{pstd}
Artificial data simulation: lognormal continuous random variables and
discretized random variables

        {bf:. {stata clear}}
        {bf:. {stata matrix C = (.25, .5*.25 \ .5*.25, .25)}}
        {bf:. {stata drawnorm u0 u1, n(1000) cov(C)}}
	 
        {bf:. {stata generate dad = exp(u0)}}
        {bf:. {stata generate son = exp(u1)}}

        {bf:. {stata generate dad_disc = irecode(u0, -2, -1, 1, 2)}}
        {bf:. {stata generate son_disc = irecode(u1, -2, -1, 1, 2)}}

{pstd}
Typical use of {cmd:igmobil}

        {bf:. {stata igmobil son dad}}
        {bf:. {stata igmobil son dad, classes(10) noinequal}}
        {bf:. {stata igmobil son_disc dad_disc, discrete }}

{pstd}
Customizing IGM based on inequality measures 

        {bf:. {stata igmobil son dad, family(shorrocks) atk(2 5) ge(-2 2)}}
        {bf:. {stata igmobil son dad, family(fields) atk(5) ge(-2)}}

{pstd}
Bootstrap options and confidence intervals

{phang2}{bf:. {stata igmobil son dad, family(fields) bootstrap(reps(20) seed(12345))}}{p_end}
{phang2}{bf:. {stata igmobil son dad, family(fields) bootstrap(reps(20) seed(12345)) citype(percentile)}}

{pstd}
Testing and retrieving estimation results

{phang2}{bf:. {stata igmobil son dad, nosingle notrans family(shorrocks) bootstrap(reps(20) seed(12345))}}{p_end}
        {bf:. {stata test i15=0.30}}
        {bf:. {stata test i16=i17}}
        {bf:. {stata disp _b[i19]}}
	   
{pstd}
Saving and organizing estimation results
	   
        {bf:. {stata generate country = cond(_n<= 500, "A", "B")}}
{phang2}{bf:. {stata quietly igmobil son dad if country == "A",  nosingle noinequal}}{p_end}
        {bf:. {stata estimate store igm_A}}
{phang2}{bf:. {stata quietly igmobil son dad if country == "B",  nosingle noinequal}}{p_end}
        {bf:. {stata estimate store igm_B}}
{phang2}{bf:. {stata estimates table igm_A igm_B, stats(N) b(%9.4f) se(%9.4f) keep(i11-i13)}}

{pstd}
Including a new IGM index

{phang2}
Assume we want to add a new IGM index capturing upward mobility to the four
transition-matrix indices (such as the one in Bhattacharya and Mazumder
[2011]).  This gives the probability that the child's rank exceeds the
parent's rank by a given amount tau, given that the parent's rank is below a
given level s. 

    *--------------------------------------------------------------------------
    capture program drop myindex
        program myindex, rclass
        syntax varlist(min=2 max=2 numeric) [if] [in] [, tau(real 0) s(real 0.25)]

        marksample touse

        tempvar y x ry rx diff 
        tempname num den

        tokenize `varlist'
        quietly {
            generate `y'  = `1' if `touse'
            generate `x'  = `2' if `touse'

            cumul `y', gen(`ry')
            cumul `x', gen(`rx')

            count if (`ry'-`rx') > `tau' & `rx' <= `s'  &  `touse'
            scalar `num' = r(N)

            count if `rx' <= `s' & `touse'
            scalar `den' = r(N)

            return scalar UW = `num'/`den'
        }

	end
	*----------------------------------------------------------------------
	
{phang2}{bf:. {stata igmobil son dad, nosingle noinequal  userwr(myindex son dad, tau(0.1) s(0.25))}}


{marker stored_results}{...}
{title:Stored results}

{pstd}
{cmd:igmobil} stores results in {bf:e()}.  The results stored are the same as
in any {helpb bootstrap} command.


{title:References}

{phang}
Bhattacharya, D., and B. Mazumder. 2011. A nonparametric analysis of
black-white differences in intergenerational income mobility in the United
States. {it:Quantitative Economics} 2: 335-379.

{phang}
Checchi, D., and V. Dardanoni. 2002. Mobility comparisons: Does using
different measures matter? Departmental Working Papers 2002-15, Department of
Economics, Management, and Quantitative Methods at Universita degli Studi di
Milano. {browse "http://ideas.repec.org/p/mil/wpdepa/2002-15.html"}.

{phang}
Cowell, F. A., and C. Schluter. 1998. Income mobility: A robust approach.
Discussion paper DARP/37, Suntory and Toyota International Centres for
Economics and Related Disciplines, London Schoool of Economics and Political
Science.  {browse "http://sticerd.lse.ac.uk/dps/darp/darp37.pdf"}.

{phang}
Fields, G. S. 2010. Does income mobility equalize longer-term incomes?  New
measures of an old concept. {it:Journal of Economic Inequality} 8: 409-427.

{phang}
Shorrocks, A. F. 1978. Income inequality and income mobility.
{it:Journal of Economic Theory} 19: 376-393.


{title:Author}

{pstd}
Marco Savegnago, Bank of Italy and University of Rome 'Tor Vergata'{break}
savegnago.marco@gmail.com


{title:Also see}

{p 4 14 2}
Article:  {it:Stata Journal}, volume 16, number 2: {browse "http://www.stata-journal.com/article.html?article=st0437":st0437}
{p_end}
