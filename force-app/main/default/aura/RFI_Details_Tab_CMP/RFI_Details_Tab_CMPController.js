({
	 doInit: function (component, event, helper) {
          var rfirecId = component.get("v.recordId");
         //alert(rfirecId);
          var action = component.get("c.getRFIRecord");
          //var action = component.get("c.getfields");
          action.setParams({
              recId:rfirecId
          });
          action.setCallback(this,function(response){
              var result = response.getReturnValue();
              //alert(JSON.stringify(result));
            if(response.getState() == "SUCCESS"){
             
                var state = response.getState();
                
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                   
                     component.set("v.rfiRecordDetails", result);
                   
                                  }
            }
        })
        $A.enqueueAction(action);
      },
     openRecordPage: function (component, event, helper) {
        //alert("test");
        var recordId = event.currentTarget.dataset.id;
         //alert(recordId);
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recordId
        });
        navEvt.fire();
    },
})