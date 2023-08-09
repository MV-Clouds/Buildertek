({
    chooseItem : function(component, event, helper) {
        var navigateToObject = component.get("v.navigateToObject");
      
        var curUrl = window.location.pathname;
        
        
        console.log('@@ curUrl '+curUrl);
        var record = component.get('v.record');
        console.log('@@ record '+record[0]);
         var url = '/profile/'+record[0];
        console.log('@@ url '+url);
        
        var action = component.get("c.saveRecentlyViewed");
        action.setParams({
            "recordId": record[0],
            "url": url,
            "type": 'User',
            "title": 'Profile'
        });
        action.setCallback(this, function(data) { 
          
        });
        $A.enqueueAction(action);
        
        if(navigateToObject){
            console.log('@@ navigateToObject '+navigateToObject);
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
              "recordId": record[0]
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