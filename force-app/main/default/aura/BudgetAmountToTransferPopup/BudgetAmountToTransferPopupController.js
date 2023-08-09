({
    doInit: function (component, event, helper) {

    },

    closeModel: function (component, event, helper) {
        component.find("overlayLib").notifyClose();
    },
})