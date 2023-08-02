function formatData(scheduleData,scheduleItemsData,scheduleItemsDataList){
    var taskData = scheduleItemsData;
    var taskDependencyData = [];
    var resourceRowData = [];
    var resourceRowIdList = []
    var assignmentRowData= [];
    var scheduleItemIdsList = [];
    var rows = [];
    var formattedData = {}

    var taskListForPhase = scheduleItemsDataList;
    var firstRowDup = {};
    firstRowDup["id"] = scheduleData.Id;
    firstRowDup["name"] = scheduleData.Name
    firstRowDup["startDate"] = ""
    firstRowDup["expanded"] = true
    firstRowDup["type"] = 'Project'
    firstRowDup['customtype'] = 'Project'
    firstRowDup["endDate"] = ""
    firstRowDup["children"] = []
    firstRowDup["constraintType"] = 'none' 
    var newPhaseFlag = true;
    var taskWithphaseList = [];
    var taskPhaseRow;
    var phIndex = -1;
    for(var i=0;i<taskListForPhase.length;i++){
        if(taskListForPhase[i].buildertek__Phase__c && taskPhaseRow){
            if(taskPhaseRow['name'] != taskListForPhase[i].buildertek__Phase__c){
                phIndex = phIndex+1;
                taskPhaseRow = {}
                taskPhaseRow["type"] = 'Phase'
                
                taskPhaseRow["id"] = taskListForPhase[i].buildertek__Schedule__c+"_"+taskListForPhase[i].buildertek__Phase__c
                taskPhaseRow["name"] = taskListForPhase[i].buildertek__Phase__c
                //row["percentDone"]: 70,
                taskPhaseRow["startDate"] = ""
                taskPhaseRow["expanded"] = true
                taskPhaseRow["endDate"] = ""
                taskPhaseRow["children"] = []
                taskPhaseRow["customtype"] = 'Phase'
               // taskPhaseRow["children"].push(taskListForPhase[i])
                taskPhaseRow["constraintType"] = 'none'
                newPhaseFlag = false;
            }
                var rowChilObj = {};
                rowChilObj["type"] = 'Task'
                rowChilObj["customtype"] = taskListForPhase[i].buildertek__Type__c
                if(taskListForPhase[i].buildertek__Type__c == 'Milestone'){
                    rowChilObj["cls"] = 'milestoneTypeColor'
                }
                rowChilObj["iconCls"] = "b-fa b-fa-arrow-right"
                rowChilObj["indentVal"] = taskListForPhase[i].buildertek__Indent_Task__c;
                if(taskListForPhase[i].buildertek__Indent_Task__c){
                    rowChilObj["iconCls"] = "b-fa b-fa-arrow-left indentTrue"
                }
                rowChilObj['phase'] = taskListForPhase[i].buildertek__Phase__c
                rowChilObj["constraintType"] = 'startnoearlierthan' 
                if(scheduleItemIdsList.indexOf(taskListForPhase[i].Id) < 0){
                    scheduleItemIdsList.push(taskListForPhase[i].Id)
                }
                rowChilObj["id"] = taskListForPhase[i].Id
                rowChilObj["name"] = taskListForPhase[i].Name
                rowChilObj["percentDone"] = taskListForPhase[i].buildertek__Completion__c
                rowChilObj["startDate"] = taskListForPhase[i].buildertek__Start__c
                rowChilObj['predecessor'] = taskListForPhase[i].buildertek__Dependency__c;
                rowChilObj['internalresource'] = taskListForPhase[i].buildertek__Resource__c;
                
                if(taskListForPhase[i].buildertek__Resource__c){
                    rowChilObj['internalresourcename'] = taskListForPhase[i].buildertek__Resource__r.Name;
                }else{
                    rowChilObj['internalresourcename'] = '';
                }
                
                rowChilObj['contractorresource'] = taskListForPhase[i].buildertek__Contractor_Resource__c;
                
                if(taskListForPhase[i].buildertek__Contractor_Resource__c){
                    rowChilObj['contractorresourcename'] = taskListForPhase[i].buildertek__Contractor_Resource__r.Name;
                }else{
                    rowChilObj['contractorresourcename'] = '';
                }
                rowChilObj['contractoracc'] = taskListForPhase[i].buildertek__Contractor__c;
                rowChilObj['notes'] = taskListForPhase[i].buildertek__Notes__c;

                if(taskListForPhase[i].buildertek__Lag__c != undefined && taskListForPhase[i].buildertek__Lag__c != null && taskListForPhase[i].buildertek__Lag__c != 0){
                var startDate = new Date(taskListForPhase[i].buildertek__Start__c);
                startDate.setDate(startDate.getDate() + (taskListForPhase[i].buildertek__Lag__c));
                rowChilObj["startDate"] = new Date(startDate.getFullYear(),startDate.getMonth(),startDate.getDate(),0,0,0)
                }
               // console.log('start,',taskListForPhase[i].buildertek__Start__c)
                rowChilObj["duration"] = taskListForPhase[i].buildertek__Duration__c
                
                
               // console.log('contart',taskListForPhase[i])
                //rowChilObj["constraintDate"] = new Date(constraintDate)
                if(taskListForPhase[i].buildertek__Milestone__c){
                    rowChilObj["duration"] = 0
                    rowChilObj["cls"] = 'milestoneCompleteColor'
                    rowChilObj['orgmilestone'] = taskListForPhase[i].buildertek__Milestone__c;
                    //rowChilObj['milestone'] = true;
                }
                rowChilObj["expanded"] = true
                rowChilObj["order"] = taskListForPhase[i].buildertek__Order__c
                //rowChilObj["endDate"] = taskData[i].value[j].buildertek__Finish__c
                //row["children"].push(rowChilObj);
                var dependencyRow = {};
                if(taskListForPhase[i].buildertek__Dependency__c){
                    dependencyRow["id" ]  = taskListForPhase[i].Id+'_'+taskListForPhase[i].buildertek__Dependency__c
                dependencyRow["fromTask"] = taskListForPhase[i].buildertek__Dependency__c
                dependencyRow["toTask"]  = taskListForPhase[i].Id
                dependencyRow["lag"]  = taskListForPhase[i].buildertek__Lag__c
                taskDependencyData.push(dependencyRow)
                }
                
                
                if(!taskListForPhase[i].buildertek__Milestone__c && taskListForPhase[i].buildertek__Resource__c){
                    if(resourceRowIdList.indexOf(taskListForPhase[i].buildertek__Resource__c) < 0){
                        var resourceRow = {}
                        resourceRow['id'] = taskListForPhase[i].buildertek__Resource__c;
                        resourceRow['name'] = taskListForPhase[i].buildertek__Resource__r.Name;
                        resourceRow['calendar'] = "general";
                        resourceRowData.push(resourceRow)
                        resourceRowIdList.push(taskListForPhase[i].buildertek__Resource__c)
                    }
                    
                }
                /* if(!taskListForPhase[i].buildertek__Milestone__c && taskListForPhase[i].buildertek__Contractor__c){
                    
                    if(resourceRowIdList.indexOf(taskListForPhase[i].buildertek__Contractor__c) < 0){
                        var resourceRow = {}
                        resourceRow['id'] = taskListForPhase[i].buildertek__Contractor__c
                        resourceRow['name'] = taskListForPhase[i].buildertek__Contractor__r.Name;
                        resourceRow['calendar'] = "general";
                        resourceRowData.push(resourceRow)
                        resourceRowIdList.push(resourceRow['id'])
                    }
                    
                } */
                if(!taskListForPhase[i].buildertek__Milestone__c && taskListForPhase[i].buildertek__Contractor_Resource__c){
                    
                    if(resourceRowIdList.indexOf(taskListForPhase[i].buildertek__Contractor_Resource__c) < 0){
                        var resourceRow = {}
                        resourceRow['id'] = taskListForPhase[i].buildertek__Contractor_Resource__c
                        resourceRow['name'] = taskListForPhase[i].buildertek__Contractor_Resource__r.Name;
                        resourceRow['calendar'] = "general";
                        resourceRowData.push(resourceRow)
                        resourceRowIdList.push(resourceRow['id'])
                    }
                }
            
                
                if(!taskListForPhase[i].buildertek__Milestone__c && taskListForPhase[i].buildertek__Resource__c){
                    var assignmentRow = {}
                    assignmentRow['id'] = taskListForPhase[i].Id+'_'+taskListForPhase[i].buildertek__Resource__c+'__index_'+i+'Resource';
                    assignmentRow['event'] = taskListForPhase[i].Id
                    assignmentRow['resource'] = taskListForPhase[i].buildertek__Resource__c;
                    assignmentRowData.push(assignmentRow)
                }
               /*  if(!taskListForPhase[i].buildertek__Milestone__c && taskListForPhase[i].buildertek__Contractor__c){
                    var assignmentRow = {}
                    assignmentRow['id'] = taskListForPhase[i].Id+'_'+taskListForPhase[i].buildertek__Contractor__c+'__index_'+i+'Contractor';
                    assignmentRow['event'] = taskListForPhase[i].Id
                    assignmentRow['resource'] = taskListForPhase[i].buildertek__Contractor__c;
                    assignmentRowData.push(assignmentRow)
                } */
                if(!taskListForPhase[i].buildertek__Milestone__c && taskListForPhase[i].buildertek__Contractor_Resource__c){
                    var assignmentRow = {}
                    assignmentRow['id'] = taskListForPhase[i].Id+'_'+taskListForPhase[i].buildertek__Contractor_Resource__c+'__index'+i+'ContractorResource';
                    assignmentRow['event'] = taskListForPhase[i].Id
                    assignmentRow['resource'] = taskListForPhase[i].buildertek__Contractor_Resource__c;
                    assignmentRowData.push(assignmentRow)
                }
                taskPhaseRow["children"].push(rowChilObj);
                
               // console.log(taskPhaseRow)
                var found = false;
               if(firstRowDup['children'].length){
                   for(var k=0;k<firstRowDup['children'].length;k++){
                       if(firstRowDup['children'][k].id == taskPhaseRow['id']){
                        firstRowDup['children'][k] = taskPhaseRow
                        found = true
                       }
                   }
                    //firstRowDup['children'].phIndex = taskPhaseRow
               }else{
                    firstRowDup['children'].push(taskPhaseRow);
                    found = true
               }
               if(!found){
                    firstRowDup['children'].push(taskPhaseRow);
               }
            //firstRowDup['children'].push(taskPhaseRow);
        }else if(taskListForPhase[i].buildertek__Phase__c && !taskPhaseRow){
            taskPhaseRow = {};
            phIndex = phIndex+1;
            taskPhaseRow["type"] = 'Phase'
            taskPhaseRow["id"] = taskListForPhase[i].buildertek__Schedule__c+"_"+taskListForPhase[i].buildertek__Phase__c
            taskPhaseRow["name"] = taskListForPhase[i].buildertek__Phase__c
            //row["percentDone"]: 70,
            taskPhaseRow["startDate"] = ""
            taskPhaseRow["expanded"] = true
            taskPhaseRow["endDate"] = ""
            taskPhaseRow["children"] = []
            //taskPhaseRow["children"].push(taskListForPhase[i])
            taskPhaseRow["constraintType"] = 'none'
            var rowChilObj = {};
                rowChilObj["type"] = 'Task'
                rowChilObj["customtype"] = taskListForPhase[i].buildertek__Type__c
                if(taskListForPhase[i].buildertek__Type__c == 'Milestone'){
                    rowChilObj["cls"] = 'milestoneTypeColor'
                }
                rowChilObj["iconCls"] = "b-fa b-fa-arrow-right"
                rowChilObj["indentVal"] = taskListForPhase[i].buildertek__Indent_Task__c;
                if(taskListForPhase[i].buildertek__Indent_Task__c){
                    rowChilObj["iconCls"] = "b-fa b-fa-arrow-left indentTrue"
                }
                rowChilObj['phase'] = taskListForPhase[i].buildertek__Phase__c
                rowChilObj["constraintType"] = 'startnoearlierthan' 
                if(scheduleItemIdsList.indexOf(taskListForPhase[i].Id) < 0){
                    scheduleItemIdsList.push(taskListForPhase[i].Id)
                }
                rowChilObj["id"] = taskListForPhase[i].Id
                rowChilObj["name"] = taskListForPhase[i].Name
                rowChilObj["percentDone"] = taskListForPhase[i].buildertek__Completion__c
                rowChilObj["startDate"] = taskListForPhase[i].buildertek__Start__c
                
                rowChilObj['predecessor'] = taskListForPhase[i].buildertek__Dependency__c;
                rowChilObj['internalresource'] = taskListForPhase[i].buildertek__Resource__c;
                
                if(taskListForPhase[i].buildertek__Resource__c){
                    rowChilObj['internalresourcename'] = taskListForPhase[i].buildertek__Resource__r.Name;
                }else{
                    rowChilObj['internalresourcename'] = '';
                }

                rowChilObj['contractorresource'] = taskListForPhase[i].buildertek__Contractor_Resource__c;
                
                if(taskListForPhase[i].buildertek__Contractor_Resource__c){
                    rowChilObj['contractorresourcename'] = taskListForPhase[i].buildertek__Contractor_Resource__r.Name;
                }else{
                    rowChilObj['contractorresourcename'] = ''
                }
                rowChilObj['contractoracc'] = taskListForPhase[i].buildertek__Contractor__c;
                rowChilObj['notes'] = taskListForPhase[i].buildertek__Notes__c;

                if(taskListForPhase[i].buildertek__Lag__c != undefined && taskListForPhase[i].buildertek__Lag__c != null && taskListForPhase[i].buildertek__Lag__c != 0){
                var startDate = new Date(taskListForPhase[i].buildertek__Start__c);
                startDate.setDate(startDate.getDate() + (taskListForPhase[i].buildertek__Lag__c));
                rowChilObj["startDate"] = new Date(startDate.getFullYear(),startDate.getMonth(),startDate.getDate(),0,0,0)
                }
                //console.log('start,',taskListForPhase[i].buildertek__Start__c)
                rowChilObj["duration"] = taskListForPhase[i].buildertek__Duration__c
                
                
                // var constraintDate = new Date(taskData[i].value[j].buildertek__Start__c);
                //if(taskData[i].value[j].buildertek__Lag__c){
                //constraintDate.setDate(constraintDate.getDate() + (taskData[i].value[j].buildertek__Lag__c));
               // }
                
               // console.log('contart',constraintDate) 
               // console.log('contart',taskListForPhase[i])
                //rowChilObj["constraintDate"] = new Date(constraintDate)
                if(taskListForPhase[i].buildertek__Milestone__c){
                    rowChilObj["duration"] = 0;
                    rowChilObj["cls"] = 'milestoneCompleteColor'
                    rowChilObj['orgmilestone'] = taskListForPhase[i].buildertek__Milestone__c;
                    //rowChilObj['type'] = 'Milestone';
                    //rowChilObj['milestone'] = true;
                }
                
                rowChilObj["expanded"] = true
                rowChilObj["order"] = taskListForPhase[i].buildertek__Order__c
                //rowChilObj["endDate"] = taskData[i].value[j].buildertek__Finish__c
                //row["children"].push(rowChilObj);
                var dependencyRow = {};
                if(taskListForPhase[i].buildertek__Dependency__c){
                    dependencyRow["id" ]  = taskListForPhase[i].Id+'_'+taskListForPhase[i].buildertek__Dependency__c
                dependencyRow["fromTask"] = taskListForPhase[i].buildertek__Dependency__c
                dependencyRow["toTask"]  = taskListForPhase[i].Id
                dependencyRow["lag"]  = taskListForPhase[i].buildertek__Lag__c
                taskDependencyData.push(dependencyRow)
                }
                
                
                if(!taskListForPhase[i].buildertek__Milestone__c && taskListForPhase[i].buildertek__Resource__c){
                    if(resourceRowIdList.indexOf(taskListForPhase[i].buildertek__Resource__c) < 0){
                        var resourceRow = {}
                        resourceRow['id'] = taskListForPhase[i].buildertek__Resource__c;
                        resourceRow['name'] = taskListForPhase[i].buildertek__Resource__r.Name;
                        resourceRow['calendar'] = "general";
                        resourceRowData.push(resourceRow)
                        resourceRowIdList.push(resourceRow['id'])
                    }
                    
                }
                /* if(!taskListForPhase[i].buildertek__Milestone__c && taskListForPhase[i].buildertek__Contractor__c){
                    
                    if(resourceRowIdList.indexOf(taskListForPhase[i].buildertek__Contractor__c) < 0){
                        var resourceRow = {}
                        resourceRow['id'] = taskListForPhase[i].buildertek__Contractor__c
                        resourceRow['name'] = taskListForPhase[i].buildertek__Contractor__r.Name;
                        resourceRow['calendar'] = "general";
                        resourceRowData.push(resourceRow)
                        resourceRowIdList.push(resourceRow['id'])
                    }
                    
                } */
                if(!taskListForPhase[i].buildertek__Milestone__c && taskListForPhase[i].buildertek__Contractor_Resource__c){
                    
                    if(resourceRowIdList.indexOf(taskListForPhase[i].buildertek__Contractor_Resource__c) < 0){
                        var resourceRow = {}
                        resourceRow['id'] = taskListForPhase[i].buildertek__Contractor_Resource__c
                        resourceRow['name'] = taskListForPhase[i].buildertek__Contractor_Resource__r.Name;
                        resourceRow['calendar'] = "general";
                        resourceRowData.push(resourceRow)
                        resourceRowIdList.push(resourceRow['id'])
                    }
                }
            
                
                if(!taskListForPhase[i].buildertek__Milestone__c && taskListForPhase[i].buildertek__Resource__c){
                    var assignmentRow = {}
                    assignmentRow['id'] = taskListForPhase[i].Id+'_'+taskListForPhase[i].buildertek__Resource__c+'__index_'+i+'Resource';
                    assignmentRow['event'] = taskListForPhase[i].Id
                    assignmentRow['resource'] = taskListForPhase[i].buildertek__Resource__c;
                    assignmentRowData.push(assignmentRow)
                }
                /* if(!taskListForPhase[i].buildertek__Milestone__c && taskListForPhase[i].buildertek__Contractor__c){
                    var assignmentRow = {}
                    assignmentRow['id'] = taskListForPhase[i].Id+'_'+taskListForPhase[i].buildertek__Contractor__c+'__index_'+i+'Contractor';
                    assignmentRow['event'] = taskListForPhase[i].Id
                    assignmentRow['resource'] = taskListForPhase[i].buildertek__Contractor__c;
                    assignmentRowData.push(assignmentRow)
                } */
                if(!taskListForPhase[i].buildertek__Milestone__c && taskListForPhase[i].buildertek__Contractor_Resource__c){
                    var assignmentRow = {}
                    assignmentRow['id'] = taskListForPhase[i].Id+'_'+taskListForPhase[i].buildertek__Contractor_Resource__c+'__index'+i+'ContractorResource';
                    assignmentRow['event'] = taskListForPhase[i].Id
                    assignmentRow['resource'] = taskListForPhase[i].buildertek__Contractor_Resource__c;
                    assignmentRowData.push(assignmentRow)
                }
                taskPhaseRow["children"].push(rowChilObj);
               // console.log(taskPhaseRow)
                newPhaseFlag = false;
        }else if(!taskListForPhase[i].buildertek__Phase__c){
            phIndex = phIndex+1;
            var rowChilObj = {};
            rowChilObj["type"] = 'Task'
            rowChilObj["customtype"] = taskListForPhase[i].buildertek__Type__c
            if(taskListForPhase[i].buildertek__Type__c == 'Milestone'){
                rowChilObj["cls"] = 'milestoneTypeColor'
            }
            rowChilObj["iconCls"] = "b-fa b-fa-arrow-right"
            rowChilObj["indentVal"] = taskListForPhase[i].buildertek__Indent_Task__c;
            if(taskListForPhase[i].buildertek__Indent_Task__c){
                rowChilObj["iconCls"] = "b-fa b-fa-arrow-left indentTrue"
            }
            rowChilObj['phase'] = taskListForPhase[i].buildertek__Phase__c
            rowChilObj["constraintType"] = 'startnoearlierthan' 
            if(scheduleItemIdsList.indexOf(taskListForPhase[i].Id) < 0){
                scheduleItemIdsList.push(taskListForPhase[i].Id)
            }
            rowChilObj["id"] = taskListForPhase[i].Id
            rowChilObj["name"] = taskListForPhase[i].Name
            rowChilObj["percentDone"] = taskListForPhase[i].buildertek__Completion__c
            rowChilObj["startDate"] = taskListForPhase[i].buildertek__Start__c

            
            rowChilObj['predecessor'] = taskListForPhase[i].buildertek__Dependency__c;
            rowChilObj['internalresource'] = taskListForPhase[i].buildertek__Resource__c;
            
            if(taskListForPhase[i].buildertek__Resource__c){
                rowChilObj['internalresourcename'] = taskListForPhase[i].buildertek__Resource__r.Name;
            }else{
                rowChilObj['internalresourcename'] = '';
            }
            rowChilObj['contractorresource'] = taskListForPhase[i].buildertek__Contractor_Resource__c;
            
            if(taskListForPhase[i].buildertek__Contractor_Resource__c){
                rowChilObj['contractorresourcename'] = taskListForPhase[i].buildertek__Contractor_Resource__r.Name;
            }else{
                rowChilObj['contractorresourcename'] = '';
            }
            rowChilObj['contractoracc'] = taskListForPhase[i].buildertek__Contractor__c;
            rowChilObj['notes'] = taskListForPhase[i].buildertek__Notes__c;

            if(taskListForPhase[i].buildertek__Lag__c != undefined && taskListForPhase[i].buildertek__Lag__c != null && taskListForPhase[i].buildertek__Lag__c != 0){
            var startDate = new Date(taskListForPhase[i].buildertek__Start__c);
            startDate.setDate(startDate.getDate() + (taskListForPhase[i].buildertek__Lag__c));
            rowChilObj["startDate"] = new Date(startDate.getFullYear(),startDate.getMonth(),startDate.getDate(),0,0,0)
            }
            //console.log('start,',taskListForPhase[i].buildertek__Start__c)
            rowChilObj["duration"] = taskListForPhase[i].buildertek__Duration__c
            
            
            
           // console.log('contart',taskListForPhase[i])
            //rowChilObj["constraintDate"] = new Date(constraintDate)
            if(taskListForPhase[i].buildertek__Milestone__c){
                rowChilObj["duration"] = 0
                rowChilObj["cls"] = 'milestoneCompleteColor'
                rowChilObj['orgmilestone'] = taskListForPhase[i].buildertek__Milestone__c;
            }
            
            rowChilObj["expanded"] = true
            rowChilObj["order"] = taskListForPhase[i].buildertek__Order__c
            firstRowDup['children'].push(rowChilObj);
            //row["children"].push(rowChilObj);
            var dependencyRow = {};
            if(taskListForPhase[i].buildertek__Dependency__c){
                dependencyRow["id" ]  = taskListForPhase[i].Id+'_'+taskListForPhase[i].buildertek__Dependency__c
                dependencyRow["fromTask"] = taskListForPhase[i].buildertek__Dependency__c
                dependencyRow["toTask"]  = taskListForPhase[i].Id
                dependencyRow["lag"]  = taskListForPhase[i].buildertek__Lag__c
                taskDependencyData.push(dependencyRow)
            }
            
            
            if(!taskListForPhase[i].buildertek__Milestone__c && taskListForPhase[i].buildertek__Resource__c){
                if(resourceRowIdList.indexOf(taskListForPhase[i].buildertek__Resource__c) < 0){
                    var resourceRow = {}
                    resourceRow['id'] = taskListForPhase[i].buildertek__Resource__c;
                    resourceRow['name'] = taskListForPhase[i].buildertek__Resource__r.Name;
                    resourceRow['calendar'] = "general";
                    resourceRowData.push(resourceRow)
                    resourceRowIdList.push(resourceRow['id'])
                }
                
            }
            /* if(!taskListForPhase[i].buildertek__Milestone__c && taskListForPhase[i].buildertek__Contractor__c){
                
                if(resourceRowIdList.indexOf(taskListForPhase[i].buildertek__Contractor__c) < 0){
                    var resourceRow = {}
                    resourceRow['id'] = taskListForPhase[i].buildertek__Contractor__c
                    resourceRow['name'] = taskListForPhase[i].buildertek__Contractor__r.Name;
                    resourceRow['calendar'] = "general";
                    resourceRowData.push(resourceRow)
                    resourceRowIdList.push(resourceRow['id'])
                }
                
            } */
            if(!taskListForPhase[i].buildertek__Milestone__c && taskListForPhase[i].buildertek__Contractor_Resource__c){
                
                if(resourceRowIdList.indexOf(taskListForPhase[i].buildertek__Contractor_Resource__c) < 0){
                    var resourceRow = {}
                    resourceRow['id'] = taskListForPhase[i].buildertek__Contractor_Resource__c
                    resourceRow['name'] = taskListForPhase[i].buildertek__Contractor_Resource__r.Name;
                    resourceRow['calendar'] = "general";
                    resourceRowData.push(resourceRow)
                    resourceRowIdList.push(resourceRow['id'])
                }
            }
        
            
            if(!taskListForPhase[i].buildertek__Milestone__c && taskListForPhase[i].buildertek__Resource__c){
                var assignmentRow = {}
                assignmentRow['id'] = taskListForPhase[i].Id+'_'+taskListForPhase[i].buildertek__Resource__c+'__index_'+i+'Resource';
                assignmentRow['event'] = taskListForPhase[i].Id
                assignmentRow['resource'] = taskListForPhase[i].buildertek__Resource__c;
                assignmentRowData.push(assignmentRow)
            }
            /* if(!taskListForPhase[i].buildertek__Milestone__c && taskListForPhase[i].buildertek__Contractor__c){
                var assignmentRow = {}
                assignmentRow['id'] = taskListForPhase[i].Id+'_'+taskListForPhase[i].buildertek__Contractor__c+'__index_'+i+'Contractor';
                assignmentRow['event'] = taskListForPhase[i].Id
                assignmentRow['resource'] = taskListForPhase[i].buildertek__Contractor__c;
                assignmentRowData.push(assignmentRow)
            } */
            if(!taskListForPhase[i].buildertek__Milestone__c && taskListForPhase[i].buildertek__Contractor_Resource__c){
                var assignmentRow = {}
                assignmentRow['id'] = taskListForPhase[i].Id+'_'+taskListForPhase[i].buildertek__Contractor_Resource__c+'__index'+i+'ContractorResource';
                assignmentRow['event'] = taskListForPhase[i].Id
                assignmentRow['resource'] = taskListForPhase[i].buildertek__Contractor_Resource__c;
                assignmentRowData.push(assignmentRow)
            }
            
        }
        
    }
    rows.push(firstRowDup);
    formattedData['rows'] = rows;
    formattedData['resourceRowData'] = resourceRowData;
    formattedData['assignmentRowData'] = assignmentRowData
    formattedData['taskDependencyData'] = taskDependencyData;
    return formattedData;
}


export{ formatData };