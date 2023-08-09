({
    doInit : function(component, event, helper) {
        component.set("v.isLoading", true);
        var value = helper.getParameterByName(component, event, 'inContextOfRef');
        console.log('value-->>',{value});
        var context = '';
        var parentRecordId = '';
        component.set("v.parentRecordId", parentRecordId)
        var getFields = component.get("c.getFieldSet");
        getFields.setParams({
            objectName: 'buildertek__Walk_Through_List__c',
            fieldSetName: 'buildertek__New_WalkThrough_ComponentFields'
        });
        getFields.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                var listOfFields0 = JSON.parse(response.getReturnValue());
                console.log({listOfFields0});
                component.set("v.listOfFields0", listOfFields0);
                component.set("v.isLoading", false);
            }
        });
        $A.enqueueAction(getFields);
        if (value != null) {
            context = JSON.parse(window.atob(value));
            parentRecordId = context.attributes.recordId;
            component.set("v.parentRecordId", parentRecordId);
            console.log('parentRecordId---->>',{parentRecordId});
        } else {
            var relatedList = window.location.pathname;
            var stringList = relatedList.split("/");
            parentRecordId = stringList[4];
            if (parentRecordId == 'related') {
                var stringList = relatedList.split("/");
                parentRecordId = stringList[3];
            }
            component.set("v.parentRecordId", parentRecordId);
            console.log('parentRecordId-->>',{parentRecordId});
        }
        if(parentRecordId != null && parentRecordId != ''){
            var action = component.get("c.getobjectName");
            action.setParams({
                recordId: parentRecordId,
            });
            action.setCallback(this, function (response) {
                component.set("v.Spinner", false);
                if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                    var objName = response.getReturnValue();
                    if(objName == 'buildertek__Project__c'){
                        component.set("v.parentprojectRecordId", parentRecordId);
                    }
                } 
            });
            $A.enqueueAction(action);
        }
    },

    handleSubmit: function (component, event, helper) {
        component.set("v.isDisabled", true);
		component.set("v.isLoading", true);
        event.preventDefault(); // Prevent default submit
        var fields = event.getParam("fields");
        var allData = JSON.stringify(fields);

        var action = component.get("c.saveData");
        action.setParams({
            allData : allData
        });
        action.setCallback(this, function(response){
            if(response.getState() == 'SUCCESS') {            
                var result = response.getReturnValue();
                console.log({result});
                var saveNnew = component.get("v.isSaveNew");
                if(saveNnew){
                    $A.get('e.force:refreshView').fire();
                    component.set("v.isSaveNew", false);
                }else{
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": result,
                        "slideDevName": "Detail"
                    });
                    navEvt.fire();
                    var workspaceAPI = component.find("workspace");
                    workspaceAPI.getFocusedTabInfo().then(function(response) {
                        var focusedTabId = response.tabId;
                        workspaceAPI.closeTab({tabId: focusedTabId});
                    }
                    )
                    .catch(function(error) {
                        console.log(error);
                    }
                    );
                    $A.get("e.force:closeQuickAction").fire();

                }
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The record has been saved successfully.",
                    "type": "success"
                });
                toastEvent.fire();
                component.set("v.isDisabled", false);
                component.set("v.isLoading", false);
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Something went wrong. Please try again.",
                    "type": "error"
                });
                toastEvent.fire();
                component.set("v.isDisabled", false);
                component.set("v.isLoading", false);
            }
        });
        $A.enqueueAction(action);
    },

    handlesaveNnew : function(component, event, helper) {
        component.set("v.isSaveNew", true);
    },

    closeModel: function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });
        $A.get("e.force:closeQuickAction").fire();
        component.set("v.isOpen", false);
        window.setTimeout(
            $A.getCallback(function() {
                $A.get('e.force:refreshView').fire();
            }), 1000
        );
   },

})