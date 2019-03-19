** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			2_clean_2008_2013_dc.do
    //  project:				BNR
    //  analysts:				Jacqueline CAMPBELL
    //  date first created      19-MAR-2019
    // 	date last modified	    19-MAR-2019
    //  algorithm task			Cleaning 2008 & 2013 cancer datasets, Creating site groupings
    //  status                  Completed
    //  objectve                To have one dataset with cleaned and grouped 2008 data for inclusion in 2014 cancer report.


    ** General algorithm set-up
    version 15
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
    log using "`logpath'\3_clean_2008_2013_dc.smcl", replace
** HEADER -----------------------------------------------------

* ************************************************************************
* CLEANING
* Using version02 dofiles created in 2014 data review folder (Sync)
**************************************************************************

** Load the dataset with recently matched death data
use "`datapath'\version01\2-working\2008_2013_cancer_prep_dc.dta", clear

count //2,608

** Create date of death (dod) variable
**gen dod=dlc if slc==2

** Assign deathid previously found when cleaning NAACCR-IACR datasets, in prep for merge with death data
gen deathid=.

//2014_cancer_deaths_dc.dta - 2008
replace deathid=20818 if pid=="20080497" //previous deathid==11744
replace deathid=21244 if pid=="20080320" //previous deathid==19308
replace deathid=14656 if pid=="20080022" //previous deathid==21675
replace deathid=19593 if pid=="20080019" //previous deathid==22730
replace deathid=23102 if pid=="20080013" //previous deathid==21088
replace deathid=15697 if pid=="20080730" //previous deathid==18140
replace deathid=22326 if pid=="20080252" //previous deathid==817
replace deathid=16608 if pid=="20080166" //previous deathid==19225
replace deathid=13521 if pid=="20080668" //previous deathid==3173
replace deathid=22454 if pid=="20080230" //previous deathid==22895
replace deathid=12638 if pid=="20080017" //previous deathid==21696
replace deathid=14323 if pid=="20080689" //previous deathid==1091
replace deathid=21281 if pid=="20080154" //previous deathid==14185
replace deathid=16466 if pid=="20080677" //previous deathid==23941
replace deathid=13038 if pid=="20080337" //previous deathid==18167
replace deathid=13018 if pid=="20080714" //previous deathid==7768
replace deathid=13836 if pid=="20080620" //previous deathid==23518
replace deathid=13242 if pid=="20080216" //previous deathid==1099
replace deathid=16724 if pid=="20080684" //previous deathid==852
replace deathid=22999 if pid=="20080539" //previous deathid==4308
replace deathid=15773 if pid=="20080306" //previous deathid==8358
replace deathid=17239 if pid=="20080023" //previous deathid==14600
replace deathid=17684 if pid=="20080365" //previous deathid==16703
replace deathid=14724 if pid=="20080345" //previous deathid==5059
replace deathid=18266 if pid=="20080305" //previous deathid==9778
replace deathid=12296 if pid=="20080276" //previous deathid==11344
replace deathid=23772 if pid=="20080738" //previous deathid==12603
replace deathid=21462 if pid=="20080540" //previous deathid==10939
replace deathid=23482 if pid=="20080044" //previous deathid==7950
replace deathid=20557 if pid=="20080041" //previous deathid==11345
replace deathid=11915 if pid=="20080628" //previous deathid==19688
replace deathid=11917 if pid=="20080034" //previous deathid==20438
replace deathid=15789 if pid=="20080233" //previous deathid==10116
replace deathid=16015 if pid=="20080200" //previous deathid==1247
replace deathid=15645 if pid=="20080211" //previous deathid==19796
replace deathid=21308 if pid=="20080373" //previous deathid==17456
replace deathid=24105 if pid=="20080316" //previous deathid==21980
replace deathid=21053 if pid=="20080751" //previous deathid==12522
replace deathid=13789 if pid=="20080488" //previous deathid==19740
replace deathid=19016 if pid=="20080686" //previous deathid==15824
replace deathid=13720 if pid=="20080570" //previous deathid==1137
replace deathid=17176 if pid=="20080487" //previous deathid==13509
replace deathid=17012 if pid=="20080045" //previous deathid==21853
replace deathid=18242 if pid=="20080027" //previous deathid==20512
replace deathid=18460 if pid=="20080353" //previous deathid==4030
replace deathid=12719 if pid=="20080531" //previous deathid==494
replace deathid=14622 if pid=="20080416" //previous deathid==8462
replace deathid=23317 if pid=="20080026" //previous deathid==19258
replace deathid=11928 if pid=="20080031" //previous deathid==7816
replace deathid=12859 if pid=="20080325" //previous deathid==6020
replace deathid=13778 if pid=="20080253" //previous deathid==3019
replace deathid=18154 if pid=="20080043" //previous deathid==1692
replace deathid=14013 if pid=="20080290" //previous deathid==7026
replace deathid=22809 if pid=="20080517" //previous deathid==15461
replace deathid=15099 if pid=="20080680" //previous deathid==16251
replace deathid=12790 if pid=="20080181" //previous deathid==19266
replace deathid=19012 if pid=="20080509" //previous deathid==10543
replace deathid=23098 if pid=="20080434" //previous deathid==12648
replace deathid=14872 if pid=="20080508" //previous deathid==3642
replace deathid=16789 if pid=="20081064" //previous deathid==13711
replace deathid=22601 if pid=="20080594" //previous deathid==5413
replace deathid=13056 if pid=="20080238" //previous deathid==5989
replace deathid=17981 if pid=="20080054" //previous deathid==2837
replace deathid=20432 if pid=="20080349" //previous deathid==22950
replace deathid=15325 if pid=="20080059" //previous deathid==21487
replace deathid=21539 if pid=="20080243" //previous deathid==11065
replace deathid=18813 if pid=="20080150" //previous deathid==11405
replace deathid=12735 if pid=="20080642" //previous deathid==7979
replace deathid=20158 if pid=="20080505" //previous deathid==3761
replace deathid=13523 if pid=="20080472" //previous deathid==13535
replace deathid=12784 if pid=="20080435" //previous deathid==15856
replace deathid=15373 if pid=="20080137" //previous deathid==23893
replace deathid=18416 if pid=="20080543" //previous deathid==10676
replace deathid=22209 if pid=="20080221" //previous deathid==12670
replace deathid=16267 if pid=="20080410" //previous deathid==9275
replace deathid=14765 if pid=="20080565" //previous deathid==21177
replace deathid=18952 if pid=="20080883" //previous deathid==2388
replace deathid=20863 if pid=="20080065" //previous deathid==1665
replace deathid=22395 if pid=="20080348" //previous deathid==8798
replace deathid=13333 if pid=="20080484" //previous deathid==3243
replace deathid=20214 if pid=="20080330" //previous deathid==3421
replace deathid=20319 if pid=="20080234" //previous deathid==17723
replace deathid=18195 if pid=="20080578" //previous deathid==9374
replace deathid=13899 if pid=="20080636" //previous deathid==4454
replace deathid=14690 if pid=="20080208" //previous deathid==5256
replace deathid=20525 if pid=="20080341" //previous deathid==19048
replace deathid=20561 if pid=="20080327" //previous deathid==14174
replace deathid=12204 if pid=="20080412" //previous deathid==13162
replace deathid=14613 if pid=="20080562" //previous deathid==21086
replace deathid=20444 if pid=="20080213" //previous deathid==4317
replace deathid=18290 if pid=="20080601" //previous deathid==2167
replace deathid=22921 if pid=="20080155" //previous deathid==2424
replace deathid=13787 if pid=="20080574" //previous deathid==12086
replace deathid=16039 if pid=="20080622" //previous deathid==5187
replace deathid=18543 if pid=="20080257" //previous deathid==11162
replace deathid=14450 if pid=="20080063" //previous deathid==4644
replace deathid=17577 if pid=="20080544" //previous deathid==10577
replace deathid=15486 if pid=="20080775" //previous deathid==16789
replace deathid=13068 if pid=="20080174" //previous deathid==17010
replace deathid=21263 if pid=="20080360" //previous deathid==18710
replace deathid=17954 if pid=="20080169" //previous deathid==13263
replace deathid=21380 if pid=="20080250" //previous deathid==8339
replace deathid=21371 if pid=="20080661" //previous deathid==12001
replace deathid=20226 if pid=="20080212" //previous deathid==3321
replace deathid=15493 if pid=="20080576" //previous deathid==18444
replace deathid=16473 if pid=="20080553" //previous deathid==9000
replace deathid=18974 if pid=="20080292" //previous deathid==15476
replace deathid=12122 if pid=="20080156" //previous deathid==20707

replace natregno="210620-0062" if pid=="20080497"
replace natregno="201130-0080" if pid=="20080730"
replace natregno="260722-7002" if pid=="20080457"
replace natregno="250323-0068" if pid=="20081054"
replace natregno="341125-0024" if pid=="20080305"
replace natregno="430906-7017" if pid=="20080739"
replace natregno="250612-8012" if pid=="20080738"
replace natregno="270715-0039" if pid=="20080462"
replace natregno="500612-8002" if pid=="20080686"
replace natregno="240612-0010" if pid=="20080484"
replace natregno="340429-0011" if pid=="20080353"
replace natregno="200830-0093" if pid=="20080416"
replace natregno="300620-0046" if pid=="20080043"
replace natregno="250312-0012" if pid=="20080434"
replace natregno="310330-0038" if pid=="20081064"
replace natregno="250808-0104" if pid=="20080432"
replace natregno="300408-0010" if pid=="20080472"
replace natregno="170830-8000" if pid=="20080435"
replace natregno="360916-0068" if pid=="20080543"
replace natregno="360713-8033" if pid=="20080410"
replace natregno="300902-0011" if pid=="20080578"
replace natregno="471204-0015" if pid=="20080341"
replace natregno="430601-8054" if pid=="20080719"
replace natregno="321017-0076" if pid=="20080327"
replace natregno="220929-0051" if pid=="20080775"
replace natregno="270112-0038" if pid=="20080576"

//2014_cancer_deaths_dc.dta - 2013
replace deathid=17631 if pid=="20130053" //previous deathid==5099
replace deathid=20470 if pid=="20130154" //previous deathid==11801
replace deathid=22696 if pid=="20130135" //previous deathid==17703
replace deathid=17132 if pid=="20130161" //previous deathid==19202
replace deathid=18870 if pid=="20130072" //previous deathid==22104
replace deathid=19735 if pid=="20130409" //previous deathid==5406
replace deathid=20361 if pid=="20130672" //previous deathid==19421
replace deathid=19491 if pid=="20130153" //previous deathid==17921
replace deathid=23051 if pid=="20130055" //previous deathid==3728
replace deathid=18608 if pid=="20130091" //previous deathid==6714
replace deathid=21860 if pid=="20130131" //previous deathid==16735
replace deathid=18649 if pid=="20130274" //previous deathid==21945
replace deathid=19520 if pid=="20130114" //previous deathid==14116
replace deathid=20652 if pid=="20130173" //previous deathid==21211
replace deathid=18758 if pid=="20130104" //previous deathid==24169
replace deathid=21443 if pid=="20130345" //previous deathid==12550
replace deathid=20885 if pid=="20130145" //previous deathid==21464
replace deathid=18967 if pid=="20130677" //previous deathid==10007
replace deathid=19506 if pid=="20130139" //previous deathid==13287
replace deathid=24029 if pid=="20130082" //previous deathid==8318
replace deathid=18686 if pid=="20130631" //previous deathid==3391
replace deathid=18821 if pid=="20130625" //previous deathid==1023
replace deathid=21117 if pid=="20130813" //previous deathid==18599
replace deathid=15359 if pid=="20131003" //previous deathid==20328
replace deathid=21573 if pid=="20130374" //previous deathid==4710
replace deathid=21136 if pid=="20130128" //previous deathid==4397
replace deathid=23268 if pid=="20130102" //previous deathid==8005
replace deathid=21885 if pid=="20130156" //previous deathid==20168
replace deathid=22551 if pid=="20130037" //previous deathid==9702
replace deathid=18760 if pid=="20130163" //previous deathid==2664
replace deathid=20532 if pid=="20130032" //previous deathid==18937
replace deathid=20313 if pid=="20130606" //previous deathid==17734
replace deathid=19766 if pid=="20130504" //previous deathid==23091
replace deathid=20676 if pid=="20130063" //previous deathid==22892
replace deathid=17695 if pid=="20130313" //previous deathid==13982
replace deathid=21977 if pid=="20130150" //previous deathid==4545
replace deathid=19201 if pid=="20130814" //previous deathid==23540
replace deathid=18896 if pid=="20130818" //previous deathid==13141
replace deathid=20460 if pid=="20130141" //previous deathid==24166
replace deathid=21172 if pid=="20130103" //previous deathid==16675
replace deathid=23428 if pid=="20130038" //previous deathid==13142
replace deathid=19548 if pid=="20130096" //previous deathid==10089
replace deathid=21106 if pid=="20130027" //previous deathid==15892
replace deathid=23276 if pid=="20130119" //previous deathid==2401
replace deathid=23185 if pid=="20130073" //previous deathid==22526
replace deathid=20005 if pid=="20130130" //previous deathid==744
replace deathid=21564 if pid=="20130768" //previous deathid==20744
replace deathid=22534 if pid=="20130044" //previous deathid==12503
replace deathid=18684 if pid=="20130648" //previous deathid==17611
replace deathid=19840 if pid=="20130127" //previous deathid==10403
replace deathid=22959 if pid=="20130031" //previous deathid==12632
replace deathid=19345 if pid=="20130885" //previous deathid==4218
replace deathid=22722 if pid=="20130079" //previous deathid==4675
replace deathid=17648 if pid=="20130319" //previous deathid==20859
replace deathid=21279 if pid=="20130361" //previous deathid==8255
replace deathid=19938 if pid=="20130396" //previous deathid==7677
replace deathid=18669 if pid=="20130067" //previous deathid==10712
replace deathid=19928 if pid=="20130886" //previous deathid==14134
replace deathid=22730 if pid=="20130022" //previous deathid==1089
replace deathid=16495 if pid=="20130661" //previous deathid==2759
replace deathid=21141 if pid=="20130769" //previous deathid==18762
replace deathid=20804 if pid=="20130696" //previous deathid==21663
replace deathid=19681 if pid=="20130830" //previous deathid==1409
replace deathid=21145 if pid=="20130362" //previous deathid==7764
replace deathid=20111 if pid=="20130674" //previous deathid==21844
replace deathid=21495 if pid=="20130426" //previous deathid==12948
replace deathid=22445 if pid=="20130874" //previous deathid==19340

replace natregno="441219-0078" if pid=="20130772"
replace natregno="430916-0127" if pid=="20130361"
replace natregno="290210-0134" if pid=="20130396"
replace natregno="470831-0059" if pid=="20130886"
replace natregno="460928-0146" if pid=="20130814"
replace natregno="461123-0063" if pid=="20130818"
replace natregno="190511-0027" if pid=="20130661"
replace natregno="421121-9999" if pid=="20130650"
replace natregno="560725-0072" if pid=="20130696"
replace natregno="471124-0012" if pid=="20130830"
replace natregno="300608-0059" if pid=="20130362"
replace natregno="841016-0041" if pid=="20130674"
replace natregno="610630-0103" if pid=="20130631"
replace natregno="370126-0030" if pid=="20130426"
replace natregno="490110-0091" if pid=="20130813"
replace natregno="450902-0022" if pid=="20130374"
replace natregno="440214-0018" if pid=="20130874"

//redcap deathdataALL - 2008
replace deathid=6496 if pid=="20080586"
replace deathid=9574 if pid=="20080421"
replace deathid=11650 if pid=="20080011"
replace deathid=9763 if pid=="20080161"
replace deathid=11208 if pid=="20080177"
replace deathid=10974 if pid=="20080269"
replace deathid=8483 if pid=="20080347"
replace deathid=4404 if pid=="20080344"
replace deathid=6057 if pid=="20080346"
replace deathid=3608 if pid=="20080465"
replace deathid=9794 if pid=="20080182"
replace deathid=7939 if pid=="20080301"
replace deathid=8917 if pid=="20080377"
replace deathid=7522 if pid=="20080631"
replace deathid=3161 if pid=="20080654"
replace deathid=4878 if pid=="20080461"
replace deathid=4374 if pid=="20080387"
replace deathid=3314 if pid=="20080535"
replace deathid=9462 if pid=="20080616"
replace deathid=10333 if pid=="20080533"
replace deathid=8890 if pid=="20080324"
replace deathid=11204 if pid=="20080029"
replace deathid=11206 if pid=="20080042"
replace deathid=5393 if pid=="20080608"
replace deathid=2206 if pid=="20080597"
replace deathid=6484 if pid=="20080367"
replace deathid=4055 if pid=="20080545"
replace deathid=1762 if pid=="20080047"
replace deathid=9263 if pid=="20080323"
replace deathid=6533 if pid=="20080321"
replace deathid=11523 if pid=="20080057"
replace deathid=4282 if pid=="20080504"
replace deathid=11245 if pid=="20080286"
replace deathid=6776 if pid=="20080476"
replace deathid=4117 if pid=="20080381"
replace deathid=5862 if pid=="20080279"
replace deathid=10655 if pid=="20080328"
replace deathid=10735 if pid=="20080385"
replace deathid=3519 if pid=="20080296"
replace deathid=9566 if pid=="20080561"
replace deathid=3637 if pid=="20080581"
replace deathid=10298 if pid=="20080136"
replace deathid=7199 if pid=="20080205"
replace deathid=10148 if pid=="20080187"
replace deathid=9385 if pid=="20080278"
replace deathid=1828 if pid=="20080720"
replace deathid=4783 if pid=="20080580"
replace deathid=7239 if pid=="20080469"
replace deathid=10696 if pid=="20080123"
replace deathid=5489 if pid=="20080479"
replace deathid=9863 if pid=="20080203"
replace deathid=8534 if pid=="20080740"

replace natregno="190923-0052" if pid=="20080421"
replace natregno="590829-9999" if pid=="20080177"
replace natregno="291003-0077" if pid=="20080344"
replace natregno="430715-0054" if pid=="20080766"
replace natregno="240826-0038" if pid=="20080465"
replace natregno="320518-0056" if pid=="20080592"
replace natregno="230104-0040" if pid=="20080301"
replace natregno="221127-0018" if pid=="20080377"
replace natregno="221219-0066" if pid=="20080654"
replace natregno="320402-7019" if pid=="20080450"
replace natregno="491113-0039" if pid=="20081109"
replace natregno="250906-0022" if pid=="20080461"
replace natregno="310705-0050" if pid=="20080533"
replace natregno="361011-0078" if pid=="20080504"
replace natregno="210130-0107" if pid=="20080476"
replace natregno="120821-8006" if pid=="20080385"
replace natregno="220708-9999" if pid=="20080205"
replace natregno="360722-7034" if pid=="20080720"
replace natregno="300818-7001" if pid=="20080740"

count //2,608

** Merge (redcap) death data with cancer data
merge m:1 deathid using "`datapath'\version01\2-working\2008-2017_deaths_dc.dta"

/*
    Result                           # of obs.
    -----------------------------------------
    not matched                        26,265
        from master                     2,304  (_merge==1)
        from using                     23,961  (_merge==2)

    matched                               304  (_merge==3)
    -----------------------------------------

*/
count //26,569

** Check merged correctly
**list pid deathid fname lname pname if _merge==3 //2 incorrect - corrected above and re-ran above code


** Remove unmatched deaths (didn't merge)
count if pid=="" //23,961
drop if pid=="" //23,961 deleted

count //2,608

STOPPED HERE

*************************************************
** BLANK & INCONSISTENCY CHECKS - PATIENT TABLE
** CHECKS 1 - 46
** (1) CORRECT INCONSISTENCIES
** (2) EXPORT FOR CANREG5 DATABASE (CLEAN)
*************************************************

** Check 1 (ID)
count if pid=="" //0

** Check 2 (Names)
count if fname=="" //0
count if init=="" //25
replace init="99" if init=="" //25 changes
count if lname=="" //0

** Check 3 (DOB, NRN)
count if dob==. //40
count if dob==. & natregno!="" & natregno!="99" & natregno!="999999-9999" //2
replace dob=d(28dec1935) if pid=="20080885" //1 change
replace natregno="999999-9999" if pid=="20081071" //1 change
count if natregno=="" & dob!=. //0
//missing
gen currentd=c(current_date)
gen double currentdatedob=date(currentd, "DMY", 2017)
drop currentd
format currentdatedob %dD_m_CY
label var currentdate "Current date DOB"
count if dob!=. & dob>currentdatedob //0
drop currentdatedob
//future date
count if length(natregno)<11 & natregno!="" //12
replace natregno="999999-9999" if pid=="20080670" //1 change
replace natregno="999999-9999" if pid=="20080685" //1 change
replace natregno="999999-9999" if pid=="20080790" //2 changes
replace natregno="999999-9999" if pid=="20080791" //1 change
replace natregno="999999-9999" if pid=="20080792" //1 change
replace natregno="999999-9999" if pid=="20080829" //1 change
replace natregno="999999-9999" if pid=="20081112" //1 change
replace natregno="430823-0038" if pid=="20080225" //1 change
replace natregno="460115-0065" if pid=="20080277" //1 change
replace natregno="430121-0045" if pid=="20080287" //1 change
replace natregno="470331-0112" if pid=="20080297" //1 change
//length error
gen nrnday = substr(natregno,5,2)
count if dob==. & natregno!="" & natregno!="9999999999" & natregno!="999999-9999" & nrnday!="99" //0
//dob missing but full nrn available
gen dob_year = year(dob) if natregno!="" & natregno!="9999999999" & natregno!="999999-9999" & nrnday!="99" & length(natregno)==11
gen yr1=.
replace yr1 = 20 if dob_year>1999
replace yr1 = 19 if dob_year<2000
replace yr1 = 19 if dob_year==.
replace yr1 = 99 if natregno=="99"
list pid dob_year dob natregno yr yr1 if dob_year!=. & dob_year > 1999
gen str nrn = substr(natregno,1,6) if natregno!="" & natregno!="9999999999" & natregno!="999999-9999" & nrnday!="99" & length(natregno)==11
**gen nrnlen=length(nrn)
**drop if nrnlen!=6
destring nrn, replace
format nrn %06.0f
nsplit nrn, digits(2 2 2) gen(year month day)
format year month day %02.0f
tostring yr1, replace
gen year2 = string(year,"%02.0f")
gen nrnyr = substr(yr1,1,2) + substr(year2,1,2)
destring nrnyr, replace
sort nrn
gen dobchk=mdy(month, day, nrnyr)
format dobchk %dD_m_CY
count if dob!=dobchk & dobchk!=. //1
list pid age natregno nrn dob dobchk dob_year if dob!=dobchk & dobchk!=.
replace dob=dobchk if dob!=dobchk & dobchk!=. //1 change
drop dob_year day month year nrnday nrnyr year2 yr yr1 nrn dobchk
//dob does not match nrn

** Check 4 (sex)
count if sex==. //0



**



** Check for dod
count if slc==2 & dod==.

*************************************************
** BLANK & INCONSISTENCY CHECKS - TUMOUR TABLE
** CHECKS 47 - ...
** (1) CORRECT INCONSISTENCIES
** (2) EXPORT FOR CANREG5 DATABASE (CLEAN)
*************************************************

** Check ... (DA)
count if ttda=="" //0
count if length(ttda)<1 //0

** Check ... (primary site, topography)
replace primarysite="OVERLAP-STOMACH INVOLV. BODY,PYLORIC AN." if pid==20080634
replace topography=168 if pid=="20080634"

* ************************************************************************
* SITE GROUPINGS
* Using ...?
**************************************************************************
count if icd10==""


count //

save "`datapath'\version01\2-working\2008_2013_cancer_clean_dc.dta" ,replace
label data "BNR-Cancer prepared 2008 & 2013 data"
notes _dta :These data prepared for 2008 & 2013 inclusion in 2014 cancer report
