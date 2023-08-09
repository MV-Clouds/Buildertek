public without sharing class CheckInCustomRecordPageController {     

    @AuraEnabled
    public list<buildertek__Check_In__c> checkInList;
    
    @AuraEnabled 
    public integer offst;
    
    @AuraEnabled 
    public integer total;
    
    @AuraEnabled 
    public boolean hasprev;
    
    @AuraEnabled 
    public boolean hasnext;

    @AuraEnabled 
    public String orgBaseUrl = '';

    @AuraEnabled 
    public integer totalPage;
    
    private static integer pagesize = 5;
    private static integer offset;
    
    @AuraEnabled
    public static CheckInCustomRecordPageController getCheckIns(boolean next, boolean prev, decimal off, string projectId) {
        offset = (integer)off;
        list<buildertek__Check_In__c> li = new list<buildertek__Check_In__c>();
        integer listlength = [SELECT count() FROM buildertek__Check_In__c WHERE Name != null AND buildertek__Project__c =: projectId];
        
        if (!schema.sobjecttype.Account.isaccessible()) {
            li = new list<buildertek__Check_In__c>();
        } else {
            if (next==false && prev==false) {
                li = [SELECT id, Name, buildertek__Status__c, buildertek__Notes__c, (SELECT Id, ContentDocument.title FROM ContentDocumentLinks) FROM buildertek__Check_In__c WHERE buildertek__Project__c =: projectId LIMIT :pagesize OFFSET :offset];
            } else if(next==true && (offset+pagesize)<=listlength) {
                offset = offset + pagesize;
                li = [SELECT id, Name, buildertek__Status__c, buildertek__Notes__c, (SELECT Id, ContentDocument.title FROM ContentDocumentLinks) FROM buildertek__Check_In__c WHERE buildertek__Project__c =: projectId LIMIT :pagesize OFFSET :offset];
            } else if(prev==true && offset>0) {
                offset = offset - pagesize;
                li = [SELECT id, Name, buildertek__Status__c, buildertek__Notes__c, (SELECT Id, ContentDocument.title FROM ContentDocumentLinks) FROM buildertek__Check_In__c WHERE buildertek__Project__c =: projectId LIMIT :pagesize OFFSET :offset];
            }
        }

        CheckInCustomRecordPageController pageController = new CheckInCustomRecordPageController();
        pageController.checkInList = li;
        pageController.offst = offset;
        pageController.hasprev = hasprev(offset);   
        pageController.hasnext = hasnxt(offset,listlength,pagesize);
        pageController.orgBaseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        pageController.totalPage = integer.valueOf(Math.ceil(Decimal.valueOf(listlength)/pagesize));
        
        return pageController;
    }
    
    private static boolean hasprev(integer off) {
        if (off > 0) {
            return false;
        }
        return true; 
    }

    private static boolean hasnxt(integer off,integer li,integer ps) {
        if(off + ps < li) {
            return false;
        }
        return true;
    }
}