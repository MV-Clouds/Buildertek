public class BT_FormatGanttData {
      @AuraEnabled
      public static String formatScheduleData(List<buildertek__Project_Task__c> schItemData,buildertek__Schedule__c scheduleData){
        //List<buildertek__Project_Task__c> budgetItemsToInsert = (List<buildertek__Project_Task__c>)System.JSON.deserialize(scheduleItemsStringData, List<buildertek__Project_Task__c>.class);

        
        List<cls_dependencyRows> taskDependencyData = new List<cls_dependencyRows>();
        List<cls_resourceRows> resourceRowData = new List<cls_resourceRows>();
        Set<String> resourceRowIdList = new Set<String>();
        set<String>scheduleItemIdsList = new Set<String>();
        List<cls_assignmentRows> assignmentRowData= new List<cls_assignmentRows>();
        List<cls_children> rows = new List<cls_children>();
        cls_assignments assignments= new cls_assignments();
        cls_resources resources = new cls_resources();
        cls_tasks tasks = new cls_tasks();
        List<buildertek__Project_Task__c> taskListForPhase = schItemData;
        cls_children firstRowDup = new cls_children();
        firstRowDup.id = scheduleData.Id;
        firstRowDup.name = scheduleData.Name;
        //row.percentDone: 70,
        firstRowDup.startDate= '';
        firstRowDup.expanded = true;
        firstRowDup.type = 'Project';
        firstRowDup.endDate = '' ;
        firstRowDup.children = new List<cls_children>();
        //firstRowDup.children = [];
        firstRowDup.constraintType = 'none' ;
        Boolean newPhaseFlag = true;
        //var taskWithphaseList = [];

        cls_children taskPhaseRow = new cls_children();
        System.debug(taskPhaseRow == null);
        System.debug(taskPhaseRow);

        Integer phIndex = -1;
        for(Integer i=0;i<taskListForPhase.Size();i++){
            System.debug(!String.isBlank(taskListForPhase[i].buildertek__Phase__c) + '--------------' );
            if(taskListForPhase[i].buildertek__Phase__c != null && taskPhaseRow != null){
                if(taskPhaseRow.name != taskListForPhase[i].buildertek__Phase__c){
                    phIndex = phIndex+1;
                    taskPhaseRow = new cls_children();
                    taskPhaseRow.type = 'Phase';
                    taskPhaseRow.id = taskListForPhase[i].buildertek__Schedule__c+'_'+taskListForPhase[i].buildertek__Phase__c;
                    taskPhaseRow.name = taskListForPhase[i].buildertek__Phase__c;
                    //row.percentDone: 70,
                    taskPhaseRow.startDate = '';
                    taskPhaseRow.expanded = true;
                    taskPhaseRow.endDate = '';
                    taskPhaseRow.children = new List<cls_children>();
                   // taskPhaseRow.children.add(taskListForPhase[i])
                    taskPhaseRow.constraintType = 'none';
                    newPhaseFlag = false;
                }
                cls_children rowChilObj = new cls_children();
                    rowChilObj.type = 'Task';
                    rowChilObj.phase = taskListForPhase[i].buildertek__Phase__c;
                    rowChilObj.constraintType = 'startnoearlierthan' ;
                    if(!scheduleItemIdsList.contains(taskListForPhase[i].Id)){
                        scheduleItemIdsList.add(taskListForPhase[i].Id);
                    }
                    rowChilObj.id = taskListForPhase[i].Id;
                    rowChilObj.name = taskListForPhase[i].Name;
                    if(taskListForPhase[i].buildertek__Completion__c != null)
                    rowChilObj.percentDone = Integer.valueOf(taskListForPhase[i].buildertek__Completion__c);
                    //rowChilObj.startDate = taskListForPhase[i].buildertek__Start__c;
                    rowChilObj.startDate = DateTime.newInstance(
                        taskListForPhase[i].buildertek__Start__c.year(), taskListForPhase[i].buildertek__Start__c.month(), taskListForPhase[i].buildertek__Start__c.day()
                    ).format('yyyy-MM-dd');
                    
                    rowChilObj.predecessor = taskListForPhase[i].buildertek__Dependency__c;
                    rowChilObj.internalresource = taskListForPhase[i].buildertek__Resource__c;
                    
                    if(!String.isBlank(taskListForPhase[i].buildertek__Resource__c)){
                        rowChilObj.internalresourcename = taskListForPhase[i].buildertek__Resource__r.Name;
                    }else{
                        rowChilObj.internalresourcename = '';
                    }
                    
                    rowChilObj.contractorresource = taskListForPhase[i].buildertek__Contractor_Resource__c;
                    
                    //Added for contractor **Start**
                    if(!String.isBlank(taskListForPhase[i].buildertek__Contractor_Resource__c)){
                        rowChilObj.contractorresourcename = taskListForPhase[i].buildertek__Contractor_Resource__r.Name;
                    }else{
                        rowChilObj.contractorresourcename = '';
                    }
                    //Added for contractor **End**
                    rowChilObj.contractoracc = taskListForPhase[i].buildertek__Contractor__c;

                    rowChilObj.contractorname = taskListForPhase[i].buildertek__Contractor__r.Name;//Added for contractor

                    rowChilObj.notes = taskListForPhase[i].buildertek__Notes__c;

                    if(taskListForPhase[i].buildertek__Lag__c != null){
                        //var startDate = new Date(taskListForPhase[i].buildertek__Start__c);
                        //new Date(startDate.getFullYear(),startDate.getMonth(),startDate.getDate(),0,0,0);
                        Date startDate = taskListForPhase[i].buildertek__Start__c;
                        startDate.addDays(Integer.valueOf(taskListForPhase[i].buildertek__Lag__c));
                        String sDate = DateTime.newInstance(
                        startDate.year(), startDate.month(), startDate.day()
                        ).format('yyyy-MM-dd');
                        rowChilObj.startDate = string.valueOf(sDate);
                    }
                   // console.log('start,',taskListForPhase[i].buildertek__Start__c)
                    rowChilObj.duration = taskListForPhase[i].buildertek__Duration__c;
                    if(taskListForPhase[i].buildertek__Milestone__c){
                        rowChilObj.duration = 0;
                    }
                    rowChilObj.expanded = true;
                    rowChilObj.order = Integer.valueOf(taskListForPhase[i].buildertek__Order__c);
                    //row.children.add(rowChilObj);
                    cls_dependencyRows dependencyRow =new cls_dependencyRows();
                   // var dependencyRow = {};
                    if(!String.isBlank(taskListForPhase[i].buildertek__Dependency__c)){
                        dependencyRow.id  = taskListForPhase[i].Id+'_'+taskListForPhase[i].buildertek__Dependency__c;
                        dependencyRow.fromTask = taskListForPhase[i].buildertek__Dependency__c;
                        dependencyRow.toTask= taskListForPhase[i].Id;
                        dependencyRow.lag  = taskListForPhase[i].buildertek__Lag__c;
                        taskDependencyData.add(dependencyRow);
                    }
                    
                    
                    if(taskListForPhase[i].buildertek__Milestone__c == false&& !String.isBlank(taskListForPhase[i].buildertek__Resource__c)){
                        if(!resourceRowIdList.contains(taskListForPhase[i].buildertek__Resource__c)){
                            cls_resourceRows resourceRow = new cls_resourceRows();
                            resourceRow.id = taskListForPhase[i].buildertek__Resource__c;
                            resourceRow.name = taskListForPhase[i].buildertek__Resource__r.Name;
                            resourceRow.calendar = 'general';
                            resourceRowData.add(resourceRow);
                            resourceRowIdList.add(taskListForPhase[i].buildertek__Resource__c);
                        }
                        
                    }
                    if(taskListForPhase[i].buildertek__Milestone__c == false && !String.isBlank(taskListForPhase[i].buildertek__Contractor__c)){
                        
                        if(!resourceRowIdList.contains(taskListForPhase[i].buildertek__Contractor__c)){
                            cls_resourceRows resourceRow = new cls_resourceRows();
                            resourceRow.id = taskListForPhase[i].buildertek__Contractor__c;
                            resourceRow.name = taskListForPhase[i].buildertek__Contractor__r.Name;
                            resourceRow.calendar = 'general';
                            resourceRowData.add(resourceRow);
                            resourceRowIdList.add(resourceRow.id);
                        }
                        
                    }
                    if(taskListForPhase[i].buildertek__Milestone__c == false && !String.isBlank(taskListForPhase[i].buildertek__Contractor_Resource__c)){
                        
                        if(!resourceRowIdList.contains(taskListForPhase[i].buildertek__Contractor_Resource__c) ){
                            cls_resourceRows resourceRow = new cls_resourceRows();
                            resourceRow.id = taskListForPhase[i].buildertek__Contractor_Resource__c;
                            resourceRow.name = taskListForPhase[i].buildertek__Contractor_Resource__r.Name;
                            resourceRow.calendar = 'general';
                            resourceRowData.add(resourceRow);
                            resourceRowIdList.add(resourceRow.id);
                        }
                    }
                
                    
                    if(taskListForPhase[i].buildertek__Milestone__c == false && !String.isBlank(taskListForPhase[i].buildertek__Resource__c)){
                        cls_assignmentRows assignmentRow = new cls_assignmentRows();
                        assignmentRow.id = taskListForPhase[i].Id+'_'+taskListForPhase[i].buildertek__Resource__c+'__index_'+i+'Resource';
                        assignmentRow.event = taskListForPhase[i].Id;
                        assignmentRow.resource = taskListForPhase[i].buildertek__Resource__c;
                        assignmentRowData.add(assignmentRow);
                    }
                    if(taskListForPhase[i].buildertek__Milestone__c == false && !String.isBlank(taskListForPhase[i].buildertek__Contractor__c)){
                        cls_assignmentRows assignmentRow = new cls_assignmentRows();
                        assignmentRow.id = taskListForPhase[i].Id+'_'+taskListForPhase[i].buildertek__Contractor__c+'__index_'+i+'Contractor';
                        assignmentRow.event = taskListForPhase[i].Id;
                        assignmentRow.resource = taskListForPhase[i].buildertek__Contractor__c;
                        assignmentRowData.add(assignmentRow);
                    }
                    if(taskListForPhase[i].buildertek__Milestone__c == false && !String.isBlank(taskListForPhase[i].buildertek__Contractor_Resource__c)){
                        cls_assignmentRows assignmentRow = new cls_assignmentRows();
                        assignmentRow.id = taskListForPhase[i].Id+'_'+taskListForPhase[i].buildertek__Contractor_Resource__c+'__index'+i+'ContractorResource';
                        assignmentRow.event = taskListForPhase[i].Id;
                        assignmentRow.resource = taskListForPhase[i].buildertek__Contractor_Resource__c;
                        assignmentRowData.add(assignmentRow);
                    }
                    taskPhaseRow.children.add(rowChilObj);
                    Boolean found = false;
                    if(firstRowDup.children.Size() > 0){
                       for(Integer k=0;k<firstRowDup.children.Size();k++){
                            if(firstRowDup.children[k].id == taskPhaseRow.id){
                                firstRowDup.children[k] = taskPhaseRow;
                                found = true;
                            }
                       }
                   }else{
                        firstRowDup.children.add(taskPhaseRow);
                        found = true;
                   }
                   if(!found){
                        firstRowDup.children.add(taskPhaseRow);
                   }
            }else if(!String.isBlank(taskListForPhase[i].buildertek__Phase__c) && taskPhaseRow == null){
                taskPhaseRow = new cls_children();
                phIndex = phIndex+1;
                taskPhaseRow.type = 'Phase';
                taskPhaseRow.id = taskListForPhase[i].buildertek__Schedule__c+'_'+taskListForPhase[i].buildertek__Phase__c;
                taskPhaseRow.name = taskListForPhase[i].buildertek__Phase__c;
                //row.percentDone: 70,
                taskPhaseRow.startDate = '';
                taskPhaseRow.expanded = true;
                taskPhaseRow.endDate = '';
                taskPhaseRow.children = new List<cls_children>();
                //taskPhaseRow.children.add(taskListForPhase[i])
                taskPhaseRow.constraintType = 'none';
                cls_children rowChilObj = new cls_children();
                    rowChilObj.type = 'Task';
                    rowChilObj.phase = taskListForPhase[i].buildertek__Phase__c;
                    rowChilObj.constraintType = 'startnoearlierthan' ;
                    if(!scheduleItemIdsList.contains(taskListForPhase[i].Id)){
                        scheduleItemIdsList.add(taskListForPhase[i].Id);
                    }
                    rowChilObj.id = taskListForPhase[i].Id;
                    rowChilObj.name = taskListForPhase[i].Name;
                    if(taskListForPhase[i].buildertek__Completion__c != null)
                    rowChilObj.percentDone = Integer.valueOf(taskListForPhase[i].buildertek__Completion__c);
                    //rowChilObj.startDate = taskListForPhase[i].buildertek__Start__c;
                    rowChilObj.startDate = DateTime.newInstance(
                        taskListForPhase[i].buildertek__Start__c.year(), taskListForPhase[i].buildertek__Start__c.month(), taskListForPhase[i].buildertek__Start__c.day()
                    ).format('yyyy-MM-dd');
    
                    rowChilObj.predecessor = taskListForPhase[i].buildertek__Dependency__c;
                    rowChilObj.internalresource = taskListForPhase[i].buildertek__Resource__c;
                    
                    if(!String.isBlank(taskListForPhase[i].buildertek__Resource__c)){
                        rowChilObj.internalresourcename = taskListForPhase[i].buildertek__Resource__r.Name;
                    }else{
                        rowChilObj.internalresourcename = '';
                    }

                    rowChilObj.contractorresource = taskListForPhase[i].buildertek__Contractor_Resource__c;
                    
                    //Added for contractor **Start**
                    if(!String.isBlank(taskListForPhase[i].buildertek__Contractor_Resource__c)){
                        rowChilObj.contractorresourcename = taskListForPhase[i].buildertek__Contractor_Resource__r.Name;
                    }else{
                        rowChilObj.contractorresourcename = '';
                    }
                    //Added for contractor **End**

                    rowChilObj.contractoracc = taskListForPhase[i].buildertek__Contractor__c;

                    rowChilObj.contractorname = taskListForPhase[i].buildertek__Contractor__r.Name;//Added for contractor

                    rowChilObj.notes = taskListForPhase[i].buildertek__Notes__c;

                    if(taskListForPhase[i].buildertek__Lag__c != null){
                    /* var startDate = new Date(taskListForPhase[i].buildertek__Start__c);
                        startDate.setDate(startDate.getDate() + (taskListForPhase[i].buildertek__Lag__c));
                        rowChilObj.startDate = new Date(startDate.getFullYear(),startDate.getMonth(),startDate.getDate(),0,0,0) */
                        Date startDate = taskListForPhase[i].buildertek__Start__c;
                        startDate.addDays(Integer.valueOf(taskListForPhase[i].buildertek__Lag__c));
                        String sDate = DateTime.newInstance(
                        startDate.year(), startDate.month(), startDate.day()
                        ).format('yyyy-MM-dd');
                        rowChilObj.startDate = sDate;//.format('yyyy-MM-dd');
                    }
                    //console.log('start,',taskListForPhase[i].buildertek__Start__c)
                    rowChilObj.duration = taskListForPhase[i].buildertek__Duration__c;
                    
                    
                    
                   // console.log('contart',taskListForPhase[i])
                    //rowChilObj['constraintDate'] = new Date(constraintDate)
                    if(taskListForPhase[i].buildertek__Milestone__c){
                        rowChilObj.duration = 1;
                        rowChilObj.milestone = true;
                    }
                    
                    rowChilObj.expanded = true;
                    rowChilObj.order = Integer.valueOf(taskListForPhase[i].buildertek__Order__c);
                    //row.children.add(rowChilObj);
                    cls_dependencyRows dependencyRow =new cls_dependencyRows();
                    if(!String.isBlank(taskListForPhase[i].buildertek__Dependency__c)){
                        dependencyRow.id  = taskListForPhase[i].Id+'_'+taskListForPhase[i].buildertek__Dependency__c;
                    dependencyRow.fromTask = taskListForPhase[i].buildertek__Dependency__c;
                    dependencyRow.toTask= taskListForPhase[i].Id;
                    dependencyRow.lag  = taskListForPhase[i].buildertek__Lag__c;
                    taskDependencyData.add(dependencyRow);
                    }
                    
                    
                    if(taskListForPhase[i].buildertek__Milestone__c == false && !String.isBlank(taskListForPhase[i].buildertek__Resource__c)){
                        if(!resourceRowIdList.contains(taskListForPhase[i].buildertek__Resource__c)){
                            cls_resourceRows resourceRow = new cls_resourceRows();
                            resourceRow.id = taskListForPhase[i].buildertek__Resource__c;
                            resourceRow.name = taskListForPhase[i].buildertek__Resource__r.Name;
                            resourceRow.calendar = 'general';
                            resourceRowData.add(resourceRow);
                            resourceRowIdList.add(resourceRow.id);
                        }
                        
                    }
                    if(taskListForPhase[i].buildertek__Milestone__c == false && !String.isBlank(taskListForPhase[i].buildertek__Contractor__c)){
                        
                        if(!resourceRowIdList.contains(taskListForPhase[i].buildertek__Contractor__c) ){
                            cls_resourceRows resourceRow = new cls_resourceRows();
                            resourceRow.id = taskListForPhase[i].buildertek__Contractor__c;
                            resourceRow.name = taskListForPhase[i].buildertek__Contractor__r.Name;
                            resourceRow.calendar = 'general';
                            resourceRowData.add(resourceRow);
                            resourceRowIdList.add(resourceRow.id);
                        }
                        
                    }
                    if(taskListForPhase[i].buildertek__Milestone__c == false && !String.isBlank(taskListForPhase[i].buildertek__Contractor_Resource__c)){
                        
                        if(!resourceRowIdList.contains(taskListForPhase[i].buildertek__Contractor_Resource__c)){
                            cls_resourceRows resourceRow = new cls_resourceRows();
                            resourceRow.id = taskListForPhase[i].buildertek__Contractor_Resource__c;
                            resourceRow.name = taskListForPhase[i].buildertek__Contractor_Resource__r.Name;
                            resourceRow.calendar = 'general';
                            resourceRowData.add(resourceRow);
                            resourceRowIdList.add(resourceRow.id);
                        }
                    }
                
                    
                    if(taskListForPhase[i].buildertek__Milestone__c == false&& String.isBlank(taskListForPhase[i].buildertek__Resource__c)){
                        cls_assignmentRows assignmentRow = new cls_assignmentRows();
                        assignmentRow.id = taskListForPhase[i].Id+'_'+taskListForPhase[i].buildertek__Resource__c+'__index_'+i+'Resource';
                        assignmentRow.event = taskListForPhase[i].Id;
                        assignmentRow.resource = taskListForPhase[i].buildertek__Resource__c;
                        assignmentRowData.add(assignmentRow);
                    }
                    if(taskListForPhase[i].buildertek__Milestone__c == false && String.isBlank(taskListForPhase[i].buildertek__Contractor__c)){
                        cls_assignmentRows assignmentRow = new cls_assignmentRows();
                        assignmentRow.id = taskListForPhase[i].Id+'_'+taskListForPhase[i].buildertek__Contractor__c+'__index_'+i+'Contractor';
                        assignmentRow.event = taskListForPhase[i].Id;
                        assignmentRow.resource = taskListForPhase[i].buildertek__Contractor__c;
                        assignmentRowData.add(assignmentRow);
                    }
                    if(taskListForPhase[i].buildertek__Milestone__c  == false && String.isBlank(taskListForPhase[i].buildertek__Contractor_Resource__c)){
                        cls_assignmentRows assignmentRow = new cls_assignmentRows();
                        assignmentRow.id = taskListForPhase[i].Id+'_'+taskListForPhase[i].buildertek__Contractor_Resource__c+'__index'+i+'ContractorResource';
                        assignmentRow.event = taskListForPhase[i].Id;
                        assignmentRow.resource = taskListForPhase[i].buildertek__Contractor_Resource__c;
                        assignmentRowData.add(assignmentRow);
                    }
                    taskPhaseRow.children.add(rowChilObj);
                   // console.log(taskPhaseRow)
                    newPhaseFlag = false;
            }else if(!String.isBlank(taskListForPhase[i].buildertek__Phase__c)){
                phIndex = phIndex+1;
                cls_children rowChilObj = new cls_children();
                rowChilObj.type = 'Task';
                rowChilObj.phase = taskListForPhase[i].buildertek__Phase__c;
                rowChilObj.constraintType = 'startnoearlierthan' ;
                if(!scheduleItemIdsList.contains(taskListForPhase[i].Id)){
                    scheduleItemIdsList.add(taskListForPhase[i].Id);
                }
                rowChilObj.id = taskListForPhase[i].Id;
                rowChilObj.name = taskListForPhase[i].Name;
                if(taskListForPhase[i].buildertek__Completion__c != null)
                rowChilObj.percentDone = Integer.valueOf(taskListForPhase[i].buildertek__Completion__c);
                
                rowChilObj.startDate = DateTime.newInstance(
                    taskListForPhase[i].buildertek__Start__c.year(), taskListForPhase[i].buildertek__Start__c.month(), taskListForPhase[i].buildertek__Start__c.day()
                ).format('yyyy-MM-dd');

                
                rowChilObj.predecessor = taskListForPhase[i].buildertek__Dependency__c;
                rowChilObj.internalresource = taskListForPhase[i].buildertek__Resource__c;
                
                if(!String.isBlank(taskListForPhase[i].buildertek__Resource__c)){
                    rowChilObj.internalresourcename = taskListForPhase[i].buildertek__Resource__r.Name;
                }else{
                    rowChilObj.internalresourcename = '';
                }
                rowChilObj.contractorresource = taskListForPhase[i].buildertek__Contractor_Resource__c;
                
                //Added for contractor **Start**
                if(!String.isBlank(taskListForPhase[i].buildertek__Contractor_Resource__c)){
                    rowChilObj.contractorresourcename = taskListForPhase[i].buildertek__Contractor_Resource__r.Name;
                }else{
                    rowChilObj.contractorresourcename = '';
                }
                //Added for contractor **End**

                rowChilObj.contractoracc = taskListForPhase[i].buildertek__Contractor__c;

                rowChilObj.contractorname = taskListForPhase[i].buildertek__Contractor__r.Name;//Added for contractor
                
                rowChilObj.notes = taskListForPhase[i].buildertek__Notes__c;

                if(taskListForPhase[i].buildertek__Lag__c != null){
                    /* var startDate = new Date(taskListForPhase[i].buildertek__Start__c);
                    startDate.setDate(startDate.getDate() + (taskListForPhase[i].buildertek__Lag__c));
                    rowChilObj.startDate = new Date(startDate.getFullYear(),startDate.getMonth(),startDate.getDate(),0,0,0) */
                   /*  String sDate = taskListForPhase[i].buildertek__Start__c;
                    Date startDate = Date.newInstance(Integer.valueOf(sDate.split('-')[0]),Integer.valueOf(sDate.split('-')[1]),Integer.valueOf(sDate.split('-')[2]));
                    startDate.addDays(Integer.valueOf(taskListForPhase[i].buildertek__Lag__c)); */
                    Date startDate = taskListForPhase[i].buildertek__Start__c;
                    startDate.addDays(Integer.valueOf(taskListForPhase[i].buildertek__Lag__c));
                    String sDate = DateTime.newInstance(
                        startDate.year(), startDate.month(), startDate.day()
                    ).format('yyyy-MM-dd');
                    rowChilObj.startDate = sDate;//;.format('yyyy-MM-dd');
                }
                //console.log('start,',taskListForPhase[i].buildertek__Start__c)
                rowChilObj.duration = taskListForPhase[i].buildertek__Duration__c;
                
                
                
               // console.log('contart',taskListForPhase[i])
                //rowChilObj['constraintDate'] = new Date(constraintDate)
                if(taskListForPhase[i].buildertek__Milestone__c){
                    rowChilObj.duration = 0;
                }
                
                rowChilObj.expanded = true;
                rowChilObj.order = Integer.valueOf(taskListForPhase[i].buildertek__Order__c);
                firstRowDup.children.add(rowChilObj);
                //row.children.add(rowChilObj);
                cls_dependencyRows dependencyRow =new cls_dependencyRows();
                if(!String.isBlank(taskListForPhase[i].buildertek__Dependency__c)){
                    dependencyRow.id  = taskListForPhase[i].Id+'_'+taskListForPhase[i].buildertek__Dependency__c;
                    dependencyRow.fromTask = taskListForPhase[i].buildertek__Dependency__c;
                    dependencyRow.toTask= taskListForPhase[i].Id;
                    dependencyRow.lag  = taskListForPhase[i].buildertek__Lag__c;
                    taskDependencyData.add(dependencyRow);
                }
                
                
                if(taskListForPhase[i].buildertek__Milestone__c == false && !String.isBlank(taskListForPhase[i].buildertek__Resource__c)){
                    if(!resourceRowIdList.contains(taskListForPhase[i].buildertek__Resource__c) ){
                        cls_resourceRows resourceRow = new cls_resourceRows();
                        resourceRow.id = taskListForPhase[i].buildertek__Resource__c;
                        resourceRow.name = taskListForPhase[i].buildertek__Resource__r.Name;
                        resourceRow.calendar = 'general';
                        resourceRowData.add(resourceRow);
                        resourceRowIdList.add(resourceRow.id);
                    }
                    
                }
                if(taskListForPhase[i].buildertek__Milestone__c == false && !String.isBlank(taskListForPhase[i].buildertek__Contractor__c)){
                    
                    if(!resourceRowIdList.contains(taskListForPhase[i].buildertek__Contractor__c) ){
                        cls_resourceRows resourceRow = new cls_resourceRows();
                        resourceRow.id = taskListForPhase[i].buildertek__Contractor__c;
                        resourceRow.name = taskListForPhase[i].buildertek__Contractor__r.Name;
                        resourceRow.calendar = 'general';
                        resourceRowData.add(resourceRow);
                        resourceRowIdList.add(resourceRow.id);
                    }
                    
                }
                if(taskListForPhase[i].buildertek__Milestone__c == false && !String.isBlank(taskListForPhase[i].buildertek__Contractor_Resource__c)){
                    
                    if(!resourceRowIdList.contains(taskListForPhase[i].buildertek__Contractor_Resource__c)){
                        cls_resourceRows resourceRow = new cls_resourceRows();
                        resourceRow.id = taskListForPhase[i].buildertek__Contractor_Resource__c;
                        resourceRow.name = taskListForPhase[i].buildertek__Contractor_Resource__r.Name;
                        resourceRow.calendar = 'general';
                        resourceRowData.add(resourceRow);
                        resourceRowIdList.add(resourceRow.id);
                    }
                }
            
                
                if(taskListForPhase[i].buildertek__Milestone__c == false&& !String.isBlank(taskListForPhase[i].buildertek__Resource__c)){
                    cls_assignmentRows assignmentRow = new cls_assignmentRows();
                    assignmentRow.id = taskListForPhase[i].Id+'_'+taskListForPhase[i].buildertek__Resource__c+'__index_'+i+'Resource';
                    assignmentRow.event = taskListForPhase[i].Id;
                    assignmentRow.resource = taskListForPhase[i].buildertek__Resource__c;
                    assignmentRowData.add(assignmentRow);
                }
                if(taskListForPhase[i].buildertek__Milestone__c  == false && !String.isBlank(taskListForPhase[i].buildertek__Contractor__c)){
                    cls_assignmentRows assignmentRow = new cls_assignmentRows();
                    assignmentRow.id = taskListForPhase[i].Id+'_'+taskListForPhase[i].buildertek__Contractor__c+'__index_'+i+'Contractor';
                    assignmentRow.event = taskListForPhase[i].Id;
                    assignmentRow.resource = taskListForPhase[i].buildertek__Contractor__c;
                    assignmentRowData.add(assignmentRow);
                }
                if(taskListForPhase[i].buildertek__Milestone__c  == false&& !String.isBlank(taskListForPhase[i].buildertek__Contractor_Resource__c)){
                    cls_assignmentRows assignmentRow = new cls_assignmentRows();
                    assignmentRow.id = taskListForPhase[i].Id+'_'+taskListForPhase[i].buildertek__Contractor_Resource__c+'__index'+i+'ContractorResource';
                    assignmentRow.event = taskListForPhase[i].Id;
                    assignmentRow.resource = taskListForPhase[i].buildertek__Contractor_Resource__c;
                    assignmentRowData.add(assignmentRow);
                }
                
            }
            
        }
        //console.log(taskListForPhase)
        //console.log(taskWithphaseList)
        rows.add(firstRowDup);
        //rows.add(firstRow)
        tasks.rows = rows;
        resources.rows = resourceRowData;
        //resources['rows'] = this.showAllContacts
        assignments.rows= assignmentRowData;
        
        ganttJSON ganttJsonData = new ganttJSON();
        ganttJsonData.tasks = tasks;
        ganttJsonData.resources = resources;
        ganttJsonData.dependenciesRows = taskDependencyData;
        ganttJsonData.assignments = assignments;
        ganttJsonData.resourcerows = resourceRowData;
        ganttJsonData.assignmentrows = assignmentRowData;
        String ganttString = JSON.serialize(ganttJsonData);
        return ganttString;
      }
    
    
    public class ganttJSON{
        @AuraEnabled
        public boolean success;
       
        @AuraEnabled
        public cls_tasks tasks;
        @AuraEnabled
        public cls_dependencies dependencies;
        @AuraEnabled
        public cls_resources resources;
        @AuraEnabled
        public cls_assignments assignments;
        @AuraEnabled
        public List<cls_dependencyRows>  dependenciesRows;
        @AuraEnabled
        public List<cls_resourceRows> resourcerows ;
        @AuraEnabled
        public List<cls_assignmentRows> assignmentrows;
        
        /*class cls_rows {
            public Integer id;	//1
            public String name;	//Important date
            public String startDate;	//2019-01-30
            public String endDate; 
            public Integer duration;	//0
            public String constraintType;
            public String type;
            public Boolean expanded;
            public String predecessor;
            public String internalresource;
            public String internalresourcename;
            public String contractorresource;
            public String contractorresourcename;
            public Integer percentDone;
            public Integer order;

        }*/
        
        
        
        /* class cls_baselines {
            public String startDate;	//2019-01-13T23:00:00
            public String endDate;	//2019-03-15T23:00:00
        } */
        
        
        
    }
    
    public class cls_children {
        @AuraEnabled
        public List<cls_children> children;
        @AuraEnabled
        public String id;	//11
        @AuraEnabled
        public String name;	//Install Apache test
        @AuraEnabled
        public Integer percentDone;	//50
        @AuraEnabled
        public String startDate;	//2019-01-14
        @AuraEnabled
        public Decimal duration;	//1
        @AuraEnabled
        public String endDate;	//2019-01-14
        @AuraEnabled
        public String type;	//Task
        @AuraEnabled
        public String phase;
        @AuraEnabled
        public String constraintType;
        @AuraEnabled
        public Boolean expanded;
        @AuraEnabled
        public String predecessor;
        @AuraEnabled
        public String internalresource;
        @AuraEnabled
        public String internalresourcename;
        @AuraEnabled
        public String contractorresource;
        @AuraEnabled
        public String contractorresourcename;
        @AuraEnabled
        public Integer order;
        @AuraEnabled
        public Decimal lag;
        @AuraEnabled
        public String contractoracc;
        @AuraEnabled
        public String notes;
        @AuraEnabled
        public Boolean milestone;

        //Added for contractor
        @AuraEnabled
        public String contractorname;
        //public cls_baselines[] baselines;
    }
    
    public class cls_tasks {
        @AuraEnabled
        public cls_children[] rows;
        //public cls_rows[] rows;
    }

    
    public class cls_dependencies {
        @AuraEnabled
        public cls_dependencyRows[] rows;
    }
    public class cls_resources {
        @AuraEnabled
        public cls_resourceRows[] rows;
    }
    public class cls_assignments {
        @AuraEnabled
        public cls_assignmentRows[] rows;
    }
    
    public class cls_assignmentRows{
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String event;
        @AuraEnabled
        public String resource;
    }
    
    public class cls_resourceRows{
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String calendar;
    }
    public class cls_dependencyRows{
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String fromTask;
        @AuraEnabled
        public String toTask;
        @AuraEnabled
        public Decimal lag ;
    }
   /*  @AuraEnabled
    public static fromJSON parse(String json){
        return (fromJSON) System.JSON.deserialize(json, fromJSON.class);
    } */
}