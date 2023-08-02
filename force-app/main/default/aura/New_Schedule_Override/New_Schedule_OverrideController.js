({
    doInit : function(component, event, helper) {
        console.log('===doInit===');
        var value = helper.getParameterByName(component, event, 'inContextOfRef');
        console.log("value ===  "+JSON.stringify(value));
        var context = '';
        var parentRecordId = '';
        component.set("v.parentRecordId", parentRecordId);
        if (value != null) {
            context = JSON.parse(window.atob(value));
            parentRecordId = context.attributes.recordId;
            component.set("v.parentRecordId", parentRecordId);
        } else {
            var relatedList = window.location.pathname;
            console.log("Check related list : "+JSON.stringify(relatedList));
            //"/lightning/r/buildertek__Project__c/a1Q1K000006yuf9UAA/related/buildertek__Schedules__r/view"
            if(relatedList.includes('buildertek__Project__c') && relatedList.includes('buildertek__Schedules__r') && relatedList.includes('related')){
                var stringList = relatedList.split("/");
                parentRecordId = stringList[4];
                console.log("Parent "+parentRecordId)
                /*if (parentRecordId == 'related') {
                    var stringList = relatedList.split("/");
                    parentRecordId = stringList[3];
                }*/
            }
            else if(relatedList.includes('buildertek__Project__c')  && !relatedList.includes('buildertek__Schedules__r') && !relatedList.includes('related')){
                var stringList = relatedList.split("/");
                parentRecordId = stringList[4];
            }

                else {
                    parentRecordId = '';
                }


            component.set("v.parentRecordId", parentRecordId);
        }
        console.log('check parent Id '+ component.get("v.parentRecordId"));
        if(parentRecordId != null && parentRecordId != ''){
            var action = component.get("c.getobjectName");
            action.setParams({
                recordId: parentRecordId,
            });
            action.setCallback(this, function (response) {
                if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                    var objName = response.getReturnValue();
                    if(objName.sobjectType == 'buildertek__Project__c'){
                        component.set("v.parentRecordId", parentRecordId);
                        if(objName.projectManagerId != 'Error'){
                            component.set("v.ProjectManagerId",objName.projectManagerId);
                        }

                    }
                }
            });
            $A.enqueueAction(action);

        }
        helper.getFields(component, event, helper);
        var action1 = component.get("c.fetchScheduleList");
        action1.setCallback(this,function(response){
            if(response.getState()=='SUCCESS'){
                /* var a = JSON.parse(JSON.stringify(response.getReturnValue()))
                var b = a.splice(0,5)*/
                component.set('v.masterId',JSON.parse(JSON.stringify(response.getReturnValue())))
                component.set('v.masterCount',JSON.parse(JSON.stringify(response.getReturnValue())).length)
            }
        })
        $A.enqueueAction(action1);
        var action2 = component.get("c.getUser");
        action2.setCallback(this, function(response){
            // debugger;
            if(response.getState() === "SUCCESS"){
                var result = response.getReturnValue();
                var commUserId = result.Id;
                if(result.IsPortalEnabled == true){
                    component.set("v.Iscommunity",true)
                }
            }
        })
        $A.enqueueAction(action2);
        // alert(component.get("v.recordId"))
    },
    handleOnSubmit : function(component, event, helper) {
        console.log('===handleOnSubmit===');
        component.set("v.Spinner", true);
        component.set("v.showMessage",true);
        event.preventDefault(); // stop form submission
        var eventFields = event.getParam("fields");
        console.log('eventFields ',JSON.parse(JSON.stringify(eventFields)));
        debugger
        // alert(JSON.stringify(eventFields));
        component.find('recordEditForm').submit(eventFields);


        /*  var action = component.get("c.CreateScheduleItems");
        action.setParams({
            masterScheduleItems : component.get("v.scheduleLineItems")
        })
        /*action.setCallback(this, function(response){
            var ScheduleItems = response.getReturnValue();
            alert('ScheduleItems--->'+JSON.stringify(ScheduleItems));
            component.set("v.scheduleLineItems", ScheduleItems);
        });*/
        //$A.enqueueAction(action);

    },

    handleOnSuccess : function(component, event, helper) {
        console.log('===handleOnSuccess===');
        var record = event.getParams().response;
        var newSchId = record.id;
        component.set('v.schedulerecId',newSchId)
        helper.savefunc(component, event, helper);
        var workspaceAPI = component.find("workspace");
        var isSaveNew = component.get("v.isSaveAndNew");
        /*workspaceAPI.getFocusedTabInfo().then(function (response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({
                tabId: focusedTabId
            });
        }).catch(function (error) {
            console.log('Error', JSON.stringify(error));
        });*/



    },


    closeModel: function (component, event, helper) {
        console.log('===closeModel===');
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function (response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({
                tabId: focusedTabId
            });
        })
        .catch(function (error) {
            console.log(error);
        });
        /*$A.get("e.force:closeQuickAction").fire();
        window.setTimeout(
            $A.getCallback(function () {
                $A.get('e.force:refreshView').fire();
            }), 1000
        );*/
        var action = component.get("c.getListViews");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var listviews = response.getReturnValue();
                var navEvent = $A.get("e.force:navigateToList");
                navEvent.setParams({
                    "listViewId": listviews.Id,
                    "listViewName": null,
                    "scope": "buildertek__Schedule__c"
                });
                navEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },

    /*gotoList : function (component, event, helper) {
    var action = component.get("c.getListViews");
    action.setCallback(this, function(response){
        var state = response.getState();
        if (state === "SUCCESS") {
            var listviews = response.getReturnValue();
            var navEvent = $A.get("e.force:navigateToList");
            navEvent.setParams({
                "listViewId": listviews.Id,
                "listViewName": null,
                "scope": "buildertek__Schedule__c"
            });
            navEvent.fire();
        }
    });
    $A.enqueueAction(action);
},*/

    handleOnError : function(component, event, helper) {
        console.log('===handleOnError===');
        var record = event.getParams().response;
        console.log({record});
        console.log(event.getParams());
        var errors = event.getParams();
        console.log("response", JSON.stringify(errors));

        //alert(record.Id);
    },

    radioGroup : function(component, event, helper) {
        console.log('===radioGroup===');
        var radioGrpValue = component.get("v.masterItem.Id");
        console.log('radioGrpValue',radioGrpValue);
    },


    handleClose : function(component, event, helper) {
        console.log('===handleClose===');
        // Close the action panel
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        // alert('cancel function called');
        dismissActionPanel.fire();


    },
    saveSelectedPO : function (component, event, helper) {
        console.log('===saveSelectedPO===');
        //  alert("MasterId--->"+event.currentTarget.id);
        component.set("v.selectedMasterId",event.currentTarget.id);
        var action = component.get("c.getScheduleItemList");
        action.setParams({
            masterId : component.get("v.selectedMasterId")
        })
        action.setCallback(this, function(response){
            var ScheduleItems = response.getReturnValue();
            // alert('ScheduleItems--->'+JSON.stringify(ScheduleItems));
            component.set("v.scheduleLineItems", ScheduleItems);
        });
        $A.enqueueAction(action);
    },

    onSaveandNew : function(component, event, helper) {
        console.log('===onSaveandNew===');
        //helper.savefunc(component, event, helper);
        component.set('v.isLoading', true);
        /*event.preventDefault(); // Prevent default submit
        var fields = event.getParam("listOfFields");
        if(!fields){
        	var fieldsFromForm = JSON.parse(JSON.stringify(component.get("v.listOfFields")));
            fields['buildertek__Description__c'] = fieldsFromForm
        }*/
        component.set("v.isSaveAndNew",true);
        //component.find('recordEditForm').submit(fields); // Submit form
        // $A.get('e.force:refreshView').fire();

    },

})