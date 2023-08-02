({
    handleShowModal: function(component, evt, helper) {
        var modalBody;
        var rid = component.get("v.recordId");
        console.log("--rid--"+rid);
        $A.createComponent("c:issuesCreateAndUpdate", {currentRec:rid},
                           function(content, status) {
                               if (status === "SUCCESS") {
                                   modalBody = content;
                                   component.find('overlayLib').showCustomModal({
                                       header: "Application Confirmation",
                                       body: modalBody,
                                       showCloseButton: true,
                                       cssClass: "mymodal",
                                       closeCallback: function() {
                                           //alert('You closed the alert!');
                                       }
                                   })
                               }
                           });
    },
    doInit : function(component, event, helper){
        var recId = component.get("v.recordId");
        var action = component.get("c.isclosedcase");
        // set the parameters to method 
        action.setParams({ workorderid : recId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("From server: "+response.getReturnValue());
                component.set("v.isclosed", response.getReturnValue());
                
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
        
    },
    navigateToCmp : function(component, event, helper) {
        var recdid = component.get("v.recordId");
        console.log("--recdid in navigateToCmp--"+recdid);
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:issuesCreateAndUpdate",
            componentAttributes: {
                recordId:recdid
            }
        });
        evt.fire();
    } 
})