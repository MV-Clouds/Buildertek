public class COLineTabForProjectController {
    
    // public static List<MasterBudgetsClass> MasterBudgetsClassList {get;set;}
    // public COLineTabForProjectController(){

    //      MasterBudgetsClassList = new List<MasterBudgetsClass>();
    // }

    @AuraEnabled
    public static object getMasterBudgets(String recId){
        
        List<String> COIdsList = New List<String>();
        
        List <buildertek__Change_Order__c> ChangeOrderList = [select Id, Name, buildertek__Project__c from buildertek__Change_Order__c where buildertek__Project__c  =:recId];
        
        if(ChangeOrderList.size()>0){
            for(buildertek__Change_Order__c CO : ChangeOrderList){
                COIdsList.add(CO.Id);  
            }
        }
        
        
        map<String , List<buildertek__Change_Order_Item__c>> GroupingMap = new map<String , List<buildertek__Change_Order_Item__c>>(); 
        
        List<MasterBudgetsClass> MasterBudgetsClassList = new List<MasterBudgetsClass>();
        
        List<buildertek__Change_Order_Item__c> nullspoRecList;
        
        List<buildertek__Change_Order_Item__c> MainpoRecList = new List<buildertek__Change_Order_Item__c>();
        
        If(Schema.sObjectType.buildertek__Change_Order_Item__c.fields.Name.isAccessible() &&
           Schema.sObjectType.buildertek__Change_Order_Item__c.fields.buildertek__Change_Order__c.isAccessible() &&
           Schema.sObjectType.buildertek__Change_Order_Item__c.fields.buildertek__Item_Name__c.isAccessible() &&
           Schema.sObjectType.buildertek__Change_Order_Item__c.fields.buildertek__Unit_Price__c.isAccessible() &&
           Schema.sObjectType.buildertek__Change_Order_Item__c.fields.buildertek__Unit_Sales_Price__c.isAccessible() &&
           Schema.sObjectType.buildertek__Change_Order_Item__c.fields.buildertek__Vendor__c.isAccessible() &&
           Schema.sObjectType.buildertek__Change_Order_Item__c.fields.buildertek__Purchase_Order__c.isAccessible()){ 
               MainpoRecList = [SELECT Id,
                                Name, 
                                buildertek__Change_Order__c,
                                buildertek__Change_Order__r.Name,
                                buildertek__Item_Name__c,
                                buildertek__Unit_Price__c,
                                buildertek__Unit_Sales_Price__c,
                                buildertek__Vendor__c,
                                buildertek__Vendor__r.Name,
                                buildertek__Auto_Number1__c,
                                buildertek__Purchase_Order__c,
                                buildertek__Purchase_Order__r.Name
                                FROM buildertek__Change_Order_Item__c Where buildertek__Change_Order__c IN: COIdsList AND buildertek__Vendor__c != ''  ORDER BY buildertek__Vendor__r.Name , buildertek__Change_Order__r.Name , buildertek__Auto_Number1__c];    
           }
        system.debug('MainpoRecList.size()>0------------->'+MainpoRecList.size());
        
        If(Schema.sObjectType.buildertek__Change_Order_Item__c.fields.Name.isAccessible() &&
           Schema.sObjectType.buildertek__Change_Order_Item__c.fields.buildertek__Change_Order__c.isAccessible() &&
           Schema.sObjectType.buildertek__Change_Order_Item__c.fields.buildertek__Item_Name__c.isAccessible() &&
           Schema.sObjectType.buildertek__Change_Order_Item__c.fields.buildertek__Unit_Price__c.isAccessible() &&
           Schema.sObjectType.buildertek__Change_Order_Item__c.fields.buildertek__Unit_Sales_Price__c.isAccessible() &&
           Schema.sObjectType.buildertek__Change_Order_Item__c.fields.buildertek__Vendor__c.isAccessible() &&
           Schema.sObjectType.buildertek__Change_Order_Item__c.fields.buildertek__Purchase_Order__c.isAccessible()){ 
               nullspoRecList = [SELECT Id,
                                 Name, 
                                 buildertek__Change_Order__c,
                                 buildertek__Change_Order__r.Name,
                                 buildertek__Item_Name__c,
                                 buildertek__Unit_Price__c,
                                 buildertek__Unit_Sales_Price__c,
                                 buildertek__Vendor__c,
                                 buildertek__Vendor__r.Name,
                                 buildertek__Auto_Number1__c,
                                 buildertek__Purchase_Order__c,
                                 buildertek__Purchase_Order__r.Name
                                 FROM buildertek__Change_Order_Item__c Where buildertek__Change_Order__c IN: COIdsList AND buildertek__Vendor__c = ''  ORDER BY buildertek__Change_Order__r.Name , buildertek__Auto_Number1__c];    
           }
        
                system.debug('nullspoRecList.size()>0------------->'+nullspoRecList.size());

        if(nullspoRecList.size()>0){
            MainpoRecList.addAll(nullspoRecList);
        }
        
        
        system.debug('MainpoRecList----------------->'+MainpoRecList.size());
        
        for(buildertek__Change_Order_Item__c POrec : MainpoRecList){
            if(GroupingMap.get(POrec.buildertek__Vendor__r.name) == null){
                GroupingMap.put(POrec.buildertek__Vendor__r.name , new List<buildertek__Change_Order_Item__c>());
            }
            GroupingMap.get(POrec.buildertek__Vendor__r.name).add(POrec);
        }
        
        
        for(String PO : GroupingMap.keySet()){
            MasterBudgetsClass MasterBudgetsClassRecord = new MasterBudgetsClass(); 
            MasterBudgetsClassRecord.groupName = PO;
            MasterBudgetsClassRecord.poCheck = false;
            MasterBudgetsClassRecord.poRecordList = GroupingMap.get(PO);
            List<POInnerClass> POInnerClassList = new List<POInnerClass>();
            for(buildertek__Change_Order_Item__c PO1 : GroupingMap.get(PO)){
                POInnerClass POInnerClassRecord = new POInnerClass();
                POInnerClassRecord.poCheck = false;
                POInnerClassRecord.poRecord = PO1;
                POInnerClassList.add(POInnerClassRecord); 
            }
            MasterBudgetsClassRecord.poRecInner = POInnerClassList;
            MasterBudgetsClassList.add(MasterBudgetsClassRecord);
        }
        
        return  MasterBudgetsClassList;   
    }
    
    
    public class MasterBudgetsClass{
        
        @AuraEnabled
        public buildertek__Change_Order_Item__c poRecord {get;set;}
        
        
        @AuraEnabled
        public boolean poCheck {get;set;}
        
        @AuraEnabled
        public String groupName {get;set;}
        
        @AuraEnabled
        public List<buildertek__Change_Order_Item__c> poRecordList {get;set;}
        
        @AuraEnabled
        public List<POInnerClass> poRecInner {get;set;}
        
    }
    
    
    public class POInnerClass{
        @AuraEnabled
        public boolean poCheck {get;set;}
        
        @AuraEnabled
        public buildertek__Change_Order_Item__c poRecord {get;set;}
    }
    
    
    
    // @AuraEnabled
    // public static object findByName1(String searchKey , string recId) {
    //     List<String> COIdsList = New List<String>();
        
    //     List <buildertek__Change_Order__c> ChangeOrderList = [select Id, Name, buildertek__Project__c from buildertek__Change_Order__c where buildertek__Project__c  =:recId];
        
    //     if(ChangeOrderList.size()>0){
    //         for(buildertek__Change_Order__c CO : ChangeOrderList){
    //             COIdsList.add(CO.Id);  
    //         }
    //     }
        
        
    //     map<String , List<buildertek__Change_Order_Item__c>> GroupingMap = new map<String , List<buildertek__Change_Order_Item__c>>(); 
        
    //     List<MasterBudgetsClass> MasterBudgetsClassList = new List<MasterBudgetsClass>();
        
    //     List<buildertek__Change_Order_Item__c> nullspoRecList;
        
    //     List<buildertek__Change_Order_Item__c> MainpoRecList = new List<buildertek__Change_Order_Item__c>();
        
    //     String  name =  '%'+ searchKey + '%'; 
    //     if(name != null){
    //         MainpoRecList = [SELECT Id,
    //                          Name, 
    //                          buildertek__Change_Order__c,
    //                          buildertek__Change_Order__r.Name,
    //                          buildertek__Item_Name__c,
    //                          buildertek__Unit_Price__c,
    //                          buildertek__Unit_Sales_Price__c,
    //                          buildertek__Vendor__c,
    //                          buildertek__Vendor__r.Name,
    //                          buildertek__Auto_Number1__c,
    //                          buildertek__Purchase_Order__c,
    //                          buildertek__Purchase_Order__r.Name
    //                          FROM buildertek__Change_Order_Item__c Where buildertek__Vendor__r.Name LIKE :name AND buildertek__Change_Order__c IN: COIdsList AND buildertek__Vendor__c != ''  ORDER BY buildertek__Vendor__r.Name]; 
    //     }
        
    //     if(name != null){
    //         nullspoRecList = [SELECT Id,
    //                           Name, 
    //                           buildertek__Change_Order__c,
    //                           buildertek__Change_Order__r.Name,
    //                           buildertek__Item_Name__c,
    //                           buildertek__Unit_Price__c,
    //                           buildertek__Unit_Sales_Price__c,
    //                           buildertek__Vendor__c,
    //                           buildertek__Vendor__r.Name,
    //                           buildertek__Auto_Number1__c,
    //                           buildertek__Purchase_Order__c,
    //                           buildertek__Purchase_Order__r.Name
    //                           FROM buildertek__Change_Order_Item__c Where buildertek__Vendor__r.Name LIKE :name AND buildertek__Change_Order__c IN: COIdsList AND buildertek__Vendor__c = ''  ORDER BY buildertek__Vendor__r.Name]; 
    //     }
        
    //     if(nullspoRecList.size()>0){
    //         MainpoRecList.addAll(nullspoRecList);
    //     }
        
    //     system.debug('MainpoRecList---------->'+MainpoRecList);
        
    //     for(buildertek__Change_Order_Item__c POrec : MainpoRecList){
    //         system.debug('GroupingMap.get(POrec.buildertek__Vendor__c)----------->'+GroupingMap.get(POrec.buildertek__Vendor__r.name));
    //         if(GroupingMap.get(POrec.buildertek__Vendor__r.name) == null){
    //             system.debug('new List<buildertek__Change_Order_Item__c>()----->'+new List<buildertek__Change_Order_Item__c>());
    //             GroupingMap.put(POrec.buildertek__Vendor__r.name , new List<buildertek__Change_Order_Item__c>());
    //         }
    //         GroupingMap.get(POrec.buildertek__Vendor__r.name).add(POrec);
    //     }
        
        
    //     system.debug('GroupingMap.keySet()-------->'+GroupingMap.keySet());
        
    //     for(String PO : GroupingMap.keySet()){
    //         MasterBudgetsClass MasterBudgetsClassRecord = new MasterBudgetsClass(); 
    //         MasterBudgetsClassRecord.groupName = PO;
    //         MasterBudgetsClassRecord.poCheck = false;
    //         MasterBudgetsClassRecord.poRecordList = GroupingMap.get(PO);
    //         List<POInnerClass> POInnerClassList = new List<POInnerClass>();
    //         for(buildertek__Change_Order_Item__c PO1 : GroupingMap.get(PO)){
    //             POInnerClass POInnerClassRecord = new POInnerClass();
    //             POInnerClassRecord.poCheck = false;
    //             POInnerClassRecord.poRecord = PO1;
    //             POInnerClassList.add(POInnerClassRecord); 
    //         }
    //         MasterBudgetsClassRecord.poRecInner = POInnerClassList;
    //         MasterBudgetsClassList.add(MasterBudgetsClassRecord);
    //     }
        
    //     return  MasterBudgetsClassList;
        
    // }
    
    // @AuraEnabled
    // public static object findByName(String searchKey , string recId) {
    //     List<String> COIdsList = New List<String>();
        
    //     List <buildertek__Change_Order__c> ChangeOrderList = [select Id, Name, buildertek__Project__c from buildertek__Change_Order__c where buildertek__Project__c  =:recId];
        
    //     if(ChangeOrderList.size()>0){
    //         for(buildertek__Change_Order__c CO : ChangeOrderList){
    //             COIdsList.add(CO.Id);  
    //         }
    //     }
        
        
    //     map<String , List<buildertek__Change_Order_Item__c>> GroupingMap = new map<String , List<buildertek__Change_Order_Item__c>>(); 
        
    //     List<MasterBudgetsClass> MasterBudgetsClassList = new List<MasterBudgetsClass>();
        
    //     List<buildertek__Change_Order_Item__c> nullspoRecList;
        
    //     List<buildertek__Change_Order_Item__c> MainpoRecList = new List<buildertek__Change_Order_Item__c>();
        
    //     String  name =  '%'+ searchKey + '%'; 
    //     // System.debug('name==='+name);
    //     // name = '%' +name;
    //     System.debug('updated Name=='+name);
    //     if(name != null){
    //         MainpoRecList = [SELECT Id,
    //                          Name, 
    //                          buildertek__Change_Order__c,
    //                          buildertek__Change_Order__r.Name,
    //                          buildertek__Item_Name__c,
    //                          buildertek__Unit_Price__c,
    //                          buildertek__Unit_Sales_Price__c,
    //                          buildertek__Vendor__c,
    //                          buildertek__Vendor__r.Name,
    //                          buildertek__Auto_Number1__c,
    //                          buildertek__Purchase_Order__c,
    //                          buildertek__Purchase_Order__r.Name
    //                          FROM buildertek__Change_Order_Item__c Where buildertek__Change_Order__r.Name LIKE :name AND buildertek__Change_Order__c IN: COIdsList AND buildertek__Vendor__c != ''  ORDER BY buildertek__Vendor__r.Name ];
    //     }
        
    //     if(name != null){
    //         nullspoRecList = [SELECT Id,
    //                           Name, 
    //                           buildertek__Change_Order__c,
    //                           buildertek__Change_Order__r.Name,
    //                           buildertek__Item_Name__c,
    //                           buildertek__Unit_Price__c,
    //                           buildertek__Unit_Sales_Price__c,
    //                           buildertek__Vendor__c,
    //                           buildertek__Vendor__r.Name,
    //                           buildertek__Auto_Number1__c,
    //                           buildertek__Purchase_Order__c,
    //                           buildertek__Purchase_Order__r.Name
    //                           FROM buildertek__Change_Order_Item__c Where buildertek__Change_Order__r.Name LIKE :name AND buildertek__Change_Order__c IN: COIdsList AND buildertek__Vendor__c = ''  ORDER BY buildertek__Vendor__r.Name]; 
    //     }
        
    //     if(nullspoRecList.size()>0){
    //         MainpoRecList.addAll(nullspoRecList);
    //     }
        
    //     for(buildertek__Change_Order_Item__c POrec : MainpoRecList){
    //         if(GroupingMap.get(POrec.buildertek__Vendor__r.name) == null){
    //             GroupingMap.put(POrec.buildertek__Vendor__r.name , new List<buildertek__Change_Order_Item__c>());
    //         }
    //         GroupingMap.get(POrec.buildertek__Vendor__r.name).add(POrec);
    //     }
        
        
    //     for(String PO : GroupingMap.keySet()){
    //         MasterBudgetsClass MasterBudgetsClassRecord = new MasterBudgetsClass(); 
    //         MasterBudgetsClassRecord.groupName = PO;
    //         MasterBudgetsClassRecord.poCheck = false;
    //         MasterBudgetsClassRecord.poRecordList = GroupingMap.get(PO);
    //         List<POInnerClass> POInnerClassList = new List<POInnerClass>();
    //         for(buildertek__Change_Order_Item__c PO1 : GroupingMap.get(PO)){
    //             POInnerClass POInnerClassRecord = new POInnerClass();
    //             POInnerClassRecord.poCheck = false;
    //             POInnerClassRecord.poRecord = PO1;
    //             POInnerClassList.add(POInnerClassRecord); 
    //         }
    //         MasterBudgetsClassRecord.poRecInner = POInnerClassList;
    //         MasterBudgetsClassList.add(MasterBudgetsClassRecord);
    //     }
        
    //     return  MasterBudgetsClassList;
        
    // }


    @AuraEnabled
    public static object findByName(String searchKey3, String searchKey2, String searchKey , string recId) {
     
        List<String> COIdsList = New List<String>();
        
        List <buildertek__Change_Order__c> ChangeOrderList = [select Id, Name, buildertek__Project__c from buildertek__Change_Order__c where buildertek__Project__c  =:recId];
        
        if(ChangeOrderList.size()>0){
            for(buildertek__Change_Order__c CO : ChangeOrderList){
                COIdsList.add(CO.Id);  
            }
        }
     
        map<String , List<buildertek__Change_Order_Item__c>> GroupingMap = new map<String , List<buildertek__Change_Order_Item__c>>(); 
        List<MasterBudgetsClass> MasterBudgetsClassList = new List<MasterBudgetsClass>();
        List<buildertek__Change_Order_Item__c> nullspoRecList;
        List<buildertek__Change_Order_Item__c> MainpoRecList = new List<buildertek__Change_Order_Item__c>();
        
        String  searchChangeOrder =  !(String.isBlank(searchKey)) ? '%'+ searchKey + '%' : null; 
        String  searchVendor =  !(String.isBlank(searchKey3)) ? '%'+ searchKey3 + '%' : null; 
        String  searchLineItem =  !(String.isBlank(searchKey2)) ? '%'+ searchKey2 + '%' : null; 
       
        String whereCondition = '';
        if(searchChangeOrder != null && searchVendor != null && searchLineItem != null){
            whereCondition = 'buildertek__Change_Order__r.Name LIKE \''+searchChangeOrder +'\' AND buildertek__Vendor__r.Name LIKE \''+searchVendor +'\' AND Name LIKE \'' +searchLineItem +'\' AND buildertek__Change_Order__c IN : COIdsList AND (buildertek__Vendor__c != \'\' OR  buildertek__Vendor__c = \'\')  ORDER BY buildertek__Vendor__r.Name';
        }else if(searchChangeOrder != null && searchVendor == null && searchLineItem == null){
            whereCondition = 'buildertek__Change_Order__r.Name LIKE \''+searchChangeOrder +'\' AND buildertek__Change_Order__c IN : COIdsList AND (buildertek__Vendor__c != \'\' OR  buildertek__Vendor__c = \'\')  ORDER BY buildertek__Vendor__r.Name';
        }else if(searchChangeOrder == null && searchVendor != null && searchLineItem == null){
            whereCondition = 'buildertek__Vendor__r.Name LIKE  \''+searchVendor +'\' AND buildertek__Change_Order__c IN :COIdsList AND (buildertek__Vendor__c != \'\' OR  buildertek__Vendor__c = \'\')  ORDER BY buildertek__Vendor__r.Name';
        }else if(searchChangeOrder == null && searchVendor == null && searchLineItem != null){
            whereCondition = 'Name LIKE  \''+searchLineItem +'\' AND buildertek__Change_Order__c IN : COIdsList AND (buildertek__Vendor__c != \'\' OR  buildertek__Vendor__c = \'\')  ORDER BY Name';
        }else if(searchChangeOrder != null && searchVendor != null && searchLineItem == null){
            whereCondition = 'buildertek__Change_Order__r.Name LIKE \''+searchChangeOrder +'\' AND buildertek__Vendor__r.Name LIKE \''+searchVendor +'\' AND buildertek__Change_Order__c IN : COIdsList AND (buildertek__Vendor__c != \'\' OR  buildertek__Vendor__c = \'\')  ORDER BY buildertek__Vendor__r.Name';
        }else if(searchChangeOrder != null && searchVendor == null && searchLineItem != null){
            whereCondition = 'buildertek__Change_Order__r.Name LIKE \''+searchChangeOrder +'\' AND Name LIKE  \''+searchLineItem +'\' AND buildertek__Change_Order__c IN : COIdsList AND (buildertek__Vendor__c != \'\' OR  buildertek__Vendor__c = \'\')  ORDER BY buildertek__Vendor__r.Name';
        }else if(searchChangeOrder == null && searchVendor != null && searchLineItem != null){
            whereCondition = 'buildertek__Vendor__r.Name LIKE \''+searchVendor +'\' AND Name LIKE  \''+searchLineItem +'\' AND buildertek__Change_Order__c IN : COIdsList AND (buildertek__Vendor__c != \'\' OR  buildertek__Vendor__c = \'\')  ORDER BY buildertek__Vendor__r.Name';
        }
       
        
        String Query = 'SELECT Id,Name, buildertek__Change_Order__c,buildertek__Change_Order__r.Name,buildertek__Item_Name__c,buildertek__Unit_Price__c,buildertek__Unit_Sales_Price__c,buildertek__Vendor__c,buildertek__Vendor__r.Name,buildertek__Auto_Number1__c,buildertek__Purchase_Order__c,buildertek__Purchase_Order__r.Name FROM buildertek__Change_Order_Item__c WHERE '+whereCondition;
        MainpoRecList = database.query(Query);
        if(MainpoRecList.size() > 0){
            for(buildertek__Change_Order_Item__c POrec : MainpoRecList){
                if(GroupingMap.get(POrec.buildertek__Vendor__r.name) == null){
                    GroupingMap.put(POrec.buildertek__Vendor__r.name , new List<buildertek__Change_Order_Item__c>());
                }
                GroupingMap.get(POrec.buildertek__Vendor__r.name).add(POrec);
            }
            
            for(String PO : GroupingMap.keySet()){
                MasterBudgetsClass MasterBudgetsClassRecord = new MasterBudgetsClass(); 
                MasterBudgetsClassRecord.groupName = PO;
                MasterBudgetsClassRecord.poCheck = false;
                MasterBudgetsClassRecord.poRecordList = GroupingMap.get(PO);
                List<POInnerClass> POInnerClassList = new List<POInnerClass>();
                for(buildertek__Change_Order_Item__c PO1 : GroupingMap.get(PO)){
                    POInnerClass POInnerClassRecord = new POInnerClass();
                    POInnerClassRecord.poCheck = false;
                    POInnerClassRecord.poRecord = PO1;
                    POInnerClassList.add(POInnerClassRecord); 
                }
                MasterBudgetsClassRecord.poRecInner = POInnerClassList;
                MasterBudgetsClassList.add(MasterBudgetsClassRecord);
            }
            return  MasterBudgetsClassList;
        }else{
            return null;
        }
        
    }
    
    
    @AuraEnabled
    public static buildertek__Purchase_Order__c  createPO(List<String> budgetIds, String recordId, String poVendorId){
        
        
        // buildertek__Purchase_Order__c newPO = [select Id, Name, buildertek__Project__c from buildertek__Purchase_Order__c];
        
        
        buildertek__Purchase_Order__c newPO = new buildertek__Purchase_Order__c(
            buildertek__Project__c=recordId,
            buildertek__Vendor__c = poVendorId
        );
        insert newPO;
        
        List<buildertek__Change_Order_Item__c> COLinesList;
        COLinesList = [select Id, 
                       Name,
                       buildertek__Change_Order__c,
                       buildertek__Change_Order__r.Name,
                       buildertek__Item_Name__c,
                       buildertek__Unit_Price__c,
                       buildertek__Unit_Sales_Price__c,
                       buildertek__Vendor__c,
                       buildertek__Vendor__r.Name,
                       buildertek__Auto_Number1__c,
                       buildertek__Purchase_Order__c,
                       buildertek__Cost_Code__c,
                       buildertek__Purchase_Order_Line__c
                       FROM buildertek__Change_Order_Item__c Where Id IN:budgetIds];
        
        List<buildertek__Purchase_Order_Item__c> BudgetItemist =  new List<buildertek__Purchase_Order_Item__c>();
        
        List<buildertek__Change_Order_Item__c> COItemist =  new List<buildertek__Change_Order_Item__c>();
        
        
        Map<String,String> COPOLineMap = new Map<String,String>();
        
        if(!COLinesList.isEmpty()){
            for(buildertek__Change_Order_Item__c masterBudget : COLinesList){
                buildertek__Purchase_Order_Item__c BudgetItem = new buildertek__Purchase_Order_Item__c();
                buildertek__Change_Order_Item__c COItem = new buildertek__Change_Order_Item__c();
                BudgetItem.buildertek__Purchase_Order__c = newPO.Id;
                BudgetItem.Name = masterBudget.name;
                BudgetItem.buildertek__Quantity__c = 1;
                BudgetItem.buildertek__Unit_Price__c = masterBudget.buildertek__Unit_Price__c;
                BudgetItem.buildertek__Cost_Code__c = masterBudget.buildertek__Cost_Code__c;
                BudgetItemist.add(BudgetItem);
                COItem.Id = masterBudget.Id;
                COItem.buildertek__Purchase_Order__c = newPO.Id;
                COItem.buildertek__Vendor__c = poVendorId;
                COItemist.add(COItem);
            }
        }
        
        if(BudgetItemist.size() > 0){
            insert BudgetItemist;
        }
        
        if(COItemist.size() > 0){
            update COItemist;
        }
        
        
        integer IndexNum = 0;
        
          List<buildertek__Change_Order_Item__c> FinalCOLineList =  new List<buildertek__Change_Order_Item__c>();
        
        for(buildertek__Change_Order_Item__c coI : COLinesList){
            buildertek__Change_Order_Item__c BudgetItem2 = new buildertek__Change_Order_Item__c();
            BudgetItem2.Id = coI.Id;
            BudgetItem2.buildertek__Purchase_Order_Line__c = BudgetItemist[IndexNum].Id;
            FinalCOLineList.add(BudgetItem2);
            IndexNum++;
        }
        
        if(FinalCOLineList.size() > 0){
            update FinalCOLineList;
        }
        
        
        return newPO; 
    }
    
    
    //  @AuraEnabled
    // public static object findByName2(String searchKey , string recId) {
    //     List<String> COIdsList = New List<String>();
        
    //     List <buildertek__Change_Order__c> ChangeOrderList = [select Id, Name, buildertek__Project__c from buildertek__Change_Order__c where buildertek__Project__c  =:recId];
        
    //     if(ChangeOrderList.size()>0){
    //         for(buildertek__Change_Order__c CO : ChangeOrderList){
    //             COIdsList.add(CO.Id);  
    //         }
    //     }
        
        
    //     map<String , List<buildertek__Change_Order_Item__c>> GroupingMap = new map<String , List<buildertek__Change_Order_Item__c>>(); 
        
    //     List<MasterBudgetsClass> MasterBudgetsClassList = new List<MasterBudgetsClass>();
        
    //     List<buildertek__Change_Order_Item__c> nullspoRecList;
        
    //     List<buildertek__Change_Order_Item__c> MainpoRecList = new List<buildertek__Change_Order_Item__c>();
        
    //     String  name =  '%'+ searchKey + '%'; 
    //     System.debug('Name : '+name);
    //     if(name != null){
    //         MainpoRecList = [SELECT Id,
    //                          Name, 
    //                          buildertek__Change_Order__c,
    //                          buildertek__Change_Order__r.Name,
    //                          buildertek__Item_Name__c,
    //                          buildertek__Unit_Price__c,
    //                          buildertek__Unit_Sales_Price__c,
    //                          buildertek__Vendor__c,
    //                          buildertek__Vendor__r.Name,
    //                          buildertek__Auto_Number1__c,
    //                          buildertek__Purchase_Order__c, 
    //                          buildertek__Purchase_Order__r.Name
    //                          FROM buildertek__Change_Order_Item__c Where Name LIKE :name AND buildertek__Change_Order__c IN: COIdsList AND buildertek__Vendor__c != ''  ORDER BY Name ];
    //     }
        
    //     if(name != null){
    //         nullspoRecList = [SELECT Id,
    //                           Name, 
    //                           buildertek__Change_Order__c,
    //                           buildertek__Change_Order__r.Name,
    //                           buildertek__Item_Name__c,
    //                           buildertek__Unit_Price__c,
    //                           buildertek__Unit_Sales_Price__c,
    //                           buildertek__Vendor__c,
    //                           buildertek__Vendor__r.Name,
    //                           buildertek__Auto_Number1__c,
    //                           buildertek__Purchase_Order__c,
    //                           buildertek__Purchase_Order__r.Name
    //                           FROM buildertek__Change_Order_Item__c Where Name LIKE :name AND buildertek__Change_Order__c IN: COIdsList AND buildertek__Vendor__c = ''  ORDER BY Name]; 
    //     }
        
    //     if(nullspoRecList.size()>0){
    //         MainpoRecList.addAll(nullspoRecList);
    //     }
        
    //     for(buildertek__Change_Order_Item__c POrec : MainpoRecList){
    //         if(GroupingMap.get(POrec.buildertek__Vendor__r.name) == null){
    //             GroupingMap.put(POrec.buildertek__Vendor__r.name , new List<buildertek__Change_Order_Item__c>());
    //         }
    //         GroupingMap.get(POrec.buildertek__Vendor__r.name).add(POrec);
    //     }
        
        
    //     for(String PO : GroupingMap.keySet()){
    //         MasterBudgetsClass MasterBudgetsClassRecord = new MasterBudgetsClass(); 
    //         MasterBudgetsClassRecord.groupName = PO;
    //         MasterBudgetsClassRecord.poCheck = false;
    //         MasterBudgetsClassRecord.poRecordList = GroupingMap.get(PO);
    //         List<POInnerClass> POInnerClassList = new List<POInnerClass>();
    //         for(buildertek__Change_Order_Item__c PO1 : GroupingMap.get(PO)){
    //             POInnerClass POInnerClassRecord = new POInnerClass();
    //             POInnerClassRecord.poCheck = false;
    //             POInnerClassRecord.poRecord = PO1;
    //             POInnerClassList.add(POInnerClassRecord); 
    //         }
    //         System.debug('POInnerClassList=='+POInnerClassList);
    //         MasterBudgetsClassRecord.poRecInner = POInnerClassList;
    //         MasterBudgetsClassList.add(MasterBudgetsClassRecord);
    //     }
        
    //     return  MasterBudgetsClassList;
        
    // }
    
}