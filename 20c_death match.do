** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          20c_death match.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      11-AUG-2022
    // 	date last modified      15-AUG-2022
    //  algorithm task          Matching cleaned, current and previous cancer datasets with cleaned death 2015-2021 dataset
    //  status                  Completed
    //  objective               To have a cleaned and matched dataset with updated vital status
    //  methods                 (1) Combine datasets of previous and current years (from dofiles 20a + 20b)
	//							(2) Create incidence matching ds by removing previously matched cases
	//							(3) Add 2008-2021 death matching dataset (from dofile 5d)
	//							(4) Perform duplicates checks using NRN, DOB and NAMES
	//							(5) Fill in pid and cr5id variables in matched death record 
	//							(6) Prep matched deaths for merge with ds in dofile 20e

    ** General algorithm set-up
    version 17.0
    clear all
    macro drop _all
    set more off

    ** Initialising the STATA log and allow automatic page scrolling
    capture {
            program drop _all
    	drop _all
    	log close
    	}

    ** Set working directories: this is for DATASET and LOGFILE import and export
    ** DATASETS to encrypted SharePoint folder
    local datapath "X:/The University of the West Indies/DataGroup - repo_data/data_p117"
    ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    local logpath X:/OneDrive - The University of the West Indies/repo_datagroup/repo_p117

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\20c_death match.smcl", replace
** HEADER -----------------------------------------------------

*********************
** PREP AND FORMAT **
*********************
** Combine previous cancer incidence ds (from dofile 20b_update previous years cancer.do) with current cancer incidence ds (from dofile 20a_clean current years cancer.do)
use "`datapath'\version09\3-output\2016-2018_cancer_nonreportable_identifiable", clear

drop flag*

count //3260

append using "`datapath'\version09\3-output\2008_2013_2014_2015_crosschecked_nonreportable"
drop flag*

count //7288

** Check for and remove cases that have been previously matched
count if deathid==. //4904
count if deathid!=. //2384 - cases that have previously matched with death data
count if deathid==. & slc==1 //3144 - alive cases
count if deathid==. & slc!=1 //1760 - deceased cases that have not been previously matched with death data
//count if dd_dod==. & slc!=1 //1729

** JC 11aug2022: with the old death matching method (merging based on name) some cases were incorrectly matched to the wrong person
** Identify and correct these previous incorrect matches
count if deathid!=. & slc==1 //7 - reviewed in multiyr REDCap deathdb: previously matched to different person with same name
list pid cr5id dxyr fname lname natregno slc dlc dod dd_dod dd_dodyear deathid if deathid!=. & slc==1
replace deathid=. if pid=="20081085"
replace deathid=. if pid=="20150033"
replace deathid=. if pid=="20150457"
replace deathid=. if pid=="20150514"
replace deathid=. if pid=="20151146"
replace deathid=. if pid=="20151206"
replace deathid=. if pid=="20151241"

count if deathid!=. & slc!=2 //0

count if deathid==. //4911
count if deathid!=. //2377 - cases that have previously matched with death data
count if deathid!=. & dd_coddeath=="" //41 - some cases seemed to have been matched but others have not although they have the correct deathid
replace dd_coddeath=dd_cod1a if deathid!=. & dd_coddeath=="" & dd_cod1a!="" //36 changes
list pid cr5id dxyr fname lname natregno slc dlc dod dd_dod dd_dodyear deathid if deathid!=. & dd_coddeath=="" //5 - 2 has incorrect deathid but all are correct but do not have death data merged so need to remove deathid so they can be matched
replace deathid=. if pid=="20080295"
replace deathid=. if pid=="20080885"
replace deathid=. if pid=="20081058"
replace deathid=. if pid=="20130331"
replace deathid=. if pid=="20140849"

count if deathid!=. & dd_cod1a=="" //1556
tab dxyr if deathid!=. & dd_cod1a=="" //2008, 2013-2015 (mainly 2008, 2013, 2014)
count if deathid==. & slc==1 //3151 - alive cases
count if deathid==. & slc!=1 //1761 - deceased cases that have not been previously matched with death data

** Save this ds for use in final clean dofile 20e
save "`datapath'\version09\3-output\2008_2013-2018_nonreportable_identifiable" ,replace

** Since a few have correct deathid but no merged death data, create a variable to identify cases that need to be matched
gen tomatch=1 if deathid==. //4919 changes
//replace tomatch=1 if deathid!=. & dd_coddeath=="" //4 changes

count if tomatch!=. //4919
count //7288
drop if tomatch==. //2369 deleted

count //4919

** Create cancer incidence ds for matching with 2015-2021 death ds
** Note only match with 2015-2021 deaths as the previous years were already matched to 2008-2014 deaths
save "`datapath'\version09\2-working\2008_2013-2018_cancer for death matching", replace


** Add death dataset created in dofile 5d_prep match mort.do
append using "`datapath'\version09\3-output\2015-2021_deaths_for_matching"

count //23,479

order pid deathid fname lname natregno dob age

********************************
** CHECK AND IDENTIFY MATCHES **
********************************
** Search for matches by NRN, DOB, NAMES

*********
** NRN **
********* 
** Check NRN is correctly formatted in prep for duplicate check
count if length(natregno)==9 //0
count if length(natregno)==8 //0
count if length(natregno)==7 //0

//count if natregno=="" & dd_natregno!="" //17,753
//replace natregno=dd_natregno if natregno=="" & dd_natregno!="" //17,753 changes

count if natregno==""|natregno=="999999-9999"|regexm(natregno,"9999") //1045 - a combo of missing NRNs from both cancer ds and death ds
count if natregno=="" & dd_nrn!=. //1 - checked in electoral list and this is the correct NRN for this person; I corrected in 5d_prep match mort.do instead of below so this now is 0
/*
list pid deathid fname lname if natregno=="" & dd_nrn!=.
gen nrn2=nrn if natregno=="" & dd_nrn!=.
tostring nrn2 ,replace
replace natregno=nrn2 if record_id==28513
drop nrn2
*/

** Identify possible matches using NRN
preserve
drop if natregno==""|natregno=="999999-9999"|regexm(natregno,"9999") //remove blank/missing NRNs as these will be flagged as duplicates of each other
//1045 deleted
sort natregno 
quietly by natregno : gen dup = cond(_N==1,0,_n)
sort natregno lname fname pid deathid 
count if dup>0 //3805 - review these in Stata's Browse/Edit window
order pid cr5id deathid dd_natregno natregno fname lname dd_age age dd_dodyear dxyr dd_coddeath morph
//check there are no duplicate NRNs in the death ds as then it won't merge in 20d_final clean.do
keep if deathds==1 & dup>0 //20,655 deleted
sort natregno
quietly by natregno : gen dupnrn = cond(_N==1,0,_n)
sort natregno lname fname pid deathid 
count if dupnrn>0 //0
save "`datapath'\version09\2-working\2015-2021_deaths_for_merging_NRN" ,replace
count //1779
restore


** Tag records already checked so review of possible matches is not repeated for DOB and NAMES checks
gen matched=1 if deathid==21416|deathid==22552|deathid==30043|deathid==26175|deathid==24678|deathid==21047|deathid==20629|deathid==22943 ///
				|deathid==20667|deathid==35859|deathid==34432|deathid==25129|deathid==25127|deathid==21409|deathid==19975|deathid==26155 ///
				|deathid==23387|deathid==22713|deathid==22623|deathid==25653|deathid==22148|deathid==26575|deathid==25590|deathid==25125 ///
				|deathid==24600|deathid==20323|deathid==24673|deathid==34878|deathid==23639|deathid==21297|deathid==19941|deathid==35771 ///
				|deathid==21166|deathid==24259|deathid==32399|deathid==21340|deathid==20763|deathid==21758|deathid==36390|deathid==22056 ///
				|deathid==19565|deathid==20154|deathid==21542|deathid==24568|deathid==22275|deathid==22731|deathid==20193|deathid==25338 ///
				|deathid==23903|deathid==23653|deathid==23249|deathid==23731|deathid==26258|deathid==26420|deathid==22737|deathid==25977 ///
				|deathid==20931|deathid==21975|deathid==20916|deathid==22230|deathid==23225|deathid==23537|deathid==22743|deathid==22346 ///
				|deathid==20666|deathid==19372|deathid==26864|deathid==20485|deathid==24057|deathid==19434|deathid==23896|deathid==26808 ///
				|deathid==19807|deathid==20838|deathid==24603|deathid==20191|deathid==23449|deathid==21371|deathid==24690|deathid==20378 ///
				|deathid==22305|deathid==26185|deathid==21439|deathid==23341|deathid==35496|deathid==19751|deathid==20641|deathid==26388 ///
				|deathid==20634|deathid==22145|deathid==19971|deathid==24707|deathid==24811|deathid==33726|deathid==25239|deathid==25000 ///
				|deathid==21616|deathid==22377|deathid==23725|deathid==25034|deathid==21954|deathid==23220|deathid==24161|deathid==22817 ///
				|deathid==23010|deathid==29496|deathid==20229|deathid==29771|deathid==20197|deathid==23629|deathid==22762|deathid==26789 ///
				|deathid==21635|deathid==20618|deathid==20661|deathid==21285|deathid==20925|deathid==22656|deathid==26071|deathid==22912 ///
				|deathid==19702|deathid==25676|deathid==21777|deathid==20480|deathid==24753|deathid==23483|deathid==24058|deathid==24530 ///
				|deathid==20980|deathid==19750|deathid==19792|deathid==26567|deathid==19347|deathid==24664|deathid==22073|deathid==21084 ///
				|deathid==22199|deathid==26498|deathid==17157|deathid==23085|deathid==26030|deathid==19952|deathid==26234|deathid==23791 ///
				|deathid==21747|deathid==21931|deathid==25709|deathid==23120|deathid==20185|deathid==22329|deathid==24191|deathid==25182 ///
				|deathid==25566|deathid==23517|deathid==33533|deathid==22380|deathid==22985|deathid==22020|deathid==19831|deathid==30008 ///
				|deathid==23991|deathid==32269|deathid==25980|deathid==21976|deathid==22721|deathid==22304|deathid==19446|deathid==20782 ///
				|deathid==24106|deathid==24506|deathid==20400|deathid==25830|deathid==24437|deathid==22128|deathid==20636|deathid==26334 ///
				|deathid==23262|deathid==25516|deathid==22674|deathid==23125|deathid==24483|deathid==21501|deathid==26356|deathid==22155
replace matched=1 if deathid==23979|deathid==25785|deathid==21842|deathid==22156|deathid==25598|deathid==37064|deathid==24228|deathid==18118 ///
				|deathid==25730|deathid==34684|deathid==20472|deathid==19114|deathid==27163|deathid==25393|deathid==23763|deathid==24165 ///
				|deathid==34157|deathid==26408|deathid==21848|deathid==20988|deathid==21941|deathid==26811|deathid==26747|deathid==21856 ///
				|deathid==22865|deathid==23722|deathid==19517|deathid==26096|deathid==26437|deathid==20139|deathid==33549|deathid==28977 ///
				|deathid==21619|deathid==25519|deathid==20534|deathid==24121|deathid==20675|deathid==21735|deathid==19915|deathid==26519 ///
				|deathid==20455|deathid==25918|deathid==23650|deathid==26883|deathid==17261|deathid==24940|deathid==23402|deathid==23389 ///
				|deathid==24430|deathid==25685|deathid==20200|deathid==26638|deathid==26102|deathid==22174|deathid==23696|deathid==19953 ///
				|deathid==25304|deathid==28328|deathid==34389|deathid==24481|deathid==24785|deathid==24556|deathid==21924|deathid==22146 ///
				|deathid==20573|deathid==22314|deathid==21968|deathid==22137|deathid==23456|deathid==26365|deathid==23390|deathid==32700 ///
				|deathid==22049|deathid==20040|deathid==23074|deathid==20232|deathid==25409|deathid==24173|deathid==28124|deathid==25434 ///
				|deathid==19826|deathid==25163|deathid==21216|deathid==19694|deathid==19962|deathid==33614|deathid==23092|deathid==25497 ///
				|deathid==22177|deathid==25821|deathid==25896|deathid==21154|deathid==20538|deathid==25327|deathid==24265|deathid==36728 ///
				|deathid==33988|deathid==34537|deathid==26832|deathid==22872|deathid==23832|deathid==22927|deathid==26123|deathid==23193 ///
				|deathid==24096|deathid==19646|deathid==26758|deathid==24659|deathid==22463|deathid==35622|deathid==24650|deathid==23813 ///
				|deathid==24823|deathid==22462|deathid==24542|deathid==19963|deathid==26294|deathid==23972|deathid==29315|deathid==34899 ///
				|deathid==22765|deathid==24164|deathid==35318|deathid==28926|deathid==23955|deathid==21429|deathid==20635|deathid==21074 ///
				|deathid==27720|deathid==21317|deathid==25264|deathid==22369|deathid==19679|deathid==19370|deathid==24115|deathid==20359 ///
				|deathid==24513|deathid==20419|deathid==21717|deathid==23937|deathid==21763|deathid==19684|deathid==21356|deathid==23058 ///
				|deathid==26394|deathid==19625|deathid==26188|deathid==23689|deathid==24479|deathid==21936|deathid==26520|deathid==19910 ///
				|deathid==25958|deathid==25816|deathid==27381|deathid==26285|deathid==19369|deathid==24576|deathid==36932|deathid==22190 ///
				|deathid==22198|deathid==27837|deathid==27006|deathid==36526|deathid==19346|deathid==31854|deathid==20118|deathid==21059 ///
				|deathid==25253|deathid==22937|deathid==23998|deathid==23081|deathid==22334|deathid==19619|deathid==25334|deathid==25061 ///
				|deathid==21674|deathid==24863|deathid==20543|deathid==22041|deathid==21286|deathid==21960|deathid==34778|deathid==20855 ///
				|deathid==31925|deathid==27349|deathid==22559|deathid==33675|deathid==34165|deathid==23599|deathid==28260|deathid==25782 ///
				|deathid==34804|deathid==35240|deathid==25514|deathid==25770|deathid==22086|deathid==22098|deathid==32653|deathid==24571
//200 changes
replace matched=1 if deathid==23749|deathid==26007|deathid==26529|deathid==32989|deathid==29066|deathid==22701|deathid==20722|deathid==24459 ///
				|deathid==22744|deathid==21235|deathid==20962|deathid==22618|deathid==22565|deathid==21121|deathid==33532|deathid==25400 ///
				|deathid==25403|deathid==18176|deathid==25209|deathid==22115|deathid==24581|deathid==21289|deathid==22572|deathid==23235 ///
				|deathid==20953|deathid==22364|deathid==23386|deathid==22203|deathid==25535|deathid==21196|deathid==25405|deathid==28437 ///
				|deathid==26265|deathid==24043|deathid==19764|deathid==21548|deathid==20570|deathid==25545|deathid==36240|deathid==21626 ///
				|deathid==24021|deathid==22171|deathid==25550|deathid==20689|deathid==20890|deathid==22909|deathid==23022|deathid==22458 ///
				|deathid==24101|deathid==24414|deathid==25596|deathid==19438|deathid==34670|deathid==24251|deathid==22740|deathid==33515 ///
				|deathid==26199|deathid==21921|deathid==22760|deathid==25026|deathid==19334|deathid==24564|deathid==23215|deathid==31719 ///
				|deathid==36958|deathid==23435|deathid==19914|deathid==21204|deathid==21633|deathid==26008|deathid==24237|deathid==33308 ///
				|deathid==26244|deathid==26446|deathid==20913|deathid==37278|deathid==19979|deathid==19505|deathid==26624|deathid==21137 ///
				|deathid==21412|deathid==22257|deathid==23506|deathid==26784|deathid==20938|deathid==23502|deathid==34343|deathid==23751 ///
				|deathid==23862|deathid==26302|deathid==27262|deathid==24489|deathid==23680|deathid==19463|deathid==27166|deathid==20744 ///
				|deathid==22269|deathid==27947|deathid==26414|deathid==21431|deathid==25779|deathid==32608|deathid==25726|deathid==22577 ///
				|deathid==21375|deathid==25189|deathid==25665|deathid==24114|deathid==19824|deathid==22050|deathid==26677|deathid==24405 ///
				|deathid==25401|deathid==17803|deathid==19767|deathid==23190|deathid==26068|deathid==27737|deathid==20274|deathid==21046 ///
				|deathid==20843|deathid==24476|deathid==21321|deathid==21485|deathid==24756|deathid==22599|deathid==24813|deathid==32026 ///
				|deathid==25603|deathid==25436|deathid==32467|deathid==25071|deathid==23444|deathid==23913|deathid==27503|deathid==24532 ///
				|deathid==20011|deathid==25502|deathid==22066|deathid==20309|deathid==20087|deathid==26195|deathid==21280|deathid==26076 ///
				|deathid==18231|deathid==24866|deathid==28645|deathid==29342|deathid==37056|deathid==23798|deathid==27500|deathid==26499 ///
				|deathid==21952|deathid==20797|deathid==34946|deathid==22292|deathid==31937|deathid==19825|deathid==26655|deathid==26812 ///
				|deathid==24975|deathid==19709|deathid==26311|deathid==19738|deathid==20830|deathid==22757|deathid==22243|deathid==24132 ///
				|deathid==22379|deathid==26724|deathid==26849|deathid==33013|deathid==26129|deathid==19731|deathid==19966|deathid==34751 ///
				|deathid==21143|deathid==19427|deathid==24128|deathid==34470|deathid==20373|deathid==36333|deathid==20498|deathid==20569 ///
				|deathid==20713|deathid==22008|deathid==24158|deathid==20749|deathid==23375|deathid==21234|deathid==23023|deathid==33771 ///
				|deathid==21266|deathid==23739|deathid==27914|deathid==20881|deathid==32999|deathid==25967|deathid==23917|deathid==27485 ///
				|deathid==22502|deathid==19847|deathid==22375|deathid==26103|deathid==23124|deathid==23784|deathid==28428|deathid==25736
//208 changes
replace matched=1 if deathid==20967|deathid==19846|deathid==28277|deathid==21538|deathid==25831|deathid==21691|deathid==21712|deathid==36357 ///
				|deathid==24155|deathid==23863|deathid==36208|deathid==23147|deathid==25970|deathid==20377|deathid==19585|deathid==21159 ///
				|deathid==24099|deathid==25548|deathid==36475|deathid==25753|deathid==27514|deathid==24981|deathid==19494|deathid==20845 ///
				|deathid==26097|deathid==21226|deathid==26306|deathid==24995|deathid==32957|deathid==35163|deathid==28203|deathid==23673 ///
				|deathid==26680|deathid==31984|deathid==22668|deathid==23676|deathid==32988|deathid==26457|deathid==23296|deathid==21041 ///
				|deathid==23321|deathid==36017|deathid==27356|deathid==25195|deathid==28338|deathid==22528|deathid==20708|deathid==25528 ///
				|deathid==36434|deathid==24865|deathid==24303|deathid==34748|deathid==33364|deathid==20290|deathid==22229|deathid==21454 ///
				|deathid==20753|deathid==28386|deathid==25402|deathid==27856|deathid==27696|deathid==19460|deathid==23384|deathid==20321 ///
				|deathid==23487|deathid==35930|deathid==26445|deathid==26061|deathid==22806|deathid==21519|deathid==25414|deathid==22933 ///
				|deathid==20568|deathid==27883|deathid==22391|deathid==32414|deathid==35587|deathid==26019|deathid==28401|deathid==24407 ///
				|deathid==22970|deathid==22494|deathid==20626|deathid==26489|deathid==26387|deathid==25553|deathid==33291|deathid==36345 ///
				|deathid==23992|deathid==19927|deathid==26433|deathid==25855|deathid==20755|deathid==25892|deathid==21457|deathid==24176 ///
				|deathid==28053|deathid==28147|deathid==27220|deathid==22772|deathid==27482|deathid==26148|deathid==26460|deathid==21899 ///
				|deathid==20272|deathid==21522|deathid==29826|deathid==33558|deathid==36242|deathid==20168|deathid==26566|deathid==29720 ///
				|deathid==23594|deathid==25697|deathid==23450|deathid==20319|deathid==21276|deathid==27922|deathid==21415|deathid==34257 ///
				|deathid==21584|deathid==31722|deathid==35634|deathid==20646|deathid==27128|deathid==25618|deathid==22478|deathid==23812 ///
				|deathid==22468|deathid==23431|deathid==24918|deathid==25829|deathid==36858|deathid==23471|deathid==27205|deathid==25889 ///
				|deathid==34648|deathid==23762|deathid==36384|deathid==19321|deathid==21253|deathid==25888|deathid==24088|deathid==21382 ///
				|deathid==20003|deathid==26392|deathid==35345|deathid==25992|deathid==23473|deathid==35554|deathid==28396|deathid==23087 ///
				|deathid==33571|deathid==29530|deathid==24434|deathid==23247|deathid==33602|deathid==20100|deathid==25417|deathid==21716 ///
				|deathid==34808|deathid==20244|deathid==25488|deathid==20437|deathid==25386|deathid==24710|deathid==21946|deathid==31935 ///
				|deathid==34351|deathid==25085|deathid==26947|deathid==26326|deathid==34336|deathid==24969|deathid==20673|deathid==23038 ///
				|deathid==19717|deathid==21918|deathid==26314|deathid==36417|deathid==25112|deathid==27476|deathid==24827|deathid==24127 ///
				|deathid==34380|deathid==29077|deathid==31947|deathid==26191|deathid==22290|deathid==32438|deathid==26320|deathid==31910
//192 changes
replace matched=1 if deathid==27357|deathid==25610|deathid==25307|deathid==21006|deathid==26539|deathid==23588|deathid==24888|deathid==22255 ///
				|deathid==25435|deathid==25330|deathid==23665|deathid==24410|deathid==20507|deathid==25936|deathid==24883|deathid==24998 ///
				|deathid==34938|deathid==25492|deathid==23186|deathid==23183|deathid==29642|deathid==25060|deathid==23767|deathid==23065 ///
				|deathid==24448|deathid==22914|deathid==22374|deathid==22658|deathid==20738|deathid==26400|deathid==23020|deathid==25727 ///
				|deathid==24050|deathid==21351|deathid==25695|deathid==29456|deathid==21282|deathid==36419|deathid==25806|deathid==34834 ///
				|deathid==23371|deathid==22376|deathid==27150|deathid==29722|deathid==23540|deathid==27678|deathid==25474|deathid==26859 ///
				|deathid==23854|deathid==19493|deathid==21129|deathid==25389|deathid==36564|deathid==25925|deathid==22017|deathid==21173 ///
				|deathid==23566|deathid==24624|deathid==26695|deathid==19472|deathid==24309|deathid==29095|deathid==25226|deathid==21063 ///
				|deathid==33889|deathid==23641|deathid==26722|deathid==35847|deathid==26267|deathid==21989|deathid==25629|deathid==26968 ///
				|deathid==35595|deathid==21707|deathid==24703|deathid==20326|deathid==36472|deathid==23789|deathid==21102|deathid==34075 ///
				|deathid==28609|deathid==20486|deathid==23846|deathid==27227|deathid==26117|deathid==18280|deathid==25662|deathid==29937 ///
				|deathid==23941|deathid==25717|deathid==22862|deathid==26752|deathid==22321|deathid==21115|deathid==29596|deathid==24487 ///
				|deathid==33001|deathid==20478|deathid==22481|deathid==24563|deathid==32271|deathid==24009|deathid==33448|deathid==25057 ///
				|deathid==20816|deathid==33683|deathid==31490|deathid==25635|deathid==35247|deathid==25142|deathid==26033|deathid==25104 ///
				|deathid==22033|deathid==22166|deathid==25066|deathid==23227|deathid==29293|deathid==32418|deathid==32549|deathid==25895 ///
				|deathid==24961|deathid==26432|deathid==36061|deathid==25769|deathid==31736|deathid==27770|deathid==20305|deathid==20207 ///
				|deathid==21818|deathid==26422|deathid==22811|deathid==28653|deathid==27164|deathid==24014|deathid==23700|deathid==37280 ///
				|deathid==22487|deathid==21664|deathid==26059|deathid==21343|deathid==22904|deathid==21456|deathid==20924|deathid==20278 ///
				|deathid==31565|deathid==32272|deathid==29449|deathid==37313|deathid==26346|deathid==34533|deathid==17665|deathid==36539 ///
				|deathid==22154|deathid==26701|deathid==33426|deathid==24611|deathid==33332|deathid==24098|deathid==22407|deathid==25615 ///
				|deathid==22451|deathid==27923|deathid==25322|deathid==23901|deathid==20251|deathid==21427|deathid==23974|deathid==22025
//168 changes
replace matched=1 if deathid==33025|deathid==22089|deathid==21813|deathid==26470|deathid==23778|deathid==32596|deathid==21637|deathid==33365 ///
				|deathid==20051|deathid==36438|deathid==23826|deathid==21650|deathid==21991|deathid==25251|deathid==32963|deathid==22893 ///
				|deathid==19672|deathid==34113|deathid==27955|deathid==21647|deathid==33406|deathid==29754|deathid==23152|deathid==24003 ///
				|deathid==33167|deathid==23334|deathid==25688|deathid==28954|deathid==27951|deathid==24300|deathid==21988|deathid==23652 ///
				|deathid==32008|deathid==24201|deathid==20341|deathid==26997|deathid==21662|deathid==22988|deathid==26597|deathid==24540 ///
				|deathid==24420|deathid==24475|deathid==25438|deathid==31971|deathid==26154|deathid==35151|deathid==22931|deathid==24809 ///
				|deathid==22358|deathid==36985|deathid==22916|deathid==21440|deathid==26534|deathid==35285|deathid==21018|deathid==22576 ///
				|deathid==34869|deathid==32243|deathid==28897|deathid==22273|deathid==28148|deathid==35058|deathid==24223|deathid==26126 ///
				|deathid==34453|deathid==29533|deathid==22315|deathid==24830|deathid==26466|deathid==25017|deathid==35790|deathid==20671 ///
				|deathid==25965|deathid==25131|deathid==25667|deathid==22361|deathid==21909|deathid==32953|deathid==21552|deathid==36159 ///
				|deathid==25058|deathid==20252|deathid==26318|deathid==26718|deathid==24991|deathid==20999|deathid==24126|deathid==32711 ///
				|deathid==25915|deathid==26866|deathid==19947|deathid==27746|deathid==20457|deathid==25927|deathid==26525|deathid==25728 ///
				|deathid==26060|deathid==19852|deathid==27020|deathid==27003|deathid==36317|deathid==19581|deathid==25199|deathid==21800 ///
				|deathid==23867|deathid==36442|deathid==36794|deathid==23060|deathid==21182|deathid==20806|deathid==23678|deathid==35238 ///
				|deathid==20383|deathid==23103|deathid==24172|deathid==26691|deathid==19897|deathid==24371|deathid==17773|deathid==22326 ///
				|deathid==20729|deathid==21374|deathid==24216|deathid==23768|deathid==23986|deathid==20720|deathid==22045|deathid==29783 ///
				|deathid==23354|deathid==23865|deathid==28758|deathid==20285|deathid==24906|deathid==24697|deathid==28291|deathid==26249 ///
				|deathid==24854|deathid==20211|deathid==27488|deathid==20727|deathid==23368|deathid==23457|deathid==23574|deathid==19596 ///
				|deathid==20531|deathid==22836|deathid==20448|deathid==26561|deathid==24142|deathid==22523|deathid==20482|deathid==32523 ///
				|deathid==23699|deathid==34733|deathid==28010|deathid==35087|deathid==34757|deathid==19598|deathid==23690|deathid==26082 ///
				|deathid==21436|deathid==28283|deathid==17342|deathid==25914|deathid==22825|deathid==25871|deathid==22019|deathid==36768 ///
				|deathid==20096|deathid==35135|deathid==34557|deathid==20104|deathid==34584|deathid==20638|deathid==36960|deathid==26742 ///
				|deathid==24467|deathid==22785|deathid==26693|deathid==28589|deathid==24310|deathid==23921|deathid==28506|deathid==24030
//184 changes
replace matched=1 if deathid==24119|deathid==25787|deathid==33404|deathid==24110|deathid==19416|deathid==27698|deathid==22488|deathid==28712 ///
				|deathid==25202|deathid==26451|deathid==24269|deathid==32569|deathid==25849|deathid==21359|deathid==22535|deathid==34570 ///
				|deathid==34773|deathid==27280|deathid==29803|deathid==29321|deathid==32474|deathid==36014|deathid==26348|deathid==27402 ///
				|deathid==28178|deathid==26390|deathid==20456|deathid==34385|deathid==37273|deathid==36207|deathid==25242|deathid==17628 ///
				|deathid==23746|deathid==27716|deathid==23561|deathid==26192|deathid==23742|deathid==23075|deathid==27217|deathid==27337 ///
				|deathid==24601|deathid==27794|deathid==21762|deathid==17810|deathid==21133|deathid==26156|deathid==26776|deathid==33264 ///
				|deathid==21387|deathid==26176|deathid==34538|deathid==24833|deathid==24290|deathid==23445|deathid==26456|deathid==26391 ///
				|deathid==31584|deathid==24902|deathid==22531|deathid==36752|deathid==26328|deathid==25032|deathid==31485|deathid==36603 ///
				|deathid==31527|deathid==28907|deathid==21971|deathid==24702|deathid==19775|deathid==25245|deathid==25445|deathid==21500 ///
				|deathid==21792|deathid==27279|deathid==22132|deathid==35101|deathid==25152|deathid==37005|deathid==36703|deathid==22496 ///
				|deathid==20071|deathid==23721|deathid==25073|deathid==22465|deathid==27116|deathid==20575|deathid==23964|deathid==37210 ///
				|deathid==35099|deathid==34676|deathid==22632|deathid==29295|deathid==23304|deathid==25569|deathid==21480|deathid==22745 ///
				|deathid==23886|deathid==21801|deathid==20414|deathid==25410|deathid==20086|deathid==24596|deathid==20090|deathid==19989 ///
				|deathid==17429|deathid==22540|deathid==22899|deathid==19866|deathid==24045|deathid==21937|deathid==23887|deathid==32893 ///
				|deathid==26144|deathid==26613|deathid==25677|deathid==26645|deathid==32080|deathid==25344|deathid==22076|deathid==29179 ///
				|deathid==21620|deathid==21631|deathid==27556|deathid==22794|deathid==22027|deathid==24593|deathid==22546|deathid==23326 ///
				|deathid==28392|deathid==29467|deathid==22392|deathid==35655|deathid==25546|deathid==36171|deathid==22005|deathid==22022 ///
				|deathid==21104|deathid==27683|deathid==20691|deathid==27574|deathid==22316|deathid==23944|deathid==36972|deathid==28044 ///
				|deathid==23466|deathid==21293|deathid==25453|deathid==21860|deathid==27494|deathid==36282|deathid==21368|deathid==23928 ///
				|deathid==22457|deathid==34256|deathid==25150|deathid==22088|deathid==29148|deathid==22929|deathid==35484|deathid==26991 ///
				|deathid==34548|deathid==31563|deathid==24351|deathid==24551|deathid==24771|deathid==27595|deathid==32166|deathid==25637 ///
				|deathid==34543|deathid==26875|deathid==25935|deathid==33333|deathid==26189|deathid==27358|deathid==22218|deathid==21210 ///
				|deathid==21330|deathid==26780|deathid==19000|deathid==28141|deathid==25413|deathid==21029|deathid==35493|deathid==20294 ///
				|deathid==22333|deathid==35112|deathid==24671|deathid==32293|deathid==31752|deathid==26778|deathid==24561|deathid==26491 ///
				|deathid==24803|deathid==36496|deathid==20773|deathid==29679|deathid==20880|deathid==33842|deathid==19419|deathid==22448 ///
				|deathid==35320|deathid==20512|deathid==20549|deathid==21560|deathid==29645|deathid==22529|deathid==35382|deathid==22278 ///
				|deathid==22610|deathid==20230|deathid==22611|deathid==28921|deathid==34116|deathid==36052|deathid==33288|deathid==33230 ///
				|deathid==22911|deathid==20718|deathid==20833|deathid==25491|deathid==29584|deathid==33265|deathid==27209|deathid==35300 ///
				|deathid==36490|deathid==24220|deathid==21014|deathid==22415|deathid==29602|deathid==37041|deathid==23251|deathid==26477 ///
				|deathid==26708|deathid==35478|deathid==34916|deathid==21764|deathid==20391|deathid==22249|deathid==24877|deathid==27104
//240 changes
replace matched=1 if deathid==22913|deathid==25040|deathid==27743|deathid==19333|deathid==22276|deathid==20796|deathid==33036|deathid==24018 ///
				|deathid==22719|deathid==22335|deathid==22853|deathid==32589|deathid==27866|deathid==32600|deathid==26621|deathid==27842 ///
				|deathid==33524|deathid==24585|deathid==21072|deathid==21238|deathid==31867|deathid==27385|deathid==21463|deathid==26423 ///
				|deathid==34130|deathid==34431|deathid==33434|deathid==20107|deathid==25171|deathid==24676|deathid==23668|deathid==20374 ///
				|deathid==33715|deathid==28240|deathid==32856|deathid==24869|deathid==32424|deathid==34169|deathid==24890|deathid==24748 ///
				|deathid==21852|deathid==28451|deathid==26978|deathid==29517|deathid==36275|deathid==25567|deathid==36430|deathid==22459 ///
				|deathid==29819|deathid==26942|deathid==23726|deathid==28481|deathid==27519|deathid==20474|deathid==22144|deathid==19907 ///
				|deathid==25325|deathid==23486|deathid==24625|deathid==23633|deathid==32891|deathid==26620|deathid==25819|deathid==31904 ///
				|deathid==19480|deathid==26364|deathid==23410|deathid==21277|deathid==32750|deathid==20993|deathid==25828|deathid==26135 ///
				|deathid==23902|deathid==23550|deathid==23277|deathid==23920|deathid==20203|deathid==25360|deathid==32145|deathid==21360 ///
				|deathid==21871|deathid==25657|deathid==22728|deathid==22666|deathid==26386|deathid==28508|deathid==32384|deathid==27265 ///
				|deathid==26603|deathid==27057|deathid==26626|deathid==27830|deathid==27115|deathid==26826|deathid==25132|deathid==25644 ///
				|deathid==24494|deathid==25500|deathid==27539|deathid==34653|deathid==24824|deathid==24064|deathid==24769|deathid==28845 ///
				|deathid==27211|deathid==22830|deathid==28303|deathid==24922|deathid==24554|deathid==21599|deathid==20884|deathid==27778 ///
				|deathid==29165|deathid==22469|deathid==21806|deathid==33213|deathid==23279|deathid==26819|deathid==35948|deathid==27864 ///
				|deathid==22510|deathid==25319|deathid==26186|deathid==27988|deathid==23981|deathid==24684|deathid==28978|deathid==22709 ///
				|deathid==22591|deathid==23035|deathid==34920|deathid==25826|deathid==33278|deathid==27339|deathid==27136|deathid==34208 ///
				|deathid==27809|deathid==25532|deathid==23970|deathid==28351|deathid==24565|deathid==26004|deathid==27624|deathid==21004 ///
				|deathid==25696|deathid==21866|deathid==26573|deathid==36142|deathid==23056|deathid==20678|deathid==24718|deathid==22422 ///
				|deathid==25801|deathid==22665|deathid==33138|deathid==24677|deathid==36683|deathid==32368|deathid==27748|deathid==24598 ///
				|deathid==33066|deathid==22039|deathid==32039|deathid==22840|deathid==28865|deathid==21358|deathid==24177|deathid==33047 ///
				|deathid==24202|deathid==36648|deathid==26100|deathid==36458|deathid==26739|deathid==26441|deathid==28637|deathid==21299 ///
				|deathid==22638|deathid==26690|deathid==26919|deathid==25721|deathid==24613|deathid==22613|deathid==22267|deathid==32239 ///
				|deathid==20780|deathid==37325|deathid==23711|deathid==23348|deathid==27484|deathid==19739|deathid==36667|deathid==24654 ///
				|deathid==31512|deathid==27854|deathid==33956|deathid==20645|deathid==27322|deathid==21786|deathid==32226|deathid==26608 ///
				|deathid==23640|deathid==24536|deathid==27764|deathid==19571|deathid==25111|deathid==25185|deathid==26447|deathid==36063 ///
				|deathid==22640|deathid==28200|deathid==26397|deathid==34354|deathid==24755|deathid==25281|deathid==27641|deathid==34954 ///
				|deathid==25933|deathid==29166|deathid==22327|deathid==24873|deathid==20330|deathid==35431|deathid==25875|deathid==25558 ///
				|deathid==19642|deathid==27804|deathid==27341|deathid==23960|deathid==27474|deathid==26673|deathid==25258|deathid==25423 ///
				|deathid==20760|deathid==24387|deathid==22841|deathid==24720|deathid==26816|deathid==19729|deathid==24579|deathid==24245
//240 changes
replace matched=1 if deathid==22856|deathid==20271|deathid==20014|deathid==22945|deathid==37110|deathid==25760|deathid==35176|deathid==21723 ///
				|deathid==23123|deathid==20518|deathid==20915|deathid==20777|deathid==22520|deathid==25176|deathid==27952|deathid==24964 ///
				|deathid==25068|deathid==33183|deathid==24602|deathid==22605|deathid==22729|deathid==25053|deathid==24816|deathid==35737 ///
				|deathid==25506|deathid==26842|deathid==27646|deathid==24256|deathid==21338|deathid==23808|deathid==23736|deathid==35553 ///
				|deathid==22992|deathid==26869|deathid==34445|deathid==32667|deathid==27882|deathid==34328|deathid==35192|deathid==25825 ///
				|deathid==22241|deathid==25906|deathid==21995|deathid==27554|deathid==23683|deathid==24450|deathid==24594|deathid==24901 ///
				|deathid==24270|deathid==25827|deathid==25352|deathid==29765|deathid==26674|deathid==20758|deathid==24917|deathid==22201 ///
				|deathid==27352|deathid==23131|deathid==24967|deathid==18226|deathid==22196|deathid==34419|deathid==32170|deathid==20565 ///
				|deathid==26229|deathid==19983|deathid==31687|deathid==33967|deathid==21951|deathid==24399|deathid==23291|deathid==32605 ///
				|deathid==36140|deathid==27986|deathid==25169|deathid==27703|deathid==25455|deathid==34322|deathid==26032|deathid==32833 ///
				|deathid==24716|deathid==23497|deathid==25396|deathid==25448|deathid==26712|deathid==23849|deathid==32372|deathid==32346 ///
				|deathid==26687|deathid==25956|deathid==21189|deathid==27173|deathid==28651|deathid==34768|deathid==27873|deathid==25501 ///
				|deathid==26020|deathid==25246|deathid==25181|deathid==25638|deathid==20687|deathid==27127|deathid==32065|deathid==23062 ///
				|deathid==25820|deathid==21653|deathid==31787|deathid==31739|deathid==27405|deathid==23099|deathid==24470|deathid==25939 ///
				|deathid==25025|deathid==21602|deathid==25692|deathid==22272|deathid==33421|deathid==21947|deathid==21497|deathid==34216 ///
				|deathid==27099|deathid==35265|deathid==28983|deathid==28158|deathid==32419|deathid==36305|deathid==26211|deathid==33576 ///
				|deathid==34153|deathid==27507|deathid==26941|deathid==36169|deathid==28880|deathid==24059|deathid==29971|deathid==22480 ///
				|deathid==25210|deathid==25374|deathid==34567|deathid==26317|deathid==22901|deathid==25311|deathid==26848|deathid==21938 ///
				|deathid==28118|deathid==27247|deathid==33736|deathid==34125|deathid==35113|deathid==33378|deathid==23976|deathid==35535 ///
				|deathid==29108|deathid==24680|deathid==24331|deathid==34430|deathid==33125|deathid==25964|deathid==34914|deathid==32727 ///
				|deathid==36452|deathid==19933|deathid==24293
//163 changes

count if matched==1 //1799


*********
** DOB **
*********
** Create DOB as not in death dataset (DOB was created in 5d_prep match mort.do)
preserve
drop if matched==1 //1779 deleted
//remove death records that have already been matched to avoid repetition of work
count if dob!=. & birthdate=="" //0 - these are the numeric and string DOBs in the incidence ds
** Create the string DOB in the death ds (there's already the numeric DOB)
gen dd_dobyear=year(dd_dob) if dd_dob!=.
tostring dd_dobyear ,replace
gen dd_dobmonth=month(dd_dob) if dd_dob!=.
tostring dd_dobmonth ,replace
replace dd_dobmonth="0"+dd_dobmonth if length(dd_dobmonth)<2 & dd_dobmonth!="."
gen dd_dobday=day(dd_dob) if dd_dob!=.
tostring dd_dobday ,replace
replace dd_dobday="0"+dd_dobday if length(dd_dobday)<2 & dd_dobday!="."
gen dd_birthdate=dd_dobyear+dd_dobmonth+dd_dobday if dd_dobyear!="" & dd_dobyear!="."

gen dd_dobyr=substr(natregno, 1, 2) if natregno!="" & deathds==1
gen dd_dobmon=substr(natregno, 3, 2) if natregno!="" & deathds==1
gen dd_dobdy=substr(natregno, 5, 2) if natregno!="" & deathds==1
replace dd_birthdate=dd_dobyr+dd_dobmon+dd_dobdy if dd_birthdate=="" //10,726 changes

drop if dd_dobmon=="99" | dd_dobday=="99" //0 deleted
count if length(dd_birthdate)<8 //16,454

replace dd_dobyr="19"+dd_dobyr if regex(substr(dd_dobyr,1,1),"[0]") & dd_age>90 & length(dd_birthdate)<8 & dd_birthdate!="" //4 changes
replace dd_dobyr="19"+dd_dobyr if dd_age>90 & length(dd_birthdate)<8 & dd_birthdate!="" & length(dd_dobyr)<4 //1,559 changes
replace dd_dobyr="19"+dd_dobyr if dd_age>20 & length(dd_birthdate)<8 & dd_birthdate!="" & length(dd_dobyr)<4 //9,013 changes
count if length(dd_birthdate)<8 & length(dd_dobyr)<4 & dd_birthdate!="" //110
replace dd_dobyr="20"+dd_dobyr if length(dd_birthdate)<8 & length(dd_dobyr)<4 & dd_birthdate!="" //110 changes

replace dd_birthdate=dd_dobyr+dd_dobmon+dd_dobdy if length(dd_birthdate)<8 & dd_birthdate!="" //10,726 changes
count if length(dd_birthdate)<8 & dd_birthdate!="" //0


count if dd_birthdate=="99999999" //0
replace dd_birthdate="" if dd_birthdate=="99999999" //0 changes
replace dd_birthdate = lower(rtrim(ltrim(itrim(dd_birthdate)))) //0 changes
drop dd_dobdy dd_dobmon dd_dobyr dd_dobday dd_dobmonth dd_dobyear
drop if dd_birthdate=="" & deathds==1 | dd_birthdate=="99999999" & deathds==1 //809 deleted

replace birthdate=dd_birthdate if birthdate=="" & dd_birthdate!="" //15,972

** Look for matches using DOB
sort lname fname birthdate
quietly by lname fname birthdate : gen dup = cond(_N==1,0,_n)
sort lname fname birthdate pid
count if dup>0 //339 - review these in Stata's Browse/Edit window
order pid deathid fname lname primarysite dd_coddeath birthdate dob dd_dob natregno dot dod
//check there are no duplicate DOBs in the death ds as then it won't merge in 20d_final clean.do
** Review possible matches by DOB then if any are not "true" matches, tag these so that these can be dropped from the death ds for merging with the incidence ds in 20d_final clean.do
gen nomatch=1 if deathid==23918|deathid==24041

save "`datapath'\version09\2-working\possibledups_DOB" ,replace

keep if deathds==1 & dup>0 & nomatch==. //20,877 deleted
count //14
save "`datapath'\version09\2-working\2015-2021_deaths_for_merging_DOB" ,replace

//check for possible matches where DOB match but name doesn't match
use "`datapath'\version09\2-working\possibledups_DOB" ,clear
drop if deathds==1 & dup>0 & nomatch==. //14 deleted
sort birthdate
quietly by birthdate : gen dupdob = cond(_N==1,0,_n)
sort birthdate lname fname pid
count if dupdob>0 //12,924
count if dupdob>0 & birthdate!="" //12,857 - review these in Stata's Browse/Edit window
order pid deathid fname lname birthdate natregno dd_dod dod dlc primarysite dd_coddeath dob dd_dob dot

//above list is too long for the current time constraints so use below list instead
sort lname birthdate
quietly by lname birthdate : gen duplndob = cond(_N==1,0,_n)
sort birthdate lname fname pid
count if duplndob>0 //427
count if duplndob>0 & birthdate!="" //423
order pid deathid fname lname birthdate natregno dd_dod dod dlc primarysite dd_coddeath dob dd_dob dot

replace nomatch=1 if deathds==1 & deathid!=22396 & deathid!=26352 & deathid!=19938 & deathid!=19510 ///
					& deathid!=33989 & deathid!=31532 & deathid!=20717 & deathid!=30077

count if deathds==1 & duplndob>0 & nomatch==. //8
	
** To ensure the death record correctly merges with its corresponding PID, use pid and cr5id as the variables in the mrege
gen matchpid=pid if pid=="20080653"
fillmissing matchpid
replace pid=matchpid if deathid==22396
gen matchcr5id=cr5id if pid=="20080653"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==22396
drop matchpid matchcr5id

gen matchpid=pid if pid=="20080734"
fillmissing matchpid
replace pid=matchpid if deathid==26352
gen matchcr5id=cr5id if pid=="20080734"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==26352
drop matchpid matchcr5id

gen matchpid=pid if pid=="20140830"
fillmissing matchpid
replace pid=matchpid if deathid==19938
gen matchcr5id=cr5id if pid=="20140830"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==19938
drop matchpid matchcr5id

gen matchpid=pid if pid=="20080745"
fillmissing matchpid
replace pid=matchpid if deathid==19510
gen matchcr5id=cr5id if pid=="20080745"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==19510
drop matchpid matchcr5id

gen matchpid=pid if pid=="20080722"
fillmissing matchpid
replace pid=matchpid if deathid==33989
gen matchcr5id=cr5id if pid=="20080722"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==33989
drop matchpid matchcr5id

gen matchpid=pid if pid=="20090060"
fillmissing matchpid
replace pid=matchpid if deathid==31532
gen matchcr5id=cr5id if pid=="20090060"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==31532
drop matchpid matchcr5id

gen matchpid=pid if pid=="20150072"
fillmissing matchpid
replace pid=matchpid if deathid==20717
gen matchcr5id=cr5id if pid=="20150072"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==20717
drop matchpid matchcr5id

gen matchpid=pid if pid=="20160551"
fillmissing matchpid
replace pid=matchpid if deathid==30077
gen matchcr5id=cr5id if pid=="20160551"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==30077
drop matchpid matchcr5id

keep if deathds==1 & dupdob>0 & nomatch==. //20,869 deleted
count //8
save "`datapath'\version09\2-working\2015-2021_deaths_for_merging_DOBLNAME" ,replace
restore


** Tag records already checked so a review of possible matches is not repeated for NAMES check
replace matched=1 if deathid==19663|deathid==21407|deathid==22753|deathid==21969|deathid==27787|deathid==25481|deathid==30019|deathid==24170 ///
				|deathid==24587|deathid==26948|deathid==24025|deathid==20649|deathid==27723|deathid==25813|deathid==22396|deathid==26352 ///
				|deathid==19938|deathid==19510|deathid==33989|deathid==31532|deathid==20717|deathid==30077
//22 changes

count if matched==1 //1801

***********
** NAMES **
***********
drop if matched==1 //1801 deleted
sort lname fname
quietly by lname fname:  gen dup = cond(_N==1,0,_n)
count if dup>0 //2756 - review these in Stata's Browse/Edit window
//check these against MedData + electoral list as NRNs in death data often incorrect
order pid cr5id deathid fname lname birthdate natregno dd_dod dod dlc primarysite dd_coddeath init dd_mname dob dd_dob dot


gen matchpid=pid if pid=="20161116"
fillmissing matchpid
replace pid=matchpid if deathid==20840
gen matchcr5id=cr5id if pid=="20161116"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==20840
drop matchpid matchcr5id
replace matched=1 if deathid==20840

gen matchpid=pid if pid=="20182010"
fillmissing matchpid
replace pid=matchpid if deathid==34035
gen matchcr5id=cr5id if pid=="20182010"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==34035
drop matchpid matchcr5id
replace matched=1 if deathid==34035

gen matchpid=pid if pid=="20170871"
fillmissing matchpid
replace pid=matchpid if deathid==23872
gen matchcr5id=cr5id if pid=="20170871"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==23872
drop matchpid matchcr5id
replace matched=1 if deathid==23872

gen matchpid=pid if pid=="20180391"
fillmissing matchpid
replace pid=matchpid if deathid==26147
gen matchcr5id=cr5id if pid=="20180391"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==26147
drop matchpid matchcr5id
replace matched=1 if deathid==26147

gen matchpid=pid if pid=="20180697"
fillmissing matchpid
replace pid=matchpid if deathid==25207
gen matchcr5id=cr5id if pid=="20180697"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==25207
drop matchpid matchcr5id
replace matched=1 if deathid==25207

gen matchpid=pid if pid=="20170517"
fillmissing matchpid
replace pid=matchpid if deathid==35512
gen matchcr5id=cr5id if pid=="20170517"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==35512
drop matchpid matchcr5id
replace matched=1 if deathid==35512
replace natregno=subinstr(natregno,"41","47",.) if deathid==35512
replace dd_age=73 if deathid==35512

gen matchpid=pid if pid=="20170397"
fillmissing matchpid
replace pid=matchpid if deathid==32611
gen matchcr5id=cr5id if pid=="20170397"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==32611
drop matchpid matchcr5id
replace matched=1 if deathid==32611
replace natregno=subinstr(natregno,"34","64",.) if deathid==32611
replace dd_age=56 if deathid==32611

gen matchpid=pid if pid=="20161130"
fillmissing matchpid
replace pid=matchpid if deathid==19812
gen matchcr5id=cr5id if pid=="20161130"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==19812
drop matchpid matchcr5id
replace matched=1 if deathid==19812

gen matchpid=pid if pid=="20160229"
fillmissing matchpid
replace pid=matchpid if deathid==20647
gen matchcr5id=cr5id if pid=="20160229"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==20647
drop matchpid matchcr5id
replace matched=1 if deathid==20647
replace natregno=subinstr(natregno,"33","35",.) if deathid==20647
replace dd_age=80 if deathid==20647

gen matchpid=pid if pid=="20180039"
fillmissing matchpid
replace pid=matchpid if deathid==24781
gen matchcr5id=cr5id if pid=="20180039"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==24781
drop matchpid matchcr5id
replace matched=1 if deathid==24781
replace natregno=subinstr(natregno,"44","40",.) if deathid==24781
replace dd_age=78 if deathid==24781

gen matchpid=pid if pid=="20130432"
fillmissing matchpid
replace pid=matchpid if deathid==36093
gen matchcr5id=cr5id if pid=="20130432"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==36093
drop matchpid matchcr5id
replace matched=1 if deathid==36093

gen matchpid=pid if pid=="20180920"
fillmissing matchpid
replace pid=matchpid if deathid==26845
gen matchcr5id=cr5id if pid=="20180920"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==26845
drop matchpid matchcr5id
replace matched=1 if deathid==26845

gen matchpid=pid if pid=="20160881"
fillmissing matchpid
replace pid=matchpid if deathid==20030
gen matchcr5id=cr5id if pid=="20160881"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==20030
drop matchpid matchcr5id
replace matched=1 if deathid==20030
replace natregno=subinstr(natregno,"7","8",.) if deathid==20030
replace natregno=subinstr(natregno,"808","807",.) if deathid==20030
replace dd_age=87 if deathid==20030

gen matchpid=pid if pid=="20160979"
fillmissing matchpid
replace pid=matchpid if deathid==21013
gen matchcr5id=cr5id if pid=="20160979"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==21013
drop matchpid matchcr5id
replace matched=1 if deathid==21013
replace natregno=subinstr(natregno,"08","68",.) if deathid==21013

gen matchpid=pid if pid=="20180556"
fillmissing matchpid
replace pid=matchpid if deathid==29324
gen matchcr5id=cr5id if pid=="20180556"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==29324
drop matchpid matchcr5id
replace matched=1 if deathid==29324
replace natregno=subinstr(natregno,"56","50",.) if deathid==29324
replace dd_age=69 if deathid==29324

gen matchpid=pid if pid=="20182135"
fillmissing matchpid
replace pid=matchpid if deathid==26013
gen matchcr5id=cr5id if pid=="20182135"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==26013
drop matchpid matchcr5id
replace matched=1 if deathid==26013
replace natregno=subinstr(natregno,"50","20",.) if deathid==26013
replace dd_age=56 if deathid==26013

gen matchpid=pid if pid=="20181096"
fillmissing matchpid
replace pid=matchpid if deathid==24820
gen matchcr5id=cr5id if pid=="20181096"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==24820
drop matchpid matchcr5id
replace matched=1 if deathid==24820

gen matchpid=pid if pid=="20172011"
fillmissing matchpid
replace pid=matchpid if deathid==34335
gen matchcr5id=cr5id if pid=="20172011"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==34335
drop matchpid matchcr5id
replace matched=1 if deathid==34335
replace natregno=subinstr(natregno,"90","70",.) if deathid==34335

gen matchpid=pid if pid=="20161106"
fillmissing matchpid
replace pid=matchpid if deathid==19512
gen matchcr5id=cr5id if pid=="20161106"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==19512
drop matchpid matchcr5id
replace matched=1 if deathid==19512

gen matchpid=pid if pid=="20170731"
fillmissing matchpid
replace pid=matchpid if deathid==24335
gen matchcr5id=cr5id if pid=="20170731"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==24335
drop matchpid matchcr5id
replace matched=1 if deathid==24335

gen matchpid=pid if pid=="20182158"
fillmissing matchpid
replace pid=matchpid if deathid==36194
gen matchcr5id=cr5id if pid=="20182158"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==36194
drop matchpid matchcr5id
replace matched=1 if deathid==36194

gen matchpid=pid if pid=="20170975"
fillmissing matchpid
replace pid=matchpid if deathid==22831
gen matchcr5id=cr5id if pid=="20170975"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==22831
drop matchpid matchcr5id
replace matched=1 if deathid==22831

gen matchpid=pid if pid=="20172029"
fillmissing matchpid
replace pid=matchpid if deathid==23490
gen matchcr5id=cr5id if pid=="20172029"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==23490
drop matchpid matchcr5id
replace matched=1 if deathid==23490

gen matchpid=pid if pid=="20180741"
fillmissing matchpid
replace pid=matchpid if deathid==25461
gen matchcr5id=cr5id if pid=="20180741"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==25461
drop matchpid matchcr5id
replace matched=1 if deathid==25461

gen matchpid=pid if pid=="20160711"
fillmissing matchpid
replace pid=matchpid if deathid==21451
gen matchcr5id=cr5id if pid=="20160711"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==21451
drop matchpid matchcr5id
replace matched=1 if deathid==21451

gen matchpid=pid if pid=="20161189"
fillmissing matchpid
replace pid=matchpid if deathid==20617
gen matchcr5id=cr5id if pid=="20161189"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==20617
drop matchpid matchcr5id
replace matched=1 if deathid==20617

gen matchpid=pid if pid=="20160852"
fillmissing matchpid
replace pid=matchpid if deathid==19632
gen matchcr5id=cr5id if pid=="20160852"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==19632
drop matchpid matchcr5id
replace matched=1 if deathid==19632
replace natregno=subinstr(natregno,"52","42",.) if deathid==19632
replace dd_age=73 if deathid==19632

gen matchpid=pid if pid=="20160799"
fillmissing matchpid
replace pid=matchpid if deathid==22103
gen matchcr5id=cr5id if pid=="20160799"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==22103
drop matchpid matchcr5id
replace matched=1 if deathid==22103

gen matchpid=pid if pid=="20170687"
fillmissing matchpid
replace pid=matchpid if deathid==22339
gen matchcr5id=cr5id if pid=="20170687"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==22339
drop matchpid matchcr5id
replace matched=1 if deathid==22339
replace natregno=subinstr(natregno,"66","61",.) if deathid==22339
replace dd_age=55 if deathid==22339

gen matchpid=pid if pid=="20161200"
fillmissing matchpid
replace pid=matchpid if deathid==20355
gen matchcr5id=cr5id if pid=="20161200"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==20355
drop matchpid matchcr5id
replace matched=1 if deathid==20355

gen matchpid=pid if pid=="20161201"
fillmissing matchpid
replace pid=matchpid if deathid==21408
gen matchcr5id=cr5id if pid=="20161201"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==21408
drop matchpid matchcr5id
replace matched=1 if deathid==21408

gen matchpid=pid if pid=="20160863"
fillmissing matchpid
replace pid=matchpid if deathid==19814
gen matchcr5id=cr5id if pid=="20160863"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==19814
drop matchpid matchcr5id
replace matched=1 if deathid==19814

gen matchpid=pid if pid=="20160569"
fillmissing matchpid
replace pid=matchpid if deathid==22258
gen matchcr5id=cr5id if pid=="20160569"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==22258
drop matchpid matchcr5id
replace matched=1 if deathid==22258

gen matchpid=pid if pid=="20180097"
fillmissing matchpid
replace pid=matchpid if deathid==28783
gen matchcr5id=cr5id if pid=="20180097"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==28783
drop matchpid matchcr5id
replace matched=1 if deathid==28783

gen matchpid=pid if pid=="20180928"
fillmissing matchpid
replace pid=matchpid if deathid==25668
gen matchcr5id=cr5id if pid=="20180928"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==25668
drop matchpid matchcr5id
replace matched=1 if deathid==25668

gen matchpid=pid if pid=="20180930"
fillmissing matchpid
replace pid=matchpid if deathid==26403
gen matchcr5id=cr5id if pid=="20180930"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==26403
drop matchpid matchcr5id
replace matched=1 if deathid==26403

gen matchpid=pid if pid=="20171009"
fillmissing matchpid
replace pid=matchpid if deathid==23160
gen matchcr5id=cr5id if pid=="20171009"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==23160
drop matchpid matchcr5id
replace matched=1 if deathid==23160

gen matchpid=pid if pid=="20180931"
fillmissing matchpid
replace pid=matchpid if deathid==26045
gen matchcr5id=cr5id if pid=="20180931"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==26045
drop matchpid matchcr5id
replace matched=1 if deathid==26045

gen matchpid=pid if pid=="20180932"
fillmissing matchpid
replace pid=matchpid if deathid==26279
gen matchcr5id=cr5id if pid=="20180932"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==26279
drop matchpid matchcr5id
replace matched=1 if deathid==26279

gen matchpid=pid if pid=="20160893"
fillmissing matchpid
replace pid=matchpid if deathid==20242
gen matchcr5id=cr5id if pid=="20160893"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==20242
drop matchpid matchcr5id
replace matched=1 if deathid==20242

gen matchpid=pid if pid=="20180159"
fillmissing matchpid
replace pid=matchpid if deathid==25174
gen matchcr5id=cr5id if pid=="20180159"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==25174
drop matchpid matchcr5id
replace matched=1 if deathid==25174

gen matchpid=pid if pid=="20160482"
fillmissing matchpid
replace pid=matchpid if deathid==33721
gen matchcr5id=cr5id if pid=="20160482"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==33721
drop matchpid matchcr5id
replace matched=1 if deathid==33721
replace natregno=subinstr(natregno,"81","91",.) if deathid==33721

gen matchpid=pid if pid=="20162040"
fillmissing matchpid
replace pid=matchpid if deathid==22330
gen matchcr5id=cr5id if pid=="20162040"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==22330
drop matchpid matchcr5id
replace matched=1 if deathid==22330
replace natregno=subinstr(natregno,"50","40",.) if deathid==22330

gen matchpid=pid if pid=="20180227"
fillmissing matchpid
replace pid=matchpid if deathid==25960
gen matchcr5id=cr5id if pid=="20180227"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==25960
drop matchpid matchcr5id
replace matched=1 if deathid==25960
replace natregno=subinstr(natregno,"20","50",.) if deathid==25960

gen matchpid=pid if pid=="20180935"
fillmissing matchpid
replace pid=matchpid if deathid==24573
gen matchcr5id=cr5id if pid=="20180935"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==24573
drop matchpid matchcr5id
replace matched=1 if deathid==24573
replace natregno=subinstr(natregno,"70","40",.) if deathid==24573

gen matchpid=pid if pid=="20170847"
fillmissing matchpid
replace pid=matchpid if deathid==22986
gen matchcr5id=cr5id if pid=="20170847"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==22986
drop matchpid matchcr5id
replace matched=1 if deathid==22986
replace natregno=subinstr(natregno,"02","20",.) if deathid==22986

gen matchpid=pid if pid=="20161110"
fillmissing matchpid
replace pid=matchpid if deathid==20792
gen matchcr5id=cr5id if pid=="20161110"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==20792
drop matchpid matchcr5id
replace matched=1 if deathid==20792

gen matchpid=pid if pid=="20170797"
fillmissing matchpid
replace pid=matchpid if deathid==23766
gen matchcr5id=cr5id if pid=="20170797"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==23766
drop matchpid matchcr5id
replace matched=1 if deathid==23766

drop dup
keep if deathds==1 & matched==1 //21,630 deleted
count //48
save "`datapath'\version09\2-working\2015-2021_deaths_for_merging_NAMES" ,replace
