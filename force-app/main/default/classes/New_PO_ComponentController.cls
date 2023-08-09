public with sharing class New_PO_ComponentController {
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

    @AuraEnabled
    public static string saveRecord(String data){
        System.debug('In save method');
        buildertek__Purchase_Order__c POInsert = (buildertek__Purchase_Order__c)JSON.deserialize(data, buildertek__Purchase_Order__c.class);
        if(POInsert.buildertek__Type__c == null){
            POInsert.buildertek__Type__c = 'Standard';
        }
        System.debug('POInsert ==? '+POInsert);
        insert POInsert;
        return POInsert.ID;
    }

    @AuraEnabled
    public static String getobjectName(Id recordId){
        String sObjName = recordId.getSObjectType().getDescribe().getName();  
        return sObjName;
    }

    @AuraEnabled
    public static String getCustomerId (Id recordId){
        String sObjName = recordId.getSObjectType().getDescribe().getName();  
        if(sObjName == 'buildertek__Project__c'){
            buildertek__Project__c project = [SELECT buildertek__Customer__c FROM buildertek__Project__c WHERE Id = :recordId];
            return project.buildertek__Customer__c;
        }
        return '';
    }

    @AuraEnabled
    public static String savePOLineItems (List<buildertek__Purchase_Order_Item__c> listofPOItemsToSave, Id recordId ){
        System.debug('listofPOItemsToSave ==? '+listofPOItemsToSave);
        System.debug('recordId ==? '+recordId);
        //loop over the list and set the PO Id
        for(buildertek__Purchase_Order_Item__c poItem : listofPOItemsToSave){
            poItem.buildertek__Purchase_Order__c = recordId;
        }
        insert listofPOItemsToSave;

        return 'Success';
    }

    @AuraEnabled
    public static String getadminvalues(){
		buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [Select Id, buildertek__Send_Vendor_Lien_Release_On_Approval__c,buildertek__Create_PO__c,
                                                                                              buildertek__Send_PO_On_Approval__c, buildertek__Email_Subject__c,buildertek__Create_Invoice_on_Approval__c
		                                                                                      from buildertek__Admin_Interface_Node_Configuration__c
		                                                                                      WHERE Name = :'Purchase Order Configuration'];
        String createPO = adminInterfaceNodeConfigurations.buildertek__Create_PO__c ;

        return createPO;
    }   

}