public class RFQToAccountClass {
    
    @AuraEnabled
    public static string getRfqTo(){
       return UserInfo.getDefaultCurrency();
    }
    @AuraEnabled
    public static Boolean getmulticurrency(){
       return UserInfo.isMultiCurrencyOrganization();
    }
    @AuraEnabled
    public static List<String> getDropDown(String objName, String fieldName){
        List<String> pickListValuesList = new List<String>();
        try{
            Schema.SObjectType s = Schema.getGlobalDescribe().get(objName);
            Schema.DescribeSObjectResult r = s.getDescribe();
            Map<String, Schema.SObjectField> fields = r.fields.getMap();
            Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry pickListVal : ple){
                pickListValuesList.add(pickListVal.getLabel());
            }
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return pickListValuesList;
    }
    
    @AuraEnabled
    public static String getFieldSet(){
        
        String result = '';
        List<String> pickListValuesList = new List<String>();
        try{
            SObjectType objToken = Schema.getGlobalDescribe().get('buildertek__RFI__c');
            Schema.DescribeSObjectResult d = objToken.getDescribe();
            Map<String, Schema.FieldSet> FsMap = d.fieldSets.getMap();
            if (FsMap.containsKey('buildertek__RFI_Detail_Page_Field_Set')){
                for (Schema.FieldSetMember f : FsMap.get('buildertek__RFI_Detail_Page_Field_Set').getFields()){
                    if (result != ''){
                        result += ',';
                    }
                    String jsonPart = '{';
                    jsonPart += '"label":"' + f.getLabel()+'",';
                    jsonPart += '"required":"' + (f.getDBRequired() || f.getRequired())+'",';
                    jsonPart += '"type":"' + (f.getType())+'",';
                    jsonPart += '"name":"' + f.getFieldPath()+'"';
                    if (String.valueOf(f.getType()) == 'PICKLIST'){
                        pickListValuesList = getDropDown('buildertek__RFI__c', String.valueOf(f.getFieldPath()));
                        jsonPart += ',"pickListValuesList":' + JSON.serialize(pickListValuesList);
                    }
                    jsonPart += '}';
                    result += jsonPart;
                }
            }
            
        } catch (Exception e){
            result += e.getLineNumber()+' : ' + e.getMessage();
            System.debug('Error::' + e.getMessage());
            System.debug('Error At Line::' + e.getLineNumber());
        }
        return '[' + result + ']';
    }
    
     @AuraEnabled
    public static List<buildertek__RFQ_To_Vendor__c> getquoterecord(string recId){
        List<buildertek__RFQ_To_Vendor__c> RFQRec = [SELECT Id, Name,buildertek__Vendor__c,buildertek__Status__c,buildertek__Submitted_Date__c,buildertek__Accepted_Date__c,buildertek__Awarded_Date__c,buildertek__Vendor_Quote_Amount__c,buildertek__Quote_Amount__c,buildertek__Open_RFI__c,buildertek__RFQ__c,buildertek__Contact__c,buildertek__Notes__c
                                                 FROM buildertek__RFQ_To_Vendor__c WHERE id =:recId];
        return RFQRec;
    }
    
 @AuraEnabled
    public static List<buildertek__RFI__c> getRFIRecord(string recId){
        List<buildertek__RFI__c> RFIRec = [SELECT Id, buildertek__Subject__c, buildertek__Status__c, buildertek__Question__c, 
                                                     buildertek__Due_Date__c, buildertek__Last_Responded_By__c,buildertek__Last_Responded_By__r.Name, buildertek__Last_Responded_Date__c, 
                                                     buildertek__RFQ_To_Vendor__c,buildertek__RFQ_To_Vendor__r.Name, buildertek__RFI_Assigned_To__c, buildertek__RFI_Assigned_To__r.Name,
                                                     buildertek__RFI_Reassigned_To__c FROM buildertek__RFI__c WHERE id =:recId];
        return RFIRec;
    }
    @AuraEnabled
    public static List<buildertek__RFQ_To_Vendor__c> getRFQRecord(string recId){
        List<buildertek__RFQ_To_Vendor__c> RFQRec = new List<buildertek__RFQ_To_Vendor__c>();
        if(UserInfo.isMultiCurrencyOrganization()){
            string rfqrecords = 'SELECT Id, Name,CurrencyIsoCode, buildertek__RFQ__c,buildertek__RFQ__r.Name,buildertek__RFQ__r.buildertek__Auto_Number__c, buildertek__Accepted_Date__c,buildertek__Due_Date__c,buildertek__Rejected_Date__c,'+
                      'buildertek__Awarded_Date__c, buildertek__Contact__c,buildertek__Contact__r.Name,buildertek__Submitted_Date__c, buildertek__Vendor__c, buildertek__Vendor__r.Name,'+
                       'buildertek__Status__c,buildertek__Estimated_Work_Rollup__c,buildertek__Vendor_Estimated_Work_Rollup__c,buildertek__Notes__c,buildertek__Open_RFI__c,buildertek__Vendor_Quote_Amount__c,buildertek__Quote_Amount__c FROM buildertek__RFQ_To_Vendor__c WHERE id =:recId';
            RFQRec = Database.query(rfqrecords);
        }else{
            RFQRec = [SELECT Id, Name, buildertek__RFQ__c,buildertek__RFQ__r.Name,buildertek__RFQ__r.buildertek__Auto_Number__c, buildertek__Accepted_Date__c,buildertek__Due_Date__c,buildertek__Rejected_Date__c,
                      buildertek__Awarded_Date__c, buildertek__Contact__c,buildertek__Contact__r.Name,
                      buildertek__Submitted_Date__c, buildertek__Vendor__c, buildertek__Vendor__r.Name,
                      buildertek__Status__c,buildertek__Notes__c,buildertek__Open_RFI__c,buildertek__Vendor_Quote_Amount__c,buildertek__Quote_Amount__c FROM buildertek__RFQ_To_Vendor__c WHERE id =:recId];
        }
        return RFQRec;
    }
    

}