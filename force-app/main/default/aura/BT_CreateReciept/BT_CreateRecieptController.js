({
    doInit: function (component, event, helper) {
        var value = helper.getParameterByName(component, event, 'inContextOfRef');
        var context = '';
        var parentRecordId = '';
        component.set("v.parentRecordId", parentRecordId);
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
            console.log('Parent Id::'+parentRecordId);
            component.set("v.parentRecordId", parentRecordId);
        }
         if(parentRecordId != null && parentRecordId != ''){
            var action = component.get("c.getproject");
            action.setParams({
                recordId: parentRecordId,
            });
            action.setCallback(this, function (response) {
                if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                    var objName = response.getReturnValue();
                    component.set("v.parentprojectRecordId", objName);
                } 
            });
            $A.enqueueAction(action);
         }
        helper.getFields(component, event, helper);
    },

    handleError: function (component, event, helper) {
        var error = event.getParam("error");
        console.error(JSON.stringify(error));
    },
    closeModel: function (component, event, helper) {
        component.set('v.isLoading', true);
        //var workspaceAPI = component.find("workspace");
        // workspaceAPI.getAllTabInfo().then(function (response) {
        //     console.log(response);
        //     debugger;
        // }).catch(function (error) {
        //     console.log(error);
        // });
        // workspaceAPI.getFocusedTabInfo().then(function (response) {
        //         var focusedTabId = response.tabId;
        //         workspaceAPI.closeTab({
        //             tabId: focusedTabId
        //         });
        //     })
        //     .catch(function (error) {
        //         console.log(error);
        //     });
        
        $A.get("e.force:closeQuickAction").fire();
        window.setTimeout(
            $A.getCallback(function () {
                $A.get('e.force:refreshView').fire();
            }), 1000
        );
    },

    handleSubmit: function (component, event, helper) {
        // debugger;
        component.set('v.isdisabled', true);
        component.set('v.isLoading', true);
        var fields = event.getParam("fields");
        event.preventDefault(); // Prevent default submit
        component.find('recordViewFormNew').submit(fields); // Submit form
        component.set("v.isSaveNew",false);
    },

    onRecordSuccess: function (component, event, helper) {
        debugger;
        if(component.get("v.isSaveNew")==true){
            component.set("v.displayCmp",false);
            setTimeout(function () {
                component.set("v.isSaveNew",false);
                component.set('v.isLoading', false);
                component.set("v.displayCmp",true);
            },1000);
            return false;
        }
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function (response) {
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
                message: 'Receipt created successfully',
                messageTemplate: "Receipt created successfully.",
                messageTemplateData: [{
                    url: baseURL + '/lightning/r/buildertek__Receipt__c/' + escape(payload.id) + '/view',
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
            navEvt.fire();
        }, 200);
    },

    saveAndNew: function (component, event, helper) {
        debugger;
        component.set('v.isLoading', true);
        event.preventDefault(); // Prevent default submit
        var fields = event.getParam("listOfFields");
        component.find('recordViewFormNew').submit(fields); // Submit form
        //$A.get('e.force:refreshView').fire();
        component.set("v.isSaveNew",true);
    }
})