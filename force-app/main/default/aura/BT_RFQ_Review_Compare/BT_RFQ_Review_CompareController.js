({
    doInit: function (component, event, helper) {},
    scriptsLoaded: function (component, event, helper) {},
    awardSelectedVendor: function (component, event, helper) {
        component.set('v.vendorName', '');
        component.set('v.vendorId', '');
        component.set('v.isAwardedClick', true);
        component.set('v.vendorName', event.getSource().get("v.alternativeText"));
        component.set('v.vendorId', event.getSource().get("v.name"));
    },
    
    cancelAward: function (component, event, helper) {
        component.set('v.isAwardedClick', false);
    },
})