({
    doInit : function(component, event, helper) {
        helper.getRecordDetails(component, event, helper);
    },
    Send : function(component, event, helper) {
        
        helper.Sendmail(component, event, helper);
    },
    Cancel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();  
       
    },
   
})