({
	getProductsForNewFSE : function(component,helper,redId) {
		
       
        var action = component.get("c.getProducts");
        
        action.setCallback(this,function(response){
            
            var state = response.getState();
            if(state === "SUCCESS")
            {
                component.set("v.getProducts", response.getReturnValue());
                console.log('Products from server ',response.getReturnValue());
            }
            else if(state === "ERROR")
            {
                console.log('Error from Server');
            }
        });
        $A.enqueueAction(action);
	},
    getServiceRecource : function(component,helper,redId)
    {
        console.log('Ser Rec ID ',redId);
        var action = component.get("c.getServiceRecource");
        action.setParams({srId : redId});
        action.setCallback(this,function(response){
            
            var state = response.getState();
            if(state === "SUCCESS")
            {
                var locationId = response.getReturnValue().LocationId;
                if (locationId == null || locationId == "undefined"){
                    console.log('locationId:' +locationId);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Please check if Location is set on Service Resource."
                    });
                    toastEvent.fire();
                    helper.handleCancelEvent(component,event,helper);
                }else{
					component.set("v.getServiceRes", response.getReturnValue());
                }
                  

            }
            else if(state === "ERROR")
            {
                console.log('Error from Server');
                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Please check if Service Resource is Active."
                    });
                    toastEvent.fire();
                    helper.handleCancelEvent(component,event,helper);
            }
        });
        $A.enqueueAction(action);
    },
    
    getServiceRecourceSelfOrOther : function(component,helper,redId)
    {
        console.log('Ser Rec ID ',redId);
        var action1 = component.get("c.getServiceRecourceSelfOrOther");
        action1.setParams({srId : redId});
        action1.setCallback(this,function(response){
            
            var state = response.getState();
            if(state === "SUCCESS")
            {
                component.set("v.selfNew",response.getReturnValue());
 				console.log('Self or Other ',response.getReturnValue());
            }
            else if(state === "ERROR")
            {
                console.log('Error from Server');
            }
        });
        $A.enqueueAction(action1);
    },
    handleCancelEvent : function(component,event,helper)
    {
        var recId = component.get("v.recordId");
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/"+recId
        });
        urlEvent.fire();
    }
    
})