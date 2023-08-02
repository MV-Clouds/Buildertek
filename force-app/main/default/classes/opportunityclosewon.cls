public class opportunityclosewon {
 @AuraEnabled
    public static List<buildertek__Project__c> getprojectRecord(String opptyRecId) {
        Opportunity oppRec = [Select Id,Name,AccountId From Opportunity WHERE Id =: opptyRecId];
        return new List<buildertek__Project__c>([Select id,Name,buildertek__Community__c,buildertek__Address__c from buildertek__Project__c where buildertek__Customer__c = null AND  Name =: oppRec.Name]);
   }


    @AuraEnabled
    public static String opptyStageValueCheckandProject(String recordId){
        String type='Opportunity';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(type);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        
        
        /*for (String fieldName: fieldMap.keySet()) {
            System.debug('##Field API Name='+fieldName);// list of all field API name        
            fieldMap.get(fieldName).getDescribe().getLabel();//It provides to get the object fields label.
          }*/
        
        if(fieldMap.keySet().contains('buildertek__checkopptystage__c')){
            List<Opportunity> opptyrecList = [Select Id,Name,AccountId, StageName,buildertek__checkOpptyStage__c FROM Opportunity WHERE Id =: recordId];
            system.debug(opptyrecList[0].AccountId);
            if(opptyrecList[0].AccountId != null){
               system.debug(opptyrecList);
               List<buildertek__Project__c> projects = [Select Id,Name,buildertek__Account__c FROM buildertek__Project__c Where buildertek__Customer__c =: opptyrecList[0].AccountId];
                system.debug(projects);
                if(projects.Size() > 0){
                    return 'Already linked to project';
                }
            }else if(opptyrecList[0].AccountId == null){
                return 'No Account';
            }
            return opptyrecList[0].buildertek__checkOpptyStage__c;
        }
        return 'false';
        
    }
  
  @AuraEnabled
    public static String updateproject(List<String>projectIds, String oppId){
        try{
            List<String> SelectedProjectIds = projectIds;
            List<Opportunity> updateoppsList = new List<Opportunity>();
            // List<String> RFQrecordIds = productIds;
            
            String RfqRecId = oppId;
            // String budgetRecId = RfqId;
            
            
            Opportunity opp = [SELECT Id, AccountId, Account.Name from Opportunity where Id =: oppId];
            String type='Opportunity';
            
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType leadSchema = schemaMap.get(type);
            Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
            if(fieldMap.keySet().contains('buildertek__checkopptystage__c')){
                Opportunity updateOpp = new Opportunity();
                updateOpp.buildertek__checkOpptyStage__c = 'Project Created';
                updateOpp.Id = opp.Id;
                updateoppsList.add(updateOpp);
                
                update updateoppsList;
            }
            
            
            List<buildertek__Project__c> Projects = [Select id,Name,buildertek__Community__c,buildertek__Address__c from buildertek__Project__c where Id IN :SelectedProjectIds];
             List<buildertek__Project__c> projItemList = new List<buildertek__Project__c>();
            for( buildertek__Project__c Project : Projects){
               // Opportunity projItem = new Opportunity();
                 Project.buildertek__Customer__c=opp.AccountId;
               
                projItemList.add(Project);
            }
           
            system.debug(projItemList);
            update projItemList;
            return projItemList[0].id;
        }catch (Exception ex){
            String error =ex.getMessage();
            return error;
        }
        
    }
    
    
    @AuraEnabled
    public Static String setopptyCheckFieldFasle( String oppId){
        List<Opportunity> updateoppsList = new List<Opportunity>();
        
        Opportunity opp = [SELECT Id, Name,AccountId, Account.Name from Opportunity where Id =: oppId];
        buildertek__Project__c newProject = new buildertek__Project__c();
        newProject.buildertek__Customer__c= opp.AccountId;
        newProject.Name = opp.Name;//+'-'+opp.Account.Name;
        insert newProject;
        String type = 'Opportunity';
        
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType leadSchema = schemaMap.get(type);
            Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
            if(fieldMap.keySet().contains('buildertek__checkopptystage__c')){
                    //Opportunity opp = [SELECT Id, AccountId, Account.Name from Opportunity where Id =: oppId];
                Opportunity updateOpp = new Opportunity();
                updateOpp.buildertek__checkOpptyStage__c = 'Project Created';
                updateOpp.Id = oppId;
                updateoppsList.add(updateOpp);
                
                update updateoppsList;
               // return updateOpp.buildertek__checkOpptyStage__c;
            }
        if(newProject.Id != null){
            return newProject.Id;
        }
            return 'false';
        
    }
    
   @AuraEnabled
    public static String getadminvalue(){
        System.debug('---getadminvalue---');
        buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [Select Id,buildertek__Assign_to_Existing_Project_on_Closed_Won__c
                                                                                              from buildertek__Admin_Interface_Node_Configuration__c
                                                                                              WHERE Name = :'Opportunity Configuration' AND buildertek__Assign_to_Existing_Project_on_Closed_Won__c !=false];
                                                                                              System.debug('adminInterfaceNodeConfigurations-->'+adminInterfaceNodeConfigurations);
        if(adminInterfaceNodeConfigurations.buildertek__Assign_to_Existing_Project_on_Closed_Won__c == true){
            return 'success';
        }else{
            return 'error';
        }
    } 
     @AuraEnabled
    public static projDataTableWrapper getProjects(Integer pageNumber, Integer pageSize, string projRecId, String projectName, String Community, String Address,String opptyRecId){
        List<buildertek__Project__c> projectList = new List<buildertek__Project__c>();
        
       
        
        
        Integer offset = (pageNumber - 1) * pageSize;
        //Total Records 
        Integer totalRecords = 0;
        //system.debug('pricebook'+priceBook);
        list<String> pB1 = new list<String>();
        
        
       /* if(priceBook != '' && priceBook != null){
            system.debug('pricebookAt starting'+priceBook);
            String query1 = 'select Id, Name,Pricebook2.Name,Product2Id from PricebookEntry where Pricebook2.Name LIKE  \'%'+String.escapeSingleQuotes(priceBook)+'%\'';
            system.debug('query111111111'+query1);
            list<PricebookEntry> productIdInPB = Database.Query(query1);
            
            
            for(PricebookEntry Pricebook1 : productIdInPB){
                pB1.add(Pricebook1.Product2Id);
            }
        }
        system.debug('pbe'+pB1);*/
        
         Opportunity oppRec = [Select Id,Name,AccountId From Opportunity WHERE Id =: opptyRecId];
        String oppName= oppRec.Name;
        if(projectName != '' || Community != '' || Address != ''){
            String query = 'Select COUNT() FROM buildertek__Project__c  where id!=NULL  AND buildertek__Customer__c = null  AND  Name =: oppName ';
            if(projectName != '' && projectName != null){
                query = query+ ' AND Name LIKE \'%'+String.escapeSingleQuotes(projectName)+'%\'';
            }
            if(Community != '' && Community != null){
                query = query+ ' AND buildertek__Community__c LIKE \'%'+String.escapeSingleQuotes(Community)+'%\'';
            }
            if(Address != '' && Address != null){
                query = query+ ' AND buildertek__Address__c LIKE \'%'+String.escapeSingleQuotes(Address)+'%\'';
                system.debug(query);
            }
            
           
            //system.debug('111111111111111111111111'+query);
            totalRecords = Database.countQuery(query);
            system.debug('TotalRecords'+totalRecords);
        }else{
            totalRecords = [SELECT COUNT() FROM buildertek__Project__c where buildertek__Customer__c = null  AND  Name =: oppName ];
        }
        /* else{
totalRecords = [SELECT COUNT() FROM buildertek__RFQ__c 
WHERE buildertek__Status__c ='Awarded' OR buildertek__Status__c ='Accepted'];
}  */
        
        
        Integer recordEnd = pageSize * pageNumber;
        
        //Instance of Contact DataTable Wrapper Class
        projDataTableWrapper objDT = new projDataTableWrapper();
        objDT.pageSize = pageSize;
        objDT.pageNumber = pageNumber;
        objDT.recordStart = offset + 1;
        objDT.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
        objDT.totalRecords = totalRecords;
        if(projectName != '' || Community != '' || Address != '' ){
            String queryList = 'Select Id,Name,buildertek__Community__c,buildertek__Address__c FROM buildertek__Project__c  WHERE  Name =:oppName  AND buildertek__Customer__c = null ';
            if(projectName != '' && projectName != null){
                queryList = queryList+ ' AND (Name LIKE \'%'+projectName+'%\')'; //String.escapeSingleQuotes(description)
            }
            if(Community != '' && Community != null){
                queryList = queryList+ ' AND (buildertek__Community__c LIKE \'%'+Community+'%\')';
            }
            if(Address != '' && Address != null){
                queryList = queryList+ ' AND (buildertek__Address__c LIKE \'%'+Address+'%\')';
                system.debug(queryList);
            }
            
            queryList = queryList+ ' ORDER BY Name LIMIT :pageSize OFFSET :offset';
            // system.debug(queryList);
            objDT.recordList = Database.query(queryList);
            // system.debug(objDT.recordList);
            
        }
        else{
             objDT.recordList = [Select Id,Name,buildertek__Community__c,buildertek__Address__c FROM buildertek__Project__c where buildertek__Customer__c = null AND  Name =: oppName  ORDER BY Name 
                                LIMIT :pageSize
                                OFFSET :offset];
        }
        
        
        return objDT;
        //return rfqList;
    }
    
    
    
    
 public class projDataTableWrapper{
        @AuraEnabled
        public Integer pageSize{ get; set; }
        
        @AuraEnabled
        public Integer pageNumber{ get; set; }
        
        @AuraEnabled
        public Integer totalRecords{ get; set; }
        
        @AuraEnabled
        public Integer recordStart{ get; set; }
        
        @AuraEnabled
        public Integer recordEnd{ get; set; }
        
        @AuraEnabled
        public List<buildertek__Project__c> recordList{ get; set; }
    }      
}