public class POPageController {
    @AuraEnabled
    public static object getMasterBudgets(String recId, Integer pageNumber, Integer pageSize, String poFilter, String poLineFilter, String tradeTypeFilter, String projectFilter, String productFilter, String permitFilter){
        
        system.debug('pageNumber--------->'+pageNumber);
        system.debug('pageSize----------->'+pageSize);
        
        Integer offset;
        offset = (pageNumber - 1) * pageSize;
        Integer totalRecords = 0;
        Integer recordEnd = pageSize * pageNumber;
        string orgCurr = UserInfo.getDefaultCurrency();
        System.debug('poFilter=====>'+poFilter);
        String query = 'Select COUNT() FROM buildertek__Purchase_Order__c';
        if(poFilter != ''){
            
            if(poFilter != '' && poFilter != null){
                query = query+ ' Where (buildertek__Vendor__r.Name LIKE \'%'+String.escapeSingleQuotes(poFilter)+'%\')';
                query = query+ ' or (Name LIKE \'%'+String.escapeSingleQuotes(poFilter)+'%\')';
                query = query+ ' or (buildertek__Status__c LIKE \'%'+String.escapeSingleQuotes(poFilter)+'%\')';
                query = query+ ' or (buildertek__Project__r.Name LIKE \'%'+String.escapeSingleQuotes(poFilter)+'%\')';
                
            }
            totalRecords = Database.countQuery(query);
            System.debug('tradeTypeFilter===============>'+tradeTypeFilter);
        }else if(tradeTypeFilter != ''){
            if(tradeTypeFilter != '' && tradeTypeFilter != null){
                query = query+ ' Where (buildertek__Vendor__r.buildertek__Trade_Type_Lookup__r.Name LIKE \'%'+String.escapeSingleQuotes(tradeTypeFilter)+'%\')';
            }
            totalRecords = Database.countQuery(query);
        } else if(projectFilter != ''){
            if(projectFilter != '' && projectFilter != null){
                query = query+ ' Where (buildertek__Project__r.Name LIKE \'%'+String.escapeSingleQuotes(projectFilter)+'%\')';
            }
            totalRecords = Database.countQuery(query);
        }
        
        
        
        else{
            totalRecords = [select COUNT()  
                            from buildertek__Purchase_Order__c where (buildertek__Status__c != 'Ordered' AND buildertek__Status__c != 'Paid' AND buildertek__Status__c != 'Partially Paid')]; 
        }
        
        
        List<MasterBudgetsClass> MasterBudgetsClassList = new List<MasterBudgetsClass>();
        List<buildertek__Purchase_Order__c> nullspoRecList;
        List<buildertek__Purchase_Order__c> MainpoRecList = new List<buildertek__Purchase_Order__c>();
        String queryList = 'select Id, Name, buildertek__Type__c,toLabel(buildertek__Phase__c),buildertek__Vendor__c,buildertek__Vendor__r.Name,buildertek__Vendor__r.buildertek__Trade_Type_Lookup__r.Name,buildertek__Vendor__r.buildertek__Email_Address__c,buildertek__Status__c,buildertek__Description__c,buildertek__Change_Order__c,buildertek__Change_Order__r.Name, buildertek__PO_Total__c, buildertek__Paid_Amount__c, buildertek__PO_Balance__c, buildertek__Date_Ordered__c, buildertek__Project__c, buildertek__Project__r.Name,';
        queryList = queryList +  ' (select Id, Name, buildertek__Purchase_Order__c,buildertek__Total_Price__c,buildertek__Tax__c, buildertek__Purchase_Order__r.Name, buildertek__Quantity__c, buildertek__Unit_Price__c, buildertek__Description__c, buildertek__Total_Amount_Tax__c from Purchase_Order_Items__r) FROM buildertek__Purchase_Order__c';
        queryList = queryList+ ' Where (buildertek__Status__c != \'Ordered\' AND buildertek__Status__c != \'Paid\' AND buildertek__Status__c != \'Partially Paid\') ';
        if(poFilter != '' || tradeTypeFilter != '' || projectFilter != '' || permitFilter != ''){
            if(poFilter != ''){
                
                queryList = queryList+ ' AND (buildertek__Vendor__r.Name LIKE \'%'+String.escapeSingleQuotes(poFilter)+'%\'';
                
                queryList = queryList+ ' or Name LIKE \'%'+String.escapeSingleQuotes(poFilter)+'%\'';
                
                queryList = queryList+ ' or buildertek__Status__c LIKE \'%'+String.escapeSingleQuotes(poFilter)+'%\'';
                queryList = queryList+ ' or buildertek__Project__r.Name LIKE \'%'+String.escapeSingleQuotes(poFilter)+'%\')';
                
                
                
                
            }
            if(tradeTypeFilter != ''){
                if(tradeTypeFilter != '' && tradeTypeFilter != null){
                    queryList = queryList+ ' AND (buildertek__Vendor__r.buildertek__Trade_Type_Lookup__r.Name LIKE \'%'+String.escapeSingleQuotes(tradeTypeFilter)+'%\')';
                }
            }
            if(projectFilter != ''){
                if(projectFilter != '' && projectFilter != null){
                    queryList = queryList+ ' AND (buildertek__Project__r.Name LIKE \'%'+String.escapeSingleQuotes(projectFilter)+'%\')';
                }
                
            }

            if(permitFilter != '' && permitFilter != null){
                queryList = queryList+ ' AND (buildertek__Permit__r.Name LIKE \'%'+String.escapeSingleQuotes(permitFilter)+'%\') AND (buildertek__Permit__r.buildertek__Status__c = \'Completed\')';
            }

            queryList = queryList+ ' ORDER BY buildertek__Phase__c  DESC NULLS last, buildertek__Vendor__r.Name ASC NULLS last, Name DESC, buildertek__Status__c ASC';
            MainpoRecList = Database.query(queryList); 

        }
        
        else if(poLineFilter != '' || productFilter != ''){
            MainpoRecList = [SELECT Id,
                             Name, 
                             buildertek__Type__c,
                             toLabel(buildertek__Phase__c),
                             buildertek__Vendor__c,
                             buildertek__Vendor__r.Name,
                             buildertek__Vendor__r.buildertek__Email_Address__c,
                             buildertek__Vendor__r.buildertek__Trade_Type_Lookup__r.Name,
                             buildertek__Status__c,
                             buildertek__Description__c,
                             buildertek__Change_Order__c,
                             buildertek__Change_Order__r.Name,
                             buildertek__PO_Total__c,
                             buildertek__Paid_Amount__c,
                             buildertek__PO_Balance__c,
                             buildertek__Date_Ordered__c,
                             buildertek__Project__c,
                             buildertek__Project__r.Name,(select Id, Name, 
                                                          buildertek__Purchase_Order__c, 
                                                          buildertek__Purchase_Order__r.Name,
                                                          buildertek__Quantity__c,
                                                          buildertek__Unit_Price__c,
                                                          buildertek__Description__c,
                                                          buildertek__Tax__c,
                                                          buildertek__Total_Price__c,
                                                          buildertek__Total_Amount_Tax__c, 
                                                          buildertek__Product__c,
                                                          buildertek__Product__r.ProductCode from Purchase_Order_Items__r)
                             FROM buildertek__Purchase_Order__c where (buildertek__Status__c != 'Ordered' AND buildertek__Status__c != 'Paid' AND buildertek__Status__c != 'Partially Paid') ORDER BY buildertek__Phase__c  DESC NULLS last, buildertek__Vendor__r.Name ASC NULLS last, Name DESC, buildertek__Status__c ASC ];    
        }else {
            MainpoRecList = [SELECT Id,
                             Name, 
                             buildertek__Type__c,
                             toLabel(buildertek__Phase__c),
                             buildertek__Vendor__c,
                             buildertek__Vendor__r.Name,
                             buildertek__Vendor__r.buildertek__Email_Address__c,
                             buildertek__Vendor__r.buildertek__Trade_Type_Lookup__r.Name,
                             buildertek__Status__c,
                             buildertek__Description__c,
                             buildertek__Change_Order__c,
                             buildertek__Change_Order__r.Name,
                             buildertek__PO_Total__c,
                             buildertek__Paid_Amount__c,
                             buildertek__PO_Balance__c,
                             buildertek__Date_Ordered__c,
                             buildertek__Project__c,
                             buildertek__Project__r.Name,(select Id, Name, 
                                                          buildertek__Purchase_Order__c, 
                                                          buildertek__Purchase_Order__r.Name,
                                                          buildertek__Quantity__c,
                                                          buildertek__Unit_Price__c,
                                                          buildertek__Description__c,
                                                          buildertek__Tax__c,
                                                          buildertek__Total_Price__c,
                                                          buildertek__Total_Amount_Tax__c, 
                                                          buildertek__Product__c,
                                                          buildertek__Product__r.ProductCode from Purchase_Order_Items__r)
                             FROM buildertek__Purchase_Order__c where (buildertek__Status__c != 'Ordered' AND buildertek__Status__c != 'Paid' AND buildertek__Status__c != 'Partially Paid') ORDER BY buildertek__Phase__c  DESC NULLS last, buildertek__Vendor__r.Name ASC NULLS last, Name DESC, buildertek__Status__c ASC  LIMIT :pageSize OFFSET :offset];    
        }
        
        map<String , List<buildertek__Purchase_Order__c>> GroupingMap = new map<String , List<buildertek__Purchase_Order__c>>(); 
        System.debug('MainpoRecList======>====='+MainpoRecList);
        for(buildertek__Purchase_Order__c POrec : MainpoRecList){
            System.debug('POrec======>'+POrec);
            if(POrec.Purchase_Order_Items__r.size() > 0){
                if(GroupingMap.get(POrec.buildertek__Phase__c) == null){
                    GroupingMap.put(POrec.buildertek__Phase__c , new List<buildertek__Purchase_Order__c>());
                }
                GroupingMap.get(POrec.buildertek__Phase__c).add(POrec);
            }
        }
        
        for(String PO : GroupingMap.keySet()){
            MasterBudgetsClass MasterBudgetsClassRecord = new MasterBudgetsClass(); 
            MasterBudgetsClassRecord.groupName = PO;
            MasterBudgetsClassRecord.poCheck = false;
            MasterBudgetsClassRecord.expanded = false; 
            MasterBudgetsClassRecord.pageSize = pageSize;
            if(poFilter != '' || poLineFilter != '' || tradeTypeFilter != '' || projectFilter != '' || productFilter != '' || permitFilter != ''){
                MasterBudgetsClassRecord.pageNumber = 1;  
            }else{
                MasterBudgetsClassRecord.pageNumber = pageNumber;
            }
            MasterBudgetsClassRecord.recordStart = offset + 1;
            MasterBudgetsClassRecord.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
            MasterBudgetsClassRecord.totalRecords = totalRecords; 
            MasterBudgetsClassRecord.orgCurr = orgCurr;
            
            List<POInnerClass> POInnerClassList = new List<POInnerClass>();
            List<POLinesWrapper> POLinesList = new List<POLinesWrapper>(); 
            
            for(buildertek__Purchase_Order__c PO1 : GroupingMap.get(PO)){
                system.debug('varmatest--->'+PO1.Purchase_Order_Items__r.size());
                if(PO1.Purchase_Order_Items__r.size() > 0){
                    POInnerClass POInnerClassRecord = new POInnerClass();
                    POLinesList = new List<POLinesWrapper>();
                    for(buildertek__Purchase_Order_Item__c lines : PO1.Purchase_Order_Items__r){
                        POLinesWrapper POLi = new POLinesWrapper();
                        if(poLineFilter != '' && poLineFilter != null && productFilter != '' && productFilter != null){
                            if(lines.Name != null && lines.Name != '' && lines.buildertek__Product__r.ProductCode != null && lines.buildertek__Product__r.ProductCode != ''){
                                if(lines.Name.toLowercase().contains(poLineFilter.toLowercase()) && lines.buildertek__Product__r.ProductCode.toLowercase().contains(productFilter.toLowercase())){
                                    POLi.RecordId = lines.Id;
                                    POLi.Name = lines.Name;
                                    system.debug('innerif'+lines.buildertek__Description__c);
                                    POLi.Description = lines.buildertek__Description__c;
                                    POLi.PurchaseOrder = lines.buildertek__Purchase_Order__r.Name;
                                    POLi.Quantity = lines.buildertek__Quantity__c;
                                    POLi.UnitCost = lines.buildertek__Unit_Price__c ;
                                    POLi.TaxRate = lines.buildertek__Tax__c ;
                                    POLi.TotalPrice = lines.buildertek__Total_Price__c ;
                                    POLi.TotalCost = lines.buildertek__Total_Amount_Tax__c;
                                    POLi.expanded = false;
                                    POLi.PORow = false;
                                    POLi.poLineCheck = false;
                                    // POLi.ProductCode = lines.buildertek__Product__r.ProductCode;
                                    POLinesList .add(POLi); 
                                }
                            }
                        }
                        else if(productFilter != '' && productFilter != null){
                            if (lines.buildertek__Product__r.ProductCode != null && lines.buildertek__Product__r.ProductCode != '') {
                                if(lines.buildertek__Product__r.ProductCode.toLowercase().contains(productFilter.toLowercase())){
                                    POLi.RecordId = lines.Id;
                                    POLi.Name = lines.Name;
                                    system.debug('innerif'+lines.buildertek__Description__c);
                                    POLi.Description = lines.buildertek__Description__c;
                                    POLi.PurchaseOrder = lines.buildertek__Purchase_Order__r.Name;
                                    POLi.Quantity = lines.buildertek__Quantity__c;
                                    POLi.UnitCost = lines.buildertek__Unit_Price__c ;
                                    POLi.TaxRate = lines.buildertek__Tax__c ;
                                    POLi.TotalPrice = lines.buildertek__Total_Price__c ;
                                    POLi.TotalCost = lines.buildertek__Total_Amount_Tax__c;
                                    POLi.expanded = false;
                                    POLi.PORow = false;
                                    POLi.poLineCheck = false;
                                    // POLi.ProductCode = lines.buildertek__Product__r.ProductCode;
                                    POLinesList .add(POLi); 
                                }
                            }
                        }
                        else if(poLineFilter != '' && poLineFilter != null){
                            if(lines.Name != null && lines.Name != ''){
                                if(lines.Name.toLowercase().contains(poLineFilter.toLowercase())){
                                    POLi.RecordId = lines.Id;
                                    POLi.Name = lines.Name;
                                    system.debug('innerif'+lines.buildertek__Description__c);
                                    POLi.Description = lines.buildertek__Description__c;
                                    POLi.PurchaseOrder = lines.buildertek__Purchase_Order__r.Name;
                                    POLi.Quantity = lines.buildertek__Quantity__c;
                                    POLi.UnitCost = lines.buildertek__Unit_Price__c ;
                                    POLi.TaxRate = lines.buildertek__Tax__c ;
                                    POLi.TotalPrice = lines.buildertek__Total_Price__c ;
                                    POLi.TotalCost = lines.buildertek__Total_Amount_Tax__c;
                                    POLi.expanded = false;
                                    POLi.PORow = false;
                                    POLi.poLineCheck = false;
                                    // POLi.ProductCode = lines.buildertek__Product__r.ProductCode;
                                    POLinesList .add(POLi); 
                                }
                            }
                        }
                        else if((poLineFilter == '' || poLineFilter == null) && (productFilter == '' || productFilter == null)){
                            POLi.RecordId = lines.Id;
                            POLi.Name = lines.Name;
                            POLi.Description = lines.buildertek__Description__c;
                            POLi.PurchaseOrder = lines.buildertek__Purchase_Order__r.Name;
                            POLi.Quantity = lines.buildertek__Quantity__c;
                            POLi.UnitCost = lines.buildertek__Unit_Price__c ;
                            POLi.TaxRate = lines.buildertek__Tax__c ;
                            POLi.TotalPrice = lines.buildertek__Total_Price__c ;
                            POLi.TotalCost = lines.buildertek__Total_Amount_Tax__c;
                            POLi.expanded = false;
                            POLi.PORow = false;
                            POLi.poLineCheck = false;
                            // POLi.ProductCode = lines.buildertek__Product__r.ProductCode;
                            POLinesList .add(POLi);  
                        }
                        
                    }

                    if (POLinesList.size() > 0) {
                        POLinesWrapper POLi1 = new POLinesWrapper();
                        POLi1.coastType =  'PO Total';
                        POLi1.coastValue = PO1.buildertek__PO_Total__c;
                        POLi1.PORow = true;
                        POLinesList.add(POLi1);  
    
                        POLinesWrapper POLi2 = new POLinesWrapper();
                        POLi2.coastType =  'Paid Amount';
                        POLi2.coastValue = PO1.buildertek__Paid_Amount__c;
                        POLi2.PORow = true;
                        POLinesList.add(POLi2); 
    
                        POLinesWrapper POLi3 = new POLinesWrapper();
                        POLi3.coastType =  'PO Balance';
                        POLi3.coastValue = PO1.buildertek__PO_Balance__c;
                        POLi3.PORow = true;
                        POLinesList.add(POLi3); 
                    }
                    
                    POInnerClassRecord.poLinesWrapper = POLinesList;
                    POInnerClassRecord.poCheck = false;
                    POInnerClassRecord.poRecord = PO1;
                    POInnerClassRecord.expanded = false;
                    
                    if(POLinesList.size() > 0){
                        POInnerClassList.add(POInnerClassRecord); 
                    }
                }
            }
            
            system.debug('polinelist Size'+POInnerClassList.size());
            if(POInnerClassList.size() > 0){
                
                MasterBudgetsClassRecord.poRecordList = GroupingMap.get(PO);
                MasterBudgetsClassRecord.poRecInner = POInnerClassList; 
            }
            
            MasterBudgetsClassList.add(MasterBudgetsClassRecord); 
            
        }

        return  MasterBudgetsClassList;   
    }
    
    public class MasterBudgetsClass{
        
        @AuraEnabled
        public buildertek__Purchase_Order__c poRecord {get;set;}
        
        @AuraEnabled
        public boolean poCheck {get;set;}
        
        @AuraEnabled
        public String groupName {get;set;}
        
        @AuraEnabled
        public List<buildertek__Purchase_Order__c> poRecordList {get;set;}
        
        @AuraEnabled
        public List<POInnerClass> poRecInner {get;set;}
        
        @AuraEnabled 
        public boolean expanded;
        
        @AuraEnabled
        public Integer pageSize{ get; set; }
        
        @AuraEnabled
        public Integer pageNumber{ get; set; }
        
        @AuraEnabled
        public Integer totalRecords {get;set;}
        
        @AuraEnabled
        public Integer recordStart {get;set;}
        
        @AuraEnabled
        public Integer recordEnd {get;set;}

        @AuraEnabled public String orgCurr;
        
    }
    
    public class POInnerClass{
        @AuraEnabled
        public boolean poCheck {get;set;}
        
        @AuraEnabled
        public buildertek__Purchase_Order__c poRecord {get;set;}
        
        @AuraEnabled
        public List<POLinesWrapper> poLinesWrapper {get;set;}
        
        @AuraEnabled public Boolean expanded;
    }
    
    public class POLinesWrapper{
        @AuraEnabled public String Name;
        @AuraEnabled public String Description;
        @AuraEnabled public Id RecordId;
        @AuraEnabled public String PurchaseOrder;
        @AuraEnabled public decimal Quantity;
        @AuraEnabled public decimal UnitCost;
        @AuraEnabled public decimal TotalCost;
        @AuraEnabled public decimal TaxRate;
        @AuraEnabled public decimal TotalPrice;
        @AuraEnabled public Boolean expanded;
        @AuraEnabled public Boolean PORow;
        @AuraEnabled public String coastType;
        @AuraEnabled public decimal coastValue;
        @AuraEnabled public String ProductCode;

        @AuraEnabled public String groupName {get;set;}
        
        @AuraEnabled
        public boolean poLineCheck {get;set;}
    } 
    
    @AuraEnabled
    public static object findByName(String searchKey , string recId, Integer pageNumber, Integer pageSize) {
        
        system.debug('pageNumber--------->'+pageNumber);
        system.debug('pageSize----------->'+pageSize);
        
        Integer offset;
        offset = (pageNumber - 1) * pageSize;
        
        Integer totalRecords = 0;
        
        Integer recordEnd = pageSize * pageNumber;
        
        system.debug('recordEnd------->'+recordEnd);
        
        
        map<String , List<buildertek__Purchase_Order__c>> GroupingMap = new map<String , List<buildertek__Purchase_Order__c>>(); 
        List<MasterBudgetsClass> MasterBudgetsClassList = new List<MasterBudgetsClass>();
        
        List<buildertek__Purchase_Order__c> nullspoRecList;
        
        List<buildertek__Purchase_Order__c> MainpoRecList = new List<buildertek__Purchase_Order__c>();
        
        String  name = '%' + searchKey + '%'; 
        if(name != null){
            If(Schema.sObjectType.buildertek__Purchase_Order__c.fields.Name.isAccessible() &&
               Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Phase__c.isAccessible() &&
               Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Vendor__c.isAccessible() &&
               Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Status__c.isAccessible() &&
               Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Description__c.isAccessible() &&
               Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__PO_Total__c.isAccessible() &&
               Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Paid_Amount__c.isAccessible() &&
               Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Change_Order__c.isAccessible() &&
               Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Date_Ordered__c.isAccessible() &&
               Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__PO_Balance__c.isAccessible()){ 
                   MainpoRecList = [SELECT Id,
                                    Name, 
                                    buildertek__Type__c,
                                    toLabel(buildertek__Phase__c),
                                    buildertek__Vendor__c,
                                    buildertek__Vendor__r.Name,
                                    buildertek__Vendor__r.buildertek__Email_Address__c,
                                    buildertek__Status__c,
                                    buildertek__Description__c,
                                    buildertek__Change_Order__c,
                                    buildertek__Change_Order__r.Name,
                                    buildertek__PO_Total__c,
                                    buildertek__Paid_Amount__c,
                                    buildertek__PO_Balance__c,
                                    buildertek__Date_Ordered__c,
                                    buildertek__Project__c,
                                    buildertek__Project__r.Name,(select Id, Name, 
                                                                 buildertek__Purchase_Order__c, 
                                                                 buildertek__Purchase_Order__r.Name,
                                                                 buildertek__Quantity__c,
                                                                 buildertek__Unit_Price__c,
                                                                 buildertek__Total_Amount_Tax__c from Purchase_Order_Items__r)
                                    FROM buildertek__Purchase_Order__c where (buildertek__Vendor__r.Name LIKE :name or Name LIKE :name  or buildertek__Status__c LIKE :name or buildertek__Project__r.Name LIKE :name) ORDER BY buildertek__Phase__c  DESC NULLS last, Name DESC, buildertek__Status__c ASC  LIMIT :pageSize OFFSET :offset];    
               }
        } 
        
        for(buildertek__Purchase_Order__c POrec : MainpoRecList){
            if(GroupingMap.get(POrec.buildertek__Phase__c) == null){
                GroupingMap.put(POrec.buildertek__Phase__c , new List<buildertek__Purchase_Order__c>());
            }
            GroupingMap.get(POrec.buildertek__Phase__c).add(POrec);
        }
        
        
        for(String PO : GroupingMap.keySet()){
            MasterBudgetsClass MasterBudgetsClassRecord = new MasterBudgetsClass(); 
            MasterBudgetsClassRecord.groupName = PO;
            MasterBudgetsClassRecord.poCheck = false;
            MasterBudgetsClassRecord.expanded = false; 
            MasterBudgetsClassRecord.pageSize = pageSize;
            MasterBudgetsClassRecord.pageNumber = pageNumber;
            MasterBudgetsClassRecord.recordStart = offset + 1;
            MasterBudgetsClassRecord.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
            MasterBudgetsClassRecord.totalRecords = totalRecords; 
            MasterBudgetsClassRecord.poRecordList = GroupingMap.get(PO);
            List<POInnerClass> POInnerClassList = new List<POInnerClass>();
            List<POLinesWrapper> POLinesList = new List<POLinesWrapper>(); 
            
            for(buildertek__Purchase_Order__c PO1 : GroupingMap.get(PO)){
                POInnerClass POInnerClassRecord = new POInnerClass();
                POInnerClassRecord.poCheck = false;
                POInnerClassRecord.poRecord = PO1;
                POInnerClassRecord.expanded = false;
                POInnerClassList.add(POInnerClassRecord); 
                POLinesList = new List<POLinesWrapper>();
                for(buildertek__Purchase_Order_Item__c lines : PO1.Purchase_Order_Items__r){
                    POLinesWrapper POLi = new POLinesWrapper();
                    POLi.RecordId = lines.Id;
                    POLi.Name = lines.Name;
                    POLi.PurchaseOrder = lines.buildertek__Purchase_Order__r.Name;
                    POLi.Quantity = lines.buildertek__Quantity__c;
                    POLi.UnitCost = lines.buildertek__Unit_Price__c ;
                    POLi.TotalCost = lines.buildertek__Total_Amount_Tax__c;
                    POLi.expanded = false;
                    POLi.poLineCheck = false;
                    POLinesList .add(POLi);
                }
                POInnerClassRecord.poLinesWrapper = POLinesList;
            }
            
            
            MasterBudgetsClassRecord.poRecInner = POInnerClassList;
            MasterBudgetsClassList.add(MasterBudgetsClassRecord);
        }
        
        return  MasterBudgetsClassList;    
    }
    
    @AuraEnabled
    public static object findByName2(String searchKey ,String searchKey1 , string recId, Integer pageNumber, Integer pageSize) {
        
        system.debug('pageNumber--------->'+pageNumber);
        system.debug('pageSize----------->'+pageSize);
        
        Integer offset;
        offset = (pageNumber - 1) * pageSize;
        
        Integer totalRecords = 0;
        
        Integer recordEnd = pageSize * pageNumber;
        
        system.debug('recordEnd------->'+recordEnd);
        
        map<String , List<buildertek__Purchase_Order__c>> GroupingMap = new map<String , List<buildertek__Purchase_Order__c>>(); 
        List<MasterBudgetsClass> MasterBudgetsClassList = new List<MasterBudgetsClass>();
        
        List<buildertek__Purchase_Order__c> nullspoRecList;
        
        List<buildertek__Purchase_Order__c> MainpoRecList = new List<buildertek__Purchase_Order__c>();
        
        String  name =  + searchKey + '%'; 
        String poFilt = + searchKey1 + '%'; 
        if(name != null){
            If(Schema.sObjectType.buildertek__Purchase_Order__c.fields.Name.isAccessible() &&
               Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Phase__c.isAccessible() &&
               Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Vendor__c.isAccessible() &&
               Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Status__c.isAccessible() &&
               Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Description__c.isAccessible() &&
               Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__PO_Total__c.isAccessible() &&
               Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Paid_Amount__c.isAccessible() &&
               Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Change_Order__c.isAccessible() &&
               Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Date_Ordered__c.isAccessible() &&
               Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__PO_Balance__c.isAccessible()){ 
                   MainpoRecList = [SELECT Id,
                                    Name, 
                                    buildertek__Type__c,
                                    toLabel(buildertek__Phase__c),
                                    buildertek__Vendor__c,
                                    buildertek__Vendor__r.Name,
                                    buildertek__Vendor__r.buildertek__Email_Address__c,
                                    buildertek__Status__c,
                                    buildertek__Description__c,
                                    buildertek__Change_Order__c,
                                    buildertek__Change_Order__r.Name,
                                    buildertek__PO_Total__c,
                                    buildertek__Paid_Amount__c,
                                    buildertek__PO_Balance__c,
                                    buildertek__Date_Ordered__c,
                                    buildertek__Project__c,
                                    buildertek__Project__r.Name,(select Id, Name, 
                                                                 buildertek__Purchase_Order__c, 
                                                                 buildertek__Purchase_Order__r.Name,
                                                                 buildertek__Quantity__c,
                                                                 buildertek__Unit_Price__c,
                                                                 buildertek__Total_Amount_Tax__c from Purchase_Order_Items__r where (Name LIKE :name  ))
                                    FROM buildertek__Purchase_Order__c  ORDER BY buildertek__Phase__c  DESC NULLS last, Name DESC, buildertek__Status__c ASC  LIMIT :pageSize OFFSET :offset];    
               }
        }
        
        for(buildertek__Purchase_Order__c POrec : MainpoRecList){
            if(GroupingMap.get(POrec.buildertek__Phase__c) == null){
                GroupingMap.put(POrec.buildertek__Phase__c , new List<buildertek__Purchase_Order__c>());
            }
            GroupingMap.get(POrec.buildertek__Phase__c).add(POrec);
        }
        
        
        for(String PO : GroupingMap.keySet()){
            MasterBudgetsClass MasterBudgetsClassRecord = new MasterBudgetsClass(); 
            MasterBudgetsClassRecord.groupName = PO;
            MasterBudgetsClassRecord.poCheck = false;
            MasterBudgetsClassRecord.expanded = false; 
            MasterBudgetsClassRecord.pageSize = pageSize;
            MasterBudgetsClassRecord.pageNumber = pageNumber;
            MasterBudgetsClassRecord.recordStart = offset + 1;
            MasterBudgetsClassRecord.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
            MasterBudgetsClassRecord.totalRecords = totalRecords; 
            MasterBudgetsClassRecord.poRecordList = GroupingMap.get(PO);
            List<POInnerClass> POInnerClassList = new List<POInnerClass>();
            List<POLinesWrapper> POLinesList = new List<POLinesWrapper>(); 
            
            for(buildertek__Purchase_Order__c PO1 : GroupingMap.get(PO)){
                POInnerClass POInnerClassRecord = new POInnerClass();
                POInnerClassRecord.poCheck = false;
                POInnerClassRecord.poRecord = PO1;
                POInnerClassRecord.expanded = false;
                POInnerClassList.add(POInnerClassRecord); 
                POLinesList = new List<POLinesWrapper>();
                for(buildertek__Purchase_Order_Item__c lines : PO1.Purchase_Order_Items__r){
                    POLinesWrapper POLi = new POLinesWrapper();
                    POLi.RecordId = lines.Id;
                    POLi.Name = lines.Name;
                    POLi.PurchaseOrder = lines.buildertek__Purchase_Order__r.Name;
                    POLi.Quantity = lines.buildertek__Quantity__c;
                    POLi.UnitCost = lines.buildertek__Unit_Price__c ;
                    POLi.TotalCost = lines.buildertek__Total_Amount_Tax__c;
                    POLi.expanded = false;
                    POLinesList .add(POLi);
                }
                POInnerClassRecord.poLinesWrapper = POLinesList;
            }
            
            
            MasterBudgetsClassRecord.poRecInner = POInnerClassList;
            MasterBudgetsClassList.add(MasterBudgetsClassRecord);
        }
        
        return  MasterBudgetsClassList;  
    }
    
    public class PoDetailsInnerClass{
        @AuraEnabled
        public Decimal totalPOAmount {get;set;}
        
        @AuraEnabled
        public integer totalPOs {get;set;}
        
        @AuraEnabled
        public decimal totalPaidAmount {get;set;}
        
        @AuraEnabled
        public decimal totalRemainingAmount {get;set;}
        
        @AuraEnabled
        public decimal orderedPercent {get;set;}
        
        @AuraEnabled
        public decimal paidPercent {get;set;}
    }
    
    @AuraEnabled
    public static PoDetailsInnerClass getPORecListDetails(String recId){
        
        Integer totalRecords = 0;
        decimal totalPaid = 0;
        Integer totalOrderedPos = 0;
        decimal orderedPercent = 0;
        Integer totalPaidPOs = 0;
        decimal paidPercent = 0;
        
        List<buildertek__Purchase_Order__c> poRecList = [select Id,
                                                         Name,
                                                         buildertek__Type__c,
                                                         buildertek__Phase__c,
                                                         buildertek__Vendor__c,
                                                         buildertek__Vendor__r.Name,
                                                         buildertek__Status__c,
                                                         buildertek__Description__c,
                                                         buildertek__PO_Total__c,
                                                         buildertek__Paid_Amount__c,
                                                         buildertek__PO_Balance__c,
                                                         buildertek__Project__c
                                                         FROM buildertek__Purchase_Order__c ];
        
        
        totalRecords = [SELECT COUNT() FROM buildertek__Purchase_Order__c];
        
        AggregateResult result = [SELECT SUM(buildertek__PO_Total__c )totalPO, buildertek__Project__c FROM buildertek__Purchase_Order__c  group by buildertek__Project__c];
        
        decimal totalPOAmount = (decimal)result.get('totalPO');
        
        AggregateResult result1 = [SELECT SUM(buildertek__PO_Balance__c)totalPOBalance, buildertek__Project__c FROM buildertek__Purchase_Order__c  group by buildertek__Project__c];
        
        
        decimal totalPOBalance = (decimal)result1 .get('totalPOBalance');
        
        
        AggregateResult totalPaidPurchaseOrders  = [SELECT SUM(buildertek__Paid_Amount__c )totalPaid, buildertek__Status__c FROM buildertek__Purchase_Order__c where buildertek__Status__c = 'Paid' group by buildertek__Status__c ];
        
        totalPaid = (decimal)totalPaidPurchaseOrders.get('totalPaid');
        
        totalOrderedPOs = [SELECT COUNT() FROM buildertek__Purchase_Order__c where buildertek__Status__c = 'Ordered'];
        
        if(totalOrderedPOs > 0){
            orderedPercent = totalOrderedPOs;
        }
        
        
        totalPaidPOs = [SELECT COUNT() FROM buildertek__Purchase_Order__c where buildertek__Status__c = 'Paid' ];
        
        if(totalPaidPOs > 0){
            paidPercent = totalPaidPOs;       
        }
        
        if(totalRecords > 0){
            orderedPercent = (orderedPercent / totalRecords)*100;
            paidPercent = (paidPercent / totalRecords) * 100;
        }else{
            orderedPercent = orderedPercent;
            paidPercent = paidPercent;
        } 
        
        PoDetailsInnerClass MasterBudgetsClassRecord = new PoDetailsInnerClass();
        
        MasterBudgetsClassRecord.totalPOAmount = totalPOAmount;
        MasterBudgetsClassRecord.totalRemainingAmount = totalPOBalance;
        MasterBudgetsClassRecord.totalPOs = totalRecords;
        MasterBudgetsClassRecord.totalPaidAmount = totalPaid;
        MasterBudgetsClassRecord.orderedPercent = orderedPercent;
        MasterBudgetsClassRecord.paidPercent = paidPercent;
        
        return MasterBudgetsClassRecord;
    }
    
    @AuraEnabled
    public static MessageClass sendMail(List<String> budgetIds, string filedata){
        
        system.debug('budgetIds--------->'+budgetIds);
        
        system.debug('filedata------->'+filedata);
        
        List<Innerclass> inn;
        if(filedata != null && filedata != '' && filedata != '[]'){
            system.debug('filedata'+filedata);
            inn = (List<Innerclass>)JSON.deserialize((filedata),List<Innerclass>.Class);
            system.debug(inn);
            system.debug(inn[0].fileName);
            system.debug(inn[0].fileContent);
            system.debug('kdhiic------>'+inn[0].POId);
        }
        
        EmailTemplate et = [SELECT Id,Subject, Body FROM EmailTemplate WHERE name ='Purchase Order Template' limit 1];
        
        
        MessageClass msgCls = new MessageClass();
        
        List<String> VendorEmails = new List<String>();
        
        List<buildertek__Purchase_Order__c> poList = [Select Id, Name, buildertek__Vendor__c, buildertek__Vendor__r.buildertek__Email_Address__c, buildertek__Vendor__r.Name, buildertek__Status__c,buildertek__Date_Ordered__c,buildertek__PO_Total__c from buildertek__Purchase_Order__c Where Id IN: budgetIds];
        
        system.debug('poList--------->'+poList);
        
        List<buildertek__Purchase_Order__c> OrderedPOList =  new List<buildertek__Purchase_Order__c>();
        
        
        List<contact> conlist = [select id,name from contact limit 1];
        
        List<buildertek__ConfirmationPageSiteURL__c> confirmationurl = buildertek__ConfirmationPageSiteURL__c.getall().values();
        string SiteUrl;
        if(confirmationurl.size() > 0){
            SiteUrl = confirmationurl[0].buildertek__SiteURL__c ;
        }
        
        if(!poList.isEmpty()){
            
            // Step 0: Create a master list to hold the emails we'll send
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();

            Map<Id, List<ContentVersion>> conDocMap = new Map<Id, List<ContentVersion>>();
            List<ContentVersion> cvList = new List<ContentVersion>();
            
            for (buildertek__Purchase_Order__c myContact : poList) {
                if (myContact.buildertek__Vendor__c != null && myContact.buildertek__Vendor__r.buildertek__Email_Address__c != null) {
                    
                    // Update Puechase Order Status To Ordered
                    buildertek__Purchase_Order__c poRec = new buildertek__Purchase_Order__c();
                    poRec.buildertek__Status__c = 'Ordered';
                    poRec.buildertek__Date_Ordered__c = System.today();
                    poRec.Id = myContact.Id;
                    OrderedPOList.add(poRec);
                    //
                    
                    String body = '';
                    List<Messaging.SingleEmailMessage> lstMsgs = new List<Messaging.SingleEmailMessage>();
                    Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
                    msg.setTemplateId(et.Id);
                    msg.setWhatId(myContact.Id);
                    msg.setTargetObjectId(conlist[0].Id);
                    system.debug('testtttttttttttttt------------>'+myContact.buildertek__Vendor__r.buildertek__Email_Address__c);
                    msg.toAddresses = new String[] { myContact.buildertek__Vendor__r.buildertek__Email_Address__c };
                        //msg.setToAddresses(new list<string>{EmaiValue});
                        lstMsgs.add(msg);
                    //Messaging.sendEmail(lstMsgs);
                    Savepoint sp = Database.setSavepoint();
                    Messaging.sendEmail(lstMsgs);
                    Database.rollback(sp);
                    
                    system.debug('after savepoint------->');
                    
                    // List<Messaging.Emailfileattachment> signeefileAttachments = new List<Messaging.Emailfileattachment>();
                    
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setToAddresses(new list<string>{myContact.buildertek__Vendor__r.buildertek__Email_Address__c});
                    email.setSubject(lstMsgs[0].Subject);
                    
                    body += 'Hi, <br/><br/> ';
                    body += '</br> Please &nbsp;'; 
                    body += '<a href='+ SiteUrl +'buildertek__ConfirmationPage?Id='+myContact.Id+'&templateId='+et.Id+'>Click here</a>';
                    body += '&nbsp;to confirm your Purchase Order details.' ;
                    
                    //email.setPlainTextBody(emailBody);
                    email.setHtmlBody(body);
                    
                    system.debug('myContact.Id------->'+myContact.Id);
                    
                    PageReference pagePdf = new PageReference('/apex/PurchaseOrderAttachment'); 
                    pagePdf.getParameters().put('budgetId', myContact.Id);
                    
                    blob pdfPageBlob = pagePdf.getContentAsPDF();
                    List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();

                    if(filedata != null && filedata != '' && filedata != '[]'){
                        for(Innerclass i:inn){
                            system.debug('myContact.id------->'+myContact.id);
                            system.debug('i.POId--------->'+i.POId);
                            if(myContact.id == i.POId){
                                Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();  
                                efa.setFileName(i.fileName); 
                                system.debug('wiuhwih------->'+EncodingUtil.base64Decode(i.fileContent));
                                efa.setBody(EncodingUtil.base64Decode(i.fileContent)); 
                                //efa.setContentType('application/pdf');
                                fileAttachments.add(efa);

                                // Below code for saving Document into Files section.
                                ContentVersion contentVersion = new ContentVersion(Title = i.fileName, PathOnClient = i.fileName, VersionData = EncodingUtil.base64Decode(i.fileContent), IsMajorVersion = true);
                                cvList.add(contentVersion);

                                if(!conDocMap.containsKey(myContact.Id)){
                                    conDocMap.put(myContact.Id, new List<ContentVersion>());
                                }
                                conDocMap.get(myContact.Id).add(contentVersion);

                            }
                        }
                    }
                    if(fileAttachments.size()>0){
                        email.setFileAttachments(fileAttachments);
                    }
                    mails.add(email);
                }
            }
            // Step 6: Send all emails in the master list
            Messaging.sendEmail(mails);
            msgCls.Status = 'Success';
            msgCls.Message = 'Email sent to selected Vendors successfully';

            System.debug('Started-----');
            if(cvList.size() > 0) {
                cvList = new List<ContentVersion>();
                for(Id ids : conDocMap.keySet()){
                    List<ContentVersion> cvl = new List<ContentVersion>();
                    cvl = conDocMap.get(ids);
                    insert cvl;
                    cvList.addAll(cvl);
                    conDocMap.put(ids, cvl);
                }
                List<ContentVersion> documents = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id IN :cvList];
                List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();

                for(buildertek__Purchase_Order__c myContact : poList) {
                    List<ContentVersion> cvlinklist = new List<ContentVersion>();
                    cvlinklist = conDocMap.get(myContact.Id);
                    if (cvlinklist != null) {
                        for(Integer i=0; i<documents.size(); i++){
                            for(ContentVersion cvl : cvlinklist) {
                                if(cvl.Id == documents[i].Id){
                                    ContentDocumentLink cdl = new ContentDocumentLink();
                                    cdl.LinkedEntityId = myContact.Id;
                                    cdl.ContentDocumentId = documents[i].ContentDocumentId;
                                    cdl.ShareType = 'V';
                                    cdl.Visibility = 'AllUsers';
                                    cdlList.add(cdl);
                                    System.debug('ContentDocumentLink Added.');
                                }
                            }
                        }
                    }
                }
                if(cdlList.size() > 0){
                    insert cdlList;
                }
            }
            
        }else{
            msgCls.Status = 'Failed';
            msgCls.Message = 'Please select atleast one Purchase Order'; 
        }
        
        system.debug('OrderedPOList----->'+OrderedPOList);
        
        if(!OrderedPOList.isEmpty()){
            update OrderedPOList;
        }
        
        return msgCls ;
    }
    
    public class MessageClass{
        @AuraEnabled
        public String Status {get;set;}
        @AuraEnabled
        public string Message {get;set;}
        
    } 
    
    public class Innerclass{
        @AuraEnabled public string fileName;
        @AuraEnabled public string fileContent;
        @AuraEnabled public string POId;
    }
    
    @AuraEnabled  
    public static String getContactName(String recId){
        if(recId != null && recId != ''){
            List<Contact> conList = [select Name from Contact where buildertek__Primary_PO_Contact__c = True AND AccountId =: recId];
            System.debug('Contacts : '+conList);
            if(conList.size() > 0){
                return conList[0].Name;
            }
            else{
                return 'undefine';
            }
        }
        else{
            return 'Id is null';
        }
    }
    
    @AuraEnabled 
    public static String updatePOLines(List<String> poLineIds, decimal unitCostValue){
        system.debug('poLineIds------------>'+unitCostValue);
        if(poLineIds.size() > 0){
            List<buildertek__Purchase_Order_Item__c> poLineList = [select Id, Name, buildertek__Unit_Price__c from buildertek__Purchase_Order_Item__c where Id IN: poLineIds];
            system.debug('poLineList------>'+poLineList);
            List<buildertek__Purchase_Order_Item__c> newPOLinesList = new List<buildertek__Purchase_Order_Item__c>();
            for(buildertek__Purchase_Order_Item__c poline : poLineList){
                buildertek__Purchase_Order_Item__c pol = new buildertek__Purchase_Order_Item__c();
                pol.Id = poline.Id;
                pol.Name = poline.Name;
                pol.buildertek__Unit_Price__c =  unitCostValue;
                newPOLinesList.add(pol);
            }
            
            
            system.debug('newPOLinesList------->'+newPOLinesList);
            
            if(!newPOLinesList.isEmpty()){
                update newPOLinesList;
            }
            
        }
        return 'success';
    }
    
}