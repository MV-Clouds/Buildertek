({
    doInit: function (component, event, helper) {
        component.set("v.Spinner", true);
        component.set("v.isError", false);
        component.set("v.isSucess", false);
        var url = location.href;
        var baseURL = url.substring(0, url.indexOf('--', 0));
        component.set("v.BaseURLs", baseURL);
        var myPageRef = component.get("v.pageReference");
        var recordId;
        if(myPageRef){
             recordId = myPageRef.state.buildertek__RecordId;
        }
        
        if(recordId){
            component.set("v.RecordId",recordId)
            component.set("v.isNewGantt", myPageRef.state.buildertek__isFromNewGantt)
            //recordId = component.get("v.RecordId");
            /*if(!recordId){
                recordId = myPageRef.attributes.recordId
            }*/
        }
        var action = component.get("c.getMasterSchedule");
       
        action.setParams({//recordIdFromUrl
            recordId: component.get("v.RecordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var pageSize = component.get("v.pageSize");
                var result = response.getReturnValue();
                console.log('Result::', JSON.stringify(result));
                component.set("v.masterSchedulesList", result);
                component.set("v.totalRecords", component.get("v.masterSchedulesList").length);
                component.set("v.startPage", 0);
                component.set("v.endPage", pageSize - 1);
                var PaginationList = [];
                for (var i = 0; i < pageSize; i++) {
                    if (component.get("v.masterSchedulesList").length > i)
                        PaginationList.push(result[i]);
                }

                component.set('v.PaginationList', PaginationList);

                component.set("v.Spinner", false);
            }
        });
        $A.enqueueAction(action);
    },

    handleCheck: function (component, event, helper) {
        component.set("v.isError", false);
        var checkbox = event.getSource();
        var Submittals = component.get("v.masterSchedulesList");
        for (var i = 0; i < Submittals.length; i++) {

            if (Submittals[i].masterscheduleRecord.Id == checkbox.get("v.text") && Submittals[i].scheduleCheck == false) {
                Submittals[i].scheduleCheck = true;
            } else if (Submittals[i].masterscheduleRecord.Id == checkbox.get("v.text") && Submittals[i].scheduleCheck == true) {
                Submittals[i].scheduleCheck = false;

            }

        }
        component.set("v.masterSchedulesList", Submittals);
    },

    selectAll: function (component, event, helper) {
        component.set("v.isError", false);
        var selectedHeaderCheck = event.getSource().get("v.value");
        var Submittals = JSON.parse(JSON.stringify(component.get("v.masterSchedulesList")));
        var getAllId = component.find("checkContractor");
        if (Submittals) {
            if (Submittals.length) {
                if (!Array.isArray(getAllId)) {
                    if (selectedHeaderCheck == true) {
                        component.find("checkContractor").set("v.value", true);
                    } else {
                        component.find("checkContractor").set("v.value", false);
                    }
                } else {
                    if (selectedHeaderCheck == true) {
                        for (var i = 0; i < getAllId.length; i++) {
                            component.find("checkContractor")[i].set("v.value", true);
                            var checkbox = component.find("checkContractor")[i].get("v.text");
                            Submittals[i].ScheduleCheck = true;

                        }
                    } else {
                        for (var i = 0; i < getAllId.length; i++) {
                            component.find("checkContractor")[i].set("v.value", false);

                            var checkbox = component.find("checkContractor")[i].get("v.text");
                            var Submittals = component.get("v.masterSchedulesList");
                            Submittals[i].ScheduleCheck = false;
                        }
                    }
                }
            } else {
                var i = 0;
                if (Submittals.length) {
                    if (selectedHeaderCheck == true) {
                        component.find("checkContractor").set("v.value", true);
                        var checkbox = component.find("checkContractor").get("v.text");
                        Submittals[i].ScheduleCheck = true;
                        
                        
                    } else {
                        component.find("checkContractor").set("v.value", false);
                        
                        var checkbox = component.find("checkContractor").get("v.text");
                        var Submittals = component.get("v.masterSchedulesList");
                        Submittals[i].ScheduleCheck = false;
                        
                    }
                }
            }
        }

    },

    closeModel: function (component, event, helper) {
        component.set("v.isError", false);
        var url = location.href;
        var baseURL = url.substring(0, url.indexOf('--', 0));
        var recordId = component.get("v.RecordId");
        if(component.get('v.isNewGantt')){
            //window.open(baseURL + '.lightning.force.com/lightning/r/buildertek__Schedule__c/' + escape(recordId) + '/view', '_top');
            var workspaceAPI = component.find("workspace");
            if(workspaceAPI.getFocusedTabInfo()){
                workspaceAPI.getFocusedTabInfo().then(function(response) {
                    var focusedTabId = response.tabId;
                    workspaceAPI.closeTab({tabId: focusedTabId});
                })
                .catch(function(error) {
                    console.log(error);
                    var navEvt = $A.get("e.force:navigateToSObject");
                                    navEvt.setParams({
                                        "recordId": recordId,
                                        "slideDevName": "detail"
                                    });
                                    navEvt.fire();
                    //window.open(baseURL + '.lightning.force.com/lightning/r/buildertek__Schedule__c/' + escape(recordId) + '/view', '_top');
                });
            }else{
                window.open(baseURL + '.lightning.force.com/lightning/r/buildertek__Schedule__c/' + escape(recordId) + '/view', '_top');
            }
            
        }else{
            window.open('/apex/BT_Task_Manager?recordId=' + escape(recordId), '_self')
        }
        
        //window.open(baseURL + '.lightning.force.com/lightning/r/buildertek__Schedule__c/' + escape(recordId) + '/view', '_self');
    },

    importSchedule: function (component, event, helper) {
        component.set("v.Spinner", true);
        component.set("v.showMessage",true);
        component.set("v.isError", false);
        var url = location.href;
        var baseURL = url.substring(0, url.indexOf('--', 0));
        var SchedulesList = component.get("v.masterSchedulesList");
        var ScheduleIds = [];
        for (var i = 0; i < SchedulesList.length; i++) {
            if (SchedulesList[i].scheduleCheck == true) {
                ScheduleIds.push(SchedulesList[i].masterscheduleRecord.Id);
            }
        }
        if (ScheduleIds.length > 0) {
            var action = component.get("c.importMasterScheduleLines");
            action.setParams({
                scheduleRecIds: ScheduleIds,
                recordId: component.get("v.RecordId")
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    console.log('result ===>', {result});
                    if (result.Status === 'Success') {
                        component.set("v.isSucess", true);
                        component.set("v.SucessMessage", result.Message);
                        component.set("v.Spinner", false);
                        component.set("v.showMessage",false);
                        var baseURL = component.get("v.BaseURLs");
                        var recordId = component.get("v.RecordId");
                        if(component.get('v.isNewGantt')){
                            //window.open(baseURL + '.lightning.force.com/lightning/r/buildertek__Schedule__c/' + escape(recordId) + '/view', '_top');
                            var workspaceAPI = component.find("workspace");
                            if(workspaceAPI.getFocusedTabInfo()){
                                workspaceAPI.getFocusedTabInfo().then(function(response) {
                                    var focusedTabId = response.tabId;
                                    workspaceAPI.closeTab({tabId: focusedTabId}).then(function(res){
                                        /*workspaceAPI.getFocusedTabInfo().then(function(response) {
                                            var focusedTabId = response.tabId;
                                           // $A.get('e.force:refreshView').fire();
                                            window.open('/'+recordId,'_top')
                                        }).catch(function(error) {
                                            console.log(error);
                                        });*/
                                        if(res){
                                            window.open('/'+recordId,'_top')
                                        }
                                        
                                        //$A.enqueueAction(component.get('c.doInit'))
                                        // $A.enqueueAction(navEvt.fire());
                                    }).catch(function(error) {
                                        console.log(error);
                                    });
                                    
                                }).catch(function(error) {
                                    console.log(error);
                                    var navEvt = $A.get("e.force:navigateToSObject");
                                    navEvt.setParams({
                                        "recordId": recordId,
                                        "slideDevName": "detail"
                                    });
                                    
                                    $A.enqueueAction(component.get('c.doInit'))
                                    $A.enqueueAction(navEvt.fire());
                                    location.reload();
                                });
                            }else{
                                window.open('/'+recordId, "_top");
                               // window.open(baseURL + '.lightning.force.com/lightning/r/buildertek__Schedule__c/' + escape(recordId) + '/view', '_top');
                            }
                            
                        }else{
                            window.open('/apex/BT_Task_Manager?recordId=' + escape(recordId), '_self')
                        }
                        //window.open('/apex/BT_Task_Manager?recordId=' + escape(recordId), '_self')
                    } else {
                        component.set("v.Spinner", false);
                        component.set("v.showMessage",false);
                        component.set("v.isError", true);
                        component.set("v.ErrorMessage", 'There are no schedule lines for the selected schedule.');
                    }
                }
            });
            $A.enqueueAction(action);
        } else {
            component.set("v.Spinner", false);
            component.set("v.isError", true);
            component.set("v.ErrorMessage", 'Please select at least one schedule to import.');

        }
    },

    next: function (component, event, helper) {
        component.set("v.isError", false);
        var sObjectList = component.get("v.masterSchedulesList");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var Paginationlist = [];
        var counter = 0;
        for (var i = end + 1; i < end + pageSize + 1; i++) {
            if (sObjectList.length > i) {
                Paginationlist.push(sObjectList[i]);
            }
            counter++;
        }
        start = start + counter;
        end = end + counter;
        component.set("v.startPage", start);
        component.set("v.endPage", end);
        component.set('v.PaginationList', Paginationlist);
    },
    previous: function (component, event, helper) {
        component.set("v.isError", false);
        var sObjectList = component.get("v.masterSchedulesList");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var Paginationlist = [];
        var counter = 0;
        for (var i = start - pageSize; i < start; i++) {
            if (i > -1) {
                Paginationlist.push(sObjectList[i]);
                counter++;
            } else {
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        component.set("v.startPage", start);
        component.set("v.endPage", end);
        component.set('v.PaginationList', Paginationlist);
    },
    
})