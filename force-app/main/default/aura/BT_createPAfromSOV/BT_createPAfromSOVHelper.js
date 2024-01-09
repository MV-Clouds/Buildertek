({
    showToastMessageHelper : function(component, event, helper, Titel, Message, Type, Duration ) {
        var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: Titel,
                message: Message,
                type: Type,
            }, Duration);
            toastEvent.fire();
    }
})
