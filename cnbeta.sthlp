{smcl}
{* 4May2019}{...}
{cmd:help cnbeta}{right: }
{hline}

{title:Title}


{phang}
{bf:cnbeta} {hline 2} Estimate Beta for stocks in China by using CAPM model

{title:Syntax}

{p 8 18 2}
{cmdab:cnbeta} {it: stockcode} {cmd:,} [{it:options}]


{marker options}{...}
{title:Options for cntrade}


{phang}
{opt fd(#)}:first day (from 1 to 31). The default value is 1 .{p_end}

{phang}
{opt fm(#)}:first month (from 1 to 12). The default value is 1 .{p_end}

{phang}
{opt fy(#)}:first year. The default is 1990 .{p_end}

{phang}
{opt ld(#)}:last day (from 1 to 31). The default value is 31 .{p_end}

{phang}
{opt lm(#)}:last month (from 1 to 12). The default value is 12 .{p_end}

{phang}
{opt ly(#)}:last year. The default is 2099, which will be the current year .{p_end}

{phang}
{opt byyear}:if byyear is specified, beta will be estimated by year from fy to ly .{p_end}

{phang}
{opt roll}:if roll is specified, beta will be estimated by rolling from fy to ly. The estimation are required to specify the frequnecy of the data(day,month, or year) and the window length of the estimation.{p_end}

{phang}
{opt rwindow(#)}:specify the estimation window length for rolling estimation, The default value is 12.{p_end}

{phang}
{opt datatype(string)}:specify the frequncy of data during rolling estimation, "d","m","y" stand for day, month, year respectively.{p_end}

{phang}
{opt indexop(numlist)}:if indexcode of the index you want to use in the estimation, otherwise cnbeta will automatically choose index of the divided market which the stock belongs to. {p_end}



{marker description}{...}
{title:Description}
{pstd} {hi:Cnbeta} can present the betas of stocks in China in graphs with multiple estimating ways, such as overall, byyear and roll. You can choose the estimation period by options "fy","fm","fd","ly","lm","ld". {p_end}

{pstd}{it:stockcode} is a six digit numbers ID for stocks in China. Examples of codes and the names are as following: {p_end}
{pstd} {hi:Stock Codes and Stock Names:} {p_end}
{pstd} {hi:000001} Pingan Bank  {p_end}
{pstd} {hi:000002} Vank Real Estate Co. Ltd. {p_end}
{pstd} {hi:600000} Pudong Development Bank {p_end}
{pstd} {hi:600005} Wuhan Steel Co. Ltd. {p_end}
{pstd} {hi:900901} INESA Electron Co.,Ltd. {p_end}

{pstd} You can also decide which index you want to pick as the proxy of market by the option "indexop". Index codes are as followed:{p_end}
{pstd} {hi:000001} The Shanghai Composite Index. {p_end}
{pstd} {hi:000003} The Shanghai B-share Index. {p_end}
{pstd} {hi:000300} CSI 300 Index. {p_end}
{pstd} {hi:399001} Shenzhen Component Index. {p_end}
{pstd} {hi:399108} Shenzhen B-share Index. {p_end}
{pstd} {hi:399005} Small and Medium Enterprise Board Index. {p_end}
{pstd} {hi:399006} Growth Enterprise Market Index. {p_end}

{pstd}When you want to estimate betas by rolling, choose the datatype carefully. Long period(like 10 years) and high frequency(day-type data) may lead to quite a long time of waiting for the calculation.{p_end}

{pstd}When you choose neither byyear or roll, the program regards it as to estimate the overall period beta.{p_end}

{title:Examples}
{phang}
{stata `"cnbeta 600028"'}
{p_end}
{phang}
{stata `"cnbeta 900915, byyear"'}
{p_end}
{phang}
{stata `"cnbeta 000971, byyear indexop(000300)"'}
{p_end}
{phang}
{stata `"cnbeta 000532, roll datatype(m) "'}
{p_end}
{phang}
{stata `"cnbeta 002747, roll fd(3) fm(6) fy(2016) ld(9) lm(10) ly(2018) datatype(d)"'}
{p_end}
{phang}
{stata `"cnbeta 300480, roll fy(2012) rwindow(5) datatype(m) "'}
{p_end}


{title:Acknowledgement}
{pstd}This program has been supported by Lian Yujun(Lingnan College, Sun Yat-Sen University){p_end}
{pstd}Thanks to authors of cntrade:{p_end}
{pstd}Chuntao Li,Ph.D., Xuan Zhang,Ph.D., Yuan Xue,China Stata Club(爬虫俱乐部){p_end}
{pstd}As well as authors of regfit{p_end}
{pstd}Liu wei(Renmin University of China){p_end}


{title:Authors}
{pstd}Jie Hu{p_end}
{pstd}Stata连享会 {p_end}
{pstd}Guangzhou, China{p_end}
{pstd}hujie27@mail2.sysu.edu.cn{p_end}

