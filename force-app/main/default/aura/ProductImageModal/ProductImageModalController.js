({
    doInit: function (component, event, helper) {
        component.set("v.isSpinner",true);
        helper.getProductImages(component, event, helper);
    }
})