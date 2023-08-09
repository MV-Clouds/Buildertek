public class ImportPackageLines {
    
    @AuraEnabled
    public static string insertData(String strfromle){
        String returnresponse ='';
        List<buildertek__Package_Line__c> PurchaseOrderListtoInsert = new List<buildertek__Package_Line__c>();
        //system.debug('strfromle = ' + strfromle);
        List<fieldWrapper> datalist = (List<fieldWrapper>)JSON.deserialize(strfromle, List<fieldWrapper>.class);
        
        
        // For Projects
        list<String> projectNames = new List<String>();
        
        for(fieldWrapper wrapper: datalist){
            if(wrapper.Project != null && wrapper.Project != ''){
                projectNames.add(wrapper.Project);
            }
        }
        list<buildertek__Trade_Type__c> project1 = new list<buildertek__Trade_Type__c>();
        project1 = [select Id, Name from buildertek__Trade_Type__c where Name IN: projectNames];
        
        map<String, buildertek__Trade_Type__c> projectmap = new map<String,buildertek__Trade_Type__c>();
        for(buildertek__Trade_Type__c projectItem : project1){
            projectmap.put(projectItem.Name,projectItem); 
        }
        
        
        // For Community
        list<String> communityNames = new List<String>();
        
        for(fieldWrapper wrapper: datalist){
            if(wrapper.Community != null && wrapper.Community != ''){
                communityNames.add(wrapper.Community);
            }
        }
        list<buildertek__Category__c> community1 = new list<buildertek__Category__c>();
        community1 = [select Id, Name from buildertek__Category__c where Name IN: communityNames];
        map<String, buildertek__Category__c> communitymap = new map<String,buildertek__Category__c>();
        for(buildertek__Category__c communityItem : community1){
            communitymap.put(communityItem.Name,communityItem); 
        }
        
        
        
        
        // For BuildPhase
        list<String> buildPhaseNames = new List<String>();
        
        for(fieldWrapper wrapper: datalist){
            if(wrapper.BuildPhase != null && wrapper.BuildPhase != ''){
                buildPhaseNames.add(wrapper.BuildPhase);
            }
        }
        list<buildertek__Product_Type__c> buildPhase1 = new list<buildertek__Product_Type__c>();
        buildPhase1 = [select Id, Name from buildertek__Product_Type__c where Name IN: buildPhaseNames];
        map<String, buildertek__Product_Type__c> buildPhasemap = new map<String,buildertek__Product_Type__c>();
        for(buildertek__Product_Type__c communityItem : buildPhase1){
            buildPhasemap.put(communityItem.Name,communityItem); 
        }
        
        //system.debug('datalist = ' + datalist);
        //system.debug('datalistSize = ' + datalist.size());
        for(fieldWrapper wrapper: datalist){
            buildertek__Package_Line__c PO =new  buildertek__Package_Line__c();
          
            
            if(projectmap.keySet().contains(wrapper.Project) && wrapper.Project != null && wrapper.Project != ''){
                PO.buildertek__Trade_Type__c = projectmap.get(wrapper.Project).Id;
            }
            
            system.debug('projectmap'+projectmap);
            
            if(communitymap.keySet().contains(wrapper.Community) && wrapper.Community != null && wrapper.Community != ''){
                PO.buildertek__Category__c = communitymap.get(wrapper.Community).Id;
            }
            
             if(buildPhasemap.keySet().contains(wrapper.BuildPhase) && wrapper.BuildPhase != null && wrapper.BuildPhase != ''){
                PO.buildertek__Product_Type__c = buildPhasemap.get(wrapper.BuildPhase).Id;
            }
            
            PO.buildertek__Quantity__c = wrapper.Type;
            
            PO.buildertek__Location__c = wrapper.PlanType;
            PO.buildertek__UOM__c = wrapper.UOM;
            
           
            
            PurchaseOrderListtoInsert.add(PO); 
             system.debug('takeofflist to insert'+PurchaseOrderListtoInsert);
        }
         system.debug('takeofflist to insert'+PurchaseOrderListtoInsert.size());
        
        if(PurchaseOrderListtoInsert.size() > 0){
            try {
                insert PurchaseOrderListtoInsert;
                
                system.debug('takeofflist to insert'+PurchaseOrderListtoInsert);
                returnresponse = 'SUCCESS';
            }
            catch(Exception ex){
                returnresponse = 'ERROR';
            }
        }
        return returnresponse;
    }
    
    public class fieldWrapper{        
      
        public String Project;
        public String Community;
        public String BuildPhase;
        public Decimal Type;
        public String PlanType;
        public String UOM ;
    } 
    
    
}