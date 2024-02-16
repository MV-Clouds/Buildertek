function formatApexDatatoJSData(scheduleData, scheduleItemsData, scheduleItemsDataList) {
    var taskDependencyData = [];
    var resourceRowData = [];
    let assignmentRowData = [];

    var rows = [];
    var formattedData = {};
    var firstRowDup = {};

    var taskListForPhase = scheduleItemsDataList;

    firstRowDup["id"] = scheduleData.Id;
    firstRowDup["name"] = scheduleData.buildertek__Description__c;
    firstRowDup["startDate"] = scheduleData.buildertek__Initial_Start_Date__c;
    firstRowDup["duration"] = 1;
    firstRowDup["expanded"] = true
    firstRowDup["type"] = 'Project'
    firstRowDup['customtype'] = 'Project'
    firstRowDup["endDate"] = ""
    firstRowDup["children"] = []

    //*BUIL-3699 new logic start

    firstRowDup['children'] = grpTaskOnPhase(taskListForPhase).children;

    for (var i = 0; i < taskListForPhase.length; i++) {
        console.log("taskListForPhase:- ", taskListForPhase[i]);
        var dependencyRow = {};
        if (taskListForPhase[i].buildertek__Dependency__c) {
            dependencyRow["id"] = taskListForPhase[i].Id + '_' + taskListForPhase[i].buildertek__Dependency__c
            dependencyRow["fromTask"] = taskListForPhase[i].buildertek__Dependency__c
            dependencyRow["toTask"] = taskListForPhase[i].Id
            dependencyRow["lag"] = taskListForPhase[i].buildertek__Lag__c
            taskDependencyData.push(dependencyRow)
        }

        assignmentRowData.push.apply(assignmentRowData, createAssignmentData(taskListForPhase[i], i)); //adds all the assignment data to the main list.
    }

    //* BUIL-3699 new logic end

    rows.push(firstRowDup);
    formattedData['rows'] = rows;
    formattedData['resourceRowData'] = resourceRowData;
    formattedData['assignmentRowData'] = assignmentRowData
    formattedData['taskDependencyData'] = taskDependencyData;
    console.log('rows ==> ', rows);
    console.log('resourceRowData ==> ', resourceRowData);
    console.log('assignmentRowData ==> ', assignmentRowData);
    console.log('taskDependencyData ==> ', taskDependencyData);
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
    let lagDataMap = dependencyLagData(dependenciesData);
    console.log('lagDataMap:- ', lagDataMap);
    if (data) {
        data.forEach(element => {
            console.log('element:- ', element._data);
            if (element._data.hasOwnProperty('NewPhase')) {
                phasedatamap.set(element.id, element._data.NewPhase);
            }
            if (element._data.hasOwnProperty('contractorId')) {
                contractordatamap.set(element.id, element._data.contractorId);
            }
            if (element._data.hasOwnProperty('markAsDone')) {
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
                var enddate = new Date(rowData[i]['endDate']).toLocaleDateString().split('/')
                var enddate = new Date(rowData[i]['endDate'])
                updateData['buildertek__Start__c'] = rowData[i]['startDate'].split('T')[0]
                updateData['buildertek__Finish__c'] = enddate.getFullYear() + '-' + Number(enddate.getMonth() + 1) + '-' + enddate.getDate();
                updateData['buildertek__Duration__c'] = rowData[i]['duration']
                updateData['buildertek__Completion__c'] = rowData[i]['percentDone']
                updateData['buildertek__task_color__c'] = rowData[i]['eventColor']
                updateData['buildertek__ConstraintDate__c'] = null
                updateData['buildertek__ConstraintType__c'] = 'None'
                updateData['buildertek__Lag__c'] = lagDataMap.get(rowData[i]['id']) || 0

                if (rowData[i]['customtype']) {
                    updateData['buildertek__Type__c'] = rowData[i]['customtype']
                } else {
                    if (rowData[i]['duration'] == 0) {
                        updateData['buildertek__Type__c'] = 'Milestone'
                        rowData[i]['eventColor'] = ''
                    } else {
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
                console.log('hasownproperty updateData -->', updateData.Id);
                if (phasedatamap.has(updateData.Id)) {
                    updateData['buildertek__Phase__c'] = phasedatamap.get(updateData.Id);
                }

                if (contractordatamap.has(updateData.Id)) {
                    updateData['buildertek__Contractor__c'] = contractordatamap.get(updateData.Id);
                }

                if (markAsDonemap.has(updateData.Id)) {
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

function dependencyLagData(dependenciesData) {
    const lagdatamap = new Map();
    dependenciesData.forEach(({ to, lag }) => {
        if (lag && lag > 0) {
            lagdatamap.set(to, lag);
        }
    });
    return lagdatamap;
}

function recordsTobeDeleted(oldListOfTaskRecords, newListOfTaskRecords) {
    const setOfNewRecordId = new Set();
    const listOfRecordIdToBeDeleted = [];
    newListOfTaskRecords.forEach(newTaskRecord => {
        var taskId = newTaskRecord.Id
        if (!(taskId.includes('_generatedt_'))) {
            setOfNewRecordId.add(newTaskRecord.Id);
        }
    });

    oldListOfTaskRecords.forEach(oldTaskRecord => {
        if (!setOfNewRecordId.has(oldTaskRecord.Id)) {
            listOfRecordIdToBeDeleted.push(oldTaskRecord.Id);
        }
    });
    console.log('listOfRecordIdToBeDeleted:- ', listOfRecordIdToBeDeleted);
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
        if (ctrObj.Name) {
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
            let resourcePrefixToIdentify = assignmentObj.resourceId ? assignmentObj.resourceId.slice(0, 3) : undefined;

            if (resourceMap[recordId]) {
                if (resourcePrefixToIdentify == '003') {
                    resourceMap[recordId].conList.push(assignmentObj.resourceId);
                } else if (resourcePrefixToIdentify == '005') {
                    resourceMap[recordId].usrList.push(assignmentObj.resourceId);
                }
            } else {
                if (resourcePrefixToIdentify == '003') {
                    resourceMap[recordId] = { conList: [assignmentObj.resourceId], usrList: [] };
                } else if (resourcePrefixToIdentify == '005') {
                    resourceMap[recordId] = { conList: [], usrList: [assignmentObj.resourceId] };
                }
            }
        });

        let listOfResourceToReturn = createResourceDataForApex(resourceMap);
        console.log('listOfResourceToReturn :- ', listOfResourceToReturn);
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
function makeComboBoxDataForResourceData(listOfContractors, listOfUsers) {
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

//* ayther : Mitrajsinh Gohil
//* Date : 8th Dec 2023
//* This method is used to create task Assignment Data for each task

function createAssignmentData(taskListForPhase, i) {

    var assignmentRow = {}
    var assignmentRowDataChild = [];
    if (!taskListForPhase.buildertek__Milestone__c && taskListForPhase.buildertek__Contractor_Resource_1__c) {
        assignmentRow['id'] = taskListForPhase.Id + '_' + taskListForPhase.buildertek__Contractor_Resource_1__c + '__index' + i + 'ContractorResource_Name' + taskListForPhase.buildertek__Contractor_Resource_1__r.Name;
        assignmentRow['event'] = taskListForPhase.Id
        assignmentRow['resource'] = taskListForPhase.buildertek__Contractor_Resource_1__c;
        assignmentRowDataChild.push(assignmentRow)
    }
    if (!taskListForPhase.buildertek__Milestone__c && taskListForPhase.buildertek__Contractor_Resource_2__c) {
        assignmentRow['id'] = taskListForPhase.Id + '_' + taskListForPhase.buildertek__Contractor_Resource_2__c + '__index' + i + 'ContractorResource_Name' + taskListForPhase.buildertek__Contractor_Resource_2__r.Name;
        assignmentRow['event'] = taskListForPhase.Id
        assignmentRow['resource'] = taskListForPhase.buildertek__Contractor_Resource_2__c;
        assignmentRowDataChild.push(assignmentRow)
    }

    if (!taskListForPhase.buildertek__Milestone__c && taskListForPhase.buildertek__Contractor_Resource_3__c) {
        assignmentRow['id'] = taskListForPhase.Id + '_' + taskListForPhase.buildertek__Contractor_Resource_3__c + '__index' + i + 'ContractorResource_Name' + taskListForPhase.buildertek__Contractor_Resource_3__r.Name;
        assignmentRow['event'] = taskListForPhase.Id
        assignmentRow['resource'] = taskListForPhase.buildertek__Contractor_Resource_3__c;
        assignmentRowDataChild.push(assignmentRow)
    }

    if (!taskListForPhase.buildertek__Milestone__c && taskListForPhase.buildertek__Internal_Resource_1__c) {
        assignmentRow['id'] = taskListForPhase.Id + '_' + taskListForPhase.buildertek__Internal_Resource_1__c + '__index' + i + 'ContractorResource_Name' + taskListForPhase.buildertek__Internal_Resource_1__r.Name;
        assignmentRow['event'] = taskListForPhase.Id
        assignmentRow['resource'] = taskListForPhase.buildertek__Internal_Resource_1__c;
        assignmentRowDataChild.push(assignmentRow)
    }

    if (!taskListForPhase.buildertek__Milestone__c && taskListForPhase.buildertek__Internal_Resource_3__c) {
        assignmentRow['id'] = taskListForPhase.Id + '_' + taskListForPhase.buildertek__Internal_Resource_3__c + '__index' + i + 'ContractorResource_Name' + taskListForPhase.buildertek__Internal_Resource_3__r.Name;
        assignmentRow['event'] = taskListForPhase.Id
        assignmentRow['resource'] = taskListForPhase.buildertek__Internal_Resource_3__c;
        assignmentRowDataChild.push(assignmentRow)
    }

    if (!taskListForPhase.buildertek__Milestone__c && taskListForPhase.buildertek__Internal_Resource_4__c) {
        assignmentRow['id'] = taskListForPhase.Id + '_' + taskListForPhase.buildertek__Internal_Resource_4__c + '__index' + i + 'ContractorResource_Name' + taskListForPhase.buildertek__Internal_Resource_4__r.Name;
        assignmentRow['event'] = taskListForPhase.Id
        assignmentRow['resource'] = taskListForPhase.buildertek__Internal_Resource_4__c;
        assignmentRowDataChild.push(assignmentRow)
    }

    return assignmentRowDataChild;
}

//* ayther : Mitrajsinh Gohil
//* Date : 8th Dec 2023
//* This method is used to create task row data based on the conditions
function grpTaskOnPhase(records) {
    const hierarchy = { children: [] };

    records.forEach(record => {
        const phase1 = record.buildertek__Phase__c || 'UnknownPhase1';
        const phase2 = record.buildertek__BT_Grouping__c || 'UnknownPhase2';
        const phase3 = record.buildertek__BT_Phase3__c || 'UnknownPhase3';

        if (!hierarchy.children.find(child => child.id == phase1) && phase1 !== 'UnknownPhase1') {
            hierarchy.children.push({ id: phase1, name: phase1, expanded: true, type: "Phase", children: [] });
        }

        let targetNode;

        if (phase2 !== 'UnknownPhase2' && phase3 !== 'UnknownPhase3' && phase1 !== 'UnknownPhase1') {
            let phase2Node1 = hierarchy.children.find(child => child.id === phase1)
            let phase2Node = phase2Node1.children.find(child => child.id === phase1 + phase2);

            if (!phase2Node) {
                phase2Node = { id: phase1 + phase2, name: record.buildertek__BT_Grouping__r.Name, expanded: true, type: "Phase", children: [] };
                hierarchy.children.find(child => child.id === phase1).children.push(phase2Node);
            }

            let phase3Node = phase2Node.children.find(child => child.id === phase1 + phase2 + phase3);

            if (!phase3Node) {
                phase3Node = { id: phase1 + phase2 + phase3, name: record.buildertek__BT_Phase3__r.Name, expanded: true, type: "Phase", children: [] };
                phase2Node.children.push(phase3Node);
            }

            targetNode = phase3Node;
        } else if (phase2 !== 'UnknownPhase2' && phase1 !== 'UnknownPhase1') {
            let phase2Node = hierarchy.children.find(child => child.id=== phase1).children.find(child => child.id === phase1 + phase2);

            if (!phase2Node) {
                phase2Node = { id: phase1 + phase2, name: record.buildertek__BT_Grouping__r.Name, expanded: true, type: "Phase", children: [] };
                hierarchy.children.find(child => child.id === phase1).children.push(phase2Node);
            }

            targetNode = phase2Node;
        }
        else if (phase1 !== 'UnknownPhase1') {
            targetNode = hierarchy.children.find(child => child.id === phase1);
        } else {
            targetNode = hierarchy;
        }

        let customtype;
        let duration;
        let classtype;


        console.log('customtype:- ', customtype);
        let duprecordobj = {
            id: record.Id,
            name: record.Name,
            Phase: record.buildertek__Phase__c,
            NewPhase: record.buildertek__Phase__c,
            percentDone: record.buildertek__Completion__c || 0,
            startDate: record.buildertek__Start__c,
            constraintType : "startnoearlierthan",
            constriantDate : record.buildertek__Start__c,
            expanded: true,
            type: "Task",
            iconCls: "b-fa b-fa-arrow-right",
            contractorId: record.buildertek__Contractor__c || "",
            // Add other fields as needed
        }
        if (record.Name == "Milestone Complete") {
            duprecordobj['customtype'] = 'Milestone';
            duprecordobj['duration'] = 0;
            duprecordobj['cls'] = "milestoneTypeColor";
        } else {
            duprecordobj['customtype'] = 'Task';
            duprecordobj['duration'] = record.buildertek__Duration__c || 1;
            duprecordobj['cls'] = "task";
            if(record.buildertek__Dependency__r){
                duprecordobj['predecessorName'] = record.buildertek__Dependency__r.Name
            }
            duprecordobj['eventColor'] = record.buildertek__task_color__c || "";
        }
        targetNode.children.push(duprecordobj);
    });


    return hierarchy;
}

export { formatApexDatatoJSData, convertJSONtoApexData, recordsTobeDeleted, makeComboBoxDataForContractor, calcBusinessDays, makeComboBoxDataForResourceData, setResourceDataForApexData, mergeArrays, createAssignmentData };