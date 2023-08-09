public class CloneBOM {
     @AuraEnabled
      public static buildertek__Project_Selection_Sheet_Takeoff__c getCurrentVersion(String recordId){
         buildertek__Project_Selection_Sheet_Takeoff__c takeoff = [SELECT Id, buildertek__Name__c, buildertek__Project__c, buildertek__Version_Number__c FROM buildertek__Project_Selection_Sheet_Takeoff__c WHERE Id =:recordId];
         return takeoff;
      }


    // @AuraEnabled
    // public static string cloneAnySobjet(String recordId,string version, String BOMName){
    //      Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
    //     String objectAPIName = 'buildertek__Project_Selection_Sheet_Takeoff__c';
    //     String keyPrefix = recordId.substring(0,3);
    //     Set <String> fieldMap = schemaMap.get(objectAPIName).getDescribe().fields.getMap().keySet();
    //     String soqlQuery = 'Select ' ; 
    //     for (String s :fieldMap ){
    //         if(schema.getGlobalDescribe().get(objectAPIName).getDescribe().fields.getMap().get(s).getDescribe().isAccessible()){
    //             soqlQuery +=  + s+',';
    //         }
    //     }
    //     soqlQuery =  soqlQuery.removeEnd(',');
    //     soqlQuery += ' FROM ' +objectAPIName +' WHERE Id=: recordId' ;
    //     buildertek__Project_Selection_Sheet_Takeoff__c record = Database.query(soqlQuery);
        
        
       
    //     buildertek__Project_Selection_Sheet_Takeoff__c clondedParentRecordID= record.clone(false, false, false, false);
    //     clondedParentRecordID.buildertek__Version_Number__c = version;
    //     clondedParentRecordID.buildertek__Name__c = BOMName;
       
        
    //     insert clondedParentRecordID ;
        
    //     list<buildertek__Select_Sheet__c> selectsheetList = new list<buildertek__Select_Sheet__c>();
    //     List<buildertek__Select_Sheet__c> bccList = [SELECT buildertek__Active__c,Name,
    //                                                  buildertek__Allowance__c,buildertek__Selection_Sheet_Takeoff__c,buildertek__BT_Price_Book__c,buildertek__Build_Phase__c,
    //                                                  buildertek__Category__c,buildertek__Description__c,buildertek__BL_DISCOUNT__c,buildertek__BL_DISCOUNT_AMOUNT__c,buildertek__Instructions__c,
    //                                                  buildertek__BL_LIST_PRICE_F__c,buildertek__BL_LIST_PRICE__c,buildertek__Location__c,buildertek__Location_Picklist__c,buildertek__Locked__c,
    //                                                  buildertek__Build_Reference_1__c,buildertek__Base_Location__c,buildertek__Location_Detailed_Area__c,buildertek__Location_Detail_Reference_1__c,buildertek__Install_Location__c,buildertek__Install_Location_Reference__c,
    //                                                  buildertek__BL_MARKUP__c,buildertek__BL_MARKUP_AMOUNT__c,buildertek__Option__c,buildertek__Option_Details__c,buildertek__Plan__c,buildertek__Product__c,
    //                                                  buildertek__Product_Type__c,buildertek__Project__c,buildertek__Purchase_Order__c,buildertek__Quantity__c,buildertek__Standard__c,buildertek__Takeoff_Line__c,
    //                                                  buildertek__Trade_Type__c,buildertek__Type__c,buildertek__BL_UNIT_COST__c,buildertek__Upgrade_Price__c,buildertek__Vendor__c 
    //                                                  FROM buildertek__Select_Sheet__c WHERE buildertek__Selection_Sheet_Takeoff__c =:recordId
    //                                                  ];
                                                     
    //         for(Integer i=0; i<bccList.Size();i++){
    //             buildertek__Select_Sheet__c cslCopy = bccList[i].clone(false,true);
    //             cslCopy.buildertek__Selection_Sheet_Takeoff__c = clondedParentRecordID.Id;
    //              selectsheetList.add(cslCopy);
    //         } 
    //         if(!selectsheetList.isEmpty()){
    //           insert(selectsheetList); 
    //         }                                       
                                                     
    //      return clondedParentRecordID.Id;
    // }

    @InvocableMethod
    public static void cloneBOMLine(List<List<String>> CloneIdCollectid){
      try{
          String newTakeOffId ;
          Set<String> BOMIdSet = new Set<String>();
          Schema.SObjectType TOObject = Schema.buildertek__Project_Takeoff__c.getSObjectType();
          for(List<String> slist : CloneIdCollectid){
            for(String s : slist){
              Schema.SObjectType record = Id.valueOf(s).getsobjecttype();
              if(TOObject == record){
                newTakeOffId = s;
              }else{
                BOMIdSet.add(s);
              }
            }
          }
          
          Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
          String objectAPIName = 'buildertek__Project_Selection_Sheet_Takeoff__c';
          Set <String> fieldMap = schemaMap.get(objectAPIName).getDescribe().fields.getMap().keySet();
          String soqlQuery = 'Select ' ; 
          for (String s :fieldMap ){
            if(schema.getGlobalDescribe().get(objectAPIName).getDescribe().fields.getMap().get(s).getDescribe().isAccessible()){
              soqlQuery +=  + s+',';
            }
          }
          soqlQuery =  soqlQuery.removeEnd(',');
          soqlQuery += ' FROM ' +objectAPIName +' WHERE Id IN: BOMIdSet' ;
          List<buildertek__Project_Selection_Sheet_Takeoff__c> BOMrecords = Database.query(soqlQuery);
          List<buildertek__Project_Selection_Sheet_Takeoff__c> cloneRecords = new List<buildertek__Project_Selection_Sheet_Takeoff__c>();
          for(buildertek__Project_Selection_Sheet_Takeoff__c bom : BOMrecords){
            buildertek__Project_Selection_Sheet_Takeoff__c cloneBOM = bom.clone(false, false, false, false);
            cloneBOM.buildertek__Takeoff__c = newTakeOffId;
            cloneRecords.add(cloneBOM);
          }
          
          if(!cloneRecords.isEmpty()){
            insert cloneRecords;
          } 
          
          List<buildertek__Select_Sheet__c> selectsheetList = new List<buildertek__Select_Sheet__c>();
          List<buildertek__Select_Sheet__c> bccList = [SELECT buildertek__Active__c,Name,
                                                        buildertek__Allowance__c,buildertek__Selection_Sheet_Takeoff__c,buildertek__BT_Price_Book__c,buildertek__Build_Phase__c,
                                                        buildertek__Category__c,buildertek__Description__c,buildertek__BL_DISCOUNT__c,buildertek__BL_DISCOUNT_AMOUNT__c,buildertek__Instructions__c,
                                                        buildertek__BL_LIST_PRICE_F__c,buildertek__BL_LIST_PRICE__c,buildertek__Location__c,buildertek__Location_Picklist__c,buildertek__Locked__c,
                                                        buildertek__Build_Reference_1__c,buildertek__Base_Location__c,buildertek__Location_Detailed_Area__c,buildertek__Location_Detail_Reference_1__c,buildertek__Install_Location__c,buildertek__Install_Location_Reference__c,
                                                        buildertek__BL_MARKUP__c,buildertek__BL_MARKUP_AMOUNT__c,buildertek__Option__c,buildertek__Option_Details__c,buildertek__Plan__c,buildertek__Product__c,
                                                        buildertek__Product_Type__c,buildertek__Project__c,buildertek__Purchase_Order__c,buildertek__Quantity__c,buildertek__Standard__c,buildertek__Takeoff_Line__c,
                                                        buildertek__Trade_Type__c,buildertek__Type__c,buildertek__BL_UNIT_COST__c,buildertek__Upgrade_Price__c,buildertek__Vendor__c 
                                                        FROM buildertek__Select_Sheet__c WHERE buildertek__Selection_Sheet_Takeoff__c IN: BOMIdSet];
          
          Map<Id,List<buildertek__Select_Sheet__c>> bomMap = new Map<Id,List<buildertek__Select_Sheet__c>>();
          
          for(buildertek__Select_Sheet__c boml : bccList){
            if(!bomMap.containsKey(boml.buildertek__Selection_Sheet_Takeoff__c)){
              bomMap.put(boml.buildertek__Selection_Sheet_Takeoff__c, new List<buildertek__Select_Sheet__c>());
            }
            bomMap.get(boml.buildertek__Selection_Sheet_Takeoff__c).add(boml);
          }
    
          List<buildertek__Select_Sheet__c> clonebomlineList = new List<buildertek__Select_Sheet__c>();
          for(buildertek__Project_Selection_Sheet_Takeoff__c nbom : cloneRecords){
            if(bomMap.containsKey(nbom.getCloneSourceId())){
              for(buildertek__Select_Sheet__c bomline : bomMap.get(nbom.getCloneSourceId())){
                buildertek__Select_Sheet__c cloneBOMline = bomline.clone(false, false, false, false);
                cloneBOMline.buildertek__Selection_Sheet_Takeoff__c = nbom.Id;
                clonebomlineList.add(cloneBOMline);
              }
            }
          }
    
          if(!clonebomlineList.isEmpty()){
            insert clonebomlineList;
          } 
      }catch(Exception e){
        System.debug('Exception-->'+e);
        System.debug('Exception Line Number -->'+e.getLineNumber());
        System.debug('Exception Cause -->'+e.getCause());
      }
  }
}