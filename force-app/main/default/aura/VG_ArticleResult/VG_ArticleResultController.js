({
    
    chooseItem : function(component, event, helper) {
        var navigateToObject = component.get("v.navigateToObject");
        var rec= component.get('v.record');
       
        
        if(navigateToObject){
            console.log('@@ navigateToObject '+navigateToObject);
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
              "recordId": rec.Id
            });
            navEvt.fire();

        } else {
			console.log('@@ navigateToObject '+navigateToObject);
            var chooseEvent = component.getEvent("choose");
            chooseEvent.setParams({"record": record});
            chooseEvent.fire();
        }

    }
    
})