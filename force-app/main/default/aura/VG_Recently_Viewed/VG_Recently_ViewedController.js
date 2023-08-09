({
  doInit: function(component, event, helper) {
    helper.getRecentlyViewedList(component,helper);
    },
    goToURL : function(component, event, helper) {
    
       var curItem = event.currentTarget;
      
        var url = curItem.dataset.url;
      
        var navEvt = $A.get("e.force:navigateToURL");
        navEvt.setParams({
           "url": url
         });
       navEvt.fire();
        
  }
})