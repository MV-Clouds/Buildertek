({
  getRecentlyViewedList: function(component,helper) {

    var action = component.get("c.retrieveRecentlyViewed"); 
          action.setParams({"maxRows":component.get("v.maxNoRows")});
           // alert(component.get("v.maxNoRows"));
            action.setCallback(this, function(response) {
                var state = response.getState();
                
				//console.log(' @@ data '+JSON.stringify(response.getReturnValue()));
               var recenlyViewedList = JSON.parse(response.getReturnValue());
            console.log(' @@ data '+JSON.stringify(recenlyViewedList));
              component.set("v.recentlyViewedList",recenlyViewedList) ;

            });
            
            $A.enqueueAction(action);

  }
})