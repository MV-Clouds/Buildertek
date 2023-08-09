({
    doInit: function (component, event, helper) {
       var action = component.get("c.getrfiRecord");
       var recordid=component.get("v.projRecordId");
        action.setParams({
            parentRecordId : component.get("v.recordId")
        })
        action.setCallback(this, function (response) {
            var fieldSetObj = response.getReturnValue();
           // component.set("v.rfiRec", fieldSetObj);
            if(fieldSetObj.buildertek__Status__c == 'Closed'){
              component.set("v.Isclosed",true);
               component.set("v.IsRFIclosed",false);
            }else{
                component.set("v.Isclosed",false);
               component.set("v.IsRFIclosed",true);
            }
        })
        $A.enqueueAction(action);
    },
	closeModel: function (component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get('v.recordId'),
            "slideDevName": "related"
        });
        navEvt.fire();
    },
    updateRFI : function (component, event, helper) {
        component.set("v.IsSpinner",true);
      var action = component.get("c.updaterfirec");
        action.setParams({
            projectId : component.get("v.recordId")
        })
        action.setCallback(this, function (response) {
            var fieldSetObj = response.getReturnValue();
           // component.set("v.parentprojectRecordId", fieldSetObj);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : "Success!",
                message : 'RFI updated successfully',
                type: 'success',
                duration: '10000',
                 key: 'info_alt',
                mode: 'pester'
            });
            toastEvent.fire();
            component.set("v.IsSpinner",false);
            location.reload();
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": component.get('v.recordId'),
                "slideDevName": "related"
            });
            navEvt.fire();
            $A.get('e.force:refreshView').fire();
        })
         $A.enqueueAction(action);
    },
})