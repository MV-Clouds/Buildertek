({
    doInit : function(component, event, helper) {
        var rid = component.get("v.recordId");		
        var action = component.get("c.getRelatedFiles");
        action.setParams({parentId : rid });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var a = response.getReturnValue();
                console.log(a);
                component.set("v.files",a);
            }
        });
        $A.enqueueAction(action);
    },
    
    navigateToFile: function (component, event, helper) {
        //alert('Hi');
        // var recId = event.target.getAttribute("data-recId");
        var recId =event.currentTarget.id;
        
        console.log('navigator.appName>>'+navigator.userAgent);
        var isEdge=false;
        if(navigator.userAgent.indexOf("Edge")!= -1){
            isEdge=true;
        }
        console.log('isEdge>>>'+isEdge);
        if(isEdge==false){
            console.log('isEdge111111>>>'+isEdge);
            $A.get('e.lightning:openFiles').fire({
                recordIds: [recId]
            });
        }else{
            var navLink = component.find("navLink");
            var pageRef = {
                type: 'standard__recordPage',
                attributes: {
                    actionName: 'view',
                    recordId :recId  // change record id. 
                },
            };
            navLink.navigate(pageRef, true);
        }
    }
})