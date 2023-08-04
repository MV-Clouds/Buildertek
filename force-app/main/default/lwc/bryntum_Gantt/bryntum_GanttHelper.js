import insertUpdateTask from '@salesforce/apex/BT_NewGanttChartCls.insertUpdateTask';
import {
    ShowToastEvent
} from "lightning/platformShowToastEvent";

function formatData(scheduleData, scheduleItemsData, scheduleItemsDataList) {
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
    console.log('taskListForPhase :- ' + JSON.stringify(taskListForPhase));
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
            // console.log('method 1 in helper');

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
                //rowChilObj["cls"] = 'indentTaskColor'
            }
            rowChilObj['phase'] = taskListForPhase[i].buildertek__Phase__c

            //rowChilObj["constraintType"] = 'startnoearlierthan'
                if(taskListForPhase[i].buildertek__Dependency__c){
                rowChilObj["constraintType"] = ''
                }else{
                rowChilObj["constraintType"] = 'startnoearlierthan'
            }

                if(scheduleItemIdsList.indexOf(taskListForPhase[i].Id) < 0){
                scheduleItemIdsList.push(taskListForPhase[i].Id)
            }
            rowChilObj["id"] = taskListForPhase[i].Id
            rowChilObj["name"] = taskListForPhase[i].Name
            rowChilObj["percentDone"] = taskListForPhase[i].buildertek__Completion__c
            rowChilObj["startDate"] = taskListForPhase[i].buildertek__Start__c
            rowChilObj['predecessor'] = taskListForPhase[i].buildertek__Dependency__c;

            if (taskListForPhase[i].hasOwnProperty('buildertek__Dependency__c') == true) {
                rowChilObj['predecessorName'] = taskListForPhase[i].buildertek__Dependency__r.Name;
            } else {
                rowChilObj['predecessorName'] = '';
            }

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

                if(taskListForPhase[i].buildertek__Contractor__c){
                    rowChilObj["contractorname"] = taskListForPhase[i].buildertek__Contractor__r.Name;  //Added for contractor
                }else{
                rowChilObj["contractorname"] = '';
            }

            rowChilObj['notes'] = taskListForPhase[i].buildertek__Notes__c;
            // console.log('JUMBIO IN METHOD');
                if(taskListForPhase[i].buildertek__Lag__c != undefined && taskListForPhase[i].buildertek__Lag__c != null && taskListForPhase[i].buildertek__Lag__c != 0){
                    var startDate = new Date(taskListForPhase[i].buildertek__Start__c);
                    // commented this line because it is adding extra lags in the backend data
                    // commented by Nishit (MV Clouds)
                    // startDate.setDate(startDate.getDate() + (taskListForPhase[i].buildertek__Lag__c));
                    rowChilObj["startDate"] = new Date(startDate.getFullYear(),startDate.getMonth(),startDate.getDate(),0,0,0)
                }
            // console.log('start,',taskListForPhase[i].buildertek__Start__c)
            rowChilObj["duration"] = taskListForPhase[i].buildertek__Duration__c


            // console.log('contart',taskListForPhase[i])
            //rowChilObj["constraintDate"] = new Date(constraintDate)
                if(taskListForPhase[i].buildertek__Milestone__c){
                rowChilObj["duration"] = 0
                rowChilObj["durationMile"] = taskListForPhase[i].buildertek__Duration__c;
                rowChilObj["cls"] = 'milestoneCompleteColor'
                rowChilObj['orgmilestone'] = taskListForPhase[i].buildertek__Milestone__c;
                //rowChilObj['milestone'] = true;
            }
            rowChilObj["expanded"] = true
            rowChilObj["order"] = taskListForPhase[i].buildertek__Order__c
            // rowChilObj["endDate"] = taskData[i].value[j].buildertek__Finish__c
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
                    assignmentRow['id'] = taskListForPhase[i].Id+'_'+taskListForPhase[i].buildertek__Resource__c+'__index_'+i+'Resource_Name'+taskListForPhase[i].buildertek__Resource__r.Name;
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
                    assignmentRow['id'] = taskListForPhase[i].Id+'_'+taskListForPhase[i].buildertek__Contractor_Resource__c+'__index'+i+'ContractorResource_Name'+taskListForPhase[i].buildertek__Contractor_Resource__r.Name;
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
            // console.log('method 2 in helper');

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
                //rowChilObj["cls"] = 'indentTaskColor'
            }
            rowChilObj['phase'] = taskListForPhase[i].buildertek__Phase__c
            //rowChilObj["constraintType"] = 'startnoearlierthan'
                if(taskListForPhase[i].buildertek__Dependency__c){
                rowChilObj["constraintType"] = ''
                }else{
                rowChilObj["constraintType"] = 'startnoearlierthan'
            }
                if(scheduleItemIdsList.indexOf(taskListForPhase[i].Id) < 0){
                scheduleItemIdsList.push(taskListForPhase[i].Id)
            }
            rowChilObj["id"] = taskListForPhase[i].Id
            rowChilObj["name"] = taskListForPhase[i].Name
            rowChilObj["percentDone"] = taskListForPhase[i].buildertek__Completion__c
            rowChilObj["startDate"] = taskListForPhase[i].buildertek__Start__c

            rowChilObj['predecessor'] = taskListForPhase[i].buildertek__Dependency__c;

            if (taskListForPhase[i].hasOwnProperty('buildertek__Dependency__c') == true) {
                rowChilObj['predecessorName'] = taskListForPhase[i].buildertek__Dependency__r.Name;
            } else {
                rowChilObj['predecessorName'] = '';
            }

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

                if(taskListForPhase[i].buildertek__Contractor__c){
                    rowChilObj["contractorname"] = taskListForPhase[i].buildertek__Contractor__r.Name;  //Added for contractor
                }else{
                rowChilObj["contractorname"] = '';
            }

            rowChilObj['notes'] = taskListForPhase[i].buildertek__Notes__c;

            // console.log('JUMBIO IN METHOD 2');
                if(taskListForPhase[i].buildertek__Lag__c != undefined && taskListForPhase[i].buildertek__Lag__c != null && taskListForPhase[i].buildertek__Lag__c != 0){
                var startDate = new Date(taskListForPhase[i].buildertek__Start__c);
                // startDate.setDate(startDate.getDate() + (taskListForPhase[i].buildertek__Lag__c));
                //* commneted above line for preventing lags to adding into start date
                startDate.setDate(startDate.getDate());
                // console.log('method 2 id and start date '+startDate+' id '+taskListForPhase[i].Id);
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
                    assignmentRow['id'] = taskListForPhase[i].Id+'_'+taskListForPhase[i].buildertek__Resource__c+'__index_'+i+'Resource_Name'+taskListForPhase[i].buildertek__Resource__r.Name;
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
                    assignmentRow['id'] = taskListForPhase[i].Id+'_'+taskListForPhase[i].buildertek__Contractor_Resource__c+'__index'+i+'ContractorResource_Name'+taskListForPhase[i].buildertek__Contractor_Resource__r.Name;
                assignmentRow['event'] = taskListForPhase[i].Id
                assignmentRow['resource'] = taskListForPhase[i].buildertek__Contractor_Resource__c;
                assignmentRowData.push(assignmentRow)
            }
            taskPhaseRow["children"].push(rowChilObj);
            // console.log(taskPhaseRow)
            newPhaseFlag = false;
        }else if(!taskListForPhase[i].buildertek__Phase__c){
            // console.log('method 3 in helper');
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
                //rowChilObj["cls"] = 'indentTaskColor'
            }
            rowChilObj['phase'] = taskListForPhase[i].buildertek__Phase__c
            //rowChilObj["constraintType"] = 'startnoearlierthan'
            if(taskListForPhase[i].buildertek__Dependency__c){
                rowChilObj["constraintType"] = ''
            }else{
                rowChilObj["constraintType"] = 'startnoearlierthan'
            }
            if(scheduleItemIdsList.indexOf(taskListForPhase[i].Id) < 0){
                scheduleItemIdsList.push(taskListForPhase[i].Id)
            }
            rowChilObj["id"] = taskListForPhase[i].Id
            rowChilObj["name"] = taskListForPhase[i].Name
            rowChilObj["percentDone"] = taskListForPhase[i].buildertek__Completion__c
            rowChilObj["startDate"] = taskListForPhase[i].buildertek__Start__c


            rowChilObj['predecessor'] = taskListForPhase[i].buildertek__Dependency__c;

            if (taskListForPhase[i].hasOwnProperty('buildertek__Dependency__c') == true) {
                rowChilObj['predecessorName'] = taskListForPhase[i].buildertek__Dependency__r.Name;
            } else {
                rowChilObj['predecessorName'] = '';
            }

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

            if(taskListForPhase[i].buildertek__Contractor__c){
                rowChilObj["contractorname"] = taskListForPhase[i].buildertek__Contractor__r.Name;  //Added for contractor
            }else{
                rowChilObj["contractorname"] = '';
            }

            rowChilObj['notes'] = taskListForPhase[i].buildertek__Notes__c;

            if(taskListForPhase[i].buildertek__Lag__c != undefined && taskListForPhase[i].buildertek__Lag__c != null && taskListForPhase[i].buildertek__Lag__c != 0){
            var startDate = new Date(taskListForPhase[i].buildertek__Start__c);

            // commented this line because it is adding extra lag into child record
            // commented this by Nishit (MV Clouds)
            // startDate.setDate(startDate.getDate() + (taskListForPhase[i].buildertek__Lag__c));
            startDate.setDate(startDate.getDate());

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
                assignmentRow['id'] = taskListForPhase[i].Id+'_'+taskListForPhase[i].buildertek__Resource__c+'__index_'+i+'Resource_Name'+taskListForPhase[i].buildertek__Resource__r.Name;
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
                assignmentRow['id'] = taskListForPhase[i].Id+'_'+taskListForPhase[i].buildertek__Contractor_Resource__c+'__index'+i+'ContractorResource_Name'+taskListForPhase[i].buildertek__Contractor_Resource__r.Name;
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
    console.log('rows ==> ',rows);
    console.log('resourceRowData ==> ',resourceRowData);
    console.log('assignmentRowData ==> ',assignmentRowData);
    console.log('taskDependencyData ==> ',taskDependencyData);
    return formattedData;
}

function saveeditRecordMethod(event,thisVal){
    debugger;
    var isSaveNew = false;
    if(event.currentTarget.name =='saveNew'){
        isSaveNew = true
    }
    var that = thisVal;
    thisVal.isLoaded = true
    var isNotInsert;
    var schId;
    if(thisVal.scheduleData.Id){
        schId = thisVal.scheduleData.Id
    }
    console.log('id for record ',thisVal.taskRecordId);
    if(thisVal.taskRecordId){
        thisVal.newTaskRecordCreate.Id = thisVal.taskRecordId
        isNotInsert = true
    }else{
        thisVal.newTaskRecordCreate.Id = ''
        isNotInsert = false
    }
    //that.isLoaded = false
    if(thisVal.newTaskRecordCreate.Name){
        debugger
        var added;
        //thisVal.isLoaded = true
        thisVal.showEditPopup = false;
        //console.log('test11',Date.now())
        var addedTaskFromPlusIcon
        if(!isNotInsert){
            if(thisVal.recordTaskParent){
                thisVal.GanttVar.project.stm.autoRecord = false;
                if(thisVal.recordTaskParent.type == 'Task'){
                    addedTaskFromPlusIcon = thisVal.recordTaskParent.parent.insertChild(
                        {
                            name : thisVal.newTaskRecordCreate['Name'],
                            duration : thisVal.newTaskRecordCreate['buildertek__Duration__c'],
                            startDate : thisVal.newTaskRecordCreate['buildertek__Start__c']+'T00:00:00+05:30',
                            endDate : thisVal.newTaskRecordCreate['buildertek__Finish__c']+'T00:00:00+05:30',
                            type : 'Task',
                            parentId: schId+'_'+thisVal.newTaskRecordCreate['buildertek__Phase__c'],
                            percentDone: thisVal.newTaskRecordCreate['buildertek__Completion__c'],
                            indentVal: false,
                            customtype: thisVal.newTaskRecordCreate['buildertek__Type__c'],
                            expanded:true,
                            iconCls: 'b-fa b-fa-arrow-right',
                            constraintType : thisVal.newTaskRecordCreate['buildertek__Dependency__c'] ? '' : 'startnoearlierthan'
                        },
                        thisVal.recordTaskParent.nextSibling
                    )
                    if(thisVal.newTaskRecordCreate['buildertek__Dependency__c']){
                        var newDependencies = [
                            {
                            fromTask: thisVal.recordTaskParent,
                            toTask: addedTaskFromPlusIcon,
                                type: 2  // EndToStart
                            }
                        ]
                        thisVal.GanttVar.project.dependencyStore.add(newDependencies);
                    }
                }
                if(thisVal.recordTaskParent.type == 'Phase'){
                    //have same phase
                    if(thisVal.recordTaskParent.id == schId+'_'+thisVal.newTaskRecordCreate['buildertek__Phase__c']){
                        addedTaskFromPlusIcon = thisVal.recordTaskParent.insertChild(
                            {
                                name : thisVal.newTaskRecordCreate['Name'],
                                duration : thisVal.newTaskRecordCreate['buildertek__Duration__c'],
                                startDate : thisVal.newTaskRecordCreate['buildertek__Start__c']+'T00:00:00+05:30',
                                endDate : thisVal.newTaskRecordCreate['buildertek__Finish__c']+'T00:00:00+05:30',
                                type : 'Task',
                                parentId: schId+'_'+thisVal.newTaskRecordCreate['buildertek__Phase__c'],
                                percentDone: thisVal.newTaskRecordCreate['buildertek__Completion__c'],
                                indentVal: false,
                                customtype: thisVal.newTaskRecordCreate['buildertek__Type__c'],
                                expanded:true,
                                iconCls: 'b-fa b-fa-arrow-right',
                                constraintType : thisVal.newTaskRecordCreate['buildertek__Dependency__c'] ? '' : 'startnoearlierthan'
                            },
                            thisVal.recordTaskParent.nextSibling
                        );
                        if(thisVal.newTaskRecordCreate['buildertek__Dependency__c']){
                            var dependentTask;
                            if(thisVal.GanttVar.taskStore.getById(thisVal.newTaskRecordCreate['buildertek__Dependency__c'].id)){
                                dependentTask = thisVal.GanttVar.taskStore.getById(thisVal.newTaskRecordCreate['buildertek__Dependency__c'].id);
                            }
                            var newDependencies = [
                                {
                                fromTask: dependentTask,
                                toTask: addedTaskFromPlusIcon,
                                    type: 2  // EndToStart
                                }
                            ]
                            thisVal.GanttVar.project.dependencyStore.add(newDependencies);
                        }
                    }

                    //have diff phase
                    if(thisVal.newTaskRecordCreate['buildertek__Phase__c'] && thisVal.recordTaskParent.id != schId+'_'+thisVal.newTaskRecordCreate['buildertek__Phase__c']){
                        addedTaskFromPlusIcon = customInsertPhaseMethod(schId,thisVal);
                        if(thisVal.newTaskRecordCreate['buildertek__Dependency__c']){
                            var dependentTask;
                            if(thisVal.GanttVar.taskStore.getById(thisVal.newTaskRecordCreate['buildertek__Dependency__c'].id)){
                                dependentTask = thisVal.GanttVar.taskStore.getById(thisVal.newTaskRecordCreate['buildertek__Dependency__c'].id);
                            }
                            var newDependencies = [
                                {
                                fromTask: dependentTask,
                                toTask: addedTaskFromPlusIcon,
                                    type: 2  // EndToStart
                                }
                            ]
                            thisVal.GanttVar.project.dependencyStore.add(newDependencies);
                        }
                    }

                    //have no phase
                    if(!thisVal.newTaskRecordCreate['buildertek__Phase__c']){
                        addedTaskFromPlusIcon = thisVal.GanttVar.taskStore.rootNode.children[0].insertChild(
                            {
                                name : thisVal.newTaskRecordCreate['Name'],
                                duration : thisVal.newTaskRecordCreate['buildertek__Duration__c'],
                                startDate : thisVal.newTaskRecordCreate['buildertek__Start__c']+'T00:00:00+05:30',
                                endDate : thisVal.newTaskRecordCreate['buildertek__Finish__c']+'T00:00:00+05:30',
                                type : 'Task',
                            parentId: schId,
                            percentDone: thisVal.newTaskRecordCreate['buildertek__Completion__c'],
                            indentVal: false,
                            customtype: thisVal.newTaskRecordCreate['buildertek__Type__c'],
                                expanded:true,
                            iconCls: 'b-fa b-fa-arrow-right',
                                constraintType : thisVal.newTaskRecordCreate['buildertek__Dependency__c'] ? '' : 'startnoearlierthan'
                            }
                        );
                        if(thisVal.newTaskRecordCreate['buildertek__Dependency__c']){
                            var dependentTask;
                            if(thisVal.GanttVar.taskStore.getById(thisVal.newTaskRecordCreate['buildertek__Dependency__c'].id)){
                                dependentTask = thisVal.GanttVar.taskStore.getById(thisVal.newTaskRecordCreate['buildertek__Dependency__c'].id);
                            }
                            var newDependencies = [
                                {
                                fromTask: dependentTask,
                                toTask: addedTaskFromPlusIcon,
                                    type: 2  // EndToStart
                                }
                            ]
                            thisVal.GanttVar.project.dependencyStore.add(newDependencies);
                        }
                    }

                    /* if(thisVal.recordTaskParent.children){
                        var phIdxPath = thisVal.recordTaskParent.indexPath;
                        var tDt = JSON.parse(thisVal.GanttVar.taskStore.json);
                        var phaseLen = tDt[phIdxPath[0]-1].children[phIdxPath[1]-1].children.length;
                        console.log(thisVal.recordTaskParent.children[phaseLen-2])
                        tDt[phIdxPath[0]-1].children[phIdxPath[1]-1].children.splice(phaseLen-1,0,addedTaskFromPlusIcon._data);
                    } */
                }
                if(thisVal.recordTaskParent.type == 'Project'){
                    if(thisVal.newTaskRecordCreate['buildertek__Phase__c']){
                        var phaseParent;
                        if(thisVal.GanttVar.taskStore.getById(schId+'_'+thisVal.newTaskRecordCreate['buildertek__Phase__c'])){
                            phaseParent = thisVal.GanttVar.taskStore.getById(schId+'_'+thisVal.newTaskRecordCreate['buildertek__Phase__c'])
                            addedTaskFromPlusIcon = phaseParent.insertChild(
                                {
                                    name : thisVal.newTaskRecordCreate['Name'],
                                    duration : thisVal.newTaskRecordCreate['buildertek__Duration__c'],
                                    startDate : thisVal.newTaskRecordCreate['buildertek__Start__c']+'T00:00:00+05:30',
                                    endDate : thisVal.newTaskRecordCreate['buildertek__Finish__c']+'T00:00:00+05:30',
                                    type : 'Task',
                                    parentId: schId+'_'+thisVal.newTaskRecordCreate['buildertek__Phase__c'] ,
                                percentDone: thisVal.newTaskRecordCreate['buildertek__Completion__c'],
                                indentVal: false,
                                customtype: thisVal.newTaskRecordCreate['buildertek__Type__c'],
                                    expanded:true,
                                iconCls: 'b-fa b-fa-arrow-right',
                                    constraintType : thisVal.newTaskRecordCreate['buildertek__Dependency__c'] ? '' : 'startnoearlierthan'
                                }
                            );
                        }else{
                            phaseParent = thisVal.GanttVar.taskStore.rootNode.children[0].insertChild(
                                {
                                    name : thisVal.newTaskRecordCreate['Name'],
                                    duration : thisVal.newTaskRecordCreate['buildertek__Duration__c'],
                                    startDate : thisVal.newTaskRecordCreate['buildertek__Start__c']+'T00:00:00+05:30',
                                    endDate : thisVal.newTaskRecordCreate['buildertek__Finish__c']+'T00:00:00+05:30',
                                    type : 'Phase',
                                parentId: schId,
                                percentDone: thisVal.newTaskRecordCreate['buildertek__Completion__c'],
                                indentVal: false,
                                customtype: thisVal.newTaskRecordCreate['buildertek__Type__c'],
                                    expanded:true,
                                iconCls: '',
                                    constraintType : thisVal.newTaskRecordCreate['buildertek__Dependency__c'] ? '' : 'startnoearlierthan'
                                }
                            );
                            addedTaskFromPlusIcon = phaseParent.insertChild(
                                {
                                    name : thisVal.newTaskRecordCreate['Name'],
                                    duration : thisVal.newTaskRecordCreate['buildertek__Duration__c'],
                                    startDate : thisVal.newTaskRecordCreate['buildertek__Start__c']+'T00:00:00+05:30',
                                    endDate : thisVal.newTaskRecordCreate['buildertek__Finish__c']+'T00:00:00+05:30',
                                    type : 'Task',
                                    parentId: schId+'_'+thisVal.newTaskRecordCreate['buildertek__Phase__c'] ,
                                percentDone: thisVal.newTaskRecordCreate['buildertek__Completion__c'],
                                indentVal: false,
                                customtype: thisVal.newTaskRecordCreate['buildertek__Type__c'],
                                    expanded:true,
                                iconCls: 'b-fa b-fa-arrow-right',
                                    constraintType : thisVal.newTaskRecordCreate['buildertek__Dependency__c'] ? '' : 'startnoearlierthan'
                        }
                            );
                        }
                    }else{
                        addedTaskFromPlusIcon = thisVal.GanttVar.taskStore.rootNode.children[0].insertChild(
                            {
                                name : thisVal.newTaskRecordCreate['Name'],
                                duration : thisVal.newTaskRecordCreate['buildertek__Duration__c'],
                                startDate : thisVal.newTaskRecordCreate['buildertek__Start__c']+'T00:00:00+05:30',
                                endDate : thisVal.newTaskRecordCreate['buildertek__Finish__c']+'T00:00:00+05:30',
                                type : 'Task',
                            parentId: schId,
                            percentDone: thisVal.newTaskRecordCreate['buildertek__Completion__c'],
                            indentVal: false,
                            customtype: thisVal.newTaskRecordCreate['buildertek__Type__c'],
                                expanded:true,
                            iconCls: 'b-fa b-fa-arrow-right',
                                constraintType : thisVal.newTaskRecordCreate['buildertek__Dependency__c'] ? '' : 'startnoearlierthan'
                    }
                        );
                    }
                    if(thisVal.newTaskRecordCreate['buildertek__Dependency__c']){
                        var dependentTask;
                        if(thisVal.GanttVar.taskStore.getById(thisVal.newTaskRecordCreate['buildertek__Dependency__c'].id)){
                            dependentTask = thisVal.GanttVar.taskStore.getById(thisVal.newTaskRecordCreate['buildertek__Dependency__c'].id);
                        }
                        var newDependencies = [
                            {
                            fromTask: dependentTask,
                            toTask: addedTaskFromPlusIcon,
                                type: 2  // EndToStart
                            }
                        ]
                        thisVal.GanttVar.project.dependencyStore.add(newDependencies);
                    }
                    thisVal.GanttVar.project.propagate();
                    thisVal.GanttVar.refreshRows();
                }

                thisVal.GanttVar.project.propagate();
                thisVal.GanttVar.refreshRows();
                thisVal.GanttVar.project.stm.autoRecord = true;
            }else{
                if(thisVal.newTaskRecordCreate['buildertek__Phase__c']){
                    var phaseParent;
                    if(thisVal.GanttVar.taskStore.getById(schId+'_'+thisVal.newTaskRecordCreate['buildertek__Phase__c'])){
                        phaseParent = thisVal.GanttVar.taskStore.getById(schId+'_'+thisVal.newTaskRecordCreate['buildertek__Phase__c'])
                        addedTaskFromPlusIcon = phaseParent.insertChild(
                            {
                                name : thisVal.newTaskRecordCreate['Name'],
                                duration : thisVal.newTaskRecordCreate['buildertek__Duration__c'],
                                startDate : thisVal.newTaskRecordCreate['buildertek__Start__c']+'T00:00:00+05:30',
                                endDate : thisVal.newTaskRecordCreate['buildertek__Finish__c']+'T00:00:00+05:30',
                                type : 'Task',
                                parentId: schId+'_'+thisVal.newTaskRecordCreate['buildertek__Phase__c'] ,
                            percentDone: thisVal.newTaskRecordCreate['buildertek__Completion__c'],
                            indentVal: false,
                            customtype: thisVal.newTaskRecordCreate['buildertek__Type__c'],
                                expanded:true,
                            iconCls: 'b-fa b-fa-arrow-right',
                                constraintType : thisVal.newTaskRecordCreate['buildertek__Dependency__c'] ? '' : 'startnoearlierthan'
                            }
                        );
                    }else{
                        phaseParent = thisVal.GanttVar.taskStore.rootNode.children[0].insertChild(
                            {
                                name : thisVal.newTaskRecordCreate['Name'],
                                duration : thisVal.newTaskRecordCreate['buildertek__Duration__c'],
                                startDate : thisVal.newTaskRecordCreate['buildertek__Start__c']+'T00:00:00+05:30',
                                endDate : thisVal.newTaskRecordCreate['buildertek__Finish__c']+'T00:00:00+05:30',
                                type : 'Phase',
                            parentId: schId,
                            percentDone: thisVal.newTaskRecordCreate['buildertek__Completion__c'],
                            indentVal: false,
                            customtype: thisVal.newTaskRecordCreate['buildertek__Type__c'],
                                expanded:true,
                            iconCls: '',
                                constraintType : thisVal.newTaskRecordCreate['buildertek__Dependency__c'] ? '' : 'startnoearlierthan'
                            }
                        );
                        addedTaskFromPlusIcon = phaseParent.insertChild(
                            {
                                name : thisVal.newTaskRecordCreate['Name'],
                                duration : thisVal.newTaskRecordCreate['buildertek__Duration__c'],
                                startDate : thisVal.newTaskRecordCreate['buildertek__Start__c']+'T00:00:00+05:30',
                                endDate : thisVal.newTaskRecordCreate['buildertek__Finish__c']+'T00:00:00+05:30',
                                type : 'Task',
                                parentId: schId+'_'+thisVal.newTaskRecordCreate['buildertek__Phase__c'] ,
                            percentDone: thisVal.newTaskRecordCreate['buildertek__Completion__c'],
                            indentVal: false,
                            customtype: thisVal.newTaskRecordCreate['buildertek__Type__c'],
                                expanded:true,
                            iconCls: 'b-fa b-fa-arrow-right',
                                constraintType : thisVal.newTaskRecordCreate['buildertek__Dependency__c'] ? '' : 'startnoearlierthan'
                    }
                        );
                    }
                }else{
                    addedTaskFromPlusIcon = thisVal.GanttVar.taskStore.rootNode.children[0].insertChild(
                        {
                            name : thisVal.newTaskRecordCreate['Name'],
                            duration : thisVal.newTaskRecordCreate['buildertek__Duration__c'],
                            startDate : thisVal.newTaskRecordCreate['buildertek__Start__c']+'T00:00:00+05:30',
                            endDate : thisVal.newTaskRecordCreate['buildertek__Finish__c']+'T00:00:00+05:30',
                            type : 'Task',
                            parentId: thisVal.newTaskRecordCreate['buildertek__Phase__c'] ? schId+'_'+thisVal.newTaskRecordCreate['buildertek__Phase__c'] :schId ,
                        percentDone: thisVal.newTaskRecordCreate['buildertek__Completion__c'],
                        indentVal: false,
                        customtype: thisVal.newTaskRecordCreate['buildertek__Type__c'],
                            expanded:true,
                        iconCls: 'b-fa b-fa-arrow-right',
                            constraintType : thisVal.newTaskRecordCreate['buildertek__Dependency__c'] ? '' : 'startnoearlierthan'
                }
                    );
                }
                if(thisVal.newTaskRecordCreate['buildertek__Dependency__c']){
                    var dependentTask;
                    if(thisVal.GanttVar.taskStore.getById(thisVal.newTaskRecordCreate['buildertek__Dependency__c'].id)){
                        dependentTask = thisVal.GanttVar.taskStore.getById(thisVal.newTaskRecordCreate['buildertek__Dependency__c'].id);
                    }
                    var newDependencies = [
                        {
                        fromTask: dependentTask,
                        toTask: addedTaskFromPlusIcon,
                            type: 2  // EndToStart
                        }
                    ]
                    thisVal.GanttVar.project.dependencyStore.add(newDependencies);
                }

                thisVal.GanttVar.project.propagate();
                thisVal.GanttVar.refreshRows();
            }
            setTimeout(() => {
                //that.isLoaded = false;
                var newlyAddedTasks = thisVal.plusChildRecord;
                if(addedTaskFromPlusIcon){
                    newlyAddedTasks.push(addedTaskFromPlusIcon.id);
                    thisVal.plusChildRecord = newlyAddedTasks;
                    Object.assign(that.newTaskRecordCreate , that.newTaskRecordClone);
                }
            },500);
            console.log(addedTaskFromPlusIcon);
        }
        let temp = thisVal.newTaskRecordCreate;
        console.log('temp var here ==> ',{temp});
        insertUpdateTask({taskFields: JSON.stringify(thisVal.newTaskRecordCreate),isUpdate: isNotInsert,scheduleId : schId}).then(response => {
            console.log('RESPONSE');
            console.log({response})
            const filterChangeEvent = new CustomEvent('filterchange', {
                detail: { 'message' :'refresh page' },
            });
            that.dispatchEvent(filterChangeEvent);
            /* if(!isNotInsert){
                if(thisVal.recordTaskParent){
                    var tsId = thisVal.plusChildRecord[thisVal.addedTaskNumberCustom];
                    if(tsId){
                        var wbsId = thisVal.GanttVar.getRowById(tsId)._allCells[0].innerHTML;
                        var taIndx = thisVal.GanttVar.getRowById(tsId).index;
                        if(wbsId){
                            wbsId = wbsId.split('.')
                        }
                        var taskParsedData = JSON.parse(thisVal.GanttVar.taskStore.json);
                        var newRow = wbsId[2] ? taskParsedData[Number(wbsId[0])-1].children[Number(wbsId[1])-1].children[Number(wbsId[2])-1] : (wbsId[1] ? taskParsedData[Number(wbsId[0]-1)].children[Number(wbsId[1])-1] : taskParsedData[0])
                        newRow.id = response.Id;
                        var taskRowCus = thisVal.GanttVar.tasks[taIndx];
                        taskRowCus.id = response.Id;
                        thisVal.isrenderFromSaveorInsert = true;
                        thisVal.GanttVar.project.propagate();
                        thisVal.GanttVar.refreshRows();
                        thisVal.addedTaskNumberCustom++;
                    }
                }
            }else{
                that.gettaskrecords()
            } */
            window.sessionStorage.setItem('lastInteractedTaskId',response.Id)
            that.gettaskrecords();

            //console.log('test111',Date.now())
            if(isSaveNew){
                that.addNewTask();
                that.showEditPopup = true;
            }else{
                Object.assign(that.newTaskRecordCreate , that.newTaskRecordClone);
            }
            //that.isLoaded = false;
        }).catch(error => {
            console.log('error msg here --> ',error);
            thisVal.dispatchEvent(
                new ShowToastEvent({
                    title: "Error",
                    message: 'Circular Dependancy',
                    variant: "error"
                })
            );
            that.isLoaded = false;
        })
    }else{
        thisVal.dispatchEvent(
            new ShowToastEvent({
                title: "Error",
                message: 'Please Enter Schedule Item Name',
                variant: "error"
            })
        );
        that.isLoaded = false
    }
}


function customInsertPhaseMethod(schId,thisVal){
    var addedTaskFromPlusIcon;
    if(thisVal.newTaskRecordCreate['buildertek__Phase__c']){
        var phaseParent;
        if(thisVal.GanttVar.taskStore.getById(schId+'_'+thisVal.newTaskRecordCreate['buildertek__Phase__c'])){
            phaseParent = thisVal.GanttVar.taskStore.getById(schId+'_'+thisVal.newTaskRecordCreate['buildertek__Phase__c'])
            addedTaskFromPlusIcon = phaseParent.insertChild(
                {
                    name : thisVal.newTaskRecordCreate['Name'],
                    duration : thisVal.newTaskRecordCreate['buildertek__Duration__c'],
                    startDate : thisVal.newTaskRecordCreate['buildertek__Start__c']+'T00:00:00+05:30',
                    endDate : thisVal.newTaskRecordCreate['buildertek__Finish__c']+'T00:00:00+05:30',
                    type : 'Task',
                    parentId: schId+'_'+thisVal.newTaskRecordCreate['buildertek__Phase__c'] ,
                percentDone: thisVal.newTaskRecordCreate['buildertek__Completion__c'],
                indentVal: false,
                customtype: thisVal.newTaskRecordCreate['buildertek__Type__c'],
                    expanded:true,
                iconCls: 'b-fa b-fa-arrow-right',
                    constraintType : thisVal.newTaskRecordCreate['buildertek__Dependency__c'] ? '' : 'startnoearlierthan'
                }
            );
        }else{
            phaseParent = thisVal.GanttVar.taskStore.rootNode.children[0].insertChild(
                {
                    name : thisVal.newTaskRecordCreate['buildertek__Phase__c'],
                    duration : thisVal.newTaskRecordCreate['buildertek__Duration__c'],
                    startDate : thisVal.newTaskRecordCreate['buildertek__Start__c']+'T00:00:00+05:30',
                    endDate : thisVal.newTaskRecordCreate['buildertek__Finish__c']+'T00:00:00+05:30',
                    type : 'Phase',
                parentId: schId,
                percentDone: thisVal.newTaskRecordCreate['buildertek__Completion__c'],
                indentVal: false,
                customtype: thisVal.newTaskRecordCreate['buildertek__Type__c'],
                    expanded:true,
                iconCls: '',
                    constraintType : thisVal.newTaskRecordCreate['buildertek__Dependency__c'] ? '' : 'startnoearlierthan'
                }
            );
            addedTaskFromPlusIcon = phaseParent.insertChild(
                {
                    name : thisVal.newTaskRecordCreate['Name'],
                    duration : thisVal.newTaskRecordCreate['buildertek__Duration__c'],
                    startDate : thisVal.newTaskRecordCreate['buildertek__Start__c']+'T00:00:00+05:30',
                    endDate : thisVal.newTaskRecordCreate['buildertek__Finish__c']+'T00:00:00+05:30',
                    type : 'Task',
                    parentId: schId+'_'+thisVal.newTaskRecordCreate['buildertek__Phase__c'] ,
                percentDone: thisVal.newTaskRecordCreate['buildertek__Completion__c'],
                indentVal: false,
                customtype: thisVal.newTaskRecordCreate['buildertek__Type__c'],
                    expanded:true,
                iconCls: 'b-fa b-fa-arrow-right',
                    constraintType : thisVal.newTaskRecordCreate['buildertek__Dependency__c'] ? '' : 'startnoearlierthan'
        }
            );
        }
    }else{
        addedTaskFromPlusIcon = thisVal.GanttVar.taskStore.rootNode.children[0].insertChild(
            {
                name : thisVal.newTaskRecordCreate['Name'],
                duration : thisVal.newTaskRecordCreate['buildertek__Duration__c'],
                startDate : thisVal.newTaskRecordCreate['buildertek__Start__c']+'T00:00:00+05:30',
                endDate : thisVal.newTaskRecordCreate['buildertek__Finish__c']+'T00:00:00+05:30',
                type : 'Task',
            parentId: schId,
            percentDone: thisVal.newTaskRecordCreate['buildertek__Completion__c'],
            indentVal: false,
            customtype: thisVal.newTaskRecordCreate['buildertek__Type__c'],
                expanded:true,
            iconCls: 'b-fa b-fa-arrow-right',
                constraintType : thisVal.newTaskRecordCreate['buildertek__Dependency__c'] ? '' : 'startnoearlierthan'
            }
        );
    }
    return addedTaskFromPlusIcon;
}


function customInsertTaskMethod(schId,thisVal,dependentTask){
    var addedTaskFromPlusIcon = dependentTask.insertChild(
        {
            name : thisVal.newTaskRecordCreate['Name'],
            duration : thisVal.newTaskRecordCreate['buildertek__Duration__c'],
            startDate : thisVal.newTaskRecordCreate['buildertek__Start__c']+'T00:00:00+05:30',
            endDate : thisVal.newTaskRecordCreate['buildertek__Finish__c']+'T00:00:00+05:30',
            type : 'Task',
            parentId: schId+'_'+thisVal.newTaskRecordCreate['buildertek__Phase__c'] ,
        percentDone: thisVal.newTaskRecordCreate['buildertek__Completion__c'],
        indentVal: false,
        customtype: thisVal.newTaskRecordCreate['buildertek__Type__c'],
            expanded:true,
        iconCls: 'b-fa b-fa-arrow-right',
            constraintType : thisVal.newTaskRecordCreate['buildertek__Dependency__c'] ? '' : 'startnoearlierthan'
        }
    );
    return addedTaskFromPlusIcon
}

export{ formatData,saveeditRecordMethod };