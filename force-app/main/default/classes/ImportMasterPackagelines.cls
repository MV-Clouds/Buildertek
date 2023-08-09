public class ImportMasterPackagelines {

    @AuraEnabled
    public static String insertPackage(String name,String type)
    {
        buildertek__Package__c pack = new buildertek__Package__c();
        pack.buildertek__Package_Name__c =name;
        pack.buildertek__Type__c = type;
        insert pack;
        return pack.Id;
    }
    
     @AuraEnabled
    public static List<innerClass> getPicklist(){
        String objectName = 'buildertek__Package__c';
        String fieldName ='buildertek__Type__c';
        
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        List<innerClass> innList = new List<innerClass>();
        for( Schema.PicklistEntry pickListVal : ple){
            System.debug(pickListVal.getLabel() +' '+pickListVal.getValue());
            innerClass inn = new innerClass();
            inn.label = pickListVal.getLabel();
            inn.value = pickListVal.getValue();
            innList.add(inn);
            
        } 
        return innList;
        
    }
    public class innerClass{
        @AuraEnabled public String label;
        @AuraEnabled public String value;
    }
    
     @AuraEnabled
    public static List<buildertek__Package__c> getPackage()
    {
        List<buildertek__Package__c> packRecords = [select Id,buildertek__Package_Name__c,buildertek__Type__c from buildertek__Package__c where buildertek__Type__c = 'Master'];
        return packrecords;
    }
    @AuraEnabled
    public static void ImportLines(String RecId,List<string> SelectedRecordIds){
        List<buildertek__Package_Line__c> packageLines = [SELECT Id, 
                                                          SystemModstamp, 
                                                          buildertek__Trade_Type__c,
                                                          buildertek__Package_Name__c,
                                                          buildertek__Category__c,
                                                          buildertek__Quantity__c,
                                                          buildertek__UOM__c,
                                                          buildertek__Location__c, 
                                                          buildertek__Product_Type__c,
                                                          Name 
                                                          FROM buildertek__Package_Line__c
                                                          WHERE buildertek__Package_Name__c	IN:SelectedRecordIds
                                                         ];
        List<buildertek__Package_Line__c> CloneList = new List<buildertek__Package_Line__c>();
        if(!packageLines.isEmpty()){
            for(buildertek__Package_Line__c pc:packageLines){
                buildertek__Package_Line__c clonePackage=pc.clone(false,true,true,false);
                clonePackage.buildertek__Package_Name__c = RecId; 
                CloneList.Add(clonePackage);
            }
        }
        if(!CloneList.isEmpty()){
            insert CloneList;
        }
    }
    
}