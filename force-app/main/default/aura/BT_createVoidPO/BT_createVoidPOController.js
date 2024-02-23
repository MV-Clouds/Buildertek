({
    doInit : function(component, event, helper) {
        console.log('Object API Name : ', component.get("v.sObjectName"));
    },

    handleCreateVoidPO: function(component, event, helper) {
        component.set("v.createVoidPoFlag", true);

        var action = component.get("c.createVoidPO");
        action.setParams({
            recordId : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var result = response.getReturnValue();
            if(result.status == 'success'){
                
                // var navEvt = $A.get("e.force:navigateToSObject");
                // navEvt.setParams({
                    //   "recordId": result.createRecordId,
                    //   "slideDevName": "detail"
                    // });
                    // navEvt.fire();
                    
                    var workspaceAPI = component.find("workspace");
                    workspaceAPI.getFocusedTabInfo().then((response) => {
                        workspaceAPI.openSubtab({
                            parentTabId: response.parentTabId,
                            url: `/lightning/r/${component.get("v.sObjectName")}/${result.createRecordId}/view`,
                        focus: true
                    });
                })
                helper.showToastHelper(component, event, helper,result.status , result.message , result.status , 3000 );
            }
            else if(result.status == 'error'){
                helper.showToastHelper(component, event, helper,result.status , result.message , result.status , 3000 )
            }
            $A.get("e.force:closeQuickAction").fire() ;
        });
        $A.enqueueAction(action);
    },

    handleCancel: function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire() 
    },
})
