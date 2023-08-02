public with sharing class DashboardReportwithFilterController {
    Integer day = 0;
    String lotNumber = '';
    Date deposit = null;
    String enquiry = '';
    Integer count_LastWeek = 0;
    Integer count_ThisWeek = 0;
    Integer count_ThisMonth = 0;
    Integer count_Verb_Hold = 0;
    public Integer top_verbals_hold { get; set; }
    public String searchKey {get;set;}
    public List<SelectOption> projectrecordsList {get;set;}
    public List<ReportWrapper> stockReport { get; set; }
    public List<EnquiryReportWrapper> enquiryReport { get; set; }
    public List<ContractDetailWrapper> offerWithListingReport { get; set; }
    public List<ContractDetailWrapper> contractForWeekReport { get; set; }
    public List<ContractDetailWrapper> cancelledDepositThisMonthReport { get; set; }
    public List<ContractDetailWrapper> cancelledContractLastWeekReport { get; set; }
    public List<ContractDetailWrapper> contractForMonthReport { get; set; }
    public List<EnquiryCountWrapper> lastWeekEnquiry { get; set; }
    public List<ContractWeekMonthWrapper> contractForWeekMonth { get; set; }
    public List<HoldListingWrapper> holdListingReport { get; set;}
    public List<ReservedContractWrapper> reservedContractReport { get; set; }
    public Date Today { get { return Date.today(); }}
    public Integer availableLand {get;set;}
    public Integer townhomes {get;set;}
    public Integer newdeposit {get;set;}
    public Date fltStartDate {get;set;}
    public Date fltEndDate {get;set;}
    public string render {get; set;}
    
    public DashboardReportwithFilterController(){
        if(ApexPages.currentPage().getParameters().get('startdate') != NULL){
            fltStartDate = Date.valueOf(ApexPages.currentPage().getParameters().get('startdate'));
        }
        if(ApexPages.currentPage().getParameters().get('enddate') != NULL){
            fltEndDate = Date.valueOf(ApexPages.currentPage().getParameters().get('enddate'));
        }
        if(ApexPages.currentPage().getParameters().get('searchKey') != NULL){
            searchKey = ApexPages.currentPage().getParameters().get('searchKey');
        }
        search();
    }

    public PageReference pdfpage(){
        String str = '/apex/DashboardReportwithFilterPDF?';
        if(fltStartDate != NULL){
            str += 'startdate='+fltStartDate;
        }
        if(fltEndDate != NULL){
            str += '&enddate='+fltEndDate;
        }
        if(searchKey != NULL || searchKey != ''){
            str += '&searchKey='+searchKey;
        }
        System.debug('str'+str);
        PageReference p = new PageReference(str);
        p.setRedirect(true);
        return p;
    }
    
    public void search(){
        try{
            day = 0;
            lotNumber = '';
            deposit = null;
            enquiry = '';
            count_LastWeek = 0;
            count_ThisWeek = 0;
            count_ThisMonth = 0;
            count_Verb_Hold = 0;
            top_verbals_hold = 0;
            availableLand = 0;
            townhomes = 0;
            newdeposit = 0;
            calculateCommonData();
            stockReport = getOffersDetails();
            enquiryReport = getEnquiryReport();
            offerWithListingReport = getOfferWithListingReport();
            contractForWeekReport = getContractForWeekReport();
            cancelledDepositThisMonthReport = getCancelledDepositThisMonthReport();
            cancelledContractLastWeekReport = getCancelledContractLastWeekReport();
            contractForMonthReport = getContractForMonthReport();
            lastWeekEnquiry = getLastWeekEnquiry();
            contractForWeekMonth = getContractForWeekMonth();
            holdListingReport = holdListingDetails();
            reservedContractReport = reservedContractDetails();
            projectrecordsList = new List<SelectOption>();
            List<pba__Property__c> pbaRecords = [SELECT Id, Name, RecordType.Name FROM pba__Property__c WHERE RecordType.Name = 'Project' WITH SECURITY_ENFORCED];
            if(pbaRecords.size() > 0){
               for(pba__Property__c p: pbaRecords){
                   projectrecordsList.add(new SelectOption(p.Id,p.Name));
               }
            }
        }catch(Exception e){
            System.debug('Exception-->'+e);
            System.debug('Exception-->'+e.getCause());
            System.debug('Exception-->'+e.getLineNumber());
            System.debug('Exception-->'+e.getMessage());
        }
    }

    public void reset(){
        fltStartDate = null;
        fltEndDate = null;
        search();
    }

    private void calculateCommonData() {
        try{
            String query = 'SELECT Id, Name, pba__Status__c, pba__PropertyType__c FROM pba__Listing__c';
            if(searchKey != NULL && searchKey != ''){
                query += ' WHERE Project_Unit__r.Name =\'' + searchKey + '\'';
            }
            List<pba__Listing__c> listOfListingStatus = Database.query(query);
            for (pba__Listing__c li : listOfListingStatus) {
                if(li.pba__Status__c == 'On Hold'){
                    top_verbals_hold++;
                }
                if(li.pba__Status__c == 'Available' && (li.pba__PropertyType__c != 'Residential' && li.pba__PropertyType__c != 'Project')){
                    availableLand++;
                }
                if(li.pba__Status__c == 'Available' && li.pba__PropertyType__c == 'Residential'){
                    townhomes++;
                }
            }
        }catch(Exception e){
            System.debug('Exception-->'+e);
            System.debug('Exception-->'+e.getCause());
            System.debug('Exception-->'+e.getLineNumber());
            System.debug('Exception-->'+e.getMessage());
        }
    }


    public List<ContractWeekMonthWrapper> getContractForWeekMonth() {
        try{
            String Query = 'SELECT Name, pba__ListingType__c FROM pba__Request__c WHERE pba__ListingType__c = \'Sale\' AND CreatedDate = THIS_WEEK';
            String contrMonthQuery = 'SELECT Name, pba__ListingType__c FROM pba__Request__c WHERE pba__ListingType__c = \'Sale\' AND CreatedDate = THIS_MONTH';
            String listOfOfferWeekquery = 'SELECT Id, Name, Cancellation_Date__c, pba__Status__c FROM pba__Offer__c WHERE Cancellation_Date__c = LAST_WEEK AND Previous_Status__c = \'Reserved\'';
            String listOfOfferMonthquery = 'SELECT Id, Name, Cancellation_Date__c, pba__Status__c FROM pba__Offer__c WHERE Cancellation_Date__c = THIS_MONTH AND Previous_Status__c = \'Reserved\'';
            String listOfListingWeekQuery = 'SELECT Name, pba__Status__c FROM pba__Listing__c WHERE pba__Status__c = \'On Hold\' AND Hold_Expiration_Date__c = THIS_WEEK';
            String listOfListingMonthQuery = 'SELECT Name, pba__Status__c FROM pba__Listing__c WHERE pba__Status__c =\'On Hold\' AND Hold_Expiration_Date__c = THIS_MONTH';
            if(fltStartDate != null){
                Query = Query.remove('AND CreatedDate = THIS_WEEK');
                Query += ' AND CreatedDate >: fltStartDate';
    
                contrMonthQuery = contrMonthQuery.remove('AND CreatedDate = THIS_MONTH');
                contrMonthQuery += ' AND CreatedDate >: fltStartDate';
    
                listOfOfferWeekquery = listOfOfferWeekquery.remove('Cancellation_Date__c = LAST_WEEK AND');
                listOfOfferWeekquery += ' AND Cancellation_Date__c >: fltStartDate';
    
                listOfOfferMonthquery = listOfOfferMonthquery.remove('Cancellation_Date__c = THIS_MONTH AND');
                listOfOfferMonthquery += ' AND Cancellation_Date__c >: fltStartDate';
    
                listOfListingWeekQuery = listOfListingWeekQuery.remove('AND Hold_Expiration_Date__c = THIS_WEEK');
                listOfListingWeekQuery += ' AND Hold_Expiration_Date__c >: fltStartDate';
    
                listOfListingMonthQuery = listOfListingMonthQuery.remove('AND Hold_Expiration_Date__c = THIS_MONTH');
                listOfListingMonthQuery += ' AND Hold_Expiration_Date__c >: fltStartDate';
            }
            if(fltEndDate != null){
                Query += ' AND CreatedDate <: fltEndDate';
                contrMonthQuery += ' AND CreatedDate <: fltEndDate';
                listOfOfferWeekquery += ' AND Cancellation_Date__c <: fltEndDate';
                listOfOfferMonthquery += ' AND Cancellation_Date__c <: fltEndDate';
                listOfListingWeekQuery += ' AND Hold_Expiration_Date__c <: fltEndDate';
                listOfListingMonthQuery += ' AND Hold_Expiration_Date__c <: fltEndDate';
            }
            if(searchKey != NULL && searchKey != ''){
                query += ' AND Project_Look_Up__r.Name =\'' + searchKey + '\'';
                contrMonthQuery += ' AND Project_Look_Up__r.Name =\'' + searchKey + '\'';
                listOfOfferWeekquery += ' AND Project_Look_Up__r.Name =\'' + searchKey + '\'';
                listOfOfferMonthquery += ' AND Project_Look_Up__r.Name =\'' + searchKey + '\'';
                listOfListingWeekQuery += ' AND Project_Unit__r.Name =\'' + searchKey + '\'';
                listOfListingMonthQuery += ' AND Project_Unit__r.Name =\'' + searchKey + '\'';
            }
            List<pba__Request__c> listOfContractForWeek = Database.query(Query);
            List<pba__Request__c> listOfContractForMonth = Database.query(contrMonthQuery);
    
    
            List<pba__Offer__c> listOfOfferWeek = Database.query(listOfOfferWeekquery);
            List<pba__Offer__c> listOfOfferMonth = Database.query(listOfOfferMonthquery);
    
            List<pba__Listing__c> listOfListingWeek =  Database.query(listOfListingWeekQuery);
            List<pba__Listing__c> listOfListingMonth = Database.query(listOfListingMonthQuery);
    
    
            List<ContractWeekMonthWrapper> ContractWrapper = new List<ContractWeekMonthWrapper>();
    
            ContractWeekMonthWrapper contractWeekWrapper = new ContractWeekMonthWrapper('Result For The Week', 0, 0, 0, 0, 0, 0, 0, 0, 0);
            ContractWeekMonthWrapper contractMonthWrapper = new ContractWeekMonthWrapper('Month To Date', 0, 0, 0, 0, 0, 0, 0, 0, 0);
    
            for (pba__Request__c con : listOfContractForWeek) {
                contractWeekWrapper.Sales++;
            }
            for (pba__Request__c con : listOfContractForMonth) {
                contractMonthWrapper.Sales++;
            }
            for (pba__Offer__c offer : listOfOfferWeek) {
                contractWeekWrapper.deposit_cancellation++;
            }
            for (pba__Offer__c offer1 : listOfOfferMonth) {
                contractMonthWrapper.deposit_cancellation++;
            }
    
            for (pba__Listing__c lis : listOfListingWeek) {
                contractWeekWrapper.verbal_hold++;
            }
            for (pba__Listing__c lis : listOfListingMonth) {
                contractMonthWrapper.verbal_hold++;
            }
    
            contractWeekWrapper.total_enquiry = contractWeekWrapper.Sales + contractWeekWrapper.deposit_cancellation + contractWeekWrapper.verbal_hold;
            contractMonthWrapper.total_enquiry = contractMonthWrapper.Sales + contractMonthWrapper.deposit_cancellation + contractMonthWrapper.verbal_hold;
    
            ContractWrapper.add(contractWeekWrapper);
            ContractWrapper.add(contractMonthWrapper);
            newdeposit = contractWeekWrapper.new_deposit;
            return ContractWrapper;
        }catch(Exception e){
            System.debug('Exception-->'+e);
            System.debug('Exception-->'+e.getCause());
            System.debug('Exception-->'+e.getLineNumber());
            System.debug('Exception-->'+e.getMessage());
            return null;
        }
    }
    public List<EnquiryCountWrapper> getLastWeekEnquiry() {
        try{
            String listOfLastWeekEnquiriesquery = 'SELECT Id, Name, Enquiry_Source__c, CreatedDate FROM pba__Request__c WHERE CreatedDate = LAST_WEEK';
            String listOfThisWeekEnquiriesquery = 'SELECT Id, Name, Enquiry_Source__c, CreatedDate FROM pba__Request__c WHERE CreatedDate = THIS_WEEK';
            String listOfThisMonthEnquiriesquery = 'SELECT Id, Name, Enquiry_Source__c, CreatedDate FROM pba__Request__c WHERE CreatedDate = THIS_MONTH';
            String listOfListingStatusquery = 'SELECT Name, pba__Status__c FROM pba__Listing__c WHERE pba__ListingType__c = \'Sale\'';
            if(fltStartDate != null){
                listOfLastWeekEnquiriesquery = listOfLastWeekEnquiriesquery.remove('CreatedDate = LAST_WEEK');
                listOfLastWeekEnquiriesquery += 'CreatedDate >: fltStartDate';
    
                listOfThisWeekEnquiriesquery = listOfThisWeekEnquiriesquery.remove('CreatedDate = THIS_WEEK');
                listOfThisWeekEnquiriesquery += 'CreatedDate >: fltStartDate';
    
                listOfThisMonthEnquiriesquery = listOfThisMonthEnquiriesquery.remove('CreatedDate = THIS_MONTH');
                listOfThisMonthEnquiriesquery += 'CreatedDate >: fltStartDate';
            }
    
            if(fltEndDate != null){
                listOfLastWeekEnquiriesquery += ' AND CreatedDate <: fltEndDate';
                listOfThisWeekEnquiriesquery += ' AND CreatedDate <: fltEndDate';
                listOfThisMonthEnquiriesquery += ' AND CreatedDate <: fltEndDate';
            }
    
            if(searchKey != NULL && searchKey != ''){
                listOfLastWeekEnquiriesquery += ' AND Project_Look_Up__r.Name =\'' + searchKey + '\'';
                listOfThisWeekEnquiriesquery += ' AND Project_Look_Up__r.Name =\'' + searchKey + '\'';
                listOfThisMonthEnquiriesquery += ' AND Project_Look_Up__r.Name =\'' + searchKey + '\'';
                listOfListingStatusquery += ' AND Project_Unit__r.Name =\'' + searchKey + '\'';
            }
    
            List<pba__Request__c> listOfLastWeekEnquiries = Database.query(listOfLastWeekEnquiriesquery);
    
            List<pba__Request__c> listOfThisWeekEnquiries = Database.query(listOfThisWeekEnquiriesquery);
    
            List<pba__Request__c> listOfThisMonthEnquiries = Database.query(listOfThisMonthEnquiriesquery);
    
            List<pba__Listing__c> listOfListingStatus = Database.query(listOfListingStatusquery);
    
            List<EnquiryCountWrapper> enquiryLastWeekWrapper = new List<EnquiryCountWrapper>();
    
            Date WeekEnd_Date = Date.today();
    
            if (System.now().format('EEE') == 'Mon') {
                day = 2;
                WeekEnd_Date = Date.today() + (-day);
    
            } else if (System.now().format('EEE') == 'Tue') {
                day = 3;
                WeekEnd_Date = Date.today() + (-day);
    
            } else if (System.now().format('EEE') == 'Wed') {
                day = 4;
                WeekEnd_Date = Date.today() + (-day);
    
            } else if (System.now().format('EEE') == 'Thu') {
                day = 5;
                WeekEnd_Date = Date.today() + (-day);
    
            } else if (System.now().format('EEE') == 'Fri') {
                day = 6;
                WeekEnd_Date = Date.today() + (-day);
    
            } else if (System.now().format('EEE') == 'Sat') {
                day = 7;
                WeekEnd_Date = Date.today() + (-day);
    
            } else if (System.now().format('EEE') == 'Sun') {
                day = 8;
                WeekEnd_Date = Date.today() + (-day);
            }
    
            for (pba__Request__c enq : listOfLastWeekEnquiries) {
                count_LastWeek++;
            }
            for (pba__Request__c enq : listOfThisWeekEnquiries) {
                count_ThisWeek++;
            }
            for (pba__Request__c enq : listOfThisMonthEnquiries) {
                count_ThisMonth++;
            }
            for (pba__Listing__c li : listOfListingStatus) {
                if (li.pba__Status__c == 'On Hold') {
                    count_Verb_Hold++;
                }
            }
    
            System.debug(WeekEnd_Date);
    
            EnquiryCountWrapper enquiryCountWrapper = new EnquiryCountWrapper('', 0, null, 0);
            enquiryCountWrapper.enquiry = 'Leads';
            enquiryCountWrapper.enquiry_count = count_LastWeek;
            enquiryCountWrapper.Week_Ending = WeekEnd_Date;
            enquiryCountWrapper.verbal_hold = count_Verb_Hold;
            enquiryLastWeekWrapper.add(enquiryCountWrapper);
            return enquiryLastWeekWrapper;
        }catch(Exception e){
            System.debug('Exception-->'+e);
            System.debug('Exception-->'+e.getCause());
            System.debug('Exception-->'+e.getLineNumber());
            System.debug('Exception-->'+e.getMessage());
            return null;
        }
    }

    public List<ContractDetailWrapper> getContractForMonthReport() {
        try{
            String query = 'SELECT Price__c, Cancellation_Date__c, pba_ap__Purchaser_Name__c, pba__Listing__r.Name, pba__Listing__r.pba_ausfields__Lot_Number__c, pba__Listing__r.pba__ListingPrice_pb__c, Balance_of_Deposit_Paid_Date__c, Contract_Date__c, Enquiry_Source__c FROM pba__Offer__c WHERE Contract_Date__c = THIS_MONTH';
            if(fltStartDate != null){
                query = query.remove('Contract_Date__c = THIS_MONTH');
                query += 'CreatedDate >: fltStartDate';
            }
    
            if(fltEndDate != null){
                query += ' AND CreatedDate <: fltEndDate';
            }
    
            if(searchKey != NULL && searchKey != ''){
                query += ' AND Project_Look_Up__r.Name =\'' + searchKey + '\'';
            }
            List<pba__Offer__c> listOfContractForMonth = Database.query(query);
    
            List<ContractDetailWrapper> contractForMonthWrappers = new List<ContractDetailWrapper>();
            Decimal Totalprice = 0;
            for (pba__Offer__c offerContractForMonth : listOfContractForMonth) {
    
                ContractDetailWrapper contractForMonthWrapper = new ContractDetailWrapper(offerContractForMonth);
    
                contractForMonthWrapper.purchaser_Name = offerContractForMonth.pba_ap__Purchaser_Name__c;
                contractForMonthWrapper.lot_number = offerContractForMonth.pba__Listing__r.Name;
                contractForMonthWrapper.deposit = offerContractForMonth.Balance_of_Deposit_Paid_Date__c;
                contractForMonthWrapper.contract_date = offerContractForMonth.Contract_Date__c;
                contractForMonthWrapper.list_price = offerContractForMonth.Price__c;
                contractForMonthWrapper.enquiry_source = offerContractForMonth.Enquiry_Source__c;
    
                if(offerContractForMonth.Price__c != NULL){
                    Totalprice += offerContractForMonth.Price__c;
                }
                // subtotal.purchaser_Name = 'Total';
                // subtotal.lot_number = lotNumber;
                // subtotal.deposit = deposit;
                // subtotal.contract_date = deposit;
                // subtotal.list_price = offerContractForMonth.Price__c++;
                // subtotal.enquiry_source = enquiry;
    
                contractForMonthWrappers.add(contractForMonthWrapper);
            }
            if(contractForMonthWrappers.size()>0){
                ContractDetailWrapper subtotal = new ContractDetailWrapper();
                subtotal.purchaser_Name = 'Total';
                subtotal.lot_number = lotNumber;
                subtotal.deposit = deposit;
                subtotal.contract_date = deposit;
                subtotal.list_price = Totalprice;
                subtotal.enquiry_source = enquiry;
                contractForMonthWrappers.add(subtotal);
            }
            return contractForMonthWrappers;
        }catch(Exception e){
            System.debug('Exception-->'+e);
            System.debug('Exception-->'+e.getCause());
            System.debug('Exception-->'+e.getLineNumber());
            System.debug('Exception-->'+e.getMessage());
            return null;
        }
    }

    public List<ContractDetailWrapper> getCancelledContractLastWeekReport() {
        try{
            String query = 'SELECT Price__c, Cancellation_Date__c, pba_ap__Purchaser_Name__c, pba__Listing__r.Name, pba__Listing__r.pba_ausfields__Lot_Number__c, pba__Listing__r.pba__ListingPrice_pb__c, Balance_of_Deposit_Paid_Date__c, Contract_Date__c, Enquiry_Source__c FROM pba__Offer__c WHERE (Previous_Status__c = \'Contracted\' OR Previous_Status__c = \'Unconditional\') AND Cancellation_Date__c = THIS_MONTH';
            if(fltStartDate != null){
                query = query.remove('Cancellation_Date__c = THIS_MONTH');
                query += 'Cancellation_Date__c >: fltStartDate';
            }
    
            if(fltEndDate != null){
                query += ' AND Cancellation_Date__c <: fltEndDate';
            }
    
            if(searchKey != NULL && searchKey != ''){
                query += ' AND Project_Look_Up__r.Name =\'' + searchKey + '\'';
            }
            List<pba__Offer__c> listOfCancelledContractLastWeek = Database.query(query);
    
            List<ContractDetailWrapper> cancelledContractLastWeekWrappers = new List<ContractDetailWrapper>();
            Decimal Totalprice = 0;
            for (pba__Offer__c offerlistOfCancelledContractLastWeek : listOfCancelledContractLastWeek) {
    
                ContractDetailWrapper cancelledContractLastWeekWrapper = new ContractDetailWrapper(offerlistOfCancelledContractLastWeek);
    
                cancelledContractLastWeekWrapper.purchaser_Name = offerlistOfCancelledContractLastWeek.pba_ap__Purchaser_Name__c;
                cancelledContractLastWeekWrapper.lot_number = offerlistOfCancelledContractLastWeek.pba__Listing__r.Name;
                cancelledContractLastWeekWrapper.contract_date = offerlistOfCancelledContractLastWeek.Contract_Date__c;
                cancelledContractLastWeekWrapper.cancellation_date = offerlistOfCancelledContractLastWeek.Cancellation_Date__c;
                cancelledContractLastWeekWrapper.list_price = offerlistOfCancelledContractLastWeek.Price__c;
                cancelledContractLastWeekWrapper.enquiry_source = offerlistOfCancelledContractLastWeek.Enquiry_Source__c;
                cancelledContractLastWeekWrapper.deposit = offerlistOfCancelledContractLastWeek.Balance_of_Deposit_Paid_Date__c;
                
                if(offerlistOfCancelledContractLastWeek.Price__c != NULL){
                    Totalprice += offerlistOfCancelledContractLastWeek.Price__c;
                }
                // subtotal.purchaser_Name = 'Total';
                // subtotal.lot_number = lotNumber;
                // subtotal.deposit = deposit;
                // subtotal.contract_date = deposit;
                // subtotal.cancellation_date = deposit;
                // subtotal.list_price = offerlistOfCancelledContractLastWeek.Price__c++;
                // subtotal.enquiry_source = enquiry;
    
                cancelledContractLastWeekWrappers.add(cancelledContractLastWeekWrapper);
            }
            if(cancelledContractLastWeekWrappers.size()>0){
                ContractDetailWrapper subtotal = new ContractDetailWrapper();
                subtotal.purchaser_Name = 'Total';
                subtotal.lot_number = lotNumber;
                subtotal.deposit = deposit;
                subtotal.contract_date = deposit;
                subtotal.cancellation_date = deposit;
                subtotal.list_price = Totalprice;
                subtotal.enquiry_source = enquiry;
                cancelledContractLastWeekWrappers.add(subtotal);
            }
            return cancelledContractLastWeekWrappers;
        }catch(Exception e){
            System.debug('Exception-->'+e);
            System.debug('Exception-->'+e.getCause());
            System.debug('Exception-->'+e.getLineNumber());
            System.debug('Exception-->'+e.getMessage());
            return null;
        }
    }

    public List<ContractDetailWrapper> getCancelledDepositThisMonthReport() {
        try{
            String query = 'SELECT pba__Status__c, Price__c, Cancellation_Date__c, pba_ap__Purchaser_Name__c, pba__Listing__r.Name, pba__Listing__r.pba_ausfields__Lot_Number__c, pba__Listing__r.pba__ListingPrice_pb__c, Balance_of_Deposit_Paid_Date__c, Contract_Date__c, Enquiry_Source__c FROM pba__Offer__c WHERE Previous_Status__c = \'Reserved\' AND Cancellation_Date__c = THIS_MONTH';
            if(fltStartDate != null){
                query = query.remove('Cancellation_Date__c = THIS_MONTH');
                query += 'Cancellation_Date__c >: fltStartDate';
            }
    
            if(fltEndDate != null){
                query += ' AND Cancellation_Date__c <: fltEndDate';
            }
    
            if(searchKey != NULL && searchKey != ''){
                query += ' AND Project_Look_Up__r.Name =\'' + searchKey + '\'';
            }
            List<pba__Offer__c> listOfCancelledDepositThisMonth = Database.query(query);
    
            List<ContractDetailWrapper> CancelledDepositThisMonthWrappers = new List<ContractDetailWrapper>();
            Decimal Totalprice = 0;
            for (pba__Offer__c offerCancelledDepositThisMonth : listOfCancelledDepositThisMonth) {
    
                ContractDetailWrapper cancelledDepositThisMonthWrapper = new ContractDetailWrapper(offerCancelledDepositThisMonth);
                ContractDetailWrapper subtotal = new ContractDetailWrapper(offerCancelledDepositThisMonth);
    
                cancelledDepositThisMonthWrapper.purchaser_Name = offerCancelledDepositThisMonth.pba_ap__Purchaser_Name__c;
                cancelledDepositThisMonthWrapper.lot_number = offerCancelledDepositThisMonth.pba__Listing__r.Name;
                cancelledDepositThisMonthWrapper.contract_date = offerCancelledDepositThisMonth.Contract_Date__c;
                cancelledDepositThisMonthWrapper.cancellation_date = offerCancelledDepositThisMonth.Cancellation_Date__c;
                cancelledDepositThisMonthWrapper.list_price = offerCancelledDepositThisMonth.Price__c;
                cancelledDepositThisMonthWrapper.enquiry_source = offerCancelledDepositThisMonth.Enquiry_Source__c;
                cancelledDepositThisMonthWrapper.deposit = offerCancelledDepositThisMonth.Balance_of_Deposit_Paid_Date__c;
                
                if(offerCancelledDepositThisMonth.Price__c != NULL){
                    Totalprice += offerCancelledDepositThisMonth.Price__c;
                }
                // subtotal.purchaser_Name = 'Total';
                // subtotal.lot_number = lotNumber;
                // subtotal.deposit = deposit;
                // subtotal.contract_date = deposit;
                // subtotal.cancellation_date = deposit;
                // subtotal.list_price = offerCancelledDepositThisMonth.Price__c++;
                // subtotal.enquiry_source = enquiry;
    
                CancelledDepositThisMonthWrappers.add(cancelledDepositThisMonthWrapper);
                CancelledDepositThisMonthWrappers.add(subtotal);
            }
            if(CancelledDepositThisMonthWrappers.size()>0){
                ContractDetailWrapper subtotal = new ContractDetailWrapper();
                subtotal.purchaser_Name = 'Total';
                subtotal.lot_number = lotNumber;
                subtotal.deposit = deposit;
                subtotal.contract_date = deposit;
                subtotal.cancellation_date = deposit;
                subtotal.list_price = Totalprice;
                subtotal.enquiry_source = enquiry; 
                CancelledDepositThisMonthWrappers.add(subtotal);
            }
            return CancelledDepositThisMonthWrappers;
        }catch(Exception e){
            System.debug('Exception-->'+e);
            System.debug('Exception-->'+e.getCause());
            System.debug('Exception-->'+e.getLineNumber());
            System.debug('Exception-->'+e.getMessage());
            return null;
        }
    }

    public List<ContractDetailWrapper> getContractForWeekReport() {
        try{
            String query = 'SELECT Price__c, Cancellation_Date__c, pba_ap__Purchaser_Name__c, pba__Listing__r.Name, pba__Listing__r.pba_ausfields__Lot_Number__c, pba__Listing__r.pba__ListingPrice_pb__c, Balance_of_Deposit_Paid_Date__c, Contract_Date__c, Enquiry_Source__c FROM pba__Offer__c WHERE Contract_Date__c = LAST_WEEK';
            if(fltStartDate != null){
                query = query.remove('Contract_Date__c = LAST_WEEK');
                query += 'Contract_Date__c >: fltStartDate';
            }
    
            if(fltEndDate != null){
                query += ' AND Contract_Date__c <: fltEndDate';
            }
    
            if(searchKey != NULL && searchKey !=''){
                query += ' AND Project_Look_Up__r.Name =\'' + searchKey + '\'';
            }
            List<pba__Offer__c> listOfOfferContractForWeek = Database.query(query);
            List<ContractDetailWrapper> listOfOfferContractForWeekWrappers = new List<ContractDetailWrapper>();
            Decimal Totalprice = 0;
            for (pba__Offer__c offerContractForWeek : listOfOfferContractForWeek) {
    
                ContractDetailWrapper listOfOfferContractForWeekWrapper = new ContractDetailWrapper(offerContractForWeek);
                listOfOfferContractForWeekWrapper.purchaser_Name = offerContractForWeek.pba_ap__Purchaser_Name__c;
                listOfOfferContractForWeekWrapper.lot_number = offerContractForWeek.pba__Listing__r.Name;
                listOfOfferContractForWeekWrapper.deposit = offerContractForWeek.Balance_of_Deposit_Paid_Date__c;
                listOfOfferContractForWeekWrapper.contract_date = offerContractForWeek.Contract_Date__c;
                listOfOfferContractForWeekWrapper.list_price = offerContractForWeek.Price__c;
                listOfOfferContractForWeekWrapper.enquiry_source = offerContractForWeek.Enquiry_Source__c;            
                if(offerContractForWeek.Price__c != NULL){
                    Totalprice += offerContractForWeek.Price__c;
                }
                listOfOfferContractForWeekWrappers.add(listOfOfferContractForWeekWrapper);
            }
            if(listOfOfferContractForWeekWrappers.size()>0){
                ContractDetailWrapper total = new ContractDetailWrapper();
                total.purchaser_Name = 'Total';
                total.lot_number = lotNumber;
                total.deposit = deposit;
                total.contract_date = deposit;
                total.list_price = Totalprice;
                total.enquiry_source = enquiry;
                listOfOfferContractForWeekWrappers.add(total);
            }
            return listOfOfferContractForWeekWrappers;
        }catch(Exception e){
            System.debug('Exception-->'+e);
            System.debug('Exception-->'+e.getCause());
            System.debug('Exception-->'+e.getLineNumber());
            System.debug('Exception-->'+e.getMessage());
            return null;
        }
    }

    public List<ContractDetailWrapper> getOfferWithListingReport() {
        try{
            String query = 'SELECT Forecast_Contract_Date__c, Price__c, Cancellation_Date__c, pba_ap__Purchaser_Name__c, pba__Listing__r.Name, pba__Listing__r.pba__ListingPrice_pb__c, pba__Listing__r.pba_ausfields__Lot_Number__c, Balance_of_Deposit_Paid_Date__c, Contract_Date__c, Enquiry_Source__c FROM pba__Offer__c WHERE (Initial_Deposit_Paid_Date__c = LAST_WEEK OR Balance_of_Deposit_Paid_Date__c = LAST_WEEK)';
            if(fltStartDate != null && fltEndDate != null){
                query = query.remove('(Initial_Deposit_Paid_Date__c = LAST_WEEK OR Balance_of_Deposit_Paid_Date__c = LAST_WEEK)');
                query += '((Initial_Deposit_Paid_Date__c >: fltStartDate AND Initial_Deposit_Paid_Date__c <: fltEndDate) OR (Balance_of_Deposit_Paid_Date__c >: fltStartDate AND Balance_of_Deposit_Paid_Date__c <: fltEndDate))';
            }else if(fltStartDate != null && fltEndDate == null){
                query = query.remove('(Initial_Deposit_Paid_Date__c = LAST_WEEK OR Balance_of_Deposit_Paid_Date__c = LAST_WEEK)');
                query += '(Initial_Deposit_Paid_Date__c >: fltStartDate OR Balance_of_Deposit_Paid_Date__c >: fltStartDate)';
            }else if(fltStartDate == null && fltEndDate != null){
                query = query.remove('(Initial_Deposit_Paid_Date__c = LAST_WEEK OR Balance_of_Deposit_Paid_Date__c = LAST_WEEK)');
                query += '(Initial_Deposit_Paid_Date__c <: fltEndDate OR Balance_of_Deposit_Paid_Date__c <: fltEndDate)';
            }
    
            if(searchKey != NULL && searchKey !=''){
                query += ' AND Project_Look_Up__r.Name =\'' + searchKey + '\'';
            }
            List<pba__Offer__c> listOfOfferWithListing = Database.query(query);
    
            List<ContractDetailWrapper> listOfOfferWithListingWrappers = new List<ContractDetailWrapper>();
            Decimal Totalprice = 0;
            for (pba__Offer__c offer : listOfOfferWithListing) {
    
                ContractDetailWrapper listOfOfferWithListingWrapper = new ContractDetailWrapper(offer);
                ContractDetailWrapper subtotal = new ContractDetailWrapper(offer);
    
                listOfOfferWithListingWrapper.purchaser_Name = offer.pba_ap__Purchaser_Name__c;
                listOfOfferWithListingWrapper.lot_number = offer.pba__Listing__r.Name;
                listOfOfferWithListingWrapper.deposit = offer.Balance_of_Deposit_Paid_Date__c;
                listOfOfferWithListingWrapper.list_price = offer.Price__c;
                listOfOfferWithListingWrapper.enquiry_source = offer.Enquiry_Source__c;
                listOfOfferWithListingWrapper.forecast_Contract_Date = offer.Forecast_Contract_Date__c;
                if(offer.Price__c != NULL){
                    Totalprice += offer.Price__c;
                }
                // subtotal.purchaser_Name = 'Total';
                // subtotal.lot_number = lotNumber;
                // subtotal.deposit = deposit;
                // subtotal.list_price = offer.Price__c++;
                // subtotal.enquiry_source = enquiry;
                listOfOfferWithListingWrappers.add(listOfOfferWithListingWrapper);
            }
            if(listOfOfferWithListingWrappers.size()>0){
                ContractDetailWrapper subtotal = new ContractDetailWrapper();
                subtotal.purchaser_Name = 'Total';
                subtotal.lot_number = lotNumber;
                subtotal.deposit = deposit;
                subtotal.list_price = Totalprice;
                subtotal.enquiry_source = enquiry;
                listOfOfferWithListingWrappers.add(subtotal);
            }
            return listOfOfferWithListingWrappers;
        }catch(Exception e){
            System.debug('Exception-->'+e);
            System.debug('Exception-->'+e.getCause());
            System.debug('Exception-->'+e.getLineNumber());
            System.debug('Exception-->'+e.getMessage());
            return null;
        }
    }

    public List<EnquiryReportWrapper> getEnquiryReport() {
        try{
            String Query = 'SELECT Name, Enquiry_Source__c, CreatedDate FROM pba__Request__c LIMIT 100';
            if(searchKey != NULL && searchKey != ''){
                Query = Query.removeEnd('100');
                Query = Query.remove('LIMIT');
                Query += 'WHERE Project_Look_Up__r.Name =\'' + searchKey + '\' LIMIT 100';
            }
            List<pba__Request__c> listEnquiries = Database.query(Query);
    
            Map<String, EnquiryReportWrapper> mapOfEnquiryReportWrapper = new Map<String, EnquiryReportWrapper>();
            List<EnquiryReportWrapper> EnquiryReportWrapperWrappers = new List<EnquiryReportWrapper>();
    
            EnquiryReportWrapper subtotal = new EnquiryReportWrapper('Total', 0, 0, 0, 0, 0, 0, 0);
    
            for (pba__Request__c enq : listEnquiries) {
                if (!mapOfEnquiryReportWrapper.containsKey(enq.Enquiry_Source__c)) {
                    mapOfEnquiryReportWrapper.put(enq.Enquiry_Source__c, new EnquiryReportWrapper('', 0, 0, 0, 0, 0, 0, 0));
                }
                mapOfEnquiryReportWrapper.get(enq.Enquiry_Source__c).enquiry_detail = enq.Enquiry_Source__c;
                System.debug(enq.CreatedDate.format('EEE'));
    
                if (enq.CreatedDate.format('EEE') == 'Mon') {
                    mapOfEnquiryReportWrapper.get(enq.Enquiry_Source__c).monday++;
                    subtotal.monday++;
    
                } else if (enq.CreatedDate.format('EEE') == 'Tue') {
                    mapOfEnquiryReportWrapper.get(enq.Enquiry_Source__c).tuesday++;
                    subtotal.tuesday++;
    
                } else if (enq.CreatedDate.format('EEE') == 'Wed') {
                    mapOfEnquiryReportWrapper.get(enq.Enquiry_Source__c).wednesday++;
                    subtotal.wednesday++;
    
                } else if (enq.CreatedDate.format('EEE') == 'Thu') {
                    mapOfEnquiryReportWrapper.get(enq.Enquiry_Source__c).thursday++;
                    subtotal.thursday++;
    
                } else if (enq.CreatedDate.format('EEE') == 'Fri') {
                    mapOfEnquiryReportWrapper.get(enq.Enquiry_Source__c).friday++;
                    subtotal.friday++;
    
                } else if (enq.CreatedDate.format('EEE') == 'Sat') {
                    mapOfEnquiryReportWrapper.get(enq.Enquiry_Source__c).saturday++;
                    subtotal.saturday++;
    
                } else if (enq.CreatedDate.format('EEE') == 'Sun') {
                    mapOfEnquiryReportWrapper.get(enq.Enquiry_Source__c).sunday++;
                    subtotal.sunday++;
                }
            }
            system.debug(mapOfEnquiryReportWrapper.values());
            for (EnquiryReportWrapper erw : mapOfEnquiryReportWrapper.values()) {
                EnquiryReportWrapperWrappers.add(erw);
            }
            EnquiryReportWrapperWrappers.add(subtotal);
            return EnquiryReportWrapperWrappers;
        }catch(Exception e){
            System.debug('Exception-->'+e);
            System.debug('Exception-->'+e.getCause());
            System.debug('Exception-->'+e.getLineNumber());
            System.debug('Exception-->'+e.getMessage());
            return null;
        }
    }

    public List<ReportWrapper> getOffersDetails() {
        try{
            String Query = 'SELECT Id, pba__Listing__r.Stage_Unit__c, pba__Listing__r.Id, pba__Listing__r.Name, pba__Listing__r.pba__Status__c, pba__Listing__r.Stage_Unit__r.Name, Name, pba__Status__c FROM pba__Offer__c LIMIT 100';
            if(searchKey != NULL && searchKey != ''){
                Query = Query.removeEnd('100');
                Query = Query.remove('LIMIT');
                Query += 'WHERE Project_Look_Up__r.Name =\'' + searchKey + '\' LIMIT 100';
            }
            List<pba__Offer__c> listOfOffers = Database.query(Query);
    
            Map<String, ReportWrapper> mapOfReportWrapper = new Map<String, ReportWrapper>();
            List<ReportWrapper> reportWrappers = new List<ReportWrapper>();
    
            for(pba__Offer__c offer : listOfOffers){
                if(offer.pba__Listing__r.Stage_Unit__c != NULL){
                    if (!mapOfReportWrapper.containsKey(offer.pba__Listing__r.Stage_Unit__c)) {
                        mapOfReportWrapper.put(offer.pba__Listing__r.Stage_Unit__c, new DashboardReportwithFilterController.ReportWrapper(offer.pba__Listing__r.Stage_Unit__r.Name, 0, 0, 0, 0, 0));
                    }
                    
                    DashboardReportwithFilterController.ReportWrapper rw = mapOfReportWrapper.get(offer.pba__Listing__r.Stage_Unit__c);
                    if (offer.pba__Listing__r.pba__Status__c == 'Available') {
                        rw.available++;
                    }
                    else if (offer.pba__Listing__r.pba__Status__c == 'On Hold') {
                        rw.on_hold++;
                    }
                    else if (offer.pba__Listing__r.pba__Status__c == 'Reserved') {
                        rw.deposited++;
                    }
                    else if (offer.pba__Listing__r.pba__Status__c == 'Sold') {
                        rw.sold++;
                    }
                
                    rw.total = rw.available + rw.on_hold + rw.deposited + rw.sold;
                    mapOfReportWrapper.put(offer.pba__Listing__r.Stage_Unit__c,rw);
                }
            }
            for (ReportWrapper rw : mapOfReportWrapper.values()) {
                reportWrappers.add(rw);
            }

            System.debug(reportWrappers);
            System.debug(reportWrappers.size());
            return reportWrappers;
        }catch(Exception e){
            System.debug('Exception-->'+e);
            System.debug('Exception-->'+e.getCause());
            System.debug('Exception-->'+e.getLineNumber());
            System.debug('Exception-->'+e.getMessage());
            return null;
        }
    }

    public List<HoldListingWrapper> holdListingDetails() {
        try {
            String query = 'SELECT Id, Name, pba__Status__c, Hold_Expiration_Date__c, pba_ausfields__Lot_Number__c, pba__OriginalListPrice_pb__c, pba__PetDeposit_pb__c, pba_ausfields__Parking_Comments__c FROM pba__Listing__c WHERE WHERE Project_Unit__r.RecordType.Name = \'Project\' AND pba__Status__c = \'On Hold\'';
            if(searchKey != NULL && searchKey != ''){
                query += ' AND Project_Unit__r.Name =\'' + searchKey + '\'';
            }
            if(fltStartDate != null){
                query += ' AND CreatedDate >: fltStartDate';
            }
    
            if(fltEndDate != null){
                query += ' AND CreatedDate <: fltEndDate';
            }
            List<pba__Listing__c> listOfListing = Database.query(query);
            List<HoldListingWrapper> reportWrappers = new List<HoldListingWrapper>();
            
            double totalPrice = 0;
    
            for (pba__Listing__c listing : listOfListing) {
                HoldListingWrapper reportData = new HoldListingWrapper(listing);
                DateTime dT = listing.Hold_Expiration_Date__c;
                date expireDate = null;
                if (dT != null) {
                    expireDate = date.newinstance(dT.year(), dT.month(), dT.day());
                }
                reportData.agency = '';
                reportData.lot_Number = listing.pba_ausfields__Lot_Number__c;
                reportData.verbal_Date = null;
                reportData.expire_Date = expireDate;
                reportData.list_Price = listing.pba__OriginalListPrice_pb__c;
                reportData.enquiry_Method = '';
                reportData.deposit_Paid = listing.pba__PetDeposit_pb__c;
                reportData.comments = listing.pba_ausfields__Parking_Comments__c;
                reportWrappers.add(reportData);
                if (listing.pba__OriginalListPrice_pb__c != null) {
                    totalPrice += listing.pba__OriginalListPrice_pb__c;
                }
            }
            if(reportWrappers.size()>0){
                HoldListingWrapper subtotal = new HoldListingWrapper();
                subtotal.agency = 'Total';
                subtotal.lot_Number = String.valueOf(reportWrappers.size());
                subtotal.verbal_Date = null;
                subtotal.expire_Date = null;
                subtotal.list_Price = totalPrice;
                subtotal.enquiry_Method = '';
                subtotal.deposit_Paid = null;
                subtotal.comments = '';
                reportWrappers.add(subtotal);
            }
            return reportWrappers;
        } catch (Exception e) {
            String data = 'getMessagelogin => '+e.getMessage() + 'line no => '+e.getLineNumber();
            System.debug('Error =>'+data);
            return null;
        }
    }

    public List<ReservedContractWrapper> reservedContractDetails() {
        String query = 'SELECT Id, Name, pba_ap__Purchaser_Name__c, Balance_of_Deposit_Paid_Date__c, Price__c, Enquiry_Source__c, Total_Deposit_Amount_Paid__c, pba__Listing__r.Name FROM pba__Offer__c WHERE Project_Look_Up__r.RecordType.Name = \'Project\' AND pba__Status__c = \'Reserved\'';
        if(searchKey != NULL && searchKey != ''){
            query += ' AND Project_Look_Up__r.Name =\'' + searchKey + '\'';
        }
        if(fltStartDate != null){
            query += ' AND CreatedDate >: fltStartDate';
        }

        if(fltEndDate != null){
            query += ' AND CreatedDate <: fltEndDate';
        }
        List<pba__Offer__c> listOfOffer = Database.query(query);
        List<ReservedContractWrapper> reportWrappers = new List<ReservedContractWrapper>();

        for (pba__Offer__c offer : listOfOffer) {
            ReservedContractWrapper reportData = new ReservedContractWrapper(offer);
            reportData.purchaser = offer.pba_ap__Purchaser_Name__c;
            reportData.lot_Number = offer.pba__Listing__r.Name;
            reportData.deposit_Date = offer.Balance_of_Deposit_Paid_Date__c;
            reportData.deposit_Paid = offer.Total_Deposit_Amount_Paid__c;
            reportData.sale_Price = offer.Price__c;
            reportData.enquiry_Method = offer.Enquiry_Source__c;
            reportData.contracts_Issued = '';
            reportData.comments = '';
            reportWrappers.add(reportData);
        }
        return reportWrappers;
    }

    public class ContractWeekMonthWrapper {
        public String result { get; set; }
        public Integer Sales { get; set; }
        public Integer cancellation { get; set; }
        public Integer new_deposit { get; set; }
        public Integer outstanding_deposit { get; set; }
        public Integer deposit_cancellation { get; set; }
        public Integer verbal_hold { get; set; }
        public Integer digital_phone { get; set; }
        public Integer walk_in { get; set; }
        public Integer total_enquiry { get; set; }

        public ContractWeekMonthWrapper(String res, Integer sal, Integer cancel, Integer dep, Integer out, Integer dep_can, Integer ver, Integer dig, Integer walk, Integer total_enq) {
            result = res;
            Sales = sal;
            cancellation = cancel;
            new_deposit = dep;
            outstanding_deposit = out;
            deposit_cancellation = dep_can;
            verbal_hold = ver;
            digital_phone = dig;
            walk_in = walk;
            total_enquiry = total_enq;
        }
    }

    public class ContractDetailWrapper {
        public String purchaser_Name { get; set; }
        public String lot_number { get; set; }
        public Date deposit { get; set; }
        public Decimal list_price { get; set; }
        public String enquiry_source { get; set; }
        public Date contract_date { get; set; }
        public Date cancellation_date { get; set; }
        public Date forecast_Contract_Date { get; set; }


        public ContractDetailWrapper(pba__Offer__c offer) {
            purchaser_Name = offer.pba_ap__Purchaser_Name__c;
            lot_number = offer.pba__Listing__r.Name;
            deposit = offer.Balance_of_Deposit_Paid_Date__c;
            list_price = offer.Price__c ;
            enquiry_source = offer.Enquiry_Source__c;
            contract_date = offer.Contract_Date__c;
            cancellation_date = offer.Cancellation_Date__c;
            forecast_Contract_Date = offer.Forecast_Contract_Date__c;
        }

        public ContractDetailWrapper(){}
    }
    public class EnquiryCountWrapper {
        public String enquiry { get; set; }
        public Integer enquiry_count { get; set; }
        public Date Week_Ending { get; set; }
        public Integer verbal_hold { get; set; }

        public EnquiryCountWrapper(String enq, Integer count, Date dat, Integer var) {
            enquiry = enq;
            enquiry_count = count;
            Week_Ending = dat;
            verbal_hold = var;
        }
    }

    public class EnquiryReportWrapper {
        public String enquiry_detail { get; set; }
        public Integer monday { get; set; }
        public Integer tuesday { get; set; }
        public Integer wednesday { get; set; }
        public Integer thursday { get; set; }
        public Integer friday { get; set; }
        public Integer saturday { get; set; }
        public Integer sunday { get; set; }

        public EnquiryReportWrapper(String enq, Integer mon, Integer tue, Integer wed, Integer thu, Integer fri, Integer sat, Integer sun) {
            enquiry_detail = enq;
            monday = mon;
            tuesday = tue;
            wednesday = wed;
            thursday = thu;
            friday = fri;
            saturday = sat;
            sunday = sun;
        }
    }

    public class ReportWrapper {
        public String stock_summary { get; set; }
        public Integer available { get; set; }
        public Integer on_hold { get; set; }
        public Integer deposited { get; set; }
        public Integer sold { get; set; }
        public Integer total { get; set; }

        public ReportWrapper(String summary, Integer avail, Integer hold, Integer dep, Integer sol, Integer tot) {
            stock_summary = summary;
            available = avail;
            on_hold = hold;
            deposited = dep;
            sold = sol;
            total = tot;

        }
    }

    public class HoldListingWrapper {
        public String agency { get; set; }
        public String lot_Number { get; set; }
        public Date verbal_Date { get; set; }
        public Date expire_Date { get; set; }
        public Decimal list_Price { get; set; }
        public String enquiry_Method { get; set; }
        public Decimal deposit_Paid { get; set; }
        public String comments { get; set; }

        public HoldListingWrapper(pba__Listing__c listing) {
            DateTime dT = listing.Hold_Expiration_Date__c;
            Date expireDate = null;
            if (dT != null) {
                expireDate = date.newinstance(dT.year(), dT.month(), dT.day());
            }
            agency = '';
            lot_Number = listing.pba_ausfields__Lot_Number__c;
            verbal_Date = null;
            expire_Date = expireDate;
            list_Price = listing.pba__OriginalListPrice_pb__c;
            enquiry_Method = '';
            deposit_Paid = listing.pba__PetDeposit_pb__c;
            comments = listing.pba_ausfields__Parking_Comments__c;
        }
        public HoldListingWrapper(){}
    }

    public class ReservedContractWrapper {
        public String purchaser { get; set; }
        public String lot_Number { get; set; }
        public Date deposit_Date { get; set; }
        public Decimal deposit_Paid { get; set; }
        public Decimal sale_Price { get; set; }
        public String enquiry_Method { get; set; }
        public String contracts_Issued { get; set; }
        public String comments { get; set; }

        public ReservedContractWrapper(pba__Offer__c offer) {
            purchaser = offer.pba_ap__Purchaser_Name__c;
            lot_Number = offer.pba__Listing__r.Name;
            deposit_Date = offer.Balance_of_Deposit_Paid_Date__c;
            deposit_Paid = offer.Total_Deposit_Amount_Paid__c;
            sale_Price = offer.Price__c;
            enquiry_Method = offer.Enquiry_Source__c;
            contracts_Issued = '';
            comments = '';
        }
    }
}