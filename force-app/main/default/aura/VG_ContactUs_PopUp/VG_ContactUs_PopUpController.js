({
     doInit: function(component, event, helper) {
        var action = component.get("c.contactus");
       
        action.setCallback(this, function(data) {
            component.set("v.Contactus", data.getReturnValue());
        });
        $A.enqueueAction(action);
    },
   openModel: function(component, event, helper) {
      // for Display Model,set the "isOpen" attribute to "true"
      component.set("v.isOpen", true);
   },
 
   closeModel: function(component, event, helper) {
      // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
      component.set("v.isOpen", false);
        var navEvt = $A.get("e.force:navigateToURL");        
        navEvt.setParams({
            "url": "/human-resource"
        });
        navEvt.fire();
   },
 
   
})