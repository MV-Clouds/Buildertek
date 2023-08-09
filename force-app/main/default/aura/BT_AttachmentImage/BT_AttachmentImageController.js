({
    doInit : function(component, event, helper) {
        var action = component.get("c.getAttachmentURL");
        action.setParams({
            imageUrl: component.get('v.imageUrl')
        });
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                component.set("v.fieldSet", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }
})