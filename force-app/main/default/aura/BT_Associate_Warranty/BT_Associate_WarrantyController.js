({
	doInit: function (component, event, helper) {
        component.set("v.parentRecordId", component.get("v.recordId"));
        component.set("v.isWarranty",true);
        helper.getpreviousWarrantyRec(component, event, helper);
	},
    optionSelected : function (component, event, helper) {
        var recordName = event.target.getAttribute("value");
        component.set("v.value",recordName);
    },
    CloseModel : function (component, event, helper) {
        component.set("v.isWarranty",false);
         var dismissActionPanel = $A.get("e.force:closeQuickAction");
                   dismissActionPanel.fire();
    },
    SaveModel : function (component, event, helper) {
        var newwarrantyId = component.get("v.parentRecordId"); 
        var wList = component.get("v.warrantyList");
        for(var i=0; i < wList.length; i++){
            if(wList[i].selectedWarranty == true){
                component.set("v.value",wList[i].WarrantyRec.Id);
                component.set("v.lagValue",wList[i].LagValue);
            }
        }
        var selectedwarrantyId = component.get("v.value");
        
      //  helper.savehelper(component, event);
        var action = component.get("c.newWarranty");
        var lagvalue =  component.get("v.lagValue");
       // alert('lagvalue'+lagvalue);
            action.setParams({
                warrantyId: newwarrantyId,
                selectedwarrantyId : selectedwarrantyId,
                lagvalue : lagvalue
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    var payload = event.getParams().response;
                    var url = location.href;
                    var baseURL = url.substring(0, url.indexOf('/', 14));
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'sticky',
                        message: 'Warranty Updated successfully',
                        messageTemplate: "Warranty Updated successfully.",
                        messageTemplateData: [{
                            url: baseURL + '/lightning/r/buildertek__Warranty__c/' + selectedwarrantyId + '/view',
                           // label: payload.name,
                        }],
                        type: 'success',
                        duration: '10000',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": selectedwarrantyId,
                        "slideDevName": "related"
                    });
            navEvt.fire();
                    window.setTimeout(
            $A.getCallback(function () {
                $A.get('e.force:refreshView').fire();
            }), 1000
        );
                  //  var dismissActionPanel = $A.get("e.force:closeQuickAction");
                  // dismissActionPanel.fire();
                }
                
            });
            $A.enqueueAction(action); 
    },
})