public class CreatePaymentForInvoiceAP {
    @AuraEnabled
    public static ResponseWrapper getPaymentLines(string recordId) {
        
        ResponseWrapper PaymentDetails = new ResponseWrapper();
        
        list<buildertek__Account_Payable_Clone__c> InvoiceRec = [SELECT Id,
                                                                 Name,
                                                                 buildertek__Project__c,
                                                                 buildertek__Project__r.Name,
                                                                 buildertek__Total__c,
                                                                 buildertek__Vendor__c
                                                                 FROM buildertek__Account_Payable_Clone__c
                                                                 WHERE Id =: recordId ];
        
        if(InvoiceRec.size() > 0){
            PaymentDetails.Invoice = InvoiceRec[0];
        }
        
        List<buildertek__Account_Payable_Item_Clone__c> Invoicelinelist = [SELECT Id,
                                                                           Name,
                                                                           buildertek__Description__c,
                                                                           buildertek__Quantity__c,
                                                                           buildertek__Unit_Price__c,
                                                                           buildertek__Total_Price__c,
                                                                           buildertek__Payment_Amount__c,
                                                                           buildertek__Account_Payable_Clone__c
                                                                           FROM buildertek__Account_Payable_Item_Clone__c
                                                                           WHERE buildertek__Account_Payable_Clone__c =: recordId ];
        
        if(Invoicelinelist.size() > 0){
            PaymentDetails.InvoiceLine  = Invoicelinelist ;
            return PaymentDetails;
        }else{
             return null;
        }
        
        
       
        
    }
    
    
    public class ResponseWrapper{
        @AuraEnabled
        public buildertek__Account_Payable_Clone__c Invoice {get;set;}
        @AuraEnabled
        public List<buildertek__Account_Payable_Item_Clone__c> InvoiceLine {get;set;}
      
        
    } 
    
    
    @AuraEnabled
    public static buildertek__BT_Payment__c createSovLines(String recordId, List<buildertek__Account_Payable_Item_Clone__c> invoiceLineList, list<String> lineIds, String invoiceId){
        
        
        
        buildertek__BT_Payment__c invoiceRec = [SELECT Id,
                                                 Name,
                                                  buildertek__Invoices_AP__c
                                                 FROM buildertek__BT_Payment__c
                                                 WHERE Id =: recordId];
        
        invoiceRec.buildertek__Invoices_AP__c = invoiceId;
        
        update invoiceRec;
        
        return invoiceRec;
        
      /*  List<buildertek__BT_Payment_Lines__c> PayLineList = new List<buildertek__BT_Payment_Lines__c>();
        
        List<buildertek__Account_Payable_Item_Clone__c> invoiceLinesList =  [SELECT Id,
                                                                             Name,
                                                                             buildertek__Description__c,
                                                                             buildertek__Quantity__c,
                                                                             buildertek__Unit_Price__c,
                                                                             buildertek__Total_Price__c,
                                                                             buildertek__Payment_Amount__c,
                                                                             buildertek__Account_Payable_Clone__c
                                                                             FROM buildertek__Account_Payable_Item_Clone__c
                                                                             WHERE buildertek__Account_Payable_Clone__c =: invoiceId ];
        
        
        
        for(buildertek__Account_Payable_Item_Clone__c inv : invoiceLineList){
            buildertek__BT_Payment_Lines__c pl = new buildertek__BT_Payment_Lines__c();
            pl.buildertek__Payment__c = recordId;
           // pl.buildertek__Quantity__c = inv.buildertek__Quantity__c;
           // pl.buildertek__Unit_Price__c = inv.buildertek__Unit_Price__c;
            pl.buildertek__Amount__c = inv.buildertek__Payment_Amount__c;
            pl.buildertek__Invoice_Line_AP__c = inv.Id;
            PayLineList.add(pl);
        }
        
        if(!PayLineList.isEmpty()){
            insert PayLineList;
            return invoiceRec;
        }else{
            return null;
        }       */      
    }






    public static String getobjectName(Id recordId){
        String sObjName = recordId.getSObjectType().getDescribe().getName();  
        return sObjName;
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