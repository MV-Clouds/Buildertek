({
    doInit : function(component, event, helper) {      
        helper.onLoad(component, event, helper);
    },
    verifyData: function(component, event, helper) {
        component.set("v.disableButton",true);
        component.set("v.showMessage",false);
        helper.handleSubmit(component, event, helper);
    },
    handleSuccess: function(component, event, helper) {
        helper.redirectToQLIEditor(component, event, helper);        
    },
        
    navigateToDetailPage : function(component, event, helper) {
        helper.navigateToDetailPage(component, event, helper); 
    },
})