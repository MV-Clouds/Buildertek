public class BT_ImportTakeoff {
    
    @AuraEnabled
    public static string insertData(String strfromle){
        String returnresponse ='';
        List<buildertek__Project_Takeoff__c> PurchaseOrderListtoInsert = new List<buildertek__Project_Takeoff__c>();
        //system.debug('strfromle = ' + strfromle);
        List<fieldWrapper> datalist = (List<fieldWrapper>)JSON.deserialize(strfromle, List<fieldWrapper>.class);
        
        
        // For Projects
        list<String> projectNames = new List<String>();
        
        for(fieldWrapper wrapper: datalist){
            if(wrapper.Project != null && wrapper.Project != ''){
                projectNames.add(wrapper.Project);
            }
        }
        list<buildertek__Project__c> project1 = new list<buildertek__Project__c>();
        project1 = [select Id, Name from buildertek__Project__c where Name IN: projectNames];
        
        map<String, buildertek__Project__c> projectmap = new map<String,buildertek__Project__c>();
        for(buildertek__Project__c projectItem : project1){
            projectmap.put(projectItem.Name,projectItem); 
        }
        
        
        // For Community
        list<String> communityNames = new List<String>();
        
        for(fieldWrapper wrapper: datalist){
            if(wrapper.Community != null && wrapper.Community != ''){
                communityNames.add(wrapper.Community);
            }
        }
        list<buildertek__Community__c> community1 = new list<buildertek__Community__c>();
        community1 = [select Id, Name from buildertek__Community__c where Name IN: communityNames];
        map<String, buildertek__Community__c> communitymap = new map<String,buildertek__Community__c>();
        for(buildertek__Community__c communityItem : community1){
            communitymap.put(communityItem.Name,communityItem); 
        }
        
        
        
        
        // For BuildPhase
        list<String> buildPhaseNames = new List<String>();
        
        for(fieldWrapper wrapper: datalist){
            if(wrapper.BuildPhase != null && wrapper.BuildPhase != ''){
                buildPhaseNames.add(wrapper.BuildPhase);
            }
        }
        list<buildertek__Build_Phase__c> buildPhase1 = new list<buildertek__Build_Phase__c>();
        buildPhase1 = [select Id, Name from buildertek__Build_Phase__c where Name IN: buildPhaseNames];
        map<String, buildertek__Build_Phase__c> buildPhasemap = new map<String,buildertek__Build_Phase__c>();
        for(buildertek__Build_Phase__c communityItem : buildPhase1){
            buildPhasemap.put(communityItem.Name,communityItem); 
        }
        
        //system.debug('datalist = ' + datalist);
        //system.debug('datalistSize = ' + datalist.size());
        for(fieldWrapper wrapper: datalist){
            buildertek__Project_Takeoff__c PO =new  buildertek__Project_Takeoff__c();
            PO.buildertek__Name__c = wrapper.Name;
            
            if(projectmap.keySet().contains(wrapper.Project) && wrapper.Project != null && wrapper.Project != ''){
                PO.buildertek__Project__c = projectmap.get(wrapper.Project).Id;
            }
            
            system.debug('projectmap'+projectmap);
            
            if(communitymap.keySet().contains(wrapper.Community) && wrapper.Community != null && wrapper.Community != ''){
                PO.buildertek__Community__c = communitymap.get(wrapper.Community).Id;
            }
            PO.buildertek__Type__c = wrapper.Type;
            
            PO.buildertek__Plan_Type__c = wrapper.PlanType;
            
            if(buildPhasemap.keySet().contains(wrapper.BuildPhase) && wrapper.BuildPhase != null && wrapper.BuildPhase != ''){
                PO.buildertek__Build_Phase__c = buildPhasemap.get(wrapper.BuildPhase).Id;
            }
            
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
        public String Name;
        public String Project;
        public String Community;
        public String Type;
        public String PlanType;
        public String BuildPhase;
    } 
    
    
}