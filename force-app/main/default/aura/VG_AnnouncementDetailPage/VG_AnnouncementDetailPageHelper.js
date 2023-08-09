({
       getAnnouncement:function(component,Id) {
        // alert('--in getAnnouncement ---');
         var action=component.get("c.getAnnouncementlist");
          action.setParams({
      "annId": Id,
    });
       
       
        action.setCallback(this, function(actionResult) {
           // alert(actionResult.getReturnValue());
            component.set('v.Announcements', actionResult.getReturnValue());
            console.log( JSON.stringify(component.get("v.Announcements")));
         });
          $A.enqueueAction(action);

        
        }
    
})