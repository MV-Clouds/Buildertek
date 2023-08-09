({
    getTotalRecord: function (component, event, helper) {
        var action = component.get("c.getCount");
        action.setParams({
            recordId: component.get('v.recordId'),
        });
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                component.set("v.TotalRecords", response.getReturnValue());
            }
        })
        $A.enqueueAction(action);
    },

    getTableFieldSet: function (component, event, helper) {
        var action = component.get("c.getFieldSet");
        action.setCallback(this, function (response) {
            var fieldSetObj = JSON.parse(response.getReturnValue());
            component.set("v.fieldSetValues", fieldSetObj);
            helper.getTotalRecord(component, event, helper);
            var pageNumber = component.get("v.PageNumber");
            var pageSize = component.get("v.pageSize");
            var phase = component.find("SearchPhase").get("v.value");
            var contractor = component.find("searchContractor").get("v.value");
            var contractorResources = component.find("searchContractorResources").get("v.value");
            var TradeType = component.find("searchTradeType").get("v.value");
            helper.getTableRows(component, event, helper, pageNumber, pageSize, phase, contractor, contractorResources, TradeType);
        })
        $A.enqueueAction(action);
    },

    getTableRows: function (component, event, helper, pageNumber, pageSize, phase, contractor, contractorResources, TradeType) {
        component.set('v.isLoading', true);
        var action = component.get("c.getRecords");
        var fieldSetValues = component.get("v.fieldSetValues");
        var setfieldNames = new Set();

        for (var c = 0, clang = fieldSetValues.length; c < clang; c++) {
            if (!setfieldNames.has(fieldSetValues[c].name)) {
                setfieldNames.add(fieldSetValues[c].name);
                if (fieldSetValues[c].type == 'REFERENCE') {
                    if (fieldSetValues[c].name.indexOf('__c') == -1) {
                        setfieldNames.add(fieldSetValues[c].name.substring(0, fieldSetValues[c].name.indexOf('Id')) + '.Name');
                    } else {
                        setfieldNames.add(fieldSetValues[c].name.substring(0, fieldSetValues[c].name.indexOf('__c')) + '__r.Name');
                    }
                }
            }
        }

        var arrfieldNames = [];
        setfieldNames.forEach(v => arrfieldNames.push(v));
        component.set('v.arrfieldNames', arrfieldNames);
        action.setParams({
            recordId: component.get('v.recordId'),
            fieldNameJson: JSON.stringify(arrfieldNames),
            pageNumber: pageNumber,
            pageSize: pageSize,
            phase: phase,
            contractor: contractor,
            contractorResources: contractorResources,
            TradeType: TradeType
        });
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                var list = JSON.parse(response.getReturnValue());
                if (list.length > 0) {

                    var sPhaseList = component.get("v.sPhaseList");;
                    var tempIndexList = component.get("v.tempIndexList");
                    var sPhase = sPhaseList[pageNumber-1];
                    var tempIndex = tempIndexList[pageNumber-1];
                    if (sPhase == undefined) {
                        sPhase = '';
                    }
                    if (tempIndex == undefined) {
                        tempIndex = 1;
                    }
                    list.forEach(element => {
                        if (element.buildertek__Phase__c == undefined) {
                            element.tempIndex = tempIndex;
                            tempIndex++;
                        }
                        else if (sPhase != element.buildertek__Phase__c) {
                            sPhase = element.buildertek__Phase__c;
                            tempIndex = 1;
                            element.tempIndex = tempIndex;
                            tempIndex++;
                        } else{
                            element.tempIndex = tempIndex;
                            tempIndex++;
                        }
                    });
                    sPhaseList[pageNumber] = sPhase;
                    tempIndexList[pageNumber] = tempIndex;
                    component.set("v.sPhaseList", sPhaseList);
                    component.set("v.tempIndexList", tempIndexList);

                    component.set("v.listOfRecords", list);
                    // console.log(list)

                    
                    component.set("v.cloneListOfRecords", list);
                    component.set('v.numberOfItems', list.length);
                    component.set("v.PageNumber", pageNumber);
                    this.formatDataByGroups(component,list);
                    component.set("v.RecordStart", (pageNumber - 1) * pageSize + 1);
                    component.set("v.RecordEnd", (list.length + 3) * pageNumber);
                    component.set("v.TotalPages", Math.ceil(list.length / component.get('v.TotalRecords')));
                    component.set('v.isLoading', false);

                    if (component.get('v.TotalRecords') <= pageNumber * pageSize) {
                        component.set("v.isNextDisabled", true);
                        // console.log('isNextDisabled:::', component.get("v.isNextDisabled"));
                    } else {
                        component.set("v.isNextDisabled", false);
                    }
                } else {
                    component.set('v.isLoading', false);
                }
            } else {
                component.set("v.cloneListOfRecords", []);
            }
        })
        $A.enqueueAction(action);
    },

    updateMassRecords: function (component, event, helper, phase, contractor, contractorResources, TradeType) {
        //component.set('v.isLoading', true);
        var listOfRecords = component.get('v.listOfRecords');
        // console.log({listOfRecords});
        var grpList = JSON.parse(JSON.stringify(component.get("v.grpByPhaseValuesMassUpdate")))
        // console.log({grpList});
        var newList = []
        for(var i=0;i<grpList.length;i++){
            var val = grpList[i].value
            for(var j=0;j<val.length;j++){
                newList.push(val[j])
            }
        }
        // console.log({newList});
        // listOfRecords = newList
        var action = component.get("c.updateRecords");
        var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.pageSize");
        var fieldSetValues = component.get('v.fieldSetValues');
        for (var i in listOfRecords) {
            var record = listOfRecords[i];
            if (record != undefined) {
                for (var j in fieldSetValues) {
                    if (record.buildertek__Schedule__c === undefined || record.buildertek__Schedule__c === '') {
                        record.buildertek__Schedule__c = component.get('v.recordId');
                    } else if (record[fieldSetValues[j].name] === '' || record[fieldSetValues[j].name] === undefined) {
                        record[fieldSetValues[j].name] = null;
                        record[fieldSetValues[j].name] = fieldSetValues[j].name.includes('__r') ? null : record[fieldSetValues[j].name];
                    }
                }
            } else {
                listOfRecords.splice(i, 1);
                i--;
            }
        }
        // console.log('Records To Update::', JSON.stringify(listOfRecords));
        // console.log({listOfRecords});
        action.setParams({
            recordId: component.get('v.recordId'),
            updatedRecords: JSON.stringify(listOfRecords),
            fieldSetName: JSON.stringify(component.get('v.arrfieldNames')),
            pageNumber: pageNumber,
            pageSize: pageSize,
            phase: phase,
            contractor: contractor,
            contractorResources: contractorResources,
            TradeType: TradeType
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var list = JSON.parse(response.getReturnValue());
                component.set('v.listOfRecords', list);
                component.set('v.numberOfItems', list.length);
                component.set('v.cloneListOfRecords', list);
                component.set('v.isLoading', false);
                component.set("v.PageNumber", pageNumber);
                component.set("v.RecordStart", (pageNumber - 1) * pageSize + 1);
                component.set("v.RecordEnd", (list.length + 1) * pageNumber);
                component.set("v.TotalPages", Math.ceil(list.length / component.get('v.TotalRecords')));
               // component.set('v.massUpdateEnable', false);
                this.formatDataByGroups(component,list);
                var workspaceAPI = component.find("workspace");
                if( workspaceAPI.getFocusedTabInfo()){
                    workspaceAPI.getFocusedTabInfo().then(function(response) {
                        var focusedTabId = response.tabId;
                        workspaceAPI.closeTab({tabId: focusedTabId}).then(function(response){
                            // console.log(response)
                            workspaceAPI.openSubtab({
                                parentTabId: response.parentTabId,
                                url: '/lightning/r/buildertek__Schedule__c/'+component.get("v.recordId")+'/view',
                                focus: true
                            });
                            $A.get('e.force:refreshView').fire();
                        }).catch(function(error) {
                            component.set('v.massUpdateEnable', false);
                            // console.log(error);
                            var navEvt = $A.get("e.force:navigateToSObject");
                            navEvt.setParams({
                                "recordId": component.get("v.recordId"),
                                "slideDevName": "Schedule Table"
                            });
                            navEvt.fire();
                            $A.get('e.force:refreshView').fire();
                        });
                        
                        /*var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": component.get("v.recordId"),
                            "slideDevName": "Schedule Table"
                        });
                        navEvt.fire();*/
                        
                        
                    }).catch(function(error) {
                        component.set('v.massUpdateEnable', false);
                        // console.log(error);
                        console.log('3rd condition');
                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": component.get("v.recordId"),
                            "slideDevName": "Schedule Table"
                        });
                        // navEvt.fire();
                        history.back();
                        $A.get('e.force:refreshView').fire();
                        // component.set('v.isLoading', false);
                    });
                }else{
                    component.set('v.massUpdateEnable', false);
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": component.get("v.recordId"),
                        "slideDevName": "Schedule Table"
                    });
                    navEvt.fire();
                    $A.get('e.force:refreshView').fire();
                }
                
                //refresh gantt
                var appEvent = $A.get("e.c:refresh_componenent_event");
                appEvent.setParams({
                    "refreshmessage" : "Refresh Component from table"
                });
                appEvent.fire();
                
            } else if (state === "ERROR") {
                var errorMessage = response.getError();
                var message = 'Something went wrong!';
                if (errorMessage[0].message != undefined && errorMessage[0].message.includes('Start Date') && errorMessage[0].message.includes('REQUIRED_FIELD_MISSING')) {
                    message = 'Required field missing, Start Date!';
                } else if (errorMessage[0].message != undefined && errorMessage[0].message.includes('Finish Date cannot be less than Start Date')) {
                    message = 'Finish Date cannot be less than Start Date!';
                }
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    mode: 'sticky',
                    message: message,
                    type: 'error',
                    duration: '10000',
                    mode: 'dismissible'
                });
                toastEvent.fire();
                component.set('v.isLoading', false);
                console.log('A Problem Occurred: ' + response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    massDeleteRecord: function (component, event, helper, recordIdsToDelete, phase, contractor, contractorResources, TradeType) {
        var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.pageSize");

        var action = component.get("c.massDeleteProjectTask");
        action.setParams({
            deleteRecordId: recordIdsToDelete,
            recordId: component.get('v.recordId'),
            fieldSetName: JSON.stringify(component.get('v.arrfieldNames')),
            pageNumber: pageNumber,
            pageSize: pageSize,
            phase: phase,
            contractor: contractor,
            contractorResources: contractorResources,
            TradeType: TradeType
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS" && response.getReturnValue()) {
                var list = JSON.parse(response.getReturnValue());
                component.set('v.listOfRecords', list);
                component.set('v.numberOfItems', list.length);
                component.set('v.cloneListOfRecords', list);
               
                component.set('v.isLoading', false);
                component.set("v.PageNumber", pageNumber);
                 this.formatDataByGroups(component,list);
                component.set("v.RecordStart", (pageNumber - 1) * pageSize + 1);
                component.set("v.RecordEnd", (list.length + 3) * pageNumber);
                component.set("v.TotalPages", Math.ceil(list.length / component.get('v.TotalRecords')));
                
                //refresh gantt
                var appEvent = $A.get("e.c:refresh_componenent_event");
                appEvent.setParams({
                    "refreshmessage" : "Refresh Component from table"
                });
                appEvent.fire();
            } else if (state === "ERROR") {
                component.set('v.isLoading', false);
                console.log('A Problem Occurred: ' + JSON.stringify(response.error));
            }
        });
        $A.enqueueAction(action);
    },

    deleteRecord: function (component, event, helper, deleteRecordId, phase, contractor, contractorResources, TradeType) {
        var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.pageSize");

        var action = component.get("c.deleteProject");
        action.setParams({
            deleteRecordId: deleteRecordId,
            recordId: component.get('v.recordId'),
            fieldSetName: JSON.stringify(component.get('v.arrfieldNames')),
            pageNumber: pageNumber,
            pageSize: pageSize,
            phase: phase,
            contractor: contractor,
            contractorResources: contractorResources,
            TradeType: TradeType
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS" && response.getReturnValue()) {
                var list = JSON.parse(response.getReturnValue());
                component.set('v.listOfRecords', list);
                component.set('v.numberOfItems', list.length);
                component.set('v.cloneListOfRecords', list);
                
                component.set('v.isLoading', false);
                component.set("v.PageNumber", pageNumber);
                this.formatDataByGroups(component,list);
                component.set("v.RecordStart", (pageNumber - 1) * pageSize + 1);
                component.set("v.RecordEnd", (list.length + 3) * pageNumber);
                component.set("v.TotalPages", Math.ceil(list.length / component.get('v.TotalRecords')));
            } else if (state === "ERROR") {
                component.set('v.isLoading', false);
                console.log('A Problem Occurred: ' + JSON.stringify(response.error));
            }
        });
        $A.enqueueAction(action);
    },
    
    formatDataByGroups : function(component,mapData){
        
        component.set('v.isLoading', true);
        let recordsMap = new Map();
        var mapData = JSON.parse(JSON.stringify(component.get("v.listOfRecords")));
        for (var i in mapData) {
            if(mapData[i].buildertek__Phase__c){
                if (!recordsMap.has(mapData[i].buildertek__Phase__c)) {
                    recordsMap.set(mapData[i].buildertek__Phase__c, []);
                }
                recordsMap.get(mapData[i].buildertek__Phase__c).push(JSON.parse(JSON.stringify(mapData[i])));
            }else{
                //console.log(recordsMap.has('No vendor'),recordsMap.get("No vendor"))
                if (!recordsMap.has('No Phase')) {
                    recordsMap.set('No Phase', []);
                }
                //console.log(recordsMap.has('No vendor'),recordsMap.get("No vendor"))
                recordsMap.get('No Phase').push(JSON.parse(JSON.stringify(mapData[i])));
                //console.log(recordsMap.get("No vendor"))
            }
        }
        // console.log('recordsMap'+recordsMap)
        var result = Array.from(recordsMap.entries());
        // console.log({result});
        var groupData = [];
        var pagObj = {}
        var pageArr = component.get("v.pageArr")
       // var duplicateSchedule = component.get("v.dupScheduleItems")
        for(var i in result){
            var newObj = {};
            
            newObj['key'] = result[i][0];
            
            newObj['value'] = result[i][1];
            
            newObj['expanded'] = true; //adding for expand/collapse icons
            
            groupData.push(newObj);
        }
        // console.log(groupData);
        component.set("v.grpByPhaseValuesMassUpdate",groupData)
         component.set("v.prevlastPhaseName", component.get("v.lastPhaseName"))
        var lastPhaseName = groupData[groupData.length-1].key
		var firstPhaseName = groupData[0].key
        component.set("v.firstPhaseName",firstPhaseName)
        component.set("v.prevlastPhaseNum", component.get("v.lastPhaseNum"))
        
         component.set("v.prevlastItemInPhaseNum", component.get("v.lastItemInPhaseNum"))
        var lastPhaseItemarr = groupData[groupData.length-1].value.length;
        component.set("v.lastItemInPhaseNum",lastPhaseItemarr)
        
        if(!component.get("v.iPrevClicked")){
            if(component.get("v.PageNumber") > 1){
                if(firstPhaseName ==  component.get("v.lastPhaseName")){
                    
                    component.set("v.lastPhaseNum",groupData.length + component.get("v.prevlastPhaseNum") - 1) 
                     pagObj[''+component.get("v.PageNumber")+'lastPhaseNum'] =  component.get("v.lastPhaseNum")
                    component.get("v.prevlastPhaseNum", component.get("v.prevlastPhaseNum")-1)
                }else{
                    component.set("v.lastPhaseNum",groupData.length + component.get("v.prevlastPhaseNum") ) 
                     pagObj[''+component.get("v.PageNumber")+'lastPhaseNum'] =  component.get("v.lastPhaseNum")
                }
                
            }else{
                component.set("v.prevlastPhaseNum", groupData.length)
                component.set("v.lastPhaseNum",groupData.length)
            }
            pagObj[''+component.get("v.PageNumber")+'_prevlastPhaseNum'] =  component.get("v.prevlastPhaseNum")
            pagObj[''+component.get("v.PageNumber")+'_prevlastItemInPhaseNum'] = component.get("v.prevlastItemInPhaseNum")
            pagObj[''+component.get("v.PageNumber")+'_prevlastPhaseName'] = component.get("v.prevlastPhaseName")
            pagObj[''+component.get("v.PageNumber")+'_firstPhaseName'] = component.get("v.firstPhaseName")
            if(pageArr.length  < component.get("v.PageNumber")){
                pageArr.push(pagObj)
            }else if(pageArr.length == 0){
                pageArr.push(pagObj)
            }
            
        }
        /*if(component.get("v.PageNumber") > 1){
            if(firstPhaseName ==  component.get("v.lastPhaseName")){
                component.set("v.lastPhaseNum",groupData.length + component.get("v.prevlastPhaseNum") - 1) 
                component.get("v.prevlastPhaseNum", component.get("v.prevlastPhaseNum")-1)
            }else{
                component.set("v.lastPhaseNum",groupData.length + component.get("v.prevlastPhaseNum") ) 
            }
            
        }else{
            component.set("v.prevlastPhaseNum", groupData.length)
            component.set("v.lastPhaseNum",groupData.length)
        }*/
        component.set("v.lastPhaseName",lastPhaseName)
       
        if(component.get("v.iPrevClicked")){
        
             var objc = JSON.parse(JSON.stringify(component.get("v.pageArr")[component.get("v.PageNumber")-1]));
            if(objc[''+component.get("v.PageNumber")+'_prevlastPhaseNum']){
               component.set("v.prevlastPhaseNum",JSON.parse(JSON.stringify(objc[''+component.get("v.PageNumber")+'_prevlastPhaseNum']))) 
            }
            
            if(objc[''+component.get("v.PageNumber")+'_prevlastItemInPhaseNum']){
                component.set("v.prevlastItemInPhaseNum",JSON.parse(JSON.stringify(objc[''+component.get("v.PageNumber")+'_prevlastItemInPhaseNum'])))
            }
            
            if(objc[''+component.get("v.PageNumber")+'_prevlastPhaseName']){
                component.set("v.prevlastPhaseName",JSON.parse(JSON.stringify(objc[''+component.get("v.PageNumber")+'_prevlastPhaseName'])))
            }
            
            if(objc[''+component.get("v.PageNumber")+'_firstPhaseName']){
                component.set("v.firstPhaseName",JSON.parse(JSON.stringify(objc[''+component.get("v.PageNumber")+'_firstPhaseName'])))
            }
            /*if(objc[''+component.get("v.PageNumber")+'lastPhaseNum']){
                component.set("v.lastPhaseNum",objc[''+component.get("v.PageNumber")+'lastPhaseNum'])
            }*/
               // component.set("v.lastPhaseNum", component.get("v.prevlastPhaseNum") )
            
            
        }
        // component.set('v.isLoading', false);
    }
   
    
    
    
    
    
    
    
})