public class NewChangeOrderController {
     @AuraEnabled
    public static String getobjectName(Id recordId){
        String sObjName = recordId.getSObjectType().getDescribe().getName();  
        return sObjName;
    }
    @AuraEnabled
    public static String getFieldSet(Id selectedRecordTypeId){
        system.debug('selectedRecordTypeId--->'+selectedRecordTypeId);
        String result = '';
        String COType='Customer';

        List<String> pickListValuesList = new List<String>();
        
            
            Id CustomerRecordTypeId = Schema.SObjectType.buildertek__Change_Order__c.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
            Id VendorRecordTypeId = Schema.SObjectType.buildertek__Change_Order__c.getRecordTypeInfosByName().get('Vendor').getRecordTypeId();
            if(selectedRecordTypeId==CustomerRecordTypeId){
                COType = 'Customer';
            }else if(selectedRecordTypeId==VendorRecordTypeId){ 
                COType = 'Vendor';
            }
            system.debug('COType-->'+COType);
            
            
            SObjectType objToken = Schema.getGlobalDescribe().get('buildertek__Change_Order__c');
            Schema.DescribeSObjectResult d = objToken.getDescribe();
            Map<String, Schema.FieldSet> FsMap = d.fieldSets.getMap();
            if (FsMap.containsKey('buildertek__NewChangeOrder')){
                for (Schema.FieldSetMember f : FsMap.get('buildertek__NewChangeOrder').getFields()){
                    system.debug('f.getLabel()--->'+f.getLabel());                 
                    
                    String jsonPart = '{';
                    jsonPart += '"label":"' + f.getLabel()+'",';
                    jsonPart += '"required":"' + (f.getDBRequired() || f.getRequired())+'",';
                    jsonPart += '"type":"' + (f.getType())+'",';
                    jsonPart += '"name":"' + f.getFieldPath()+'"';
                    if (String.valueOf(f.getType()) == 'PICKLIST'){
                        pickListValuesList = getDropDown('buildertek__Change_Order__c', String.valueOf(f.getFieldPath()));
                        jsonPart += ',"pickListValuesList":' + JSON.serialize(pickListValuesList);
                    }
                    jsonPart += '}';  
                     
                    if(selectedRecordTypeId==VendorRecordTypeId){
                        if(    String.valueOf(f.getFieldPath())!='buildertek__Markup__c'
                            && String.valueOf(f.getFieldPath())!='buildertek__Tax_Rate__c'
                            && String.valueOf(f.getFieldPath())!='buildertek__Contract__c'){
                            if (result != ''){
                                result += ',';
                            }  
                            result += jsonPart;
                        }                        

                    }else{
                        if (result != ''){
                            result += ',';
                        }  
                        result += jsonPart;
                    }                    
                }
            }

       
        return '[' + result + ']~'+COType;
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
    public static string getNames(String RecordId){
       buildertek__Project__c projRec = [select id,Name,buildertek__Customer__c from buildertek__Project__c  where id =: RecordId];
       List<String> value = new List<String>();
        
        return projRec.buildertek__Customer__c;
   } 
    @AuraEnabled
    public static string getContractNames(String RecordId){
       RecordType rt = [SELECT Id
                  FROM RecordType
                  WHERE sObjectType = 'buildertek__Contract__c' AND Name = 'Prime Contract'];
       list<buildertek__Contract__c> Contract = [select id,Name,buildertek__Project__c from buildertek__Contract__c  where buildertek__Project__c =: RecordId and RecordTypeId =: rt.Id Order By CreatedDate ASC limit 1];
     //  If(!Contract.isEmpty()){
       // Contract[0].id;
      //  }
         return Contract[0].id;
   } 
    @AuraEnabled
    public static string getproject(String RecordId){
        buildertek__Contract__c conRec = [select id,Name,buildertek__Project__c from buildertek__Contract__c  where id =: RecordId];
        return conRec.buildertek__Project__c;
    } 
         
    @AuraEnabled
public static List<ListView> getListViews() {
    List<ListView> listviews =
        [SELECT Id, Name FROM ListView WHERE SobjectType = 'buildertek__Change_Order__c' and Name='All'];

    // Perform isAccessible() check here
    return listviews;
}
    
    @AuraEnabled 
    public static User  getvendor(){
        String portalCode = '';
        string userName = userInfo.getUserId();
        list<Network> netRec = [SELECT Id,Status FROM Network where Status = 'Live'];
        
        if(netRec.size() > 0){
            string strQry = 'Select Id, isPortalEnabled,buildertek__Account_Id__c From User Where id=: userName';  
            list<User> userRec= Database.query(strQry);
            if(userRec.size() > 0){
                portalCode = userRec[0].get('isPortalEnabled').toString();
            }
            System.debug(userRec[0]);
            return  userRec[0] ;
        }else{
            return null;
        } 
        
    }
    
    
     @AuraEnabled
    public static String getRecordTypeName(String recTypeId){
        List<RecordType> sovRecordType  = new List<RecordType> ();
        if(recTypeId != null && recTypeId != 'undefined'){ 
           sovRecordType =[select Id,Name from RecordType where Id =: recTypeId];
            
        }else{
           sovRecordType =[select Id,Name from RecordType where sObjectType='buildertek__Change_Order__c' AND Name = 'Customer'];
            
        }
        
        return sovRecordType[0].Id;
        
        
    }
    
    
    @AuraEnabled
    public static String updateCOType(String recordId){
      
      buildertek__Change_Order__c NewCO = [select Id, Name, RecordTypeId, recordtype.name, buildertek__Type__c from buildertek__Change_Order__c where Id =: recordId];
        
        if(NewCO.recordtype.name == 'Customer'){
          NewCO.buildertek__Type__c = 'Customer' ; 
        }else{
         NewCO.buildertek__Type__c = 'Vendor' ;   
        }
        update NewCO;
        return 'success';
    }

    @AuraEnabled
    public static string saveRecord(String data){
        System.debug('In save method');
        buildertek__Change_Order__c COInsert = (buildertek__Change_Order__c)JSON.deserialize(data, buildertek__Change_Order__c.class);
        System.debug('POInsert ==? '+COInsert);
        insert COInsert;
        return COInsert.ID;
    }

    @AuraEnabled
    public static String saveCOLineItems (List<buildertek__Change_Order_Item__c> listofCOItemsToSave, Id recordId ){
        System.debug('listofPOItemsToSave ==? '+listofCOItemsToSave);
        System.debug('recordId ==? '+recordId);
        //loop over the list and set the PO Id
        for(buildertek__Change_Order_Item__c coItem : listofCOItemsToSave){
            coItem.buildertek__Change_Order__c = recordId;
        }
        insert listofCOItemsToSave;

        return 'Success';
    }

    @AuraEnabled
    public static String getadminvalues(){
        buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [Select Id,buildertek__Change_Order_Configuration__c,buildertek__Email_Subject__c , buildertek__Create_Change_order__c 
                                                                                              from buildertek__Admin_Interface_Node_Configuration__c WHERE Name=:'Change Order Configuration'];

        String createCO = adminInterfaceNodeConfigurations.buildertek__Create_Change_order__c ;



        return createCO;
    }   




}