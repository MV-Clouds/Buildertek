({
    doInit: function (component, event, helper) {
    
        var value = helper.getParameterByName(component, event, 'inContextOfRef');
        console.log('value', value);
        var context = '';
        var parentRecordId = '';
        // component.set("v.parentRecordId", parentRecordId);
        if (value != null) {
            context = JSON.parse(window.atob(value));
            parentRecordId = context.attributes.recordId;
            component.set("v.parentRecordId", parentRecordId);
        } else {
            var relatedList = window.location.pathname;
            var stringList = relatedList.split("/");
            parentRecordId = stringList[4];
            if (parentRecordId == 'related') {
                var stringList = relatedList.split("/");
                parentRecordId = stringList[3];
            }

            component.set("v.parentRecordId", parentRecordId);
        }
        helper.getFields(component, event, helper);
    },

   closeModel: function (component, event, helper) {
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
        $A.get('e.force:refreshView').fire();
        window.setTimeout(
            $A.getCallback(function () {
                $A.get('e.force:refreshView').fire();
            }), 1000*/
        
        var action = component.get("c.getListViews");
    action.setCallback(this, function(response){
        var state = response.getState();
        if (state === "SUCCESS") {
            var listviews = response.getReturnValue();
            var navEvent = $A.get("e.force:navigateToList");
            navEvent.setParams({
                "listViewId": listviews.Id,
                "listViewName": null,
                "scope": "buildertek__Budget__c"
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
                "scope": "buildertek__Budget__c"
            });
            navEvent.fire();
        }
    });
    $A.enqueueAction(action);
},*/


    handleSubmit: function (component, event, helper) {
        component.set('v.isLoading', true);
        var fields = event.getParam("fields");
        event.preventDefault(); // Prevent default submit
        component.find('recordViewForm').submit(fields); // Submit form
    },

    onRecordSuccess: function (component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function (response) {
            $A.get('e.force:refreshView').fire();
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({
                tabId: focusedTabId
            });
        }).catch(function (error) {
            console.log('Error', JSON.stringify(error));
        });
        setTimeout(function () {
            component.set('v.isLoading', false);
            var payload = event.getParams().response;
            var url = location.href;
            var baseURL = url.substring(0, url.indexOf('/', 14));
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                mode: 'sticky',
                message: 'Budget created successfully',
                messageTemplate: "Budget created successfully.",
                messageTemplateData: [{
                    url: baseURL + '/lightning/r/buildertek__Budget__c/' + escape(payload.id) + '/view',
                    label: payload.name,
                }],
                type: 'success',
                duration: '10000',
                mode: 'dismissible'
            });
            toastEvent.fire();

            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": payload.id,
                "slideDevName": "related"
            });
            $A.get('e.force:refreshView').fire();
            navEvt.fire();
        }, 200);
    },

    saveAndNew: function (component, event, helper) {
        component.set('v.isLoading', true);
        event.preventDefault(); // Prevent default submit
        var fields = event.getParam("listOfFields");
        component.find('recordViewForm').submit(fields); // Submit form
        $A.get('e.force:refreshView').fire();
    },
    // BUIL-3329 Modified By: Poojan Gabani Date: 12-06-2023 (07:15 PM)
    handleError: function (component , event , helper) {
        console.log("Error" , JSON.stringify(Error));
        toastEvent.setParams({
            mode: 'sticky',
            message: 'Error',
            messageTemplate: "Something wrong.",
            messageTemplateData: [{
                url: baseURL + '/lightning/r/buildertek__Budget__c/' + escape(payload.id) + '/view',
                label: payload.name,
            }],
            type: 'error',
            duration: '10000',
            mode: 'dismissible'
        });
        toastEvent.fire();
    }
})