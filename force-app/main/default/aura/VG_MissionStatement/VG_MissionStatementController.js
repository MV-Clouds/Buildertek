({
    doInit: function(component, event, helper) {
        var action = component.get("c.missionStatement");
        
        action.setCallback(this, function(data) {
            component.set("v.MissionStatementmdt", data.getReturnValue());
        });
        $A.enqueueAction(action);
    }
})