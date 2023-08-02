({
	doInit : function(component, event, helper) {
		component.set("v.parentRecordId", component.get("v.recordId"));
       var parentRecordId = component.get("v.recordId");
         if(parentRecordId != null && parentRecordId != ''){
            var action = component.get("c.getobjectName");
            action.setParams({
                recordId: parentRecordId,
            });
            action.setCallback(this, function (response) {
                if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                    var objName = response.getReturnValue();
                    if(objName == 'buildertek__Project__c'){
                        var projectId = component.get("v.parentRecordId");
                        //component.find("projectlookupid").set("v.value", projectId);
                        var action4 = component.get("c.getRecordField");
                        action4.setParams({
                            recordId: projectId
                        });
                        action4.setCallback(this, function (response) {
                            if (response.getState() == 'SUCCESS') {
                                //if(response.getReturnValue() != 'Empty'){
                                 component.set("v.parentaccountRecordId", response.getReturnValue());
                               // }
                            }
                        });
                      $A.enqueueAction(action4);
                    }
                } 
            });
            $A.enqueueAction(action);
        }
        
        helper.getFields(component, event, helper);
	},
    closeModel: function (component, event, helper) {
      /* var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function (response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({
                tabId: focusedTabId
            });
        }).catch(function (error) {
            console.log('Error', JSON.stringify(error));
        });
        setTimeout(function () {
            //component.set('v.isLoading', false);
            var payload = component.get("v.recordId");
            var url = location.href;
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": payload,
                "slideDevName": "related"
            });
            navEvt.fire();
        }, 200);*/
        $A.get("e.force:closeQuickAction").fire();
    },
    handleLoad : function (component, event, helper) {
        var projectId = component.get("v.parentRecordId");
        component.find("projectlookupid").set("v.value", projectId);
      //  component.find("statusid").set("v.value", 'Open');
    },
    handleSubmit: function (component, event, helper) {
        component.set('v.isdisabled', true);
        event.preventDefault(); // stop form submission
        var eventFields = event.getParam("fields");
        eventFields["buildertek__Project__c"] = component.get("v.parentRecordId");
        component.set('v.isLoading', false);
        component.find('recordViewForm').submit(eventFields); // Submit form'
    },
    handleError: function(component, event, helper) {
        var errorMsg = event.getParam("detail");
    },

    handleSuccess: function (component, event, helper) {
        var payload = event.getParams().response;
        var eventId = (payload.id).replace('"','').replace('"',''); 
        component.set('v.newwarrantyId',eventId);
       // helper.updateDueDate(component, event, helper);
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
                message: 'Pricing Request created successfully',
                messageTemplate: "Pricing Request created successfully.",
                messageTemplateData: [{
                    url: baseURL + '/lightning/r/buildertek__Pricing_Request__c/' + escape(payload.id) + '/view',
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

})