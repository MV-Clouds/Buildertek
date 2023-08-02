public with sharing class AssociateWarrantyController {
    
    @AuraEnabled
    public static list<WarrantryWrapper> warrantydetails(String warrantyrecId){
        list<WarrantryWrapper> WarrantryWrapperList = new list<WarrantryWrapper>();
        
        buildertek__Warranty__c warrantyRec = [select id,Name,buildertek__Project__c,buildertek__Status__c,buildertek__Warranty__c,buildertek__Due_Date__c,buildertek__Effective_Date__c,buildertek__Description__c from buildertek__Warranty__c where id =: warrantyrecId];
        List<id> assosiatedWarrentyIds = new list<id>();
		list<buildertek__Warranty__c> allwarranties = [select id,buildertek__Parent_Warranty__c,buildertek__Due_Date__c,buildertek__Effective_Date__c from buildertek__Warranty__c where buildertek__Project__c =: warrantyRec.buildertek__Project__c];
		for(buildertek__Warranty__c wrec :allwarranties ){
            if(wrec.buildertek__Parent_Warranty__c != null){
				assosiatedWarrentyIds.add(wrec.buildertek__Parent_Warranty__c);
                system.debug('&&&&&&&&&&&&&&&&&'+assosiatedWarrentyIds);
            }
		}
        list<buildertek__Warranty__c> warrantylist = [select id,Name,buildertek__Project__c,buildertek__Parent_Warranty__c,buildertek__Status__c,buildertek__Due_Date__c,buildertek__Effective_Date__c,buildertek__Warranty__c,buildertek__Description__c from buildertek__Warranty__c 
                                                      where buildertek__Project__c =: warrantyRec.buildertek__Project__c and (id !=: warrantyrecId and id !=: warrantyRec.buildertek__Warranty__c and id NOT IN: assosiatedWarrentyIds)];
        system.debug('***********************************************************'+warrantylist);
        if (warrantylist.size() > 0){
            for(buildertek__Warranty__c wRec : warrantylist){
                WarrantryWrapper wrap = new WarrantryWrapper();
                wrap.WarrantyRec = wRec;
                wrap.selectedWarranty = false;
                WarrantryWrapperList.add(wrap);
            }
            system.debug('@@'+WarrantryWrapperList);
			return WarrantryWrapperList;
            //return warrantylist;
        }
        return WarrantryWrapperList;
    }
    Public class WarrantryWrapper{
        @AuraEnabled
        Public buildertek__Warranty__c WarrantyRec {get;set;}
        @AuraEnabled
        Public Integer LagValue {get;set;}
        @AuraEnabled
        Public Boolean selectedWarranty {get;set;}
       
      }
    @AuraEnabled
	public static void  newWarranty(String warrantyId, String selectedwarrantyId, Integer lagvalue){
        if(selectedwarrantyId != null){
        buildertek__Warranty__c selectedwarrantyRec = [select id,Name,buildertek__Project__c,buildertek__Effective_Date__c,
                                               buildertek__Warranty__c,buildertek__Due_Date__c,buildertek__Length_of_Warranty__c
                                               from buildertek__Warranty__c where Id =: selectedwarrantyId];
        selectedwarrantyRec.buildertek__Warranty__c = warrantyId;
        selectedwarrantyRec.buildertek__Lag_Value__c = lagvalue;
        system.debug('***********************'+selectedwarrantyRec.buildertek__Lag_Value__c);
        Update selectedwarrantyRec;
        buildertek__Warranty__c warrantyRec = [select id,Name,buildertek__Project__c,buildertek__Effective_Date__c,buildertek__Parent_Warranty__c,
                                               buildertek__Warranty__c,buildertek__Due_Date__c,buildertek__Length_of_Warranty__c
                                               from buildertek__Warranty__c where Id =: warrantyId];
        warrantyRec.buildertek__Parent_Warranty__c = selectedwarrantyId;
        if(lagvalue != null){
            integer addinglagValue = integer.valueOf(lagvalue);
            warrantyRec.buildertek__Effective_Date__c = selectedwarrantyRec.buildertek__Due_Date__c.adddays(addinglagValue);
            if(warrantyRec.buildertek__Length_of_Warranty__c.contains('month') || warrantyRec.buildertek__Length_of_Warranty__c.contains('months')){
                List<string> s = warrantyRec.buildertek__Length_of_Warranty__c.split(' ');
                integer addingDays = integer.valueOf(s[0]) * 30;
                warrantyRec.buildertek__Due_Date__c = warrantyRec.buildertek__Effective_Date__c.adddays(addingDays);
            }
            if(warrantyRec.buildertek__Length_of_Warranty__c.contains('year') || warrantyRec.buildertek__Length_of_Warranty__c.contains('years')){
                List<string> s = warrantyRec.buildertek__Length_of_Warranty__c.split(' ');
                integer addingDays = integer.valueOf(s[0]) * 365;
                warrantyRec.buildertek__Due_Date__c = warrantyRec.buildertek__Effective_Date__c.adddays(addingDays);
            }
            Update warrantyRec;
        }
    }
                }

}