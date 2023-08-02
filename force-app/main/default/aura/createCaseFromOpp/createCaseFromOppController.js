({
    doInit : function(component, event, helper) {
        var self = this;
        //helper.getCaseInfo(component, event);
        helper.getOppInfo(component, event);
       //helper.getContacts(component, event,helper);
        helper.getCustomerSites(component, event);
        helper.getAccts(component, event);
    },
     getContacts : function(component, event, helper) {
         var selectedAccount = event.getSource().get("v.value");
         console.log('selectedAccount===',selectedAccount);
         if(!selectedAccount){
            selectedAccount= component.get("v.opportunityObj.AccountId");
         }
        helper.getContacts(component, event,selectedAccount);
    },
    handleSave : function(component, event, helper) {
        helper.createCase(component, event,helper);
    },
    handleCancel : function(component, event, helper) {
        window.open('/lightning/r/Opportunity/'+component.get("v.recordId")+'/view','_self');
    },
    handleLookFieldSelEvt: function(component, event, helper) {
        helper.handleLookUpFldEvt(component, event);
    },
    // function automatic called by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for displaying loading spinner 
        component.set("v.spinner", true); 
    },
    // function automatic called by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hiding loading spinner    
        component.set("v.spinner", false);
    }
})