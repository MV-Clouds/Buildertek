/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved.

Developed By: Sagar
Date:  02-Jul-2018
*/
public with sharing class ProjectTriggerHandler {
    //Boolean variable to allow skipping execution of trigger in certain scenarios
    public static Boolean blnSkipProjectTrigger = false;

    private boolean m_isExecuting = false;
    private integer BatchSize = 0;

    public ProjectTriggerHandler (boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    public void OnBeforeInsert(Project__c[] newProjects){

    }

    public void OnBeforeUpdate(Project__c[] oldProjects, Project__c[] updatedProjects, Map<ID, Project__c> ProjectMap){

    }

    public void OnBeforeDelete(Project__c[] ProjectsToDelete, Map<ID, Project__c> ProjectMap){

    }



    public void OnAfterInsert(Project__c[] newProjects, Map<ID, Project__c> newProjectsMap, Project__c[] oldProjects, Project__c[] updatedProjects, Map<ID, Project__c> ProjectMap, Map<Id, Project__c> oldProjectsMap){
        
        for(Project__c project: newProjects){

            if(project.Master_Project__c != null) {
                // clone PO from master
                String poids = '';
                List<Purchase_Order__c> poList;

                    poList = [Select Id, Name from Purchase_Order__c where Project__c =:project.Master_Project__c];

                for(Purchase_Order__c po: poList) {
                    poids  += po.Id+';';
                }

                BT_Utils.CloneAny('buildertek__Purchase_Order__c', poids, 'buildertek__Purchase_Order__c', 'buildertek__Purchase_Order_Item__c', project.Id);


                // clone Schedules from master
                String scheduleIds = '';
                for(Schedule__c schedule:[Select Id, Name from Schedule__c where Project__c =:project.Master_Project__c]) {
                    scheduleIds  += schedule.Id+';';
                }

                BT_Utils.CloneAny('buildertek__Schedule__c', scheduleIds, 'buildertek__Schedule__c', 'buildertek__Project_Task__c', project.Id);


                // clone Punch Lists from master
                String plIds = '';
                for(Punch_List__c pl:[Select Id, Name from Punch_List__c where Project__c =:project.Master_Project__c]) {
                    plIds  += pl.Id+';';
                }

                BT_Utils.CloneAny('buildertek__Punch_List__c', plIds, 'buildertek__Punch_List__c', 'buildertek__Punch_List_item__c', project.Id);



                // clone Inspections from master
                String InspectionIds = '';
                for(Inspection__c ins:[Select Id, Name from Inspection__c where Project__c =:project.Master_Project__c]) {
                    InspectionIds  += ins.Id+';';
                }



                BT_Utils.CloneAny('buildertek__Inspection__c', InspectionIds, 'buildertek__Inspection__c', 'buildertek__Inspection_Line__c', project.Id);




                // clone Inspections from master
                String WarrantyIds = '';
                for(Warranty__c ins:[Select Id, Name from Warranty__c where Project__c =:project.Master_Project__c]) {
                    WarrantyIds  += ins.Id+';';
                }
                BT_Utils.CloneAny('buildertek__Warranty__c', WarrantyIds, 'buildertek__Warranty__c', 'buildertek__Warranty_Item__c', project.Id);


                // clone Contract  from master
                String contractIds = '';
                for(Contract__c ins:[Select Id, Name from Contract__c where Project__c =:project.Master_Project__c]) {
                    contractIds  += ins.Id+';';
                }
                BT_Utils.CloneAny('buildertek__Contract__c', contractIds, 'buildertek__Contract__c', 'buildertek__Contract_Item__c', project.Id);


                // clone Contract  from master
                String QuoteIds = '';
                for(Quote__c ins:[Select Id, Name from Quote__c where Project__c =:project.Master_Project__c]) {
                    QuoteIds  += ins.Id+';';
                }
                BT_Utils.CloneAny('buildertek__Quote__c', QuoteIds, 'buildertek__Quote__c', 'buildertek__Quote_Item__c', project.Id);


                // clone Selections from master
                String selectionIds = '';
                for(Select_Sheet__c sel:[Select Id, Name from Select_Sheet__c where Project__c =:project.Master_Project__c]) {
                    selectionIds  += sel.Id+';';
                }

                //BT_Utils.CloneAny('buildertek__Select_Sheet__c', selectionIds, 'buildertek__Select_Sheet__c', 'buildertek__Selection_Item__c', project.Id);
            }

            if(project.Source_Project__c != null){
                
                /** 
                List<String> selectedITems = project.Source_Project__c.split('~');
                String projectId = selectedITems[0];
                if(selectedITems.size() > 1)
                for(String item :selectedITems[1].split(',')){

                    if(item == 'Purchase Order') {
                        // clone PO from master
                        String poids = '';
                        for(Purchase_Order__c po:[Select Id, Name,buildertek__PO_Type__c from Purchase_Order__c where Project__c =:projectId and buildertek__PO_Type__c = 'Master']) {
                            poids  += po.Id+';';
                        }


                        BT_Utils.CloneAny('buildertek__Purchase_Order__c', poids, 'buildertek__Purchase_Order__c', 'buildertek__Purchase_Order_Item__c', project.Id);
                    }

                    if(item == 'Schedule') {
                        // clone Schedules from master
                        String scheduleIds = '';
                        for(Schedule__c schedule:[Select Id, Name from Schedule__c where Project__c =:projectId]) {
                            scheduleIds  += schedule.Id+';';
                        }

                        BT_Utils.CloneAny('buildertek__Schedule__c', scheduleIds, 'buildertek__Schedule__c', 'buildertek__Project_Task__c', project.Id);

                    }

                    if(item == 'PunchList') {
                        // clone Punch Lists from master
                        String plIds = '';
                        for(Punch_List__c pl:[Select Id, Name from Punch_List__c where Project__c =:projectId]) {
                            plIds  += pl.Id+';';
                        }

                        BT_Utils.CloneAny('buildertek__Punch_List__c', plIds, 'buildertek__Punch_List__c', 'buildertek__Punch_List_item__c', project.Id);
                    }




                    if(item == 'Inspections') {
                        // clone Inspections from master
                        String InspectionIds = '';
                        for(Inspection__c ins:[Select Id, Name from Inspection__c where Project__c =:projectId]) {
                            InspectionIds  += ins.Id+';';
                        }



                        BT_Utils.CloneAny('buildertek__Inspection__c', InspectionIds, 'buildertek__Inspection__c', 'buildertek__Inspection_Line__c', project.Id);
                    }


                    if(item == 'Warranty') {
                        // clone Inspections from master
                        String WarrantyIds = '';
                        for(Warranty__c ins:[Select Id, Name from Warranty__c where Project__c =:projectId]) {
                            WarrantyIds  += ins.Id+';';
                        }
                        BT_Utils.CloneAny('buildertek__Warranty__c', WarrantyIds, 'buildertek__Warranty__c', 'buildertek__Warranty_Item__c', project.Id);

                    }

                    if(item == 'Contract') {
                        // clone Contract  from master
                        String contractIds = '';
                        for(Contract__c ins:[Select Id, Name from Contract__c where Project__c =:projectId]) {
                            contractIds  += ins.Id+';';
                        }
                        BT_Utils.CloneAny('buildertek__Contract__c', contractIds, 'buildertek__Contract__c', 'buildertek__Contract_Item__c', project.Id);

                    }

                    if(item == 'Quote') {
                        // clone Contract  from master
                        String QuoteIds = '';
                        for(Quote__c ins:[Select Id, Name from Quote__c where Project__c =:projectId]) {
                            QuoteIds  += ins.Id+';';
                        }
                        BT_Utils.CloneAny('buildertek__Quote__c', QuoteIds, 'buildertek__Quote__c', 'buildertek__Quote_Item__c', project.Id);

                    }

                    if(item == 'Budget') {
                        // clone Contract  from master
                        String QuoteIds = '';
                        List<Budget__c> budList;
                        if(Schema.sObjectType.Budget__c.fields.id.isAccessible()
                            && Schema.sObjectType.Budget__c.fields.Name.isAccessible()
                            && Schema.sObjectType.Budget__c.fields.Project__c.isAccessible()){
                            budList = [Select Id, Name from Budget__c where Project__c =:projectId];
                        }
                        for(Budget__c ins: budList) {
                            QuoteIds  += ins.Id+';';
                        }
                        BT_Utils.CloneAny('buildertek__Budget__c', QuoteIds, 'buildertek__Budget__c', 'buildertek__Budget_Item__c', project.Id);

                    }

                    if(item == 'Selection Sheet') {
                        // clone Selections from master
                        String selectionIds = '';
                        for(Select_Sheet__c sel:[Select Id, Name from Select_Sheet__c where Project__c =:projectId]) {
                            selectionIds  += sel.Id+';';
                        }

                        //BT_Utils.CloneAny('buildertek__Select_Sheet__c', selectionIds, 'buildertek__Select_Sheet__c', 'buildertek__Selection_Item__c', project.Id);
                    }

                    if(item == 'Selection') {
                        // clone Selections from master
                        String selectionIds = '';
                        for(Selection__c sel:[Select Id, Name from Selection__c where Project__c =:projectId]) {
                            selectionIds  += sel.Id+';';
                        }

                        BT_Utils.CloneAny('buildertek__Selection__c', selectionIds, 'buildertek__Selection__c', 'buildertek__Section__c', project.Id);
                    }
                }
                */
            }
        }

        // Added by Krunal
        try {
            projectCloneController(newProjects, newProjectsMap);
        } catch (Exception e) {
            System.debug('Error Message => '+e.getMessage()); 
            System.debug('Error Line no => '+e.getLineNumber());
            newProjects[0].Id.addError('projectCloneController Method Error => '+e.getMessage());		
        }

    }

    public void OnAfterInsetCreateWarranty(Project__c[] newProjects, Map<ID, Project__c> newProjectsMap){
        Set<Id> newProjIds =  new Set<Id>();
        List<buildertek__Warranty__c> newWarrantyList = new List<buildertek__Warranty__c>();
        List<buildertek__Warranty__c> checkedWarrantyList = new List<buildertek__Warranty__c>();
        checkedWarrantyList = [Select Id,Name,buildertek__Effective_Date__c,buildertek__Locked__c,buildertek__Description__c,buildertek__Status__c,
                               buildertek__Type__c,buildertek__Warranty_Manager__c,buildertek__Due_Date__c,buildertek__Project__c,buildertek__Instructions__c,buildertek__Warranty__c,
                               buildertek__Create_Warranty_On_Project_Creation__c,buildertek__Length_of_Warranty__c
                               FROM buildertek__Warranty__c where buildertek__Create_Warranty_On_Project_Creation__c= true];
        //List<buildertek__Project__c> newProjectList = new List<buildertek__Project__c>();
        if(checkedWarrantyList.Size() > 0){
            List<buildertek__Project__c> newProjectList = new List<buildertek__Project__c>();
            for(buildertek__Project__c proj : newProjects){
                newProjIds.add(proj.Id);
                for(buildertek__Warranty__c warrn : checkedWarrantyList){
                    buildertek__Warranty__c warranty = new buildertek__Warranty__c();
                    warranty.buildertek__Description__c = warrn.buildertek__Description__c;
                    warranty.buildertek__Status__c = warrn.buildertek__Status__c;
                    warranty.buildertek__Effective_Date__c = System.today();
                    warranty.buildertek__Project__c = proj.Id;
                    warranty.buildertek__Locked__c = false;
                    warranty.buildertek__Type__c = warrn.buildertek__Type__c;
                    warranty.buildertek__Warranty_Manager__c = warrn.buildertek__Warranty_Manager__c;
                    warranty.buildertek__Due_Date__c = warrn.buildertek__Due_Date__c;
                    warranty.buildertek__Instructions__c = warrn.buildertek__Instructions__c;
                    //warranty.buildertek__Warranty__c = warrn.buildertek__Warranty__c;
                    warranty.buildertek__Length_of_Warranty__c = warrn.buildertek__Length_of_Warranty__c;
                    warranty.buildertek__Create_Warranty_On_Project_Creation__c = false;
                    newWarrantyList.add(warranty);
                }
                system.debug(newWarrantyList);
                system.debug(proj.Id);
            }
            insert newWarrantyList;
            List<buildertek__Warranty__c> insertedwarratyList = [select Id, buildertek__Project__c,buildertek__Warranty__c from buildertek__Warranty__c where buildertek__Project__c =:newProjIds order by CreatedDate asc];
            Map<Id,List<buildertek__Warranty__c>> warrantyMap = new Map<Id,List<buildertek__Warranty__c>>();
            List<buildertek__Warranty__c> warrList = new List<buildertek__Warranty__c>();
            for(buildertek__Warranty__c warranty:insertedwarratyList){
                //warrList = warrantyMap.get(warranty.buildertek__Project__c);
                warrList.add(warranty);
                warrantyMap.put(warranty.buildertek__Project__c,warrList);
            }
            system.debug(warrantyMap);
            List<buildertek__Warranty__c> updateWarrantyList = new List<buildertek__Warranty__c>();

             map<Id,Id> warrantCheckmap = new map<Id,Id>();

            for(buildertek__Project__c  project :  newProjects){
                List<buildertek__Warranty__c> warrantyListItem = warrantyMap.get(project.Id);
                Integer c=1;

                for(buildertek__Warranty__c w: warrantyListItem){
                    system.debug(w);
                    if(c<warrantyListItem.size()){
                        if(!warrantCheckmap.keyset().contains(warrantyListItem[c].Id)){
                            system.debug('warProj'+project.Id);
                            system.debug('nextwarProj'+warrantyListItem[c].buildertek__Project__c);
                            if(project.Id == warrantyListItem[c].buildertek__Project__c){
                                system.debug('warProj1'+project.Id);
                                system.debug('nextwarProj1'+warrantyListItem[c].Id);
                                w.buildertek__Warranty__c = warrantyListItem[c].Id;
                                updateWarrantyList.add(w);
                                c++;
                                warrantCheckmap.put(w.buildertek__Warranty__c,w.buildertek__Warranty__c);
                            }

                        }
                    }
                }
            }
            update updateWarrantyList;
        }
    }


    public void OnAfterUpdate(Project__c[] oldProjects, Project__c[] updatedProjects, Map<ID, Project__c> ProjectMap, Map<Id, Project__c> oldProjectsMap){
        //Remove from sharing
        Set<Id> scheduleShare = new Set<Id>();
        for(Project__c proMap : ProjectMap.values()){
            if(oldProjectsMap.get(proMap.Id).buildertek__Account__c != proMap.buildertek__Account__c ){
                scheduleShare.add(proMap.buildertek__Account__c);
            }

        }


        List<buildertek__Project__c> updateprojectRecList =  new List<buildertek__Project__c>();
        //update project dates from schedules
         if (ProjectMap.keySet().size() > 0){

            for(buildertek__Project__c proj : [select Id,Name,buildertek__Actual_Start__c, buildertek__Stage__c, buildertek__Actual_Completion_Date__c,buildertek__Project_Completion__c,buildertek__Original_Start_Date__c,buildertek__Original_End_Date__c,
                                (select id,Name,buildertek__Start_Date__c,buildertek__End_Date__c,buildertek__Actual_Completion_Date_2__c,buildertek__Actual_Start_Date_2__c,buildertek__Original_Start_Date__c,buildertek__Original_End_Date__c from buildertek__Schedules__r ORDER BY CreatedDate ASC)  from buildertek__Project__c where Id IN:ProjectMap.keySet()]){
                if(proj.buildertek__Schedules__r.size() > 0){
                    buildertek__Schedule__c sch = proj.buildertek__Schedules__r[0];
                    buildertek__Project__c newProj = new buildertek__Project__c();
                    newProj.Id = proj.Id;
                    if (proj.buildertek__Stage__c != 'Completed') {
                        newProj.buildertek__Actual_Start__c = sch.buildertek__Actual_Start_Date_2__c;
                        newProj.buildertek__Actual_Completion_Date__c = sch.buildertek__Actual_Completion_Date_2__c;
                    }

                    // newProj.buildertek__Actual_Start__c = sch.buildertek__Start_Date__c;
                    //  newProj.buildertek__Actual_Completion_Date__c = sch.buildertek__End_Date__c;
                    newProj.buildertek__Original_Start_Date__c = sch.buildertek__Original_Start_Date__c;
                    newProj.buildertek__Original_End_Date__c= sch.buildertek__Original_End_Date__c;
                    //if(proj.buildertek__Project_Completion__c > 1){
                    // newProj.buildertek__Actual_Start__c = sch.buildertek__Start_Date__c;
                    // }
                    system.debug('helo.....................'+sch.buildertek__Original_End_Date__c);
                    // system.debug('hai.............'+newProj.buildertek__Original_End_Date__c);

                    updateprojectRecList.add(newProj);
                    system.debug('updateprojectRecList....'+updateprojectRecList);
                }
            }
        }

        if(updateprojectRecList.size()>0){
           system.debug('updateprojectRecList-->'+updateprojectRecList[0].buildertek__Original_End_Date__c );
            UpdateProjecttOnScheduleUpdateHandler projectUpdateHandler = new UpdateProjecttOnScheduleUpdateHandler();
            ProjectTriggerHandler.blnSkipProjectTrigger = true;
            projectUpdateHandler.updateProjectList_New(updateprojectRecList);

            ProjectTriggerHandler.blnSkipProjectTrigger = false;
            system.debug('updateprojectRecList-->'+updateprojectRecList[0].buildertek__Original_End_Date__c );
           // system.debug('updateprojectRecList-->'+updateprojectRecList[0].Id);
        }

        if(scheduleShare.size()>0){
            delete [Select Id FROM buildertek__Schedule__Share WHERE UserOrGroupId =:  scheduleShare AND AccessLevel =: 'Read' AND RowCause =: 'Manual'];
        }
    }

    public void OnBeforeUpdate(Project__c[] newProjects, Map<ID, Project__c> newProjectsMap){

    }

    public void OnAfterDelete(Project__c[] oldProjects){

    }
    public void AfterInsertProject(buildertek__Project__c[] newProjects){
        list<id> projectIds = new list<id>();
        for(buildertek__Project__c project: newProjects){
            if(project.buildertek__City__c != null && project.buildertek__State__c != null && project.buildertek__Address__c != null && project.buildertek__Zip__c != null){
               projectIds.add(project.Id);
            }
        }
        List<buildertek__Project__c> projectList = [select id,Name,buildertek__Address__c,buildertek__Zip__c,buildertek__Country__c,buildertek__State__c,buildertek__City__c from buildertek__Project__c where id IN: projectIds];
        for(buildertek__Project__c projectRec : projectList){
               FutureMethodCallout_forimage(JSON.serialize(projectRec));
            }
    }
     public void AfterUpdateProjects(buildertek__Project__c[] newProjects, Map<Id, buildertek__Project__c> oldProjectsMap){
        list<id> projectIds = new list<id>();
        for(buildertek__Project__c project: newProjects){
            if(project.buildertek__City__c != null && project.buildertek__State__c != null && project.buildertek__Address__c != null && project.buildertek__Zip__c != null &&
               (oldProjectsMap.get(project.id).buildertek__City__c !=project.buildertek__City__c || oldProjectsMap.get(project.id).buildertek__State__c !=project.buildertek__State__c
               || oldProjectsMap.get(project.id).buildertek__Address__c !=project.buildertek__Address__c || oldProjectsMap.get(project.id).buildertek__Zip__c !=project.buildertek__Zip__c)){
               projectIds.add(project.Id);
            }
        }
         if(projectIds.size()>0){
             List<buildertek__Project__c> projectList = [select id,Name,buildertek__Address__c,buildertek__Zip__c,buildertek__Country__c,buildertek__State__c,buildertek__City__c from buildertek__Project__c where id IN: projectIds];
             set<Id> projectrecids = new set<Id>();
             list<string> projectName = new List<string>();
             for(buildertek__Project__c projectRec : projectList){
                 projectrecids.add(projectRec.id);
                 projectName.add(projectRec.Name);
               //  if(!Test.isRunningTest()){
                     FutureMethodCallout_forimage(JSON.serialize(projectRec));
                // }
             }
             List<ContentDocumentLink> contentlist = [Select LinkedEntityId,ContentDocumentId from ContentDocumentLink where LinkedEntityId IN : projectrecids];
             set<id> contentdocid = new set<id>();
             if(contentlist.size()>0){
                 for(ContentDocumentLink contentRec : contentlist){
                     contentdocid.add(contentRec.ContentDocumentId);
                 }
                 list<ContentDocument> contentdocList = new list<ContentDocument>();
                 if(contentdocid.size()> 0){
                      contentdocList = [SELECT Id,Title,FileType,Createddate from ContentDocument where title IN : projectName AND Id IN : contentdocid order by createddate ASC];
                 }
                 if(contentdocList.size() >= 1){
                     delete contentdocList;
                 }
             }
         }
    }
    @Future(callout=true)
    private static void FutureMethodCallout_forimage(string projectRec) {
        buildertek__Project__c  projRec = (buildertek__Project__c)JSON.deserialize(projectRec, buildertek__Project__c.class);
        buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [Select Id,buildertek__Retreive_Aerial_Photo_of_project__c,buildertek__Google_Map_API_Key__c from buildertek__Admin_Interface_Node_Configuration__c WHERE Name=:'Project Configuration'];
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        string endpointUrl = 'https://maps.googleapis.com/maps/api/staticmap?center='+EncodingUtil.URLENCODE(projRec.buildertek__Address__c,'UTF-8')+','+EncodingUtil.URLENCODE(projRec.buildertek__City__c,'UTF-8')+','+EncodingUtil.URLENCODE(projRec.buildertek__State__c,'UTF-8')+','+EncodingUtil.URLENCODE(projRec.buildertek__Zip__c,'UTF-8')+'&zoom=19&size=400x400&key='+adminInterfaceNodeConfigurations.buildertek__Google_Map_API_Key__c+'&maptype=satellite';
     //   string endpointUrl = 'https://maps.googleapis.com/maps/api/streetview?size=600x1200&location='+EncodingUtil.URLENCODE(projRec.buildertek__Address__c,'UTF-8')+','+EncodingUtil.URLENCODE(projRec.buildertek__City__c,'UTF-8')+','+EncodingUtil.URLENCODE(projRec.buildertek__State__c,'UTF-8')+','+EncodingUtil.URLENCODE(projRec.buildertek__Zip__c,'UTF-8')+'&fov=80&heading=160&pitch=0%20&key='+adminInterfaceNodeConfigurations.buildertek__Google_Map_API_Key__c+'';
       // string endpointUrl ='https://maps.googleapis.com/maps/api/streetview?size=600x1200&location=212%20E.%20Alger,%20Dr.%20%20Blue%20Springs%20MO.%20%2064014%20&fov=80&heading=160&pitch=0%20&key=AIzaSyA3kg7YWugGl1lTXmAmaBGPNhDW9pEh5bo';
        //string endpointUrl = 'https://maps.googleapis.com/maps/api/staticmap?center='+EncodingUtil.URLENCODE(projRec.buildertek__City__c,'UTF-8')+','+EncodingUtil.URLENCODE(projRec.buildertek__State__c,'UTF-8')+'&zoom=14&size=400x400&key='+adminInterfaceNodeConfigurations.buildertek__Google_Map_API_Key__c+'&markers=color:blue';
    // string endpointUrl = 'https://maps.googleapis.com/maps/api/staticmap?center='+EncodingUtil.URLENCODE(projRec.buildertek__City__c,'UTF-8')+','+EncodingUtil.URLENCODE(projRec.buildertek__State__c,'UTF-8')+'&zoom=14&size=400x400&key='+adminInterfaceNodeConfigurations.buildertek__Google_Map_API_Key__c+'&markers=color:blue';
        request.setEndpoint(endpointUrl);
        request.setMethod('GET');
        if(!Test.isRunningTest()){
        HttpResponse response = http.send(request);
        // Parse the JSON response
        if (response.getStatusCode() == 200) {
            System.debug('The status code returned was not expected: ' +
            response.getStatusCode() + ' ' + response.getStatus());
            System.debug(response.getBody());
            blob image = response.getBodyAsBlob();
            ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
            conVer.PathOnClient = projRec.Name+'.png'; // The files name, extension is very important here which will help the file in preview.
            conVer.Title = projRec.Name; // Display name of the files
            conVer.VersionData = image ; //EncodingUtil.base64Decode(response.getBody()); // converting your binary string to Blog
            try{
            insert conVer;
                System.debug(conVer);
                Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
                ContentDocumentLink conDocLink = New ContentDocumentLink();
                conDocLink.LinkedEntityId = projRec.Id; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
                conDocLink.ContentDocumentId = conDoc;  //ContentDocumentId Id from ContentVersion
                conDocLink.shareType = 'I';
                insert conDocLink;
            }catch(Exception e){
                System.debug(e.getMessage());
            }
        }
        }
    }

    public void CreatePermits(List<buildertek__Project__c> projects){
        Set<Id> ProjectIds = new Set<Id>();
        for(buildertek__Project__c ProjectRecord : projects ){
            ProjectIds.add(ProjectRecord.Id);
        }
        List<buildertek__Permit__c> permits = [select Id,Name,buildertek__Permit_Type__c,buildertek__Permit_Sub_Type__c from buildertek__Permit__c where buildertek__Type__c = 'Master' and buildertek__Create_on_New_Project__c = True];
        List<buildertek__Permit__c> PermitRecordListToInsert = new  List<buildertek__Permit__c>();
        if(!ProjectIds.isEmpty()){
            if(!permits.isEmpty()){
                for(Id ProjectId : ProjectIds){
                    for(buildertek__Permit__c PermitRecord : permits){
                        buildertek__Permit__c newPermit = new buildertek__Permit__c();
                        newPermit.Name = PermitRecord.Name;
                        newPermit.buildertek__Permit_Type__c = 'New';
                        newPermit.buildertek__Permit_Sub_Type__c = PermitRecord.buildertek__Permit_Sub_Type__c;
                        newPermit.buildertek__Project__c = ProjectId;
                        PermitRecordListToInsert.add(newPermit);
                    }
                }
            }
        }

        if(!PermitRecordListToInsert.isEmpty()){
            insert PermitRecordListToInsert;
        }
    }

     public void CreatePermitsForNewProject(List<buildertek__Project__c> projects){
        List<buildertek__Permit__c> permits = [select Id,Name,buildertek__Permit_Type__c,buildertek__Permit_Sub_Type__c from buildertek__Permit__c where  buildertek__Create_on_New_Project__c = True];
        if(!permits.isEmpty()){
            List<buildertek__Permit__c> insertPermits = new List<buildertek__Permit__c>();
            for(buildertek__Project__c projectRecords : projects){
                for(buildertek__Permit__c permit : permits){
                    buildertek__Permit__c newPermit = new buildertek__Permit__c();
                    newPermit.Name = permit.Name;
                    newPermit.buildertek__Permit_Sub_Type__c = permit.buildertek__Permit_Sub_Type__c;
                    newPermit.buildertek__Permit_Type__c = permit.buildertek__Permit_Type__c;
                    newPermit.buildertek__Project__c = projectRecords.Id;
                    insertPermits.add(newPermit);
                }
            }
            if(!insertPermits.isEmpty()){
                insert insertPermits;
            }
        }
    }

    // Method added by sakina
    public void dummyMethod(List<buildertek__Project__c> newProjects){
        
        Map<Id,String> sourceValueMap= new  Map<Id,String>();
        Map<Id,List<String>> srcProjSelectedObj = new  Map<Id,List<String>>();

        Map<String, Set<Id>> selectedObjectsToProjectIds = new Map<String, Set<Id>>();
        // Map<Id, List<String>> selectedObjectsToProjectIds = new Map<Id, List<String>>();

        Map<Id, List<Quote__c>> quotesByProjectId = new Map<Id, List<Quote__c>>();





        for(buildertek__Project__c proj:newProjects){
            if(proj.Source_Project__c!= null){
                // map of new project Id and source project value
                sourceValueMap.put(proj.Id, proj.Source_Project__c);
            }    
        }

        System.debug('sourceValueMap'+sourceValueMap);
        for(Id projectId:sourceValueMap.keySet()){
            System.debug('projectId'+projectId);
            // get all the source project value based on new project Id
            String sourceValue=sourceValueMap.get(projectId);
            String[] parts = sourceValue.split('~');
            String selectedObjects = parts[1];
            String[] objectArray = selectedObjects.split(',');

            // selectedObjectsToProjectIds.put();

            // map of source project Id and selected Object
            for (String objectName : objectArray) {
                if (!selectedObjectsToProjectIds.containsKey(objectName)) {
                    selectedObjectsToProjectIds.put(objectName, new Set<Id>());
                    // selectedObjectsToProjectIds.put(projectId,objectName);

                }
                
                selectedObjectsToProjectIds.get(objectName).add(projectId);
            }        
            
        }
        System.debug('selectedObjectsToProjectIds'+selectedObjectsToProjectIds);
    

    }


    // Method added by krunal
    public static Set<String> sourceProjectIdsSet = new Set<String>();
    public static Map<String, String> sourceToProjectIdsMap = new Map<String, String>();
    public static Map<String, List<String>> sourceObjectsMap= new  Map<String, List<String>>();

    public static List<String> parentRecordList;

    public static void projectCloneController(List<buildertek__Project__c> projectList, Map<Id, buildertek__Project__c> projectMap){

        Set<String> sourceProjectIds = new Set<String>();
        Map<String, String> sourceToProjectMap = new  Map<String, String>();
        Map<String, List<String>> sourceObjectMap= new  Map<String, List<String>>();
        Set<String> objectSet = new Set<String>();

        for(buildertek__Project__c proj: projectList){
            if(proj.Source_Project__c!= null){
                List<String> selectedItems = proj.Source_Project__c.split('~');
                sourceToProjectMap.put(selectedItems[0], proj.Id);
                sourceProjectIds.add(selectedItems[0]);
                if(selectedItems.size() > 1){
                    List<String> selectedObject = new List<String>();
                    for(String item: selectedITems[1].split(',')){
                        selectedObject.add(item);
                        objectSet.add(item);
                    }
                    sourceObjectMap.put(selectedItems[0], selectedObject);
                }
            }    
        }

        ProjectTriggerHandler.sourceObjectsMap = sourceObjectMap;
        ProjectTriggerHandler.sourceToProjectIdsMap = sourceToProjectMap;
        ProjectTriggerHandler.sourceProjectIdsSet = sourceProjectIds;

        for (String objName : objectSet) {
            
            if(objName == 'Purchase Order') {
                CloneAny(objName, 'buildertek__Purchase_Order__c', 'buildertek__Purchase_Order_Item__c');
            }

            if(objName == 'Schedule') {
                CloneAny(objName, 'buildertek__Schedule__c', 'buildertek__Project_Task__c');
            }

            if(objName == 'PunchList') {
                CloneAny(objName, 'buildertek__Punch_List__c', 'buildertek__Punch_List_item__c');
            }

            if(objName == 'Inspections') {
                CloneAny(objName, 'buildertek__Inspection__c', 'buildertek__Inspection_Line__c');
            }

            if(objName == 'Warranty') {
                CloneAny(objName, 'buildertek__Warranty__c', 'buildertek__Warranty_Item__c');
            }

            if(objName == 'Contract') {
                CloneAny(objName, 'buildertek__Contract__c', 'buildertek__Contract_Item__c');
            }

            if(objName == 'Quote') {
                CloneAny(objName, 'buildertek__Quote__c', 'buildertek__Quote_Item__c');
            }

            if(objName == 'Budget') {
                CloneAny(objName, 'buildertek__Budget__c', 'buildertek__Budget_Item__c');
            }

            if(objName == 'Selection') {
                CloneAny(objName, 'buildertek__Selection__c', 'buildertek__Section__c');
            }

        }

    }


    public static void CloneAny(String objName, String objAPI, String childObjAPI){
        
        System.debug('CloneAny Method');
        System.debug('objName ==> '+objName);

        Set<String> sourceProjectIds = ProjectTriggerHandler.sourceProjectIdsSet;
        Map<String, String> sourceToProjectMap = ProjectTriggerHandler.sourceToProjectIdsMap;
        Map<String, List<String>> sourceObjectMap = ProjectTriggerHandler.sourceObjectsMap;

        string qryStr = prepareQuery(objAPI, 'buildertek__Project__c', sourceProjectIds);
        List<SObject> sobjListToClone = database.query(qryStr);

        List<SObject> newSobjListToClone = database.query(qryStr);
        for (SObject sObj : sobjListToClone) {
            String oldProjectId = String.valueOf(sObj.get('buildertek__Project__c'));
            if (sourceObjectMap.get(oldProjectId).contains(objName)) {
                newSobjListToClone.add(sObj);
            }
        }

        Map<String, SObject> cloneSObjList = new Map<String, SObject>();
        for (SObject sObj : newSobjListToClone) {
            String oldProjectId = String.valueOf(sObj.get('buildertek__Project__c'));
            SObject obj = sobj.clone(false, true);

            obj.put('buildertek__Project__c', sourceToProjectMap.get(oldProjectId));
            cloneSObjList.put(sobj.Id, obj);
        }

        if (objAPI == 'buildertek__Purchase_Order__c'){
            for (SObject sObj : cloneSObjList.values()){
                sObj.put('buildertek__Status__c', 'Pending');
                sObj.put('buildertek__Budget__c', null);
                sObj.put('buildertek__Budget_Line__c', null);
            }
        }

        if (objAPI == 'buildertek__Warranty__c'){

            Map<String, SObject> warrantyMap = new Map<String, SObject>();
            Map<String, String> parentMap = new Map<String, String>();

            for (SObject sObj : cloneSObjList.values()){
                parentMap.put(String.valueOf(sObj.Id), String.valueOf(sObj.get('buildertek__Warranty__c')));
                sObj.put('buildertek__Warranty__c', null);
    
                SObject obj = sobj.clone(false, true);
    
                warrantyMap.put(String.valueOf(sObj.Id), obj);
            }
            insert warrantyMap.values();

            Map<String, String> newParentMap = new Map<String, String>();
            for (String oldRecId : parentMap.keySet()) {
                if (parentMap.get(oldRecId) != null) {
                    String newRecId = warrantyMap.get(oldRecId).Id;
                    String newParentRecId = warrantyMap.get(parentMap.get(oldRecId)).Id;
                    newParentMap.put(newRecId, newParentRecId);
                }
            }

            cloneSObjList = new Map<String, SObject>();
            for (String warrantyId : warrantyMap.keySet()) {
                SObject warrantyVal = warrantyMap.get(warrantyId);
                warrantyVal.put('buildertek__Warranty__c', newParentMap.get(String.valueOf(warrantyVal.Id)));

                cloneSObjList.put(warrantyId, warrantyVal);
            }

            update cloneSObjList.values();

        } else {

            insert cloneSObjList.values();
        }


        String childQry = prepareQuery(childObjAPI, objAPI, cloneSObjList.keySet());
        System.debug('childQry ==> '+childQry);
        List<SObject> childSobjList = database.query(childQry);
        System.debug('childSobjList ==> '+childSobjList);

        List<SObject> cloneChildRec= new List<SObject>();

        if (childObjAPI == 'buildertek__Project_Task__c') {

            Map<String, String> predecessorMap = new Map<String, String>();
            Map<String, SObject> scheduleTaskMap = new Map<String, SObject>();

            for (SObject sObj : childSobjList){
                predecessorMap.put(String.valueOf(sObj.Id), String.valueOf(sObj.get('buildertek__Dependency__c')));
                sObj.put('buildertek__Dependency__c', null);

                String oldParentId = String.valueOf(sObj.get(objAPI));
                SObject obj = sobj.clone(false, true);
                obj.put(objAPI, cloneSObjList.get(oldParentId).Id);

                scheduleTaskMap.put(String.valueOf(sObj.Id), obj);
            }

            if (scheduleTaskMap.size() > 0) {
                insert scheduleTaskMap.values();

                Map<String, String> newPredecessorMap = new Map<String, String>();
                for (String taskId : predecessorMap.keySet()) {
                    if (predecessorMap.get(taskId) != null) {
                        String newTaskId = scheduleTaskMap.get(taskId).Id;
                        String newParentId = scheduleTaskMap.get(predecessorMap.get(taskId)).Id;
                        newPredecessorMap.put(newTaskId, newParentId);
                    }
                }

                List<SObject> updateTaskList = new List<SObject>();
                for (SObject task : scheduleTaskMap.values()) {
                    task.put('buildertek__Dependency__c', newPredecessorMap.get(String.valueOf(task.Id)));
                    updateTaskList.add(task);
                }

                if (updateTaskList.size() > 0) {
                    update updateTaskList;
                }
            }

        } else {

            for (SObject sobj : childSobjList){
                System.debug('sobj ==> '+sobj);
                String oldParentId = String.valueOf(sObj.get(objAPI));
    
                SObject obj = sobj.clone(false, true);
                System.debug('objAPI ==> '+objAPI);
                System.debug('cloneSObjList.get(oldParentId)) ==> '+cloneSObjList.get(oldParentId));
                obj.put(objAPI, cloneSObjList.get(oldParentId).Id);
    
                cloneChildRec.add(obj);
            }

            System.debug('cloneChildRec ==> '+cloneChildRec);
            
            if(cloneChildRec.size() > 0){
                insert cloneChildRec;
            }
        }
        
    }


    public static String prepareQuery(String sObjName, String fieldName, Set<String> recIdList){

        System.debug('ProjectTriggerHandler -> prepareQuery -> '+sObjName);

        Map<String, Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get(sObjName.toLowerCase()).getDescribe().Fields.getMap();
        String fields = '';
        
        for (Schema.SObjectField sf : fieldsMap.values()){
            Schema.DescribeFieldResult fr = sf.getDescribe();
            if (fr.isCreateable()){
                fields += fr.getName()+',';
            }
        }

        if (fields.endsWith(',')){
            fields = fields.substring(0, fields.lastIndexOf(','));
        }

        parentRecordList = new List<String>();
        for (Id recId : recIdList) {
            parentRecordList.add(recId);
        }

        String qryString;
        if (sObjName == 'buildertek__Project_Task__c') {
            qryString = 'SELECT ' + fields + ' , buildertek__Dependency__r.Name FROM ' + sObjName + ' where ' + fieldName + ' IN: parentRecordList';
        } 
        else{
            qryString = 'SELECT ' + fields + ' FROM ' + sObjName + ' where ' + fieldName + ' IN: parentRecordList';
        }

        return qryString;
    }
   
}