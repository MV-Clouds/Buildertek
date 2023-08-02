({
    doInit: function (component, event, helper) {

        var action = component.get("c.getFieldSet");
        action.setParams({
            objectName: 'buildertek__Meeting__c',
            fieldSetName: 'buildertek__MeetingFields'
        });
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                var listOfFields0 = JSON.parse(response.getReturnValue());
                console.log(listOfFields0);
                component.set("v.listOfFields0", listOfFields0);
            }
        });
        $A.enqueueAction(action);
    },

    closeModel: function (component, event, helper) {
        
        $A.get('e.force:refreshView').fire();
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/lightning/o/buildertek__Meeting__c/list?filterName=Recent"
        });
        urlEvent.fire();


        $A.get("e.force:closeQuickAction").fire();
        window.setTimeout(
            $A.getCallback(function () {
                $A.get('e.force:refreshView').fire();
            }), 1000
        );
    },

    handleSubmit: function (component, event, helper) {
        component.set("v.isDisabled", true);
        debugger;
        if (component.get("v.subject") != undefined && component.get("v.subject") != null && component.get("v.subject") != "" && component.get("v.subject") != " " && component.get("v.startDate") != undefined && component.get("v.startDate") != null && component.get("v.startDate") != "" && component.get("v.startDate") != " ") {
            event.preventDefault(); // Prevent default submit
            //var fields = event.getParam("listOfFields0");
            var fields = event.getParam("fields");
            component.find('recordViewForm').submit(fields); // Submit form
        }
        else {
            component.set("v.isDisabled", false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'Error',
                message: 'Please fill the required fields.',
                duration: ' 5000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
        }
    },

    saveAndNew: function (component, event, helper) {
        debugger;
        if (component.get("v.subject") != undefined && component.get("v.subject") != null && component.get("v.subject") != "" && component.get("v.subject") != " " && component.get("v.startDate") != undefined && component.get("v.startDate") != null && component.get("v.startDate") != "" && component.get("v.startDate") != " ") {
            event.preventDefault(); // Prevent default submit
            var fields = event.getParam("listOfFields0");
            component.find('recordViewForm').submit(fields); // Submit form
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'Success',
                message: 'Meeting created successfully.',
                duration: ' 5000',
                key: 'info_alt',
                type: 'success',
                mode: 'pester'
            });
            toastEvent.fire();
            $A.get('e.force:refreshView').fire();
        }
        else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'Error',
                message: 'Please fill the required fields.',
                duration: ' 5000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
        }
    },

    onRecordSuccess: function (component, event, helper) {
        var payload = event.getParams().response;
        var expenseId = (payload.id).replace('"', '').replace('"', '');
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function (response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({
                tabId: focusedTabId
            });
        }).catch(function (error) {
            console.log('Error', JSON.stringify(error));
        });
        $A.get('e.force:refreshView').fire();
        setTimeout(function () {
            component.set('v.isLoading', false);
            var url = location.href;
            var baseURL = url.substring(0, url.indexOf('/', 14));
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                mode: 'sticky',
                message: 'Meeting created successfully',
                messageTemplate: "Meeting created successfully.",
                messageTemplateData: [{
                    url: baseURL + '/lightning/r/buildertek__Meeting__c/' + escape(payload.id) + '/view',
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

    handleError: function (component, event, helper) {
        var error = event.getParam("error");
        console.error(JSON.stringify(error));

    }


})