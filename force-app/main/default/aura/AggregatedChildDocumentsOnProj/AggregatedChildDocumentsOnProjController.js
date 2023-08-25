({
    doInit : function(component, event, helper) {

        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
        
        var action=component.get('c.getChildObectName');
        action.setCallback(this, function (response) {
            console.log(response.getError());            
            let state=response.getState();
            if(state == 'SUCCESS'){
                let result=response.getReturnValue();
                console.log(result);

                var objectNameMap = [];

                for(var key in result){
                    if(key.includes('buildertek')){
                        objectNameMap.push({key: key, value: result[key]});
                    }
                }
                component.set('v.childObjectNameMap' ,objectNameMap );
                console.log(component.get('v.childObjectNameMap'));

            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "error",
                    "message": "Something went wrong."  
                });
                toastEvent.fire();
            }

            $A.get("e.c:BT_SpinnerEvent").setParams({
                "action": "HIDE"
            }).fire();
        });
        $A.enqueueAction(action);

    },
    openRecordPage: function(component, event, helper) {
        var recordId = event.currentTarget.dataset.recordId;
        var navService = component.find("navService");
        var pageReference = {
            type: "standard__recordPage",
            attributes: {
                recordId: recordId,
                actionName: "view"
            }
        };
        navService.navigate(pageReference);
    },
    handleObjectChange:function(component, event, helper) {
        // component.set("v.page", 1);
        // component.set("v.pageSize", 5);
        helper.loadRecords(component, event, helper );         
    },

    clickPrevious: function(component, event, helper) {
        if (component.get("v.page") > 1) {
            component.set("v.page", component.get("v.page") - 1);
            helper.loadRecords(component);
        }
      
    },
    clickNext: function(component, event, helper) {
        if (component.get("v.page") < component.get("v.totalPages")) {
             component.set("v.page", component.get("v.page") + 1);
             helper.loadRecords(component, event, helper);
        }

        
    }
})