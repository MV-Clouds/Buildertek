({
    init : function(component, event, helper) {
        helper.doinit(component, event);
    },
    handleClick : function(component, event, helper) {
        component.set("v.Spinner", true);
        helper.CreatePr(component, event);        
    },
    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event) {
        // make Spinner attribute true for display loading spinner 
        //component.set("v.Spinner", true); 
    },
    
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event){
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.Spinner", false);
    },
    cancel: function(component, event,helper) {
        helper.nevigateSobject(component, event,helper);
    }
})