({
    showToastHelper : function(component, event, helper, Title, Message, Type, Duration) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": Title,
            "type": Type,
            "message": Message,
            "duration" : Duration  
        });
        toastEvent.fire();
    }
})