public with sharing class CloseOutWarranty{
	@AuraEnabled
    public static String getwarrantyItems(String recordId){
        list<buildertek__Warranty_Item__c> wiRec = new list<buildertek__Warranty_Item__c>();
        //  buildertek__Warranty__c warrantyRec = [select id,Name,buildertek__Project__c from buildertek__Warranty__c where id =: recordId and buildertek__Warranty__c != null];
        list<buildertek__Warranty_Item__c>	warrantyItemlist = [select id,Name,buildertek__Warranty__c,buildertek__Status__c from buildertek__Warranty_Item__c where buildertek__Warranty__c =: recordId];
        for(buildertek__Warranty_Item__c warrantyItemRec : warrantyItemlist){
            warrantyItemRec.buildertek__Status__c = 'Completed';
            wiRec.add(warrantyItemRec);
        }
        Update wiRec;
        return null;
    }
    @AuraEnabled
    public static string updateWarranty(String recordId){
        system.debug('recordId'+recordId);
        list<buildertek__Warranty_Item__c> wiRec = new list<buildertek__Warranty_Item__c>();
        buildertek__Warranty__c warrantyRec = [select id,Name,buildertek__Project__c,buildertek__Status__c,buildertek__Warranty__c,buildertek__Locked__c from buildertek__Warranty__c where id =: recordId ];
        if(warrantyRec.buildertek__Locked__c == true){
            return 'isLocked';
        }else{
            warrantyRec.buildertek__Status__c = 'Closed';
            update warrantyRec;
        }
       // list<buildertek__Warranty__c> warlist = [select id,Name,buildertek__Project__c,buildertek__Status__c,buildertek__Warranty__c from buildertek__Warranty__c where buildertek__Warranty__c =: recordId];
       list<buildertek__Warranty_Item__c> warrantyItemlist = [select id,Name,buildertek__Contractor_Account__c,
                                                                               buildertek__Contractor_Resource__c,
                                                                               buildertek__Date_Submitted__c,
                                                                               buildertek__Description__c,buildertek__Details__c,buildertek__Internal_Resource__c,buildertek__Location__c,buildertek__Notes__c,buildertek__Project__c,
                                                                               buildertek__Service_Request__c,buildertek__Status__c,buildertek__Type__c,buildertek__Warranty__c,buildertek__Work_Date__c
                                                                              from buildertek__Warranty_Item__c where buildertek__Warranty__c =: recordId];
        Boolean isnextwarranty = false;
        if(warrantyRec.buildertek__Warranty__c != null){
            buildertek__Warranty__c nextwarrantyRec = [select id,Name,buildertek__Project__c,buildertek__Status__c,buildertek__Warranty__c,buildertek__Locked__c 
                                                       from buildertek__Warranty__c where id =: warrantyRec.buildertek__Warranty__c ];
            if(nextwarrantyRec.buildertek__Locked__c == true){
                isnextwarranty = true;
                for(buildertek__Warranty_Item__c warrantyItemRec : warrantyItemlist){
                    if(warrantyItemRec.buildertek__Status__c == 'Open'){
                        warrantyItemRec.buildertek__Status__c ='Completed';
                    }
                }
                update warrantyItemlist;
                return 'isnextwarrantyLocked';  
            }
            
        }
        
        
        if(warrantyRec.buildertek__Warranty__c != null && warrantyRec.buildertek__Locked__c != true && isnextwarranty != true) {
            for(buildertek__Warranty_Item__c warrantyItemRec : warrantyItemlist){
                if(warrantyItemRec.buildertek__Status__c == 'Open'){
                    buildertek__Warranty_Item__c newwritem = new buildertek__Warranty_Item__c();
                    newwritem.buildertek__Contractor_Account__c = warrantyItemRec.buildertek__Contractor_Account__c; 
                    newwritem.buildertek__Contractor_Resource__c = warrantyItemRec.buildertek__Contractor_Resource__c;
                    newwritem.buildertek__Date_Submitted__c = warrantyItemRec.buildertek__Date_Submitted__c;
                    newwritem.buildertek__Description__c = warrantyItemRec.buildertek__Description__c;
                    newwritem.buildertek__Details__c = warrantyItemRec.buildertek__Details__c;
                    newwritem.buildertek__Internal_Resource__c = warrantyItemRec.buildertek__Internal_Resource__c;
                    newwritem.buildertek__Location__c = warrantyItemRec.buildertek__Location__c;
                    newwritem.buildertek__Notes__c = warrantyItemRec.buildertek__Notes__c;
                    newwritem.buildertek__Project__c = warrantyItemRec.buildertek__Project__c;
                    newwritem.buildertek__Service_Request__c = warrantyItemRec.buildertek__Service_Request__c;
                    newwritem.buildertek__Status__c = warrantyItemRec.buildertek__Status__c;
                    newwritem.buildertek__Type__c = warrantyItemRec.buildertek__Type__c;
                    newwritem.buildertek__Work_Date__c =  warrantyItemRec.buildertek__Work_Date__c;
                    newwritem.buildertek__Warranty__c = warrantyRec.buildertek__Warranty__c;
                    wiRec.add(newwritem);
                    warrantyItemRec.buildertek__Status__c ='Completed';
                } 
            }
            insert wiRec;
            update warrantyItemlist;
            return warrantyRec.buildertek__Warranty__c;
        }
        else if(warrantyRec.buildertek__Locked__c != true){ 
            for(buildertek__Warranty_Item__c warrantyItemRec : warrantyItemlist){
                if(warrantyItemRec.buildertek__Status__c == 'Open'){
                    warrantyItemRec.buildertek__Status__c ='Completed';
                }
            }
            update warrantyItemlist;
            return 'success';
        }
        else{
            return null;
        }
    }
    

}