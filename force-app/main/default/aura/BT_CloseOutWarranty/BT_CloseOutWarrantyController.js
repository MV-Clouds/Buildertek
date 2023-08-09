({
	doInit : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.updateWarranty");
		action.setParams({
			recordId: recordId
		});
        action.setCallback(this, function (response) {
			var state = response.getState();
             if (state === "SUCCESS") {
				var warrantyvalue = response.getReturnValue();
				component.set("v.warrantyvalue", warrantyvalue);
                if(warrantyvalue == 'success'){
                    component.set("v.iswarranty", true);
                }else if(warrantyvalue == 'isLocked'){
                    component.set("v.islocked", true);
                }else if(warrantyvalue == 'isnextwarrantyLocked'){
                    component.set("v.isnextwarrantyLocked", true);
                }else{
                   // var dismissActionPanel = $A.get("e.force:closeQuickAction");
                   // dismissActionPanel.fire();
                   var payload = event.getParams().response;
                    var url = location.href;
                    var baseURL = url.substring(0, url.indexOf('/', 14));
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'sticky',
                        message: 'Warranty Updated successfully',
                        messageTemplate: "Warranty Updated successfully.",
                        messageTemplateData: [{
                            url: baseURL + '/lightning/r/buildertek__Warranty__c/' + recordId + '/view',
                           // label: payload.name,
                        }],
                        type: 'success',
                        duration: '10000',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": recordId,
                        "slideDevName": "related"
                    });
            navEvt.fire();
                    window.setTimeout(
            $A.getCallback(function () {
                $A.get('e.force:refreshView').fire();
            }), 1000
        );
                }
                 
                 
			} else {
                
				console.log('Error');
			}
		});
		$A.enqueueAction(action);
    },
    closeModel: function (component, event, helper) {
        component.set("v.iswarranty", false);
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
        
    },
    updatewarranty : function (component, event, helper) { 
        var recordId = component.get("v.recordId");
        var action = component.get("c.getwarrantyItems");
		action.setParams({
			recordId: recordId
		});
        action.setCallback(this, function (response) {
            var state = response.getState();
             if (state === "SUCCESS") {
				component.set("v.iswarranty", false);
                 var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                mode: 'sticky',
                message: 'Warranty updated successfully',
                messageTemplate: "Warranty updated successfully.",
                type: 'success',
                duration: '10000',
                mode: 'dismissible'
            });
            toastEvent.fire();
                 var dismissActionPanel = $A.get("e.force:closeQuickAction");
                 dismissActionPanel.fire();
                 window.setTimeout(
            $A.getCallback(function () {
                $A.get('e.force:refreshView').fire();
            }), 1000
        );
			} else {
				console.log('Error');
			}
		});
		$A.enqueueAction(action);
    },
})