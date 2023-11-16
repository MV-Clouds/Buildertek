function formatApexDatatoJSData(scheduleData, scheduleItemsData, scheduleItemsDataList) {
    var taskData = scheduleItemsData;
    var taskDependencyData = [];
    var resourceRowData = [];
    var resourceRowIdList = [];
    var assignmentRowData= [];
    var scheduleItemIdsList = [];
    var rows = [];
    var formattedData = {}

    var taskListForPhase = scheduleItemsDataList;
    var firstRowDup = {};
    firstRowDup["id"] = scheduleData.Id;
    firstRowDup["name"] = scheduleData.buildertek__Description__c;
    firstRowDup["startDate"] = scheduleData.buildertek__Initial_Start_Date__c;
    var projstartdate = scheduleData.buildertek__Initial_Start_Date__c;
    firstRowDup["expanded"] = true
    firstRowDup["type"] = 'Project'
    firstRowDup['customtype'] = 'Project'
    firstRowDup["endDate"] = ""
    firstRowDup["children"] = []
    // firstRowDup["constraintType"] = 'startnoearlierthan'
    // firstRowDup["constraintDate"] = ""
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

                taskPhaseRow["startDate"] = ""
                taskPhaseRow["expanded"] = true
                taskPhaseRow["Contractor"] = 'test'
                taskPhaseRow["endDate"] = ""
                taskPhaseRow["children"] = []
                taskPhaseRow["customtype"] = 'Phase'
                // taskPhaseRow["constraintDate"] = ""

                // taskPhaseRow["constraintType"] = 'startnoearlierthan'
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
            rowChilObj['phase'] = taskListForPhase[i].buildertek__Phase__c;

            //*comparing task finish date with today date and setting color accordingly
            let taskFinishDate = new Date(taskListForPhase[i].buildertek__Finish__c);
            taskFinishDate.setHours(0, 0, 0, 0);
            let todayDate = new Date();
            todayDate.setHours(0, 0, 0, 0);

            if ((taskFinishDate < todayDate) && taskListForPhase[i].buildertek__Completion__c != 100) {
                rowChilObj['eventColor'] = 'red';
            } else {
                rowChilObj['eventColor'] = taskListForPhase[i].buildertek__task_color__c;
            }


                if(taskListForPhase[i].buildertek__Dependency__c){
                // rowChilObj["constraintType"] = ''
                }else{
                // rowChilObj["constraintType"] = 'startnoearlierthan'
            }

                if(scheduleItemIdsList.indexOf(taskListForPhase[i].Id) < 0){
                scheduleItemIdsList.push(taskListForPhase[i].Id)
            }
            rowChilObj["id"] = taskListForPhase[i].Id
            rowChilObj["name"] = taskListForPhase[i].Name
            rowChilObj["percentDone"] = taskListForPhase[i].buildertek__Completion__c
            rowChilObj["startDate"] = taskListForPhase[i].buildertek__Start__c
            rowChilObj["constraintDate"] = taskListForPhase[i].buildertek__Start__c
            rowChilObj["constraintType"] = 'startnoearlierthan'
            // rowChilObj["constraintDate"] = projstartdate
            // rowChilObj["constraintType"] = 'startnoearlierthan'
            rowChilObj['predecessor'] = taskListForPhase[i].buildertek__Dependency__c;

            if (taskListForPhase[i].hasOwnProperty('buildertek__Dependency__c') == true) {
                rowChilObj['predecessorName'] = taskListForPhase[i].buildertek__Dependency__r.Name;
                // rowChilObj['']
            } else {
                rowChilObj['predecessorName'] = '';
            }

            rowChilObj['contractorId'] = taskListForPhase[i].buildertek__Contractor__c;

                if(taskListForPhase[i].buildertek__Contractor__c){
                    rowChilObj["contractorname"] = taskListForPhase[i].buildertek__Contractor__r.Name;  //Added for contractor
                }else{
                    rowChilObj["contractorname"] = '';
                }

            rowChilObj['notes'] = taskListForPhase[i].buildertek__Notes__c;
                if(taskListForPhase[i].buildertek__Lag__c != undefined && taskListForPhase[i].buildertek__Lag__c != null && taskListForPhase[i].buildertek__Lag__c != 0){
                    var startDate = new Date(taskListForPhase[i].buildertek__Start__c);
                    rowChilObj["startDate"] = new Date(startDate.getFullYear(),startDate.getMonth(),startDate.getDate(),0,0,0)
                    rowChilObj["constraintDate"] = new Date(startDate.getFullYear(),startDate.getMonth(),startDate.getDate(),0,0,0)
                    // rowChilObj["constraintDate"] = projstartdate
                    rowChilObj["constraintType"] = 'startnoearlierthan'
                }
            rowChilObj["duration"] = taskListForPhase[i].buildertek__Duration__c

                if(taskListForPhase[i].buildertek__Milestone__c){
                rowChilObj["duration"] = 0
                rowChilObj["durationMile"] = taskListForPhase[i].buildertek__Duration__c;
                rowChilObj["cls"] = 'milestoneCompleteColor'
                rowChilObj['orgmilestone'] = taskListForPhase[i].buildertek__Milestone__c;
                rowChilObj['eventColor'] = '';
            }
            rowChilObj["expanded"] = true
            rowChilObj["order"] = taskListForPhase[i].buildertek__Order__c
            rowChilObj["markAsDone"] = taskListForPhase[i].buildertek__Completed__c;
            var dependencyRow = {};
                if(taskListForPhase[i].buildertek__Dependency__c){
                    dependencyRow["id" ]  = taskListForPhase[i].Id+'_'+taskListForPhase[i].buildertek__Dependency__c
                dependencyRow["fromTask"] = taskListForPhase[i].buildertek__Dependency__c
                    dependencyRow["toTask"]  = taskListForPhase[i].Id
                    dependencyRow["lag"]  = taskListForPhase[i].buildertek__Lag__c
                taskDependencyData.push(dependencyRow)
            }

            if(!taskListForPhase[i].buildertek__Milestone__c && taskListForPhase[i].buildertek__Contractor_Resource_1__c){
                var assignmentRow = {}
                assignmentRow['id'] = taskListForPhase[i].Id+'_'+taskListForPhase[i].buildertek__Contractor_Resource_1__c+'__index'+i+'ContractorResource_Name'+taskListForPhase[i].buildertek__Contractor_Resource_1__r.Name;
                assignmentRow['event'] = taskListForPhase[i].Id
                assignmentRow['resource'] = taskListForPhase[i].buildertek__Contractor_Resource_1__c;
                assignmentRowData.push(assignmentRow)
            }
            if(!taskListForPhase[i].buildertek__Milestone__c && taskListForPhase[i].buildertek__Contractor_Resource_2__c){
                var assignmentRow = {}
                assignmentRow['id'] = taskListForPhase[i].Id+'_'+taskListForPhase[i].buildertek__Contractor_Resource_2__c+'__index'+i+'ContractorResource_Name'+taskListForPhase[i].buildertek__Contractor_Resource_2__r.Name;
                assignmentRow['event'] = taskListForPhase[i].Id
                assignmentRow['resource'] = taskListForPhase[i].buildertek__Contractor_Resource_2__c;
                assignmentRowData.push(assignmentRow)
            }
            if(!taskListForPhase[i].buildertek__Milestone__c && taskListForPhase[i].buildertek__Contractor_Resource_3__c){
                var assignmentRow = {}
                assignmentRow['id'] = taskListForPhase[i].Id+'_'+taskListForPhase[i].buildertek__Contractor_Resource_3__c+'__index'+i+'ContractorResource_Name'+taskListForPhase[i].buildertek__Contractor_Resource_3__r.Name;
                assignmentRow['event'] = taskListForPhase[i].Id
                assignmentRow['resource'] = taskListForPhase[i].buildertek__Contractor_Resource_3__c;
                assignmentRowData.push(assignmentRow)
            }
            if(!taskListForPhase[i].buildertek__Milestone__c && taskListForPhase[i].buildertek__Internal_Resource_1__c){
                var assignmentRow = {}
                assignmentRow['id'] = taskListForPhase[i].Id+'_'+taskListForPhase[i].buildertek__Internal_Resource_1__c+'__index'+i+'ContractorResource_Name'+taskListForPhase[i].buildertek__Internal_Resource_1__r.Name;
                assignmentRow['event'] = taskListForPhase[i].Id
                assignmentRow['resource'] = taskListForPhase[i].buildertek__Internal_Resource_1__c;
                assignmentRowData.push(assignmentRow)
            }
            if(!taskListForPhase[i].buildertek__Milestone__c && taskListForPhase[i].buildertek__Internal_Resource_3__c){
                var assignmentRow = {}
                assignmentRow['id'] = taskListForPhase[i].Id+'_'+taskListForPhase[i].buildertek__Internal_Resource_3__c+'__index'+i+'ContractorResource_Name'+taskListForPhase[i].buildertek__Internal_Resource_3__r.Name;
                assignmentRow['event'] = taskListForPhase[i].Id
                assignmentRow['resource'] = taskListForPhase[i].buildertek__Internal_Resource_3__c;
                assignmentRowData.push(assignmentRow)
            }
            if(!taskListForPhase[i].buildertek__Milestone__c && taskListForPhase[i].buildertek__Internal_Resource_4__c){
                var assignmentRow = {}
                assignmentRow['id'] = taskListForPhase[i].Id+'_'+taskListForPhase[i].buildertek__Internal_Resource_4__c+'__index'+i+'ContractorResource_Name'+taskListForPhase[i].buildertek__Internal_Resource_4__r.Name;
                assignmentRow['event'] = taskListForPhase[i].Id
                assignmentRow['resource'] = taskListForPhase[i].buildertek__Internal_Resource_4__c;
                assignmentRowData.push(assignmentRow)
            }

            // if(taskListForPhase[i].buildertek__ConstraintType__c == 'None' || taskListForPhase[i].buildertek__ConstraintType__c == '--None--' || taskListForPhase[i].buildertek__ConstraintType__c == null || taskListForPhase[i].buildertek__ConstraintType__c == undefined){
                rowChilObj["constraintDate"] =  scheduleData.buildertek__Start__c;
                // rowChilObj["constraintDate"] =  projstartdate;
                rowChilObj["constraintType"] =  "startnoearlierthan";
            // } else{
            //     rowChilObj["constraintDate"] =  taskListForPhase[i].buildertek__ConstraintDate__c;
            //     rowChilObj["constraintType"] =  taskListForPhase[i].buildertek__ConstraintType__c;
            //     }

                if(rowChilObj["customtype"] == "Milestone"){
                rowChilObj["constraintDate"] =  taskListForPhase[i].buildertek__End_date__c;
                rowChilObj["constraintType"] =  "muststarton";

            }


            taskPhaseRow["children"].push(rowChilObj);

            var found = false;
            if(firstRowDup['children'].length){
                for(var k=0;k<firstRowDup['children'].length;k++){
                    if(firstRowDup['children'][k].id == taskPhaseRow['id']){
                        firstRowDup['children'][k] = taskPhaseRow
                        found = true
                    }
                }
            }else{
                firstRowDup['children'].push(taskPhaseRow);
                found = true
            }
            if(!found){
                firstRowDup['children'].push(taskPhaseRow);
            }
        }else if(taskListForPhase[i].buildertek__Phase__c && !taskPhaseRow){

            taskPhaseRow = {};
            phIndex = phIndex+1;
            taskPhaseRow["type"] = 'Phase'
            taskPhaseRow["id"] = taskListForPhase[i].buildertek__Schedule__c+"_"+taskListForPhase[i].buildertek__Phase__c
            taskPhaseRow["name"] = taskListForPhase[i].buildertek__Phase__c
            taskPhaseRow["startDate"] = ""
            taskPhaseRow["constraintDate"] = ""
            taskPhaseRow["expanded"] = true
            taskPhaseRow["endDate"] = ""
            taskPhaseRow["children"] = []
            // taskPhaseRow["constraintType"] = 'startnoearlierthan'
            var rowChilObj = {};
            rowChilObj["type"] = 'Task';
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

            //*comparing task finish date with today date and setting color accordingly
            let taskFinishDate = new Date(taskListForPhase[i].buildertek__Finish__c);
            taskFinishDate.setHours(0, 0, 0, 0);
            let todayDate = new Date();
            todayDate.setHours(0, 0, 0, 0);

            if ((taskFinishDate < todayDate) && taskListForPhase[i].buildertek__Completion__c != 100) {
                rowChilObj['eventColor'] = 'red';
            } else {
                rowChilObj['eventColor'] = taskListForPhase[i].buildertek__task_color__c;
            }
                //     if(taskListForPhase[i].buildertek__Dependency__c){
                //     // rowChilObj["constraintType"] = ''
                //     }else{
                //     // rowChilObj["constraintType"] = 'startnoearlierthan'
            // }
                if(scheduleItemIdsList.indexOf(taskListForPhase[i].Id) < 0){
                scheduleItemIdsList.push(taskListForPhase[i].Id)
            }
            rowChilObj["id"] = taskListForPhase[i].Id
            rowChilObj["name"] = taskListForPhase[i].Name
            rowChilObj["percentDone"] = taskListForPhase[i].buildertek__Completion__c
            rowChilObj["startDate"] = taskListForPhase[i].buildertek__Start__c
            rowChilObj["constraintDate"] = taskListForPhase[i].buildertek__Start__c
            // rowChilObj["constraintDate"] = projstartdate
            rowChilObj["constraintType"] = 'startnoearlierthan'

            rowChilObj['predecessor'] = taskListForPhase[i].buildertek__Dependency__c;

            if (taskListForPhase[i].hasOwnProperty('buildertek__Dependency__c') == true) {
                rowChilObj['predecessorName'] = taskListForPhase[i].buildertek__Dependency__r.Name;
            } else {
                rowChilObj['predecessorName'] = '';
            }

            rowChilObj['contractorId'] = taskListForPhase[i].buildertek__Contractor__c;

                if(taskListForPhase[i].buildertek__Contractor__c){
                    rowChilObj["contractorname"] = taskListForPhase[i].buildertek__Contractor__r.Name;  //Added for contractor
                }else{
                rowChilObj["contractorname"] = '';
            }

            rowChilObj['notes'] = taskListForPhase[i].buildertek__Notes__c;

                if(taskListForPhase[i].buildertek__Lag__c != undefined && taskListForPhase[i].buildertek__Lag__c != null && taskListForPhase[i].buildertek__Lag__c != 0){
                var startDate = new Date(taskListForPhase[i].buildertek__Start__c);
                startDate.setDate(startDate.getDate());
                rowChilObj["startDate"] = new Date(startDate.getFullYear(),startDate.getMonth(),startDate.getDate(),0,0,0)
                rowChilObj["constraintDate"] = new Date(startDate.getFullYear(),startDate.getMonth(),startDate.getDate(),0,0,0)
                // rowChilObj["constraintDate"] = projstartdate
                rowChilObj["constraintType"] = 'startnoearlierthan'
                }
            rowChilObj["duration"] = taskListForPhase[i].buildertek__Duration__c


                if(taskListForPhase[i].buildertek__Milestone__c){
                rowChilObj["duration"] = 0;
                rowChilObj["cls"] = 'milestoneCompleteColor'
                rowChilObj['orgmilestone'] = taskListForPhase[i].buildertek__Milestone__c;
                rowChilObj['eventColor'] = '';
            }

            rowChilObj["expanded"] = true
            rowChilObj["order"] = taskListForPhase[i].buildertek__Order__c
            rowChilObj["markAsDone"] = taskListForPhase[i].buildertek__Completed__c;

            var dependencyRow = {};
                if(taskListForPhase[i].buildertek__Dependency__c){
                    dependencyRow["id" ]  = taskListForPhase[i].Id+'_'+taskListForPhase[i].buildertek__Dependency__c
                dependencyRow["fromTask"] = taskListForPhase[i].buildertek__Dependency__c
                dependencyRow["toTask"]  = taskListForPhase[i].Id
                dependencyRow["lag"]  = taskListForPhase[i].buildertek__Lag__c
                taskDependencyData.push(dependencyRow)
            }

            if(!taskListForPhase[i].buildertek__Milestone__c && taskListForPhase[i].buildertek__Contractor_Resource_1__c){
                var assignmentRow = {}
                assignmentRow['id'] = taskListForPhase[i].Id+'_'+taskListForPhase[i].buildertek__Contractor_Resource_1__c+'__index'+i+'ContractorResource_Name'+taskListForPhase[i].buildertek__Contractor_Resource_1__r.Name;
                assignmentRow['event'] = taskListForPhase[i].Id
                assignmentRow['resource'] = taskListForPhase[i].buildertek__Contractor_Resource_1__c;
                assignmentRowData.push(assignmentRow)
            }
            if(!taskListForPhase[i].buildertek__Milestone__c && taskListForPhase[i].buildertek__Contractor_Resource_2__c){
                var assignmentRow = {}
                assignmentRow['id'] = taskListForPhase[i].Id+'_'+taskListForPhase[i].buildertek__Contractor_Resource_2__c+'__index'+i+'ContractorResource_Name'+taskListForPhase[i].buildertek__Contractor_Resource_2__r.Name;
                assignmentRow['event'] = taskListForPhase[i].Id
                assignmentRow['resource'] = taskListForPhase[i].buildertek__Contractor_Resource_2__c;
                assignmentRowData.push(assignmentRow)
            }
            if(!taskListForPhase[i].buildertek__Milestone__c && taskListForPhase[i].buildertek__Contractor_Resource_3__c){
                var assignmentRow = {}
                assignmentRow['id'] = taskListForPhase[i].Id+'_'+taskListForPhase[i].buildertek__Contractor_Resource_3__c+'__index'+i+'ContractorResource_Name'+taskListForPhase[i].buildertek__Contractor_Resource_3__r.Name;
                assignmentRow['event'] = taskListForPhase[i].Id
                assignmentRow['resource'] = taskListForPhase[i].buildertek__Contractor_Resource_3__c;
                assignmentRowData.push(assignmentRow)
            }
            if(!taskListForPhase[i].buildertek__Milestone__c && taskListForPhase[i].buildertek__Internal_Resource_1__c){
                var assignmentRow = {}
                assignmentRow['id'] = taskListForPhase[i].Id+'_'+taskListForPhase[i].buildertek__Internal_Resource_1__c+'__index'+i+'ContractorResource_Name'+taskListForPhase[i].buildertek__Internal_Resource_1__r.Name;
                assignmentRow['event'] = taskListForPhase[i].Id
                assignmentRow['resource'] = taskListForPhase[i].buildertek__Internal_Resource_1__c;
                assignmentRowData.push(assignmentRow)
            }
            if(!taskListForPhase[i].buildertek__Milestone__c && taskListForPhase[i].buildertek__Internal_Resource_3__c){
                var assignmentRow = {}
                assignmentRow['id'] = taskListForPhase[i].Id+'_'+taskListForPhase[i].buildertek__Internal_Resource_3__c+'__index'+i+'ContractorResource_Name'+taskListForPhase[i].buildertek__Internal_Resource_3__r.Name;
                assignmentRow['event'] = taskListForPhase[i].Id
                assignmentRow['resource'] = taskListForPhase[i].buildertek__Internal_Resource_3__c;
                assignmentRowData.push(assignmentRow)
            }
            if(!taskListForPhase[i].buildertek__Milestone__c && taskListForPhase[i].buildertek__Internal_Resource_4__c){
                var assignmentRow = {}
                assignmentRow['id'] = taskListForPhase[i].Id+'_'+taskListForPhase[i].buildertek__Internal_Resource_4__c+'__index'+i+'ContractorResource_Name'+taskListForPhase[i].buildertek__Internal_Resource_4__r.Name;
                assignmentRow['event'] = taskListForPhase[i].Id
                assignmentRow['resource'] = taskListForPhase[i].buildertek__Internal_Resource_4__c;
                assignmentRowData.push(assignmentRow)
            }
            // if(taskListForPhase[i].buildertek__ConstraintType__c == 'None' || taskListForPhase[i].buildertek__ConstraintType__c == '--None--' || taskListForPhase[i].buildertek__ConstraintType__c == null || taskListForPhase[i].buildertek__ConstraintType__c == undefined){
                rowChilObj["constraintDate"] =  scheduleData.buildertek__Start__c;
                // rowChilObj["constraintDate"] =  projstartdate;
                rowChilObj["constraintType"] =  "startnoearlierthan";
            // } else{
            //     rowChilObj["constraintDate"] =  taskListForPhase[i].buildertek__ConstraintDate__c;
            //     rowChilObj["constraintType"] =  taskListForPhase[i].buildertek__ConstraintType__c;
            //     }


            taskPhaseRow["children"].push(rowChilObj);
            firstRowDup['children'].push(taskPhaseRow);
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
            rowChilObj['phase'] = taskListForPhase[i].buildertek__Phase__c;

            //*comparing task finish date with today date and setting color accordingly
            let taskFinishDate = new Date(taskListForPhase[i].buildertek__Finish__c);
            taskFinishDate.setHours(0, 0, 0, 0);
            let todayDate = new Date();
            todayDate.setHours(0, 0, 0, 0);

            if ((taskFinishDate < todayDate) && taskListForPhase[i].buildertek__Completion__c != 100) {
                rowChilObj['eventColor'] = 'red';
            } else {
                rowChilObj['eventColor'] = taskListForPhase[i].buildertek__task_color__c;
            }

            if(taskListForPhase[i].buildertek__Dependency__c){
                // rowChilObj["constraintType"] = ''
            }else{
                // rowChilObj["constraintType"] = 'startnoearlierthan'
            }
            if(scheduleItemIdsList.indexOf(taskListForPhase[i].Id) < 0){
                scheduleItemIdsList.push(taskListForPhase[i].Id)
            }
            rowChilObj["id"] = taskListForPhase[i].Id
            rowChilObj["name"] = taskListForPhase[i].Name
            rowChilObj["percentDone"] = taskListForPhase[i].buildertek__Completion__c
            rowChilObj["startDate"] = taskListForPhase[i].buildertek__Start__c
            rowChilObj["constraintDate"] = taskListForPhase[i].buildertek__Start__c
            // rowChilObj["constraintDate"] = projstartdate
            rowChilObj["constraintType"] = 'startnoearlierthan'


            rowChilObj['predecessor'] = taskListForPhase[i].buildertek__Dependency__c;

            if (taskListForPhase[i].hasOwnProperty('buildertek__Dependency__c') == true) {
                rowChilObj['predecessorName'] = taskListForPhase[i].buildertek__Dependency__r.Name;
            } else {
                rowChilObj['predecessorName'] = '';
            }

            rowChilObj['contractorId'] = taskListForPhase[i].buildertek__Contractor__c;

            if(taskListForPhase[i].buildertek__Contractor__c){
                rowChilObj["contractorname"] = taskListForPhase[i].buildertek__Contractor__r.Name;  //Added for contractor
            }else{
                rowChilObj["contractorname"] = '';
            }

            rowChilObj['notes'] = taskListForPhase[i].buildertek__Notes__c;

            if(taskListForPhase[i].buildertek__Lag__c != undefined && taskListForPhase[i].buildertek__Lag__c != null && taskListForPhase[i].buildertek__Lag__c != 0){
            var startDate = new Date(taskListForPhase[i].buildertek__Start__c);

            startDate.setDate(startDate.getDate());

            rowChilObj["startDate"] = new Date(startDate.getFullYear(),startDate.getMonth(),startDate.getDate(),0,0,0)
            rowChilObj["constraintDate"] = new Date(startDate.getFullYear(),startDate.getMonth(),startDate.getDate(),0,0,0)
            // rowChilObj["constraintDate"] = projstartdate
            rowChilObj["constraintType"] = 'startnoearlierthan'
            }
            rowChilObj["duration"] = taskListForPhase[i].buildertek__Duration__c


            rowChilObj["expanded"] = true
            rowChilObj["order"] = taskListForPhase[i].buildertek__Order__c
            rowChilObj["markAsDone"] = taskListForPhase[i].buildertek__Completed__c;
            // if(taskListForPhase[i].buildertek__ConstraintType__c == 'None' || taskListForPhase[i].buildertek__ConstraintType__c == '--None--' || taskListForPhase[i].buildertek__ConstraintType__c == null || taskListForPhase[i].buildertek__ConstraintType__c == undefined){
                rowChilObj["constraintDate"] =  scheduleData.buildertek__Start__c;
                // rowChilObj["constraintDate"] =  projstartdate;
                rowChilObj["constraintType"] =  "startnoearlierthan";
            // } else{
            //     rowChilObj["constraintDate"] =  taskListForPhase[i].buildertek__ConstraintDate__c;
            //     rowChilObj["constraintType"] =  taskListForPhase[i].buildertek__ConstraintType__c;
            // }

            if(taskListForPhase[i].buildertek__Milestone__c){
                rowChilObj["duration"] = 0
                rowChilObj["cls"] = 'milestoneCompleteColor'
                rowChilObj['orgmilestone'] = taskListForPhase[i].buildertek__Milestone__c;
                rowChilObj["constraintDate"] =  taskListForPhase[i].buildertek__End_date__c;
                rowChilObj["constraintType"] =  'muststarton';
                rowChilObj['eventColor'] = '';
            }

                        firstRowDup['children'].push(rowChilObj);
            var dependencyRow = {};
            if(taskListForPhase[i].buildertek__Dependency__c){
                dependencyRow["id" ]  = taskListForPhase[i].Id+'_'+taskListForPhase[i].buildertek__Dependency__c
                dependencyRow["fromTask"] = taskListForPhase[i].buildertek__Dependency__c
                dependencyRow["toTask"]  = taskListForPhase[i].Id
                dependencyRow["lag"]  = taskListForPhase[i].buildertek__Lag__c
                taskDependencyData.push(dependencyRow)
            }

            if(!taskListForPhase[i].buildertek__Milestone__c && taskListForPhase[i].buildertek__Contractor_Resource_1__c){
                var assignmentRow = {}
                assignmentRow['id'] = taskListForPhase[i].Id+'_'+taskListForPhase[i].buildertek__Contractor_Resource_1__c+'__index'+i+'ContractorResource_Name'+taskListForPhase[i].buildertek__Contractor_Resource_1__r.Name;
                assignmentRow['event'] = taskListForPhase[i].Id
                assignmentRow['resource'] = taskListForPhase[i].buildertek__Contractor_Resource_1__c;
                assignmentRowData.push(assignmentRow)
            }
            if(!taskListForPhase[i].buildertek__Milestone__c && taskListForPhase[i].buildertek__Contractor_Resource_2__c){
                var assignmentRow = {}
                assignmentRow['id'] = taskListForPhase[i].Id+'_'+taskListForPhase[i].buildertek__Contractor_Resource_2__c+'__index'+i+'ContractorResource_Name'+taskListForPhase[i].buildertek__Contractor_Resource_2__r.Name;
                assignmentRow['event'] = taskListForPhase[i].Id
                assignmentRow['resource'] = taskListForPhase[i].buildertek__Contractor_Resource_2__c;
                assignmentRowData.push(assignmentRow)
            }
            if(!taskListForPhase[i].buildertek__Milestone__c && taskListForPhase[i].buildertek__Contractor_Resource_3__c){
                var assignmentRow = {}
                assignmentRow['id'] = taskListForPhase[i].Id+'_'+taskListForPhase[i].buildertek__Contractor_Resource_3__c+'__index'+i+'ContractorResource_Name'+taskListForPhase[i].buildertek__Contractor_Resource_3__r.Name;
                assignmentRow['event'] = taskListForPhase[i].Id
                assignmentRow['resource'] = taskListForPhase[i].buildertek__Contractor_Resource_3__c;
                assignmentRowData.push(assignmentRow)
            }
            if(!taskListForPhase[i].buildertek__Milestone__c && taskListForPhase[i].buildertek__Internal_Resource_1__c){
                var assignmentRow = {}
                assignmentRow['id'] = taskListForPhase[i].Id+'_'+taskListForPhase[i].buildertek__Internal_Resource_1__c+'__index'+i+'ContractorResource_Name'+taskListForPhase[i].buildertek__Internal_Resource_1__r.Name;
                assignmentRow['event'] = taskListForPhase[i].Id
                assignmentRow['resource'] = taskListForPhase[i].buildertek__Internal_Resource_1__c;
                assignmentRowData.push(assignmentRow)
            }
            if(!taskListForPhase[i].buildertek__Milestone__c && taskListForPhase[i].buildertek__Internal_Resource_3__c){
                var assignmentRow = {}
                assignmentRow['id'] = taskListForPhase[i].Id+'_'+taskListForPhase[i].buildertek__Internal_Resource_3__c+'__index'+i+'ContractorResource_Name'+taskListForPhase[i].buildertek__Internal_Resource_3__r.Name;
                assignmentRow['event'] = taskListForPhase[i].Id
                assignmentRow['resource'] = taskListForPhase[i].buildertek__Internal_Resource_3__c;
                assignmentRowData.push(assignmentRow)
            }
            if(!taskListForPhase[i].buildertek__Milestone__c && taskListForPhase[i].buildertek__Internal_Resource_4__c){
                var assignmentRow = {}
                assignmentRow['id'] = taskListForPhase[i].Id+'_'+taskListForPhase[i].buildertek__Internal_Resource_4__c+'__index'+i+'ContractorResource_Name'+taskListForPhase[i].buildertek__Internal_Resource_4__r.Name;
                assignmentRow['event'] = taskListForPhase[i].Id
                assignmentRow['resource'] = taskListForPhase[i].buildertek__Internal_Resource_4__c;
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

function convertJSONtoApexData(data, taskData, dependenciesData, resourceData) {
    console.log('Data-->', data)
    console.log('taskData-->', taskData)
    console.log('dependenciesData-->', dependenciesData)
    console.log('resourceData-->', resourceData)
    let dataToPassIntoApex = {};
    let scheduleObj = {};
    var rowData = [];
    const phasedatamap = new Map();
    const contractordatamap = new Map();
    const markAsDonemap = new Map();

    if (data) {
        data.forEach(element => {
            console.log('element:- ',element._data);
            if(element._data.hasOwnProperty('NewPhase')){
                phasedatamap.set(element.id, element._data.NewPhase);
            }
            if(element._data.hasOwnProperty('contractorId')){
                contractordatamap.set(element.id, element._data.contractorId);
            }
            if(element._data.hasOwnProperty('markAsDone')){
                markAsDonemap.set(element.id, element._data.markAsDone);
            }
        });
        if (data.length > 0) {
            function getChildren(data) {
                if (data.children) {
                    for (var i = 0; i < data.children.length; i++) {
                        getChildren(data.children[i])
                    }
                } else {
                    rowData.push(data)
                }
            }
            for (let j = 0; j < taskData.length; j++) {
                getChildren(taskData[j])
            }
            var updateDataList = [];
            var updateDataCloneList = [];
            for (var i = 0; i < rowData.length; i++) {
                var updateData = {}
                var updateDataClone = {}
                var endDate
                if (rowData[i]['name'] != 'Milestone Complete') {
                    endDate = new Date(rowData[i].endDate);
                    endDate.setDate(endDate.getDate())
                } else {
                    endDate = new Date(rowData[i].endDate);
                                    }

                rowData[i].endDate = endDate;
                // if (rowData[i]['id'].indexOf('_generate') == -1)
                    updateData['Id'] = rowData[i]['id']
                // }
                updateData['buildertek__Schedule__c'] = taskData[0].id;
                updateData['Name'] = rowData[i]['name'];

                updateData['buildertek__Order__c'] = i + 1;
                //var startdate = new Date(rowData[i]['startDate'])
                var enddate = new Date(rowData[i]['endDate']).toLocaleDateString().split('/')
                //var enddate = new Date(rowData[i]['endDate']).toJSON();
                var enddate = new Date(rowData[i]['endDate'])
                updateData['buildertek__Start__c'] = rowData[i]['startDate'].split('T')[0]
                //updateData['buildertek__Finish__c'] = enddate[2] + '-'+ enddate[1] + '-'+enddate[0]
                //updateData['buildertek__Finish__c'] = enddate.split('T')[0]
                updateData['buildertek__Finish__c'] = enddate.getFullYear() + '-' + Number(enddate.getMonth() + 1) + '-' + enddate.getDate();
                updateData['buildertek__Duration__c'] = rowData[i]['duration']
                updateData['buildertek__Completion__c'] = rowData[i]['percentDone']
                updateData['buildertek__task_color__c'] = rowData[i]['eventColor']
                // if (rowData[i]['constraintDate'] != null && rowData[i]['constraintType'] != null) {
                //     updateData['buildertek__ConstraintDate__c'] = rowData[i]['constraintDate'].split('T')[0];
                //     updateData['buildertek__ConstraintType__c'] = rowData[i]['constraintType']
                // } else{
                    updateData['buildertek__ConstraintDate__c'] = null
                    updateData['buildertek__ConstraintType__c'] = 'None'
                // }
                if (rowData[i]['customtype']) {
                    updateData['buildertek__Type__c'] = rowData[i]['customtype']
                }else{
                    if (rowData[i]['duration'] == 0) {
                        updateData['buildertek__Type__c'] = 'Milestone'
                    }else{
                        updateData['buildertek__Type__c'] = 'Task'
                    }
                }

                if (rowData[i]['cls']) {
                    var check = rowData[i]['cls']
                    if (check.includes('milestoneCompleteColor')) {
                        updateData['buildertek__Milestone__c'] = true;
                    }
                }
                if (rowData[i]['iconCls'] == 'b-fa b-fa-arrow-left indentTrue') {
                    updateData['buildertek__Indent_Task__c'] = true
                } else {
                    updateData['buildertek__Indent_Task__c'] = false;
                }
                //updateData['buildertek__Indent_Task__c'] = rowData[i]['iconCls'].includes('indentTrue')
                if (rowData[i]['parentId']) {
                    if (rowData[i]['parentId'].split('_')[1]) {
                        updateData['buildertek__Phase__c'] = rowData[i]['parentId'].split('_')[1]
                    }
                }


                var filledDependency = false
                for (var j = 0; j < dependenciesData.length; j++) {
                    if (dependenciesData[j]['to'] == rowData[i]['id']) {
                        if (dependenciesData[j]['id'].indexOf('_generated') >= 0) {
                            updateData['buildertek__Dependency__c'] = dependenciesData[j]['from']
                        } else {
                            updateData['buildertek__Dependency__c'] = dependenciesData[j]['from']
                        }
                        filledDependency = true;
                    }
                    if (!filledDependency) {
                        updateData['buildertek__Dependency__c'] = null;
                    }
                }
                console.log('hasownproperty updateData -->', updateData.Id );
                if(phasedatamap.has(updateData.Id)){
                    updateData['buildertek__Phase__c'] = phasedatamap.get(updateData.Id);
                }

                if(contractordatamap.has(updateData.Id)){
                    updateData['buildertek__Contractor__c'] = contractordatamap.get(updateData.Id);
                }

                if(markAsDonemap.has(updateData.Id)){
                    updateData['buildertek__Completed__c'] = markAsDonemap.get(updateData.Id);
                }

                updateDataClone = Object.assign({}, updateData);

                if (rowData[i]['id'].indexOf('_generate') == -1) {
                    updateDataCloneList.push(updateDataClone)
                }
                updateDataList.push(updateData)
            }

            if (data[0]._data['type'] === "Project") {
                scheduleObj['id'] = data[0]._data.id;
                scheduleObj['buildertek__End_date__c'] = covertIntoDate(data[0]._data.endDate);
            }
            console.log('updateDataList ==> ', { updateDataList });
            dataToPassIntoApex['scheduleData'] = scheduleObj;
            dataToPassIntoApex['taskData'] = updateDataList;

            return dataToPassIntoApex;
        }
    }
}

function recordsTobeDeleted(oldListOfTaskRecords, newListOfTaskRecords) {
    const setOfNewRecordId = new Set();
    const listOfRecordIdToBeDeleted = [];
    newListOfTaskRecords.forEach(newTaskRecord => {
        var taskId = newTaskRecord.Id
        if(!(taskId.includes('_generatedt_'))){
            setOfNewRecordId.add(newTaskRecord.Id);
        }
    });

    oldListOfTaskRecords.forEach(oldTaskRecord => {
        if (!setOfNewRecordId.has(oldTaskRecord.Id)) {
            listOfRecordIdToBeDeleted.push(oldTaskRecord.Id);
        }
    });
    console.log('listOfRecordIdToBeDeleted:- ',listOfRecordIdToBeDeleted);
    return listOfRecordIdToBeDeleted;
}

function covertIntoDate(date) {
    var d = new Date(date),
    month = '' + (d.getMonth() + 1),
    day = '' + d.getDate(),
    year = d.getFullYear();

    if (month.length < 2)
        month = '0' + month;
    if (day.length < 2)
        day = '0' + day;

    return [year, month, day].join('-');
}

function makeComboBoxDataForContractor(listOfContractors) {
    let listOfContractorToReturn = [];

    listOfContractors.forEach(ctrObj => {
        let contractorObj = {};
        if (ctrObj.Id) {
            contractorObj['value'] = ctrObj.Id;
        }
        if(ctrObj.Name){
            contractorObj['text'] = ctrObj.Name;
        }
        listOfContractorToReturn.push(contractorObj);
    });
    return listOfContractorToReturn;
}

//* auther : Nishit Suthar
//* Date : 8th Sep 2023
//* this method is use for creating data for resources to store in backend
function setResourceDataForApexData(assignmentsData) {
    if (assignmentsData.length > 0) {
        const resourceMap = {};
        assignmentsData.forEach(assignmentObj => {
            let recordId = assignmentObj.eventId;
            let resourcePrefixToIdentify = assignmentObj.resourceId ? assignmentObj.resourceId.slice(0,3) : undefined;

            if (resourceMap[recordId]) {
                if (resourcePrefixToIdentify == '003'){
                    resourceMap[recordId].conList.push(assignmentObj.resourceId);
                } else if (resourcePrefixToIdentify == '005') {
                    resourceMap[recordId].usrList.push(assignmentObj.resourceId);
                }
            } else {
                if (resourcePrefixToIdentify == '003'){
                    resourceMap[recordId] = {conList: [assignmentObj.resourceId], usrList: []};
                } else if (resourcePrefixToIdentify == '005') {
                    resourceMap[recordId] = {conList: [], usrList: [assignmentObj.resourceId]};
                }
            }
        });

        let listOfResourceToReturn = createResourceDataForApex(resourceMap);
        console.log('listOfResourceToReturn :- ',listOfResourceToReturn);
        return listOfResourceToReturn;
    }
}

//* auther : Nishit Suthar
//* Date : 11th Sep 2023
//* this method is use for creating data for resources to store in backend
function createResourceDataForApex(resourceObjectWithList) {

    let data = resourceObjectWithList;
    let listOfapexDataToReturn = [];

    for (const id in data) {
        if (data[id].conList.length > 3 || data[id].usrList.length > 3) {
            return 'error'
        }
        let apexDataObject = {};
        apexDataObject['Id'] = id;
        const [a = null, b = null, c = null] = data[id].conList;
        apexDataObject['buildertek__Contractor_Resource_1__c'] = a;
        apexDataObject['buildertek__Contractor_Resource_2__c'] = b;
        apexDataObject['buildertek__Contractor_Resource_3__c'] = c;
        const [e = null, f = null, g = null] = data[id].usrList;
        apexDataObject['buildertek__Internal_Resource_1__c'] = e;
        apexDataObject['buildertek__Internal_Resource_4__c'] = f;
        apexDataObject['buildertek__Internal_Resource_3__c'] = g;
        listOfapexDataToReturn.push(apexDataObject);
    }

    return listOfapexDataToReturn;
}
//* auther : Nishit Suthar/krunal Lungaria
//* Date : 29th Aug 2023
//* this method is used to create data for resource combobox
function makeComboBoxDataForResourceData(listOfContractors, listOfUsers){
    let listOfResourceToReturn = [];

    listOfContractors.forEach(ctrObj => {
        if (ctrObj.Contacts) {
            ctrObj.Contacts.forEach(resObj => {
                let resourceObj = {};
                resourceObj['id'] = resObj.Id;
                resourceObj['name'] = resObj.Name;
                resourceObj['contractorId'] = resObj.AccountId;
                resourceObj['type'] = 'External Resources';
                listOfResourceToReturn.push(resourceObj);
            });
        }
    });

    listOfUsers.forEach(usrObj => {
        let resourceObj = {};
        resourceObj['id'] = usrObj.Id;
        resourceObj['name'] = usrObj.Name;
        resourceObj['type'] = 'Internal Resources';
        listOfResourceToReturn.push(resourceObj);
    });


    return listOfResourceToReturn;
}

//* auther : Nishit Suthar
//* Date : 24th Aug 2023
//* this method is used to calculate business days between two dates for project schedule
function calcBusinessDays(dDate1, dDate2) { // input given as Date objects
    var iWeeks, iDateDiff, iAdjust = 0;
    if (dDate2 < dDate1) return -1; // error code if dates transposed
    var iWeekday1 = dDate1.getDay(); // day of week
    var iWeekday2 = dDate2.getDay();
    iWeekday1 = (iWeekday1 == 0) ? 7 : iWeekday1; // change Sunday from 0 to 7
    iWeekday2 = (iWeekday2 == 0) ? 7 : iWeekday2;
    if ((iWeekday1 > 5) && (iWeekday2 > 5)) iAdjust = 1; // adjustment if both days on weekend
    iWeekday1 = (iWeekday1 > 5) ? 5 : iWeekday1; // only count weekdays
    iWeekday2 = (iWeekday2 > 5) ? 5 : iWeekday2;

    // calculate differnece in weeks (1000mS * 60sec * 60min * 24hrs * 7 days = 604800000)
    iWeeks = Math.floor((dDate2.getTime() - dDate1.getTime()) / 604800000)

    if (iWeekday1 <= iWeekday2) { //Change '<' to '<=' to include the same date
      iDateDiff = (iWeeks * 5) + (iWeekday2 - iWeekday1)
    } else {
      iDateDiff = ((iWeeks + 1) * 5) - (iWeekday1 - iWeekday2)
    }

    iDateDiff -= iAdjust // take into account both days on weekend

    return (iDateDiff + 1); // add 1 because dates are inclusive
}

//* auther : Nishit Suthar
//* Date : 11th Sep 2023
//* this method is used to merge 2 arrays of object
function mergeArrays(taskData, assignedResources) {
    const mergedList = [];

    for (const item1 of taskData) {
        let matchingItem;
        if (assignedResources) {
            for (const element of assignedResources) {
                if (element.Id === item1.Id) {
                    matchingItem = element;
                    break;
                }
            }
        }

        if (matchingItem) {
            const mergedObject = Object.assign({}, item1, matchingItem);
            mergedList.push(mergedObject);
        } else {
            item1['buildertek__Contractor_Resource_1__c'] = null;
            item1['buildertek__Contractor_Resource_2__c'] = null;
            item1['buildertek__Contractor_Resource_3__c'] = null;
            item1['buildertek__Internal_Resource_1__c'] = null;
            item1['buildertek__Internal_Resource_3__c'] = null;
            item1['buildertek__Internal_Resource_4__c'] = null;
            mergedList.push(item1);
        }
    }

    return mergedList;
}

export{ formatApexDatatoJSData, convertJSONtoApexData, recordsTobeDeleted, makeComboBoxDataForContractor, calcBusinessDays, makeComboBoxDataForResourceData, setResourceDataForApexData, mergeArrays };