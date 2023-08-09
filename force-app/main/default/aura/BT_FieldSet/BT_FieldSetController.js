({
    doInit : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        helper.onInit(component, event, helper);
    },
    fireRefreshView : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
        var inputModeBool = component.get("v.inputModeBool");
        component.set("v.inputModeBool", !inputModeBool); 
    },
    handleToggle : function(component, event, helper) {        
        var inputModeBool = component.get("v.inputModeBool");
        component.set("v.inputModeBool", !inputModeBool);
    }
})