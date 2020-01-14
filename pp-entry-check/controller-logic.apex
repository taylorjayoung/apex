
//Created By	Kashif Zai ,  9/28/2011 2:32 PM	

public class EntryCheckController {
    public List<Schedules__c> scheduleList { get; set; }
    public List<FBEntryModel> fbEntryModelList { get; set; }
    public List<FBModels> fbModel { get; set; }    //All data, one row represented by one List element
    public Map<String, List<FBEntryModel>> fbEntryModelMap { get; set; }
    public Integer count;
    public String summarize { get; set; }
    public String summarize2 { get; set; }
    public String dateField { get; set; }
    public String range { get; set; }
    public String pchk { get; set; }
    public List<HeadingModel> headingModels { get; set; }
    public Map<integer, String> daysMap;
    public Map<integer, String> daysMapFull;
    public String dealProgram { get; set; }
    public Decimal sumGrandTotal { get; set; }
    public Integer totalCount { get; set; }
    //List <String> keys;
    List <String> keys;
    List <Date> dKeys;
    public Schedules__c sDate { set; get; }
    public Schedules__c eDate { set; get; }
    public Contact con { get; set; } //
    public Deal__c deal { get; set; }
    public List<String> lstDayOfWeek { set; get; }

    Date fromDate { get; set; }
    Date toDate { get; set; }

    public String sch { get; set; }
    public String sid { get; set; }
    public String slf { get; set; }
    public String sWeek { get; set; }
    Schedules__C oldScheduleObj;
    public Schedules__C scheduleObj { get; set; }
    public List<Deal__c> lstDealAccount { set; get; }


    public integer fYear { set; get; }
    public integer fMonth { set; get; }

    public integer activeFilter { set; get; } //0-None, 1-Month, 2-Dates

    public List <ModelTotals> totals { set; get; }
    public ModelTotals totalsOfTotal { set; get; }

    public List<SelectOption> items { get; set; }
    public string months { get; set; }

    public boolean checks { set; get; }
    public boolean hasRecords { set; get; } //used to display Table or not
    public boolean missingProgram { set; get; }

    public String AccountName { set; get; }
    //They will be passed as argument to DOCFilterByDealAccount page
    public String dealFMonth { set; get; }
    public String dealFYear { set; get; }

    private void loadDaysMap() {
        daysMap = new Map<integer, String>();
        daysMap.put(1, '1Mon');
        daysMap.put(2, '2Tues');
        daysMap.put(3, '3Wed');
        daysMap.put(4, '4Th');
        daysMap.put(5, '5Fri');
        daysMap.put(6, '6Sat');
        daysMap.put(7, '7Sun');
    }
    private void loadDaysMapFull() {
        daysMapFull = new Map<integer, String>();
        daysMapFull.put(1, 'Monday');
        daysMapFull.put(2, 'Tuesday');
        daysMapFull.put(3, 'Wednesday');
        daysMapFull.put(4, 'Thursday');
        daysMapFull.put(5, 'Friday');
        daysMapFull.put(6, 'Saturday');
        daysMapFull.put(7, 'Sunday');
    }


    private String getDayOfWeek(integer day) {
        return daysMap.get(day);
    }
    private String getDayOfWeekFull(integer day) {
        return daysMapFull.get(day);
    }
    public EntryCheckController() {
        //Fetching the Previously applied Filter     
        sumGrandTotal = 0;
        totalcount = 0;

        missingProgram = false;
        hasRecords = false;
        con = new Contact();
        deal = new Deal__c();
        AccountName = '';

        sDate = new Schedules__c();
        eDate = new Schedules__c();
        sDate.Week__c = Date.today().toStartOfWeek().addDays(1);
        eDate.Week__c = Date.today().toStartOfWeek().addDays(7);
    //method for month pickList in Page.
    public List<SelectOption> getOptions() {
        Map<integer, string> monthMap = getMonth();
        List<SelectOption> options = new List<SelectOption>();
        //options.add(new SelectOption('None','-None-'));
        for (integer i = 2010; i <= 2020; i++) {
            for (integer j = 1; j <= 12; j++) {
                options.add(new SelectOption(j + '-' + i, monthMap.get(j) + ' ' + i));
            }
        }
        integer mon = date.today().month();
        integer yer = date.today().year();
        if (activeFilter != 1) {
            months = mon + '-' + yer;
        }
        return options;
    }

    public Map<integer, string> getMonth() {
        Map<integer, string> monthMap = new Map<integer, string>();
        monthMap.put(1, 'Jan');
        monthMap.put(2, 'Feb');
        monthMap.put(3, 'Mar');
        monthMap.put(4, 'Apr');
        monthMap.put(5, 'May');
        monthMap.put(6, 'Jun');
        monthMap.put(7, 'Jul');
        monthMap.put(8, 'Aug');
        monthMap.put(9, 'Sep');
        monthMap.put(10, 'Oct');
        monthMap.put(11, 'Nov');
        monthMap.put(12, 'Dec');
        return monthMap;
    }


    public PageReference search() {
        if (deal.Program__c == null) {
            missingProgram = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Deal Program is Required.'));
            return null;
        } else {
            if (sDate.Week__c == null) {
                sDate.Week__c = Date.today().toStartOfWeek().addDays(1);
            }
            eDate.Week__c = sDate.Week__c.addDays(6);
            showReport();
            PageReference pg = new PageReference('/apex/EntryCheckReport');
            return pg;
        }
    }

    // Cancel Method is used to cancel the Schedule, it will cancels the selected Record(from which Cancel button is clicked)
    public void cancel() {
        //String sid = ApexPages.currentPage().getParameters().get('sid');
        System.debug('Schedule id=======' + sid);
        System.debug('Long Form=======' + slf);
        System.debug('Schedule week=======' + sWeek);
        if (sid != null && sid.trim().length() > 0) {
            //List<Schedules__c> schedules = [select status__c, Deal_Parent__r.Program__r.Name, Deal_Parent__r.Brands__r.Name, Long_Form__c, 
            //                                Deal_Parent__r.Length__c, Week__c, RecordTypeId from Schedules__c where id=:sid];
            List<Schedules__c> schedules = [select status__c from Schedules__c where id = :sid];
            if (schedules.size() > 0) {
                schedules.get(0).status__c = 'Canceled';
                update schedules.get(0);
            }
        }
        createSchedule();
        showReport();
    }
    //method creates new schedule when hitting cancel. Cancels status if schedule exists 
    private void createSchedule() {
        Date schWeek = Date.valueOf(sWeek);
        System.debug('Schedule date=======' + schWeek);
        if (slf != null && slf.trim().length() > 0 && schWeek != null) {
            List<Deal__c> newDealList = [
                    SELECT id, Name, Brands__r.Name, Program__c
                    FROM Deal__c
                    WHERE program__c = :deal.Program__c AND Brands__r.Name = 'Availability'
                    //AND createdDate >=:Date.newInstance(s.Week__c.Year(),s.Week__c.Month(),1).toStartOfWeek().addDays(1)
                    //AND createdDate <: Date.newInstance(s.Week__c.Year(),s.Week__c.Month()+1,1).toStartOfWeek().addDays(1)
                    ORDER BY createdDate desc
            ];
            System.debug('@@@@@ New Deal List =======>' + newDealList.size());
            if (newDealList.size() > 0) {
                Schedules__c newSch = new Schedules__c();
                newSch.Deal_Parent__c = newDealList.get(0).id;
                newSch.Week__c = schWeek;
                newSch.Long_Form__c = slf;
                newSch.Rate__c = 0;
                newSch.Status__c = 'Sold';
                newSch.Units_Available__c = -1;
                insert newSch;
                System.debug('@@@ New Brand =======' + newDealList.get(0).Brands__r.Name);
                System.debug('@@@ New schedule =======' + newSch.Id);
            }
        }
    }

    //method navigates to replace shedule page.
    public PageReference replaceSchedule() {
        oldScheduleobj = NULL;
        scheduleObj = new Schedules__c();

        System.debug('@@@@@@@ Schedule id: ' + sch);

        if (sch != null && sch.trim().equals('') == false) {
            oldScheduleObj = [
                    select dealprogram__c,Deal_Parent__c,Units_Available__c,Rate__c,Week__c,Long_Form__c,status__c
                    from Schedules__c
                    where id = :sch
            ];
            scheduleObj = oldScheduleObj.clone(false, true);
        } else {
            scheduleObj.Week__c = Date.valueOf(sWeek);
            scheduleObj.Long_Form__c = slf;
            scheduleObj.Units_Available__c = 1;
            scheduleObj.status__c = 'Sold';
            scheduleObj.rate__c = 0;
        }
        createList();
        PageReference pg = new PageReference('/apex/EntryCheckReplaceSchedule');
        return pg;
    }

    private void createList() {
        String progId = deal.Program__c;
        system.debug('@@@@ DEAL PROGRAM: ' + deal.Program__c);
        system.debug('@@@@DATE ARE: ' + fromDate + ' TO ' + toDate);
//        lstDealAccount = [
//                select id,ContactAccount__c, name,program__c,program__r.name,createdDate
//                from Deal__c
//                Where program__c = :progId
//                and week_min_Field__c >= :Date.newInstance(fromDate.Year(), fromDate.Month() - 1, 1).toStartOfWeek().addDays(1)
//                and week_min_Field__c < :Date.newInstance(toDate.Year(), toDate.Month() + 1, 1).toStartOfWeek().addDays(1)
//                limit 1000
//        ];
        lstDealAccount = [
                select id,ContactAccount__c, name,program__c,program__r.name,createdDate
                from Deal__c
                Where program__c = :progId
                and week_min_Field__c >= :fromDate.toStartOfMonth().addMonths(-3).toStartOfWeek().addDays(1)
                and week_min_Field__c < :toDate.toStartOfMonth().addMonths(1).toStartOfWeek().addDays(1)
                limit 1000
        ];
        System.debug('@@@@@ Deals found =' + lstDealAccount.size());
        System.debug('@@@@@ Program =' + progId);
        System.debug('@@@@@ from date=' + Date.newInstance(fromDate.Year(), fromDate.Month() - 1, 1).toStartOfWeek().adddays(1));
        System.debug('@@@@@ to date=' + Date.newInstance(toDate.Year(), toDate.Month() + 1, 1).toStartOfWeek().adddays(1));
    }

    public PageReference replace() {
        if (oldScheduleObj != null) {
            oldScheduleObj.status__c = 'Canceled';
            oldScheduleObj.recordTypeID = getRecodType(oldScheduleObj);
            update oldScheduleObj;
        }
        scheduleObj.recordTypeId = getRecodType(scheduleObj);
        insert scheduleObj;
        showReport();
        return new PageReference('/apex/EntryCheckReport');
    }

    public PageReference back() {
        PageReference pg = new PageReference('/apex/EntryCheckReport');
        return pg;
    }

    public void setDealAccount() {
        string dealAcc = ApexPages.currentPage().getParameters().get('accName');
        scheduleObj.Deal_Parent__c = dealAcc;
    }

    private Id getRecordTypeId(String recordTypeName) {
        String rtName;
        system.debug('############ rtName: ' + recordTypeName);
        if (recordTypeName == 'Deal Paid Programming') {
            rtName = 'Paid Programming';
        } else if (recordTypeName == 'Deal Short Form') {
            rtName = 'Short Form';
        }
        system.debug('############ rtName: ' + rtName);
        List<RecordType> schRecType = [select id from RecordType where name = :recordTypeName and SObjectType = 'Schedules__c'];
        if (schRecType.size() > 0) {
            system.debug('######Record type Id: ' + schRecType.get(0).id);
            return schRecType.get(0).id;
        }
        system.debug('###### schRecType is empty ######');
        return null;
    }

    //Method adds new Schedule
    public ID getRecodType(Schedules__c schObj) {
        try {
            List<Deal__c> deals = [select RecordTypeId, RecordType.Name from Deal__c where id = :schObj.Deal_Parent__c];
            return getRecordTypeId(deals.get(0).RecordType.Name);
            //schObj.Deal_Parent__c = schObj.Deal_Parent__c;
        } catch (Exception exp) {

        }
        return null;
    }

    public PageReference showReport() {
        sumGrandTotal = 0;
        totalcount = 0;
        String dealKeyword;
        if (deal.Program__c == null) {
            missingProgram = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Deal Program is Required.'));
            return null;
        } else {
            String programID = deal.Program__c;
            List<Programs__c> progList = [SELECT id, Name FROM Programs__c WHERE id = :programId];
            if (progList.size() > 0) {
                Programs__C prog = progList.get(0);
                dealProgram = prog.Name;
            }
        }
        //THIS CAN BE ONE LINE THIS DATE THING
        if (sDate.Week__c != null) {
            fromDate = sDate.Week__c;
        } else {
            fromDate = Date.today().toStartOfWeek().addDays(1);
            sDate.Week__c = fromDate;
        }
        if (eDate.Week__c != null) {
            toDate = eDate.Week__c;
        } else {
            toDate = fromDate.addDays(6);
            eDate.Week__c = toDate;
        }
        
        
        if (con.AccountID != null) {
            string accountId = con.AccountID;

            list<account> accList = [SELECT id,name from Account where id = :accountId];

            if (accList.size() > 0) {
                Account acc = accList.get(0);
                dealKeyword = acc.name;
            }
        }

        System.debug('******' + fromDate + '***' + toDate);
        count = 0;
        loadDaysMap();
        loadDaysMapFull();
        headingModels = new List<HeadingModel>();

        scheduleList = new List<Schedules__c>();
        fbEntryModelList = new List<FBEntryModel>();
        fbEntryModelMap = new Map<String, List<FBEntryModel>>();
        fbModel = new List<FBModels>();

        date weekStart = fromDate.toStartofWeek().addDays(1);

        dealFMonth = String.ValueOf(toDate.month());
        dealFYear = String.valueOf(toDate.year());

        integer startDate = weekStart.daysBetween(fromDate);
        system.debug('### FD == ' + fromdate);
        system.debug('### TD == ' + todate);
        if (dealKeyword == null) {
            scheduleList = [
                    Select id,name,X2Calculated_Time_Period__c,LF_Daypart__c,Rate__c,LF_Week__c,
                            Long_Form__c,LF_Brand__c,X800_Number__c,day_of_week__c,Week__c, DealBrand__c,
                            DealAccount__c,Deal_Parent__r.Contact__r.AccountId
                    from Schedules__c
                    where DealProgram__c like :dealProgram AND Week__c >= :fromDate
                    AND Week__c <= :toDate AND COUNTMENOT__c = 'y'
                    AND status__c != 'Canceled'
                    ORDER BY LF_Daypart__c, Long_Form__c, Week__c, day_of_week__c asc
            ];
        } else {
            scheduleList = [
                    Select id,name,X2Calculated_Time_Period__c,LF_Daypart__c,Rate__c,LF_Week__c,
                            Long_Form__c,LF_Brand__c,X800_Number__c,day_of_week__c,Week__c, DealBrand__c,
                            DealAccount__c,Deal_Parent__r.Contact__r.AccountId
                    from Schedules__c
                    where DealProgram__c Like :dealProgram
                    AND Week__c >= :fromDate
                    AND Week__c <= :toDate AND COUNTMENOT__c = 'y' and status__c != 'Canceled'
                    AND DealAccount__c like :dealKeyword
                    ORDER BY LF_Daypart__c, Long_Form__c, Week__c, day_of_week__c asc
            ];
        }//AND Deal_Parent__r.Brands__r.name != 'Availability'
        system.debug('@@@@ Schedule List Size ==> ' + scheduleList.size());
        if (scheduleList.size() > 0) {
            hasRecords = true;
            integer days = fromDate.daysBetween(toDate);
            lstDayOfWeek = new List<String>();

            Integer dd = Integer.valueof(scheduleList.get(0).Day_of_Week__c.subString(0, 1));
            --dd;

            date tempDate = fromDate;

            integer counter = startDate;

            dKeys = new List<Date>();
            Map<Date, Integer> headings = new Map<Date, Integer>();
            Date lastSOW;

        //for every day from start date to end date
            for (date fDate = fromDate; fDate <= toDate; fDate = fDate.addDays(1)) {

                //Headers for PP Entry check
                String dayOfWeekString = getDayOfWeekFull(Math.mod(counter, 7) + 1) + '<br />' + fDate.format();

                lstDayOfWeek.add(dayOfWeekString);
                Date startOfWeek = fDate.toStartofWeek().addDays(1); //Fetching the first date of the week--First Monday
                integer cols = headings.get(startOfWeek);
                lastSOW = startOfWeek;

                if (Math.mod(counter, 7) + 1 == 7) {    //Sunday
                    Date sOW = fDate.addDays(-1).toStartofWeek().addDays(1);
                    cols = headings.get(sOW);

                    if (cols != null) {
                        cols++;
                        headings.put(sOW, cols);
                    } else {
                      //dKeys is list of Dates - start of week dates
                        dKeys.add(sOW);
                        headings.put(sOW, 1);
                    }
                    cols++;
                    headings.put(sOW, cols);

                    //lstDayOfWeek.add('Sub Total');
                    dd = 0;

                    //x--;
                } else {
                    if (cols != null) {
                        cols++;
                        headings.put(startOfWeek, cols);
                    } else {
                        dKeys.add(startOfWeek);
                        headings.put(startOfWeek, 1);
                    }
                    dd++;
                }
                counter++;
            }

            //Last Column
            if (dd != 0) {
                integer cols = headings.get(lastSOW);
                cols++;
                headings.put(lastSOW, cols);
                //lstDayOfWeek.add('Sub Total');
            }

            counter = startDate;

            for (date fDate : dKeys) {
                HeadingModel hm = new HeadingModel();
                //Date startOfWeek = fDate.toStartofWeek().addDays(1);
                hm.startOfWeek = fDate;
                integer cols = headings.get(fDate);
                hm.cols = String.valueOf(cols);
                headingModels.add(hm);
            }

            //Headers are complete


            //Create map of string keys with arays of schedules as values 
            Map<String, List<Schedules__c>> schedulesMap = new Map<String, List<Schedules__c>>();

            keys = new List<String>();

            Map<String, Map<String, FBEntryModel>> docEntryMap = new Map<String, Map<String, FBEntryModel>>();



          //iterate through schedules and create rows
            for (Schedules__c sc : scheduleList) {
                System.debug('====' + sc.X2Calculated_Time_Period__c + '====');
                FBEntryModel fb = new FBEntryModel();
                fb.schedule = sc;
                fb.recordCount = 1;
                fb.showEditable = true;
                fbEntryModelList.add(fb);


                //looks like FB Entry Model is maybe Flexbox or something for the individual cells 
                Map<String, FBEntryModel> docEntries = docEntryMap.get(sc.Long_Form__c);

                if (docEntries != null) {

                    FBEntryModel tempFb = docEntries.get(sc.Week__c + '-' + sc.Day_Of_Week__c);
                    if (tempFb != null) {
                        //Changed
                        System.Debug('@@@@Program is ' + fb.schedule.DealBrand__c);
                        if (fb.schedule.DealBrand__c != 'Availability') {
                            fb.rCount = tempFb.rCount + 1;
                        }
                        System.debug('####################### RecordCount===>' + fb.rCount);
                    } else {
                        fb.rCount = 1;
                        System.debug('######################/# RecordCount===>' + fb.rCount);
                    }

                    docEntries.put(sc.Week__c + '-' + sc.Day_Of_Week__c, fb);
                    System.debug('kkkk' + sc.Week__c + '-' + sc.Day_Of_Week__c);
                } else {
                    fb.rCount = 1;
                    docEntries = new Map<String, FBEntryModel>{
                            sc.Week__c + '-' + sc.Day_Of_Week__c => fb
                    };
                    docEntryMap.put(sc.Long_Form__c, docEntries);
                    //              if(keys.contains(sc.Long_Form__c)==false){
                    //                  System.debug('Key=='+sc.Long_Form__c);
                    keys.add(sc.Long_Form__c);
                    //                }
                }
            }

            totals = new List<ModelTotals>();
            integer sizeOfColumns = 0;
            for (HeadingModel hm : headingModels) {
                sizeOfColumns += Integer.valueOf(hm.cols);
            }

            for (integer c = 0; c <= sizeOfColumns; c++) {
                totals.add(new ModelTotals());
            }

            fbModel = new List<FBModels>();
            for (String key : Keys) {
                system.debug('## == ' + key);
                Map<String, FBEntryModel> docEntries = docEntryMap.get(key);
                List<FBEntryModel> fbEntries = new List<FBEntryModel>();
                FBModels fbm = new FBModels();
                counter = startDate;
                decimal sumOfRate = 0;
                integer recordCount = 0;
                decimal grandSumOfRate = 0;
                integer grandRecordCount = 0;

                integer tCounter = 0;

                for (date fDate = fromDate; fDate <= toDate; fDate = fDate.addDays(1)) {
                    String dowKey = fDate + '-' + getDayOfWeek(Math.mod(counter, 7) + 1);
                    system.debug('$$ == ' + dowKey);
                    FBEntryModel fbEM = docEntries.get(dowKey);
                    if (fbEM != null) {
                        system.debug('$$Found == ' + dowKey);
                        fbm.key = fbEM.schedule.Long_Form__c;
                        fbm.lfDayPart = fbEM.schedule.LF_DayPart__c;
                        fbEM.color = 'white';
                        fbEM.setWeek(fdate);
                        fbEM.isSubTotal = false;
                        fbem.showEditable = true;
                        sumOfRate += fbEM.schedule.Rate__c;
                        //Changed
                        if (fbEM.schedule.DealBrand__c != 'Availability') {
                            recordCount += fbEM.recordCount;
                        }
                        grandSumOfRate += fbEM.schedule.Rate__c;
                        if (fbEM.schedule.DealBrand__c != 'Availability') {
                            grandRecordCount += fbEM.recordCount;
                        }
                        totals[tCounter].sumOfRate += fbEM.schedule.Rate__c;
                        if (fbEM.schedule.DealBrand__c != 'Availability') {
                            totals[tCounter].recordCount += fbEM.recordCount;
                        }
                    } else {
                        system.debug('$$Not Found == ' + dowKey);
                        fbEM = new FBEntryModel();
                        fbEM.schedule = new Schedules__c(Rate__c = 0, week__c = fdate, Long_Form__c = key);
                        //fbEm.week = fDate;
                        fbEM.setWeek(fdate);
                        fbEM.sumOfRate = 0;
                        fbEM.isSubTotal = false;
                        fbEM.recordCount = 0;
                    }
                    fbEntries.add(fbEM);

                    //Get the sub total
                    if (Math.mod(counter, 7) + 1 == 7) {
                        FBEntryModel fbEM1 = new FBEntryModel();
                        fbEM1.schedule = new Schedules__c(Rate__c = sumOfRate);
/*                        if(recordCount>1){
                            fbEM1.color='rgb(84,194,84)';
                        }
                        else if(recordCount>1){
                            fbEM1.color='white';
                        }                    
*/
                        fbEM1.color = 'white';
                        fbEM1.sumOfRate = sumOfRate;
                        fbEM1.recordCount = recordCount;
                        fbEM1.isSubTotal = true;
                        //fbEntries.add(fbEM1);
                        dd = 0;
                        sumOfRate = 0;
                        recordCount = 0;
                        tCounter++;
                        totals[tCounter].sumOfRate += fbEM1.schedule.Rate__c;
                        if (fbEM1.schedule.DealBrand__c != 'Availability') {
                            totals[tCounter].recordCount += fbEM1.recordCount;
                        }
                        totals[tCounter].isSubTotal = true;
                    } else {
                        dd++;
                    }
                    counter++;
                    tCounter++;
                }

                //If last day of week is not sunday, then set the sub total
                if (dd != 0) {
                    FBEntryModel fbEM1 = new FBEntryModel();
                    fbEM1.schedule = new Schedules__c(Rate__c = sumOfRate);
                    if (recordCount > 0) {
                        fbEM1.color = 'white';
                    }
                    fbEM1.isSubTotal = true;
                    fbEM1.sumOfRate = sumOfRate;
                    fbEM1.recordCount = recordCount;
                    //fbEntries.add(fbEM1);


                    totals[tCounter].sumOfRate += fbEM1.schedule.Rate__c;
                    if (fbEM1.schedule.DealBrand__c != 'Availability') {
                        totals[tCounter].recordCount += fbEM1.recordCount;
                    }
                    totals[tCounter].isSubTotal = true;
                    tCounter++;
                }

                //Set Grand Total
                FBEntryModel fbGrandTotal = new FBEntryModel();
                fbGrandTotal.schedule = new Schedules__c();
                fbGrandTotal.sumOfRate = grandSumOfRate;
                fbGrandTotal.recordCount = grandRecordCount;

                fbm.fbEntryModels = fbEntries;
                fbm.grandTotal = fbGrandTotal;
                fbModel.add(fbm);
                //tCounter++;
                totals[tCounter].sumOfRate += fbGrandTotal.sumOfRate;
                totals[tCounter].recordCount += fbGrandTotal.recordCount;
                totals[tCounter].isSubTotal = true;
                sumGrandTotal += fbGrandTotal.sumOfRate;
                totalcount += fbGrandTotal.recordCount;

            }
        } else {
            hasRecords = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'List has no Rows'));
            headingModels = new List<headingModel>();
            lstDayOfWeek = new List<String>();
            fbModel = new List<FBModels>();
            totals = new List <ModelTotals>();
        }
        sid = '';
        slf = '';
        sWeek = '';
        return null;
//loop1------------
    }

    public void oneWeekLater() {
        sDate.Week__c = sDate.Week__c.addDays(7);
        eDate.Week__c = eDate.Week__c.addDays(7);
        showReport();
    }

    public void oneWeekBack() {
        sDate.Week__c = sDate.Week__c.addDays(-7);
        eDate.Week__c = eDate.Week__c.addDays(-7);
        showReport();
    }

    public PageReference save() {
        List <Schedules__c> lstUpdateSchedule = new List <Schedules__c>();

        for (FBModels fbmdl : fbModel) {
            if (fbmdl.chkbox == true) {
                for (FBEntryModel fbemdl : fbmdl.fbEntryModels) {
                    if (fbemdl.schedule.DealAccount__c != null)
                        lstUpdateSchedule.add(fbemdl.schedule);
                }
                fbmdl.chkbox = false;
                System.debug('#################Editable:' + fbmdl.chkbox);
            }
        }
        update lstUpdateSchedule;
        PageReference pr = new PageReference('/apex/DOCEntryCheck');
        pr.setRedirect(false);
        showReport();
        return null;
    }

    public void checkAll() {
        for (FBModels fbmdl : fbModel) {
            if (checks == true) {
                fbmdl.chkbox = true;
            } else
                    fbmdl.chkbox = false;
        }
    }
    public void createChangeLog() {
        // return new PageReference('/apex/CreateChangeLog?prg=DOC PP'+'&M='+toDate.Month()+'&Y='+toDate.Year());

        Boolean isNextMonth = false;
        Date nDate = toDate.toStartOfWeek().addDays(7);
        String prevDoc;
        if (nDate.month() < 10) {
            prevDoc = 'MVMS_DOC_0' + nDate.month() + '_' + nDate.Year();
        } else {
            prevDoc = 'MVMS_DOC_' + nDate.month() + '_' + nDate.Year();
        }

        List <Document> lstDocument = [select id,name from document where name like :prevDoc];
    }

    public class FBModels {
        public String lfDayPart { set; get; }
        public String key { get; set; }
        public List<FBEntryModel> fbEntryModels { get; set; }
        public FBEntryModel grandTotal { get; set; }
        public Decimal totalRate { get; set; }
        public Integer totalCount { get; set; }
        public Boolean chkbox { get; set; }
        FBModels() {
            chkbox = false;
        }
    }

    public class FBEntryModel {
        public Schedules__c schedule { get; set; }
        public boolean showEditable { set; get; }
        public integer wYear { set; get; }
        public integer wMonth { set; get; }
        public integer wDay { set; get; }
        public decimal sumOfRate { get; set; }
        public integer recordCount { get; set; }
        public integer rCount { get; set; }
        public boolean isSubTotal { get; set; }
        public string color { set; get; }
        public String getWeekStr() {
            return schedule.Week__c.Year() + '-' + schedule.Week__c.Month() + '-' + schedule.Week__c.Day();
        }

        public void setWeek(Date d) {
            wYear = d.year();
            wMonth = d.month();
            wDay = d.day();
            showEditable = false;
        }
        public FBEntryModel() {
            color = 'rgb(194,84,84)';
            sumOfRate = 0;
            recordCount = 0;
            schedule = new Schedules__c(rate__c = 0);
        }
    }

    public class ModelTotals {
        public double sumOfRate { set; get; }
        public integer recordCount { set; get; }
        public string color { set; get; }
        public boolean isSubTotal { get; set; }

        public ModelTotals() {
            sumOfRate = 0;
            recordCount = 0;
            color = 'red';
            isSubTotal = false;
        }
    }

    public class HeadingModel {
        public String cols { get; set; }
        public Date startOfWeek { get; set; }
    }
}

                                                
