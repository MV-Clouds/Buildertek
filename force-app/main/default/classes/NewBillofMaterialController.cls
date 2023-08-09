public with sharing class NewBillofMaterialController{
    @AuraEnabled
    public static String getobjectName(Id recordId){
        String sObjName = recordId.getSObjectType().getDescribe().getName();  
        return sObjName;
    }
    @AuraEnabled
    public static String getFieldSet(){
        String result = '';
        List<String> pickListValuesList = new List<String>();
        try{
            SObjectType objToken = Schema.getGlobalDescribe().get('buildertek__Project_Selection_Sheet_Takeoff__c');
            Schema.DescribeSObjectResult d = objToken.getDescribe();
            Map<String, Schema.FieldSet> FsMap = d.fieldSets.getMap();
            if (FsMap.containsKey('buildertek__BillofMaterialFields')){
                for (Schema.FieldSetMember f : FsMap.get('buildertek__BillofMaterialFields').getFields()){
                    if (result != ''){
                        result += ',';
                    }
                    String jsonPart = '{';
                    jsonPart += '"label":"' + f.getLabel()+'",';
                    jsonPart += '"required":"' + (f.getDBRequired() || f.getRequired())+'",';
                    jsonPart += '"type":"' + (f.getType())+'",';
                    jsonPart += '"name":"' + f.getFieldPath()+'"';
                    if (String.valueOf(f.getType()) == 'PICKLIST'){
                        pickListValuesList = getDropDown('buildertek__Project_Selection_Sheet_Takeoff__c', String.valueOf(f.getFieldPath()));
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
    public static string getNames(String RecordId){
        buildertek__Project_Takeoff__c purchaseRec = [select id,Name,buildertek__Project__c from buildertek__Project_Takeoff__c where id =: RecordId];
        return purchaseRec.buildertek__Project__c;
    }
     @AuraEnabled
    public static buildertek__Project_Selection_Sheet_Takeoff__c bomrec(String RecordId,string BOMName){
        buildertek__Project_Selection_Sheet_Takeoff__c bomRec = new buildertek__Project_Selection_Sheet_Takeoff__c();
        bomRec.buildertek__Name__c =BOMName;
        bomRec.buildertek__Project__c = RecordId;
        insert bomRec;
        return bomRec;
        }
     @AuraEnabled
    public static List<buildertek__Project_Takeoff__c> gettakeoffline(String RecordId){
       List<buildertek__Project_Takeoff__c> purchaseRecord = [select id,Name, buildertek__Name__c,buildertek__Project__c,buildertek__Status__c from 
                                                              buildertek__Project_Takeoff__c where buildertek__Project__c =: RecordId and buildertek__Status__c = 'Approved' ];
        system.debug(purchaseRecord);
        return purchaseRecord;
    } 
 
    @AuraEnabled
    public static string createlines( List<String> recordId, string bomId){
    system.debug('***');
      List<buildertek__Project_Takeoff_Lines__c> paymentRec = new List<buildertek__Project_Takeoff_Lines__c>();
        system.debug(paymentRec);
        list<buildertek__Select_Sheet__c> bomlineslist = new list<buildertek__Select_Sheet__c>();
              List<buildertek__Project_Takeoff_Lines__c> Takeofflines = [select id,Name,buildertek__Location__c,buildertek__Product_Type__c,buildertek__Quantity__c,buildertek__Description__c,buildertek__TO_AREA_REF__c,
                                                                         buildertek__Base_Location__c,buildertek__Build_Phase__c,buildertek__Trade_Type__c,
                                                                         buildertek__Categories__c,buildertek__Edge__c,
																	     buildertek__TO_BUILD_REF1__c,buildertek__Location_Detailed_Area__c,
                                                                         buildertek__TO_LOCATION_DETAIL_REF__c,buildertek__TO_INSTALL_LOC__c,
                                                                         buildertek__TO_INSTALL_LOC_REF__c,buildertek__Project_Takeoff__c
                                                                         from buildertek__Project_Takeoff_Lines__c where buildertek__Project_Takeoff__c IN: recordId ];
        system.debug(Takeofflines);
        for(buildertek__Project_Takeoff_Lines__c takeoflineRec : Takeofflines){
            buildertek__Select_Sheet__c bomRec = new buildertek__Select_Sheet__c();
            bomRec.buildertek__Build_Phase__c = takeoflineRec.buildertek__Build_Phase__c;
            bomRec.buildertek__Category__c = takeoflineRec.buildertek__Categories__c;
            bomRec.buildertek__Trade_Type__c = takeoflineRec.buildertek__Trade_Type__c;
            bomrec.Name = takeoflinerec.Name;
            bomrec.buildertek__Location_Picklist__c = takeoflinerec.buildertek__Location__c;
            bomrec.buildertek__Build_Reference_1__c = takeoflinerec.buildertek__TO_BUILD_REF1__c; 
            bomrec.buildertek__Base_Location__c = takeoflinerec.buildertek__Base_Location__c; 
            bomrec.buildertek__Location_Detailed_Area__c = takeoflinerec.buildertek__Location_Detailed_Area__c; 
            bomrec.buildertek__Location_Detail_Reference_1__c = takeoflinerec.buildertek__TO_LOCATION_DETAIL_REF__c; 
            bomrec.buildertek__Install_Location__c = takeoflinerec.buildertek__TO_INSTALL_LOC__c; 
            bomrec.buildertek__Install_Location_Reference__c = takeoflinerec.buildertek__TO_INSTALL_LOC_REF__c;
            bomrec.buildertek__Product_Type__c = takeoflinerec.buildertek__Product_Type__c;
            bomrec.buildertek__Quantity__c = takeoflinerec.buildertek__Quantity__c;
            bomrec.buildertek__Description__c = takeoflinerec.buildertek__Description__c;
            bomrec.buildertek__Takeoff_Line__c = takeoflineRec.id;
            /* bomrec.buildertek__Project__c = takeoflinerec.;
            bomrec.buildertek__Location__c = takeoflinerec.buildertek__Location__c;
             bomrec.buildertek__Location__c = takeoflinerec.buildertek__Location__c;
            bomrec.buildertek__Location__c = takeoflinerec.buildertek__Location__c;*/

            
           bomRec.buildertek__Selection_Sheet_Takeoff__c = bomId;
            bomlineslist.add(bomRec);
            system.debug(bomlineslist);
        }
        if(bomlineslist.size() > 0){
            insert bomlineslist;
            
        }
        system.debug(bomlineslist);
        return  'Success';
    }
    
    
    
}