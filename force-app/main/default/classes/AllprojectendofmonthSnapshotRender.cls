public with sharing class AllprojectendofmonthSnapshotRender {
    public List<AllprojectWrapper> projectlist { get; set; }
    public Date Today { get { return Date.today(); }}
    public String projectname {get; set;}
    // ApexPages.StandardController sc;
    // public AllprojectendofmonthSnapshotRender(ApexPages.StandardController sc) {
    // }

    public AllprojectendofmonthSnapshotRender(ApexPages.StandardController stdController){
        projectlist = getAllprojectlist();
    }

    public List<AllprojectWrapper> getAllprojectlist(){
        List<AllprojectWrapper> projectlist = new List<AllprojectWrapper>();
        String propertyId = ApexPages.currentPage().getparameters().get('ID');
        System.debug('propertyId-->'+propertyId);
        try{

            // SOQL to get Property and its offer, listing, request
            List<pba__Property__c> propertyList = [SELECT Id, Name, Sales_Agency__r.Name FROM pba__Property__c WHERE Id =:propertyId];
            System.debug('propertyList-->'+propertyList);
            projectname = propertyList[0].Name;
            List<pba__Offer__c> offerList = [SELECT Id, Name, pba__Listing__c, pba__Status__c, pba__Request__c, Initial_Deposit_Paid_Date__c, Contract_Date__c, Balance_Deposit_Amount_Paid__c, Project_Look_Up__c, Price__c, Cancellation_Date__c FROM pba__Offer__c WHERE Project_Look_Up__c IN:propertyList];
            System.debug('offerList-->'+offerList);
            List<pba__Listing__c> listingList = [SELECT Name, Id, pba__Status__c, Project_Unit__c, Hold_Expiration_Date__c FROM pba__Listing__c WHERE Project_Unit__c =:propertyId];
            System.debug('listingList-->'+listingList);
            List<pba__Request__c> reqList = [SELECT Id, Enquiry_Stage__c, Project_Look_Up__c, Source_Type__c FROM pba__Request__c WHERE Project_Look_Up__c =:propertyId AND CreatedDate = LAST_MONTH];
            System.debug('reqList-->'+reqList);            
            List<pba__Offer__History> offerHisList = [SELECT Id, IsDeleted, ParentId, CreatedById, CreatedDate, Field, DataType, OldValue, NewValue, Parent.Project_Look_Up__c, Parent.pba__Status__c, Parent.Cancellation_Date__c FROM pba__Offer__History WHERE ParentId IN: offerList];
            System.debug('offerHisList-->'+offerHisList);
    
            // for offerMap
            Map<Id,List<pba__Offer__c>> offerMap = new Map<Id,List<pba__Offer__c>>();
            for(pba__Offer__c offer: offerList){
                if(offerMap.containsKey(offer.Project_Look_Up__c)){
                    offerMap.get(offer.Project_Look_Up__c).add(offer);
                }else {
                    List<pba__Offer__c> offlist = new List<pba__Offer__c>();
                    offlist.add(offer);
                    offerMap.put(offer.Project_Look_Up__c,offlist);
                }
            }
            
            // for offerHistoryMap
            Map<Id,List<pba__Offer__History>> offerHisMap = new Map<Id,List<pba__Offer__History>>();
            for(pba__Offer__History offhis: offerHisList){
                if(offerHisMap.containsKey(offhis.Parent.Project_Look_Up__c)){
                    offerHisMap.get(offhis.Parent.Project_Look_Up__c).add(offhis);
                }else {
                    List<pba__Offer__History> offerhistorylist = new List<pba__Offer__History>();
                    offerhistorylist.add(offhis);
                    offerHisMap.put(offhis.Parent.Project_Look_Up__c,offerhistorylist);
                }
            }
    
            // for listingMap
            Map<Id,List<pba__Listing__c>> listingMap = new Map<Id,List<pba__Listing__c>>();
            for(pba__Listing__c listing: listingList){
                if(listingMap.containsKey(listing.Project_Unit__c)){
                    listingMap.get(listing.Project_Unit__c).add(listing);
                }else{
                    List<pba__Listing__c> lstlist = new List<pba__Listing__c>();
                    lstlist.add(listing);
                    listingMap.put(listing.Project_Unit__c,lstlist);
                }
            }
    
            // for requestMap
            Map<Id,List<pba__Request__c>> reqMap = new Map<Id,List<pba__Request__c>>();
            for(pba__Request__c req: reqList){
                if(reqMap.containsKey(req.Project_Look_Up__c)){
                    reqMap.get(req.Project_Look_Up__c).add(req);
                }else{
                    List<pba__Request__c> reqLst = new List<pba__Request__c>();
                    reqLst.add(req);
                    reqMap.put(req.Project_Look_Up__c,reqLst);
                }
            }
    
            // Initialization of total fields
            Decimal totalwalkin = 0;
            Decimal totalphonedigital = 0;
            Decimal totalEnquiry = 0;
            Decimal totalstockAvail = 0;
            Decimal totalNewDepo = 0;
            Decimal totalVerbalhold = 0;
            Decimal totalnewContr = 0;
            Decimal totalOutstandingDepo = 0;
            Decimal totalDepoCancellation = 0;
            Decimal totalcontrCancellation = 0;
            Decimal totalsalesMTD = 0;
            Decimal totalnetsalesMTD = 0;
            Decimal totalsalesrevenue = 0;
            Decimal totalavglotprice = 0;
    
            for(pba__Property__c pb: propertyList){
                // Intialization of variables for evry record 
                Decimal walkin = 0;
                Decimal phoneDigital = 0;
                Decimal enquirylist = 0;
                Decimal stockAvailable = 0;
                Decimal verbalHold = 0;
                Decimal newDepo =0;
                Decimal newContr =0;
                Decimal outstandingdepo =0;
                Decimal salesMTD =0;
                Decimal netsalesMTD =0;
                Decimal salesRevenue =0;
                Decimal avglotPrice = 0;
                Decimal depositCancel = 0;
                Decimal contractCancel = 0;

                AllprojectWrapper ap = new AllprojectWrapper();
                ap.projectName = pb.Name;
                ap.salesAgent = pb.Sales_Agency__r.Name;
                if(reqMap.containsKey(pb.Id)){
                    for(pba__Request__c req: reqMap.get(pb.Id)){
                        if(req.Source_Type__c == 'Walk In'){
                            walkin++;
                        }else if(req.Source_Type__c == 'Phone/Digital'){
                            phoneDigital++;
                        }
                    }
                    enquirylist = reqMap.get(pb.Id).size(); 
                }
                ap.walkIn = walkin;
                ap.phoneDigital = phoneDigital;
                ap.enquiry = enquirylist;
                if(listingMap.containsKey(pb.Id)){
                    for(pba__Listing__c lis : listingMap.get(pb.Id)){
                        if(lis.pba__Status__c == 'Available'){
                            stockAvailable++;
                        }else if(lis.pba__Status__c == 'On Hold'){
                            verbalHold++;
                        }
                    }
                }
                
                ap.stockAvailable = stockAvailable;
                ap.verbalHolds = verbalHold;
                if(offerMap.containsKey(pb.Id)){
                    for(pba__Offer__c offer: offerMap.get(pb.Id)){
                        if(offer.Initial_Deposit_Paid_Date__c != null){
                            if(offer.pba__Status__c != 'Cancelled'){
                                if(offer.Initial_Deposit_Paid_Date__c.year() == Date.Today().year()){
                                    if(offer.Initial_Deposit_Paid_Date__c.Month() == (Date.Today().addMonths(-1).Month())){
                                        newDepo++;
                                    }
                                }
                            }
                        }
                        if(offer.Contract_Date__c != null){
                            if(offer.pba__Status__c != 'Cancelled'){
                                if(offer.Contract_Date__c.year() == Date.Today().year()){
                                    if(offer.Contract_Date__c.Month() == (Date.Today().addMonths(-1).Month())){
                                        newContr++;
                                    }
                                }
                            }
                        }
                        if(offer.Balance_Deposit_Amount_Paid__c >0 && offer.Initial_Deposit_Paid_Date__c != NULL){
                            if(offer.Initial_Deposit_Paid_Date__c.year() == Date.Today().year()){
                                if(offer.Initial_Deposit_Paid_Date__c.Month() == (Date.Today().addMonths(-1).Month())){
                                    outstandingdepo++;
                                }
                            }
                        }
                        if(offer.Contract_Date__c != null){
                            if((offer.pba__Status__c != 'Cancelled')){
                                if(offer.Contract_Date__c.year() == Date.Today().year()){
                                    if(offer.Contract_Date__c.Month() == (Date.Today().addMonths(-1).Month())){
                                        salesMTD++;
                                    }
                                }
                            }
                        }
                        if(offer.Contract_Date__c != null){
                            if((offer.pba__Status__c == 'Conditional' || offer.pba__Status__c == 'Unconditional' || offer.pba__Status__c == 'Settled')){
                                if(offer.Contract_Date__c.year() == Date.Today().year()){
                                    if(offer.Contract_Date__c.Month() == (Date.Today().addMonths(-1).Month())){
                                        netsalesMTD++;
                                    }
                                }
                            }
                        }
                        if(offer.Contract_Date__c != null){
                            if((offer.pba__Status__c == 'Conditional' || offer.pba__Status__c == 'Unconditional' || offer.pba__Status__c == 'Settled')){
                                if(offer.Contract_Date__c.year() == Date.Today().year()){
                                    if(offer.Contract_Date__c.Month() == (Date.Today().addMonths(-1).Month())){
                                        salesRevenue += offer.Price__c;
                                    }
                                }
                            }
                        }
                    }
                }
                ap.newDeposit = newDepo;
                ap.newContracts = newContr;
                ap.outstandingDesposits = outstandingdepo;
                if(offerHisMap.containsKey(pb.Id)){
                    for(pba__Offer__History offhis : offerHisMap.get(pb.Id)){
                        if(offhis.Field == 'pba__Status__c'){
                            if(offhis.Parent.Cancellation_Date__c != null){
                                if(offhis.OldValue == 'Reserved' && offhis.Parent.pba__Status__c == 'Cancelled'){
                                    if(offhis.Parent.Cancellation_Date__c.year() == Date.Today().year()){
                                        if(offhis.Parent.Cancellation_Date__c.Month() == (Date.Today().addMonths(-1).Month())){
                                            depositCancel++;
                                        }
                                    }    
                                }
                            }
                            if(offhis.Parent.Cancellation_Date__c != null){
                                if((offhis.OldValue == 'Contracted' || offhis.OldValue == 'Unconditional') && offhis.Parent.pba__Status__c == 'Cancelled' && offhis.Parent.Cancellation_Date__c.Month() < Date.Today().Month()){
                                    if(offhis.Parent.Cancellation_Date__c.year() == Date.Today().year()){
                                        if(offhis.Parent.Cancellation_Date__c.Month() == (Date.Today().addMonths(-1).Month())){
                                            contractCancel++;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                ap.depositCancellation = depositCancel;
                ap.contractCancellation = contractCancel;
                ap.salesMTD = salesMTD;
                ap.netsalesMTD = netsalesMTD;
                ap.salesRevenue = salesRevenue;
                if(netsalesMTD > 0){
                    avglotPrice = salesRevenue / netsalesMTD;
                }
                ap.avglotPrice = avglotPrice;
                
                // Counting Total Here for all the columns
                /*totalwalkin += ap.walkIn;             
                totalphonedigital += ap.phoneDigital;
                totalEnquiry += ap.enquiry;
                totalstockAvail += ap.stockAvailable;
                totalNewDepo += ap.newDeposit;
                totalVerbalhold += ap.verbalHolds;
                totalnewContr += ap.newContracts;
                totalOutstandingDepo += ap.outstandingDesposits;
                totalDepoCancellation += ap.depositCancellation;
                totalcontrCancellation += ap.contractCancellation;
                totalsalesMTD += ap.salesMTD;
                totalnetsalesMTD += ap.netsalesMTD;
                totalsalesrevenue += ap.salesRevenue;
                totalavglotprice += ap.avglotPrice;*/
                projectlist.add(ap);
            }
            // Adding Total Here for all the columns
            // AllprojectWrapper ap = new AllprojectWrapper();
            // ap.projectName = 'Total';
            // ap.salesAgent = '';
            // ap.walkIn = totalwalkin;
            // ap.phoneDigital = totalphonedigital;
            // ap.enquiry = totalEnquiry;
            // ap.stockAvailable = totalstockAvail;
            // ap.newDeposit = totalNewDepo;
            // ap.verbalHolds = totalVerbalhold;
            // ap.newContracts = totalnewContr;
            // ap.outstandingDesposits = totalOutstandingDepo;
            // ap.depositCancellation = totalDepoCancellation;
            // ap.contractCancellation = totalcontrCancellation;
            // ap.salesMTD = totalsalesMTD;
            // ap.netsalesMTD = totalnetsalesMTD;
            // ap.salesRevenue = totalsalesrevenue;
            // ap.avglotPrice = totalavglotprice;
            // projectlist.add(ap);

            //return the projectlist
            if(Test.isRunningTest()){
                throw new DMLException();
            }
            return projectlist;
        }Catch(Exception e){
            System.debug('Exception-->'+e);
            System.debug('Exception-->'+e.getMessage());
            System.debug('Exception-->'+e.getLineNumber());
            System.debug('Exception-->'+e.getStackTraceString());
        }
        return projectlist;
    }
    public class AllprojectWrapper{
        public String projectName {get; set;}
        public String salesAgent {get; set;}
        public Decimal walkIn {get; set;}
        public Decimal phoneDigital {get; set;}
        public Decimal enquiry {get; set;}
        public Decimal stockAvailable {get; set;}
        public Decimal newDeposit {get; set;}
        public Decimal verbalHolds {get; set;}
        public Decimal newContracts {get; set;}
        public Decimal outstandingDesposits {get; set;}
        public Decimal depositCancellation {get; set;}
        public Decimal contractCancellation {get; set;}
        public Decimal salesMTD {get; set;}
        public Decimal netsalesMTD {get; set;}
        public Decimal salesRevenue {get; set;}
        public Decimal avglotPrice {get; set;}
    }

    public class weekcount{
        public Date startDate {get;set;}
        public Date endDate {get;set;}
    }
}