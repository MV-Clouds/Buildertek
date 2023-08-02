({
    doInit: function (component, event, helper) {
        var pageRef = component.get("v.pageReference");
        var state = pageRef.state;
        var base64Context = state.inContextOfRef;
        if (base64Context.startsWith("1\.")) {
            base64Context = base64Context.substring(2);
        }
        var addressableContext = JSON.parse(window.atob(base64Context));
        console.log('Record Id :' + addressableContext.attributes.recordId);
        component.set("v.projectrecordId", addressableContext.attributes.recordId);
       // helper.getAccountDetails(component, event, helper);
    },

    handleLoad: function (component, event, helper) {
        var projectrecordId = component.get('v.projectrecordId');
        if (projectrecordId != undefined) {
           helper.getAccountDetails(component, event, helper); 
        }
       // component.get('v.accountId', response.getReturnValue());
    },
    getprojectRec : function (component, event, helper) {
        var projectrecordId = component.get('v.projectrecordId');
        if (projectrecordId != undefined) {
           helper.getAccountDetails(component, event, helper); 
        }
    },

    handleSubmitClick: function (component, event, helper) {
        event.preventDefault();
        var eventFields = event.getParam("fields");
        component.find('recordViewForm').submit(eventFields);
    },

    onCancel: function (component, event, helper) {
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
        $A.get("e.force:closeQuickAction").fire();
        window.setTimeout(
            $A.getCallback(function () {
                $A.get('e.force:refreshView').fire();
            }), 1000
        );
       /* var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId"),
            "slideDevName": "related"
        });
        navEvt.fire(); */
    },
    handleSuccess: function (component, event, helper) {
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
        var payload = event.getParams().response;
        var expenseId = (payload.id).replace('"','').replace('"',''); 
        component.set("v.modalWindow", false);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Response!",
            "mode": 'sticky',
            "type": 'success',
            "message": 'Record has been created'
        });
        toastEvent.fire();

      //  $A.get('e.force:refreshView').fire();
        var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": payload.id,
                "slideDevName": "related"
            });
            navEvt.fire();
            
}, 200);
    }
})