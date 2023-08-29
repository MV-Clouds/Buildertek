({
    doInit : function(component, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
       helper.ChildObjectNameHelper(component, event, helper);
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