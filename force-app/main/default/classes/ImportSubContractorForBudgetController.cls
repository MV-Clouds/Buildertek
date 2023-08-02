public class ImportSubContractorForBudgetController {
    @AuraEnabled
    public static object getMasterBudgets(){
        List<MasterBudgetsClass> MasterBudgetsClassList = new List<MasterBudgetsClass>();
        List<buildertek__Contract__c> rfqList;
       //  String  name =  + searchKey + '%'; 
        date myDate = date.today();
        If(Schema.sObjectType.buildertek__Contract__c.fields.Name.isAccessible() &&
           Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Type__c.isAccessible() &&
           Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Cost_Code__c.isAccessible() &&
           Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Vendor__c.isAccessible() &&
           Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Community__c.isAccessible() &&
           Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Signed_Contract_Date__c.isAccessible() &&
           Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Contract_Amount__c.isAccessible() &&
            Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Contract_End_Date__c.isAccessible() &&
           Schema.sObjectType.buildertek__Contract__c.fields.RecordTypeId.isAccessible()){ 
               rfqList = [SELECT Id,
                           Name,
                          buildertek__Type__c,
                          buildertek__Cost_Code__r.Name,
                          buildertek__Vendor__r.Name,
                          buildertek__Community__r.Name,
                          RecordType.Name,
                          buildertek__Contract_Amount__c,
                          buildertek__Signed_Contract_Date__c,
                          buildertek__Change_Order_Amount__c,
                          buildertek__Customer_Accepted_Date__c,
                          buildertek__Accounting_Year__r.Name,
                          buildertek__Budget__r.Name,
                          buildertek__Contract_Amount_Tax_Discount_SH__c,
                          buildertek__Tax_Rate__c,
                          buildertek__Status__c,
                          buildertek__Start_Date__c,
                          buildertek__Shipping_Handling__c,
                          buildertek__Sender_Email_Response__c,
                          buildertek__RFQ__c,
                          buildertek__Revised_Contract_Amount__c,
                          buildertek__Retainage__c,
                          buildertek__BT_Quote__r.Name,
                          buildertek__Project__r.Name,
                          buildertek__Primary_Contact__r.Name,
                          buildertek__Phase__r.Name,
                          buildertek__Notes__c,
                          buildertek__Model_Code__c,
                          buildertek__Model__c,
                          buildertek__Markup_Amount__c,
                          buildertek__Markup__c,
                          buildertek__Inclusions__c,
                          buildertek__Exclusions__c,
                          buildertek__Envelope_Sent__c,
                          buildertek__Email_Template__r.Name,
                          buildertek__Email_Subject__c,
                          buildertek__Email_Body__c,
                          buildertek__Doc_Template__r.Name,
                          buildertek__Discount__c,
                          buildertek__Description__c,
                          buildertek__Cost_Code__c,
                          buildertek__Contract_In_Terms__c,
                          buildertek__Contract_Start_Date__c,
                          buildertek__Contract_Rejection_Reason__c,
                          buildertek__Contract_File__r.Name,
                          buildertek__Expiration_Date__c,
                          buildertek__Contract_End_Date__c,
                          buildertek__Contract_Number__c,
                          buildertek__Change_Order__r.Name
                    
                          
                          
                         
                          FROM buildertek__Contract__c
                          WHERE buildertek__Type__c = 'Master' and   RecordType.Name = 'Sub Contract' and (buildertek__Contract_End_Date__c = null or buildertek__Contract_End_Date__c >=: myDate)];    
               
           }
        for(buildertek__Contract__c bud : rfqList){
            MasterBudgetsClass MasterBudgetsClassRecord = new MasterBudgetsClass(); 
            MasterBudgetsClassRecord.budgetRecord = bud;
            MasterBudgetsClassRecord.budgetCheck = false;
            MasterBudgetsClassList.add(MasterBudgetsClassRecord);
        }
        return  MasterBudgetsClassList;   
    }
    
    
    
    @AuraEnabled
    public static MessageClass importSubContractItems(List<String> budgetIds, String recordId){
        MessageClass msg = new MessageClass();
        try{
            List<buildertek__Contract__c> ContractList;
            List<buildertek__Contract_Item__c> contractItems;
            
            ContractList = [SELECT Id,
                            Name,
                            buildertek__Type__c,
                            buildertek__Contract_Amount__c,
                            buildertek__Cost_Code__r.Name,
                            buildertek__Vendor__r.Name,
                            buildertek__Community__r.Name,
                            RecordType.Name
                            FROM buildertek__Contract__c
                            WHERE id IN: budgetIds and buildertek__Type__c = 'Master' and   RecordType.Name = 'Sub Contract' ];    
            
            contractItems = [SELECT Id,
                             Name,
                             buildertek__Contract__c,
                             buildertek__Total_Price__c
                             FROM buildertek__Contract_Item__c
                             WHERE buildertek__Contract__c IN : ContractList]; 
            system.debug('ContractList'+ContractList);
            system.debug('contractItems..'+contractItems);
            List<buildertek__Budget_Item__c> BudgetItemist =  new List<buildertek__Budget_Item__c>();
            if(!contractItems.isEmpty()){
                for(buildertek__Contract__c masterBudget : ContractList){
                    buildertek__Budget_Item__c BudgetItem = new buildertek__Budget_Item__c();
                    BudgetItem.buildertek__Sub_Contract__c = masterBudget.Id;
                    BudgetItem.Name = masterBudget.name;
                    BudgetItem.buildertek__Unit_Price__c = masterBudget.buildertek__Contract_Amount__c;
                    BudgetItem.buildertek__Contractor__c = masterBudget.buildertek__Vendor__c;
                    BudgetItem.buildertek__Cost_Code__c = masterBudget.buildertek__Cost_Code__c;
                    BudgetItem.buildertek__Budget__c = recordId;
                    
                    BudgetItemist.add(BudgetItem);
                    system.debug('BudgetItemist'+BudgetItemist);
                }   
            }
            if(BudgetItemist.size() > 0){
                
                insert BudgetItemist;
                
                msg.Status = 'Success';
                msg.Message = 'Sub-Contract Lines Imported Successfully';
            }else{
                msg.Status = 'Failed';
                msg.Message = 'There were no Sub-Contract Lines for the selected Sub-Contract';    
            }
            return msg;
        }catch(Exception exp){
            msg.Status = 'Failed';
            msg.Message = exp.getMessage();  
            return msg;
        }                                             
        
    }
    
    public class MessageClass{
        @AuraEnabled
        public String Status {get;set;}
        @AuraEnabled
        public string Message {get;set;}
        
    } 
    @AuraEnabled
    public static object findByName(String searchKey , string recId) {
        List<MasterBudgetsClass> MasterBudgetsClassLists = new List<MasterBudgetsClass>();
        List<buildertek__Contract__c> rfqLists;
        String  name =  + searchKey + '%'; 
        rfqLists = [SELECT Id,
                    Name,
                    buildertek__Type__c,
                    buildertek__Cost_Code__r.Name,
                    buildertek__Vendor__r.Name,
                    buildertek__Community__r.Name,
                    RecordType.Name,
                    buildertek__Contract_Amount__c,
                    buildertek__Signed_Contract_Date__c
                    FROM buildertek__Contract__c
                    WHERE buildertek__Type__c = 'Master'
                    and  buildertek__Cost_Code__r.Name LIKE :name ];
        
        for(buildertek__Contract__c bud : rfqLists){
            MasterBudgetsClass MasterBudgetsClassRecord = new MasterBudgetsClass(); 
            MasterBudgetsClassRecord.budgetRecord = bud;
            MasterBudgetsClassRecord.budgetCheck = false;
            MasterBudgetsClassLists.add(MasterBudgetsClassRecord);
        }
        return  MasterBudgetsClassLists;  
    }
    
    @AuraEnabled
    public static object findByName1(String searchKey , string recId) {
        List<MasterBudgetsClass> MasterBudgetsClassLists1 = new List<MasterBudgetsClass>();
        List<buildertek__Contract__c> rfqLists;
        String  name =  + searchKey + '%'; 
        rfqLists = [SELECT Id,
                    Name,
                    buildertek__Type__c,
                    buildertek__Cost_Code__r.Name,
                    buildertek__Vendor__r.Name,
                    buildertek__Community__r.Name,
                    RecordType.Name,
                    buildertek__Contract_Amount__c,
                    buildertek__Signed_Contract_Date__c
                    FROM buildertek__Contract__c
                    WHERE buildertek__Type__c = 'Master'
                    and  buildertek__Vendor__r.Name LIKE :name ];
        
        for(buildertek__Contract__c bud : rfqLists){
            MasterBudgetsClass MasterBudgetsClassRecord = new MasterBudgetsClass(); 
            MasterBudgetsClassRecord.budgetRecord = bud;
            MasterBudgetsClassRecord.budgetCheck = false;
            MasterBudgetsClassLists1.add(MasterBudgetsClassRecord);
        }
        return  MasterBudgetsClassLists1;  
    }
    
    @AuraEnabled
    public static object findByName2(String searchKey , string recId) {
        List<MasterBudgetsClass> MasterBudgetsClassLists2 = new List<MasterBudgetsClass>();
        List<buildertek__Contract__c> rfqLists;
        String  name =  + searchKey + '%'; 
        rfqLists = [SELECT Id,
                    Name,
                    buildertek__Type__c,
                    buildertek__Cost_Code__r.Name,
                    buildertek__Vendor__r.Name,
                    buildertek__Community__r.Name,
                    RecordType.Name,
                    buildertek__Contract_Amount__c,
                    buildertek__Signed_Contract_Date__c
                    FROM buildertek__Contract__c
                    WHERE buildertek__Type__c = 'Master'
                    and  buildertek__Community__r.Name LIKE :name ];
        
        for(buildertek__Contract__c bud : rfqLists){
            MasterBudgetsClass MasterBudgetsClassRecord = new MasterBudgetsClass(); 
            MasterBudgetsClassRecord.budgetRecord = bud;
            MasterBudgetsClassRecord.budgetCheck = false;
            MasterBudgetsClassLists2.add(MasterBudgetsClassRecord);
        }
        return  MasterBudgetsClassLists2;  
    }
    
    
    public class MasterBudgetsClass{
        @AuraEnabled
        public buildertek__Contract__c budgetRecord {get;set;}
        
        @AuraEnabled
        public boolean budgetCheck {get;set;}
    }
    
      
 @AuraEnabled
    public static String getJSONFieldSet(String sObjectName,String sFieldSetName){
        String sFieldSet='';
        sFieldSet=getFieldSet(sObjectName,sFieldSetName);
        return sFieldSet;
    }  
    
    
     @AuraEnabled
    public static String getFieldSet(String objectName, String fieldSetName){
        String result = '';
        List<String> pickListValuesList = new List<String>();
        try{
            SObjectType objToken = Schema.getGlobalDescribe().get(objectName);
            Schema.DescribeSObjectResult d = objToken.getDescribe();
            Map<String, Schema.FieldSet> FsMap = d.fieldSets.getMap();
            if (FsMap.containsKey(fieldSetName)){
                for (Schema.FieldSetMember f : FsMap.get(fieldSetName).getFields()){
                    if (result != ''){
                        result += ',';
                    }
                    String jsonPart = '{';
                    jsonPart += '"label":"' + f.getLabel()+'",';
                    jsonPart += '"required":"' + (f.getDBRequired() || f.getRequired())+'",';
                    jsonPart += '"type":"' + (f.getType())+'",';
                    jsonPart += '"name":"' + f.getFieldPath()+'"';
                    if (String.valueOf(f.getType()) == 'PICKLIST'){
                        pickListValuesList = getDropDown(objectName, String.valueOf(f.getFieldPath()));
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
 
    
    
    
    
    
    
    
    
}