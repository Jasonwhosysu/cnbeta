cap program drop cnbeta
program define cnbeta
	version 15

	syntax 	anything(name=stockquote) ///
	[,fm(integer 1)] [fd(integer 1)] [fy(integer 1990)] ///
	[lm(integer 12)] [ld(integer 31)] [ly(integer 2099)] ///
	[byyear] ///
	[roll] [rwindow(integer 12)] [datatype(string)] ///
	[indexop(numlist)]
	preserve
	
qui {	

********************************数据预处理****************************************

*生成股票代码筛选指标
		clear
		grss clear
		global id =`stockquote'
		scalar stockcode = floor(`stockquote'/1000)
*调入数据生成股价时序图
		capture which cntrade
		if _rc != 0 {
		dis in red "you should install cntrade by typing -ssc install-"
		}
		cntrade $id
		save $id.dta , replace
		global nn = stknme[1]
		tsset date
		grss tsline clsprc , xlabel(,angle(60)) subtitle("Stock Price of $nn $id ")
		graph export "$out\price_$id.png", replace
		
*指数选项处理
		if "`indexop'"!=""{
			cntrade `indexop', index
			rename rmt retmkt_`indexop'
			save index_`indexop'.dta, replace
			use "index_`indexop'.dta", clear
		}		
		else {
	*沪市B股指数
				if stockcode>899{
					cntrade 000003, index
					rename rmt retmkt_000003
					save index_000003.dta, replace
					use "index_000003.dta", clear
				}
	*沪市A股-上证综指
				else if stockcode>599{
					cntrade 000001, index
					rename rmt retmkt_000001
					save index_000001.dta, replace
					use "index_000001.dta", clear
				}
	*创业板指数			
				else if stockcode>299{
					cntrade 399006, index
					rename rmt retmkt_399006
					save index_399006.dta, replace
					use "index_399006.dta", clear
				}
	*深市B股指数			
				else if stockcode>199{
					cntrade 399108, index
					rename rmt retmkt_399108
					save index_399108.dta, replace
					use "index_399108.dta", clear
				}			
	*中小板指数			
				else if stockcode>1{
					cntrade 399005, index
					rename rmt retmkt_399005
					save index_399005.dta, replace
					use "index_399005.dta", clear
				}
	*深市A股-深成指			
				else {
					cntrade 399001, index
					rename rmt retmkt_399001
					save index_399001.dta, replace
					use "index_399001.dta", clear
				}
		}

		
		global iname=indexnme[1]
		merge 1:1 date using "$id.dta", nogen force
		gen year = year(date)
		gen month = month(date)
		gen day = day(date)
		local y_1=year[1]
		local m_1=month[1]
		local d_1=day[1]
		drop if year<`fy'
		drop if month<`fm' & year == `fy'
		drop if day<`fd' & month==`fm' & year == `fy'		
		drop if year>`ly'
		drop if month>`lm' & year == `fy'
		drop if day>`ld' & month==`fm' & year == `fy'	
		sum
		local numofob = r(N)
		if `numofob' < 10{
		disp as error "There is not enough data for estimation"
		exit 198
		}
		order date year month day index* stk* r*
		
		save "merge_$id_daydta.dta", replace
		

********************************整个区间的beta************************************		

		use "merge_$id_daydta.dta", clear 
		reg rit retmkt		
		_coef_table
		
		global starty=year[1]
		global lasty=year[_N]
		grss aaplot rit retmkt if e(sample), xline(0,lp(dash) lc(red)) ///
            yline(0,lp(dash) lc(red)) msize(*0.6) ///  
            title(" Beta Coefficient of $nn ($id) , $starty - $lasty") ///
            xtitle("Market Index Return Rate ($iname)") 
		graph export "$out\aaplot_$id_b$yr.png", replace    
    
		regfit, f(%4.2f) tvalue   //呈现拟合方程
		
********************************逐年估计*****************************************
    	
	    if "`byyear'"!=""{
			use "merge_$id_daydta.dta", clear // !!!
			bysort year: reg rit retmkt, noheader
			statsby _b[retmkt], by(year) saving("beta_year_data.dta", replace): ///
				reg rit retmkt
			use "beta_year_data.dta", clear
			keep if _stat!=.
			sum year
			local byr = r(min)
			local eyr = r(max)
			list
			#d ;
			grss twoway connect _stat year,  
					yline(1, lpattern(dash) lcolor(red*0.3)) 
					xlabel(`byr'(2)`eyr')
					ylabel(,angle(0) format(%2.1f)) 
					subtitle("$Beta Coefficient of $nn ($id), Estimated by year" )
					ytitle("beta") xtitle("");
			#d cr
			graph export "beta byyear $nn $id.png", replace
			}

********************************滚动估计*****************************************			
		if "`roll'"!=""{
*未选择数据类型
			if "`datatype'"=="m"{
								clear
				cntrade $id
				gen year = year(date)
				gen month = month(date)
				gen day = day(date)
				keep stkcd date stknme clsprc rit year month day
				gen Order=_n
				tsset Order
				gen lagmonth = L.month
				gen indic=month-lagmonth
				drop if indic==0
				gen orDer=_n
				tsset orDer
				gen t=clsprc-F.clsprc
				gen mrit=t/F.clsprc
				keep stkcd date stknme year month mrit 
				save $id_dtom.dta , replace
				clear
				*指数选项处理
					if "`indexop'"!=""{
						cntrade `indexop', index
						rename rmt retmkt_`indexop'
						save index_`indexop'.dta, replace
						use "index_`indexop'.dta", clear
					}		
					else {
				*沪市B股指数
							if stockcode>899{
								cntrade 000003, index
								rename rmt retmkt_000003
								save index_000003.dta, replace
								use "index_000003.dta", clear
							}
				*沪市A股-上证综指
							else if stockcode>599{
								cntrade 000001, index
								rename rmt retmkt_000001
								save index_000001.dta, replace
								use "index_000001.dta", clear
							}
				*创业板指数			
							else if stockcode>299{
								cntrade 399006, index
								rename rmt retmkt_399006
								save index_399006.dta, replace
								use "index_399006.dta", clear
							}
				*深市B股指数			
							else if stockcode>199{
								cntrade 399108, index
								rename rmt retmkt_399108
								save index_399108.dta, replace
								use "index_399108.dta", clear
							}			
				*中小板指数			
							else if stockcode>1{
								cntrade 399005, index
								rename rmt retmkt_399005
								save index_399005.dta, replace
								use "index_399005.dta", clear
							}
				*深市A股-深成指			
							else {
								cntrade 399001, index
								rename rmt retmkt_399001
								save index_399001.dta, replace
								use "index_399001.dta", clear
							}
					}
				gen year = year(date)
				gen month = month(date)
				gen day = day(date)
				keep indexcd date indexnme clsprc retmkt year month day
				gen Order=_n
				tsset Order
				gen lagmonth = L.month
				gen indic=month-lagmonth
				drop if indic==0
				gen orDer=_n
				tsset orDer
				gen t=clsprc-F.clsprc
				gen mretmkt=t/F.clsprc
				keep indexcd date indexnme clsprc mretmkt year month
				global iname=indexnme[1]
				merge 1:1 date using "$id_dtom.dta", nogen force
				save "merge_$id_monthdta.dta", replace
				
				
				use "merge_$id_monthdta.dta", clear
				drop if mretmkt==.
				drop if mrit==.
				gen ORDEr=_n
				tsset ORDEr
				global smonth=date[1]
				
				
				capture gen year = year(date)
				capture gen month = month(date)
				capture gen day = day(date)
				local y_1=year[1]
				local m_1=month[1]
				local d_1=day[1]
				drop if year<`fy'
				drop if month<`fm' & year == `fy'
				drop if day<`fd' & month==`fm' & year == `fy'		
				drop if year>`ly'
				drop if month>`lm' & year == `fy'
				drop if day>`ld' & month==`fm' & year == `fy'
				
				rolling _b , window(`rwindow') saving(betadata,replace) : reg mrit mretmkt	
				qui use "betadata.dta",clear 
				gen syz=start-1
				gen css=syz*12
				gen lidayou=css+ $smonth 
				format lidayou %td
				rename _b_mretmkt b1
				drop if b1>10
				label var b1 "beta"
				label var lidayou "Date"
				qui tsset lidayou
				grss twoway tsline b1 ,yline(1) ///
				title("Beta Coefficient of $nn ($id), $starty - $lasty") subtitle(" Estimated by rolling with the window of `rwindow' month") 
			}
			else{
*选择数据类型为日数据
				if "`datatype'"=="d"{			
				use "merge_$id_daydta.dta", clear
				drop if retmkt==.
				drop if rit==.
				gen ORDEr=_n
				tsset ORDEr
				global sdate=date[1]
				rolling _b , window(`rwindow') saving(betadata,replace) : reg rit retmkt	
				qui use "betadata.dta",clear	
				rename _b_retmkt b1
				drop if b1>10
				gen dateday = start + $sdate -1
				label var b1 "beta"
				label var dateday "Day"
				qui tsset dateday , daily
				grss twoway tsline b1 ,yline(1) ///
				title("Beta Coefficient of $nn ($id), $starty - $lasty") subtitle("Estimated by rolling with the window of `rwindow' day") 
				}
*选择数据类型为年数据
				else if "`datatype'"=="y"{
				clear
				cntrade $id
				gen year = year(date)
				gen month = month(date)
				gen day = day(date)
				keep stkcd date stknme clsprc rit year month day
				gen Order=_n
				tsset Order
				gen lagyear = L.year
				gen indic=year-lagyear
				drop if indic==0
				gen orDer=_n
				tsset orDer
				gen t=clsprc-F.clsprc
				gen mrit=t/F.clsprc
				keep stkcd date stknme year month mrit 
				save $id_dtoy.dta , replace
				clear
				*指数选项处理
					if "`indexop'"!=""{
						cntrade `indexop', index
						rename rmt retmkt_`indexop'
						save index_`indexop'.dta, replace
						use "index_`indexop'.dta", clear
					}		
					else {
				*沪市B股指数
							if stockcode>899{
								cntrade 000003, index
								rename rmt retmkt_000003
								save index_000003.dta, replace
								use "index_000003.dta", clear
							}
				*沪市A股-上证综指
							else if stockcode>599{
								cntrade 000001, index
								rename rmt retmkt_000001
								save index_000001.dta, replace
								use "index_000001.dta", clear
							}
				*创业板指数			
							else if stockcode>299{
								cntrade 399006, index
								rename rmt retmkt_399006
								save index_399006.dta, replace
								use "index_399006.dta", clear
							}
				*深市B股指数			
							else if stockcode>199{
								cntrade 399108, index
								rename rmt retmkt_399108
								save index_399108.dta, replace
								use "index_399108.dta", clear
							}			
				*中小板指数			
							else if stockcode>1{
								cntrade 399005, index
								rename rmt retmkt_399005
								save index_399005.dta, replace
								use "index_399005.dta", clear
							}
				*深市A股-深成指			
							else {
								cntrade 399001, index
								rename rmt retmkt_399001
								save index_399001.dta, replace
								use "index_399001.dta", clear
							}
					}
				gen year = year(date)
				gen month = month(date)
				gen day = day(date)
				keep indexcd date indexnme clsprc retmkt year month day
				gen Order=_n
				tsset Order
				gen lagyear = L.year
				gen indic=year-lagyear
				drop if indic==0
				gen orDer=_n
				tsset orDer
				gen t=clsprc-F.clsprc
				gen mretmkt=t/F.clsprc
				keep indexcd date indexnme clsprc mretmkt year month
				global iname=indexnme[1]
				merge 1:1 date using "$id_dtoy.dta", nogen force
				save "merge_$id_yeardta.dta", replace
				
				
				use "merge_$id_yeardta.dta", clear
				drop if mretmkt==.
				drop if mrit==.
				gen ORDEr=_n
				tsset ORDEr
				global syear=date[1]
				
				capture gen year = year(date)
				capture gen month = month(date)
				capture gen day = day(date)
				local y_1=year[1]
				local m_1=month[1]
				local d_1=day[1]
				drop if year<`fy'
				drop if month<`fm' & year == `fy'
				drop if day<`fd' & month==`fm' & year == `fy'		
				drop if year>`ly'
				drop if month>`lm' & year == `fy'
				drop if day>`ld' & month==`fm' & year == `fy'	
				
				rolling _b , window(`rwindow') saving(betadata,replace) : reg mrit mretmkt	
				qui use "betadata.dta",clear	
				gen syz=start-1
				gen css=syz*250
				gen lidayou=css+ $syear
				format lidayou %td
				rename _b_mretmkt b1
				drop if b1>10
				label var b1 "beta"
				label var lidayou "Date"
				qui tsset lidayou
				grss twoway tsline b1 ,yline(1) ///
				title("Beta Coefficient of $nn ($id), $starty - $lasty") subtitle("Estimated by rolling with the window of `rwindow' year") 
				}

				else{

				disp as error "you must specify datatype as 'd', 'm', or 'y'"
				exit 198	
				}
			}
		}
	}
	restore
end
