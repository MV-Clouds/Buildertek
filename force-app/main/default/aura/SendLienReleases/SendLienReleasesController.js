({
    doInit: function (component, event, helper) {
        component.set("v.Spinner", true);
        component.set("v.isError", false);
        component.set("v.isSucess", false);
        var url = location.href;
        var baseURL = url.substring(0, url.indexOf('--', 0));
        component.set("v.BaseURLs", baseURL);
        var action = component.get("c.getPurchaseOrders");
        var myPageRef = component.get("v.pageReference");
        var recordId = myPageRef.state.buildertek__parentId;
        if(!recordId){
            recordId = component.get("v.recordId");
        }
        action.setParams({//recordIdFromUrl
            recordId: recordId
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
                //alert(component.get("v.masterSchedulesList").length);
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
            if (Submittals[i].purchaseOrderRecord.Id == checkbox.get("v.text") && Submittals[i].ScheduleCheck) {//Submittals[i].ScheduleCheck == false
                Submittals[i].ScheduleCheck = true;
            } else if (Submittals[i].purchaseOrderRecord.Id == checkbox.get("v.text") && Submittals[i].ScheduleCheck == false) {//Submittals[i].ScheduleCheck == true
                Submittals[i].ScheduleCheck = false;

            }

        }
        component.set("v.masterSchedulesList", Submittals);
    },

    selectAll: function (component, event, helper) {
        component.set("v.isError", false);
        var selectedHeaderCheck = event.getSource().get("v.value");
        var Submittals = component.get("v.masterSchedulesList");
       var start =  component.get("v.startPage");
       var end =  component.get("v.endPage");
        var getAllId = component.find("checkContractor");
        if (Submittals != null) {
            if (Submittals.length > 1) {
                if (!Array.isArray(getAllId)) {
                    if (selectedHeaderCheck == true) {
                        component.find("checkContractor").set("v.value", true);
                    } else {
                        component.find("checkContractor").set("v.value", false);
                    }
                } else {
                    if (selectedHeaderCheck == true) {
                       var count = 0
                        for (var i = start; i < getAllId.length+start; i++) {
                         
                            component.find("checkContractor")[count].set("v.value", true);
                            
                            var checkbox = component.find("checkContractor")[count].get("v.text");
                            Submittals[i].ScheduleCheck = true;
                            count++;

                        }
                    } else {
                       var count = 0
                        for (var i = start; i < getAllId.length+start; i++) {
                            component.find("checkContractor")[count].set("v.value", false);
                           
                            var checkbox = component.find("checkContractor")[count].get("v.text");
                            var Submittals = component.get("v.masterSchedulesList");
                            Submittals[i].ScheduleCheck = false;
                            count++;
                        }
                    }
                }
            } else {
                var i = start;
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
		component.set("v.masterSchedulesList", Submittals);
    },

    closeModel: function (component, event, helper) {
        var myPageRef = component.get("v.pageReference");
        var recordId = myPageRef.state.buildertek__parentId;
       var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        
        .catch(function(error) {
            console.log(error);
        });
        /*$A.get("e.force:closeQuickAction").fire();
        window.setTimeout(
            $A.getCallback(function () {
                $A.get('e.force:refreshView').fire();
            }), 1000
        );*/
        setTimeout(function () {  
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": '/lightning/r/buildertek__Purchase_Order__c/'+recordId+'/related/buildertek__Purchase_Orders__r/view'
            });
            urlEvent.fire();
            
        }, 200);
    },

    next: function (component, event, helper) {
        component.set("v.isError", false);
        var sObjectList = component.get("v.masterSchedulesList");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var Paginationlist = [];
        var counter = 0;
        var checkBoxValue = 0;
        for (var i = end + 1; i < end + pageSize + 1; i++) {
            if (sObjectList.length > i) {
                Paginationlist.push(sObjectList[i]);
                if(sObjectList[i].ScheduleCheck){
                    checkBoxValue++;
                }
            }
            counter++;
        }
        start = start + counter;
        end = end + counter;
        component.set("v.startPage", start);
        component.set("v.endPage", end);
        component.set('v.PaginationList', Paginationlist);
        component.find("checkContractors").set("v.value", false);
        if(checkBoxValue == 20){
            component.find("checkContractors").set("v.value", true);
        }
        
    },
    previous: function (component, event, helper) {
        component.set("v.isError", false);
        var sObjectList = component.get("v.masterSchedulesList");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var Paginationlist = [];
        var counter = 0;
         var checkBoxValue = 0;
        for (var i = start - pageSize; i < start; i++) {
            if (i > -1) {
                Paginationlist.push(sObjectList[i]);
                counter++;
            } else {
                start++;
            }
            if(sObjectList[i].ScheduleCheck){
                checkBoxValue++;
            }
        }
        start = start - counter;
        end = end - counter;
        component.set("v.startPage", start);
        component.set("v.endPage", end);
        component.set('v.PaginationList', Paginationlist);
        component.find("checkContractors").set("v.value", false);
        if(checkBoxValue == 20){
            component.find("checkContractors").set("v.value", true);
        }
    },
    importPO : function(component, event, helper){
        var myPageRef = component.get("v.pageReference");
        var recordId = myPageRef.state.buildertek__parentId;
       component.set("v.Spinner", true);
        component.set("v.showMessage",true);
        component.set("v.isError", false);
        var SchedulesList = component.get("v.masterSchedulesList");
        console.log(component.get('v.PaginationList'));
        var posInPage = component.get('v.PaginationList');
       // alert(SchedulesList.length);
        var ScheduleIds = [];
        for (var i = 0; i < SchedulesList.length; i++) {
            if (SchedulesList[i].ScheduleCheck == true) {
                ScheduleIds.push(SchedulesList[i].purchaseOrderRecord.Id);
            }
        }
        
        /*for (var i = 0; i < SchedulesList.length; i++) {
            if (SchedulesList[i].scheduleCheck == true) {
                ScheduleIds.push(SchedulesList[i].purchaseOrderRecord.Id);
            }
        }*/
       // alert(ScheduleIds.length);
        if (ScheduleIds.length > 0) {
            var action = component.get("c.linerelase");
            action.setParams({
                scheduleRecIds: ScheduleIds,
            });
             action.setCallback(this, function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                    var workspaceAPI = component.find("workspace");
                    workspaceAPI.getFocusedTabInfo().then(function(response) {
                        var focusedTabId = response.tabId;
                        workspaceAPI.closeTab({tabId: focusedTabId});
                    })
                    
                    .catch(function(error) {
                        console.log(error);
                    });
                    var result = response.getReturnValue();
                    if(result === 'SUCCESS'){
                      setTimeout(function () {  
                        component.set("v.Spinner", false);
                        $A.get("e.force:closeQuickAction").fire(); 
                          var urlEvent = $A.get("e.force:navigateToURL");
                            urlEvent.setParams({
                                "url": '/lightning/r/buildertek__Purchase_Order__c/'+recordId+'/related/buildertek__Purchase_Orders__r/view'
                            });
                            urlEvent.fire();
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "type": 'success',
                            "message": "Email Sent Successfully"
                        });
                        toastEvent.fire();
                        }, 200);
                    }
                    $A.get('e.force:refreshView').fire();
                }
            });
            $A.enqueueAction(action); 
            
        }   else {
            component.set("v.Spinner", false);
            component.set("v.isError", true);
            component.set("v.ErrorMessage", 'Please select atlease one Schedule record');
        }
    },
})