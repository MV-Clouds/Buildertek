({
    doInit : function(component, event, helper) {
        //component.set("v.isOpen", true);
        var action = component.get("c.returnMessage"); 
        action.setParams({
            "oerRecId" : component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            var output = response.getReturnValue();
            console.log('output :'+output);
            
            var state = response.getState();
            if (state == "SUCCESS") {
                if(output > 0 ){
                    var message = "Packaging and Shipping Instruction form has been requested already. Do you want to request it again?";
                    component.set("v.message", message);
                }else{
                    var message = "A new Packaging and Shipping Instruction form will be created and notified to PM. Please click on continue to proceed.";
                    component.set("v.message", message);
                }
                
            }else if (state === "INCOMPLETE") {
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
   closeModel: function(component, event, helper) {
       $A.get("e.force:closeQuickAction").fire() 
    },
    
    createShipForm : function(component, event, helper){
        var action = component.get("c.createShipmentForm"); 
        action.setParams({
            "oerRecId" : component.get("v.recordId")
        });
        /*var oerRecId = component.get("v.recordId");
        $A.get("e.force:closeQuickAction").fire();
        var createRecordEvent = $A.get('e.force:createRecord');
       
            createRecordEvent.setParams({
                'entityApiName': 'Packaging_and_Shipping_Instruction__c',
                'defaultFieldValues': {
                    'Order_Entry_Release__c' : oerRecId,
                    
                }
            });
            createRecordEvent.fire();
        */
        action.setCallback(this, function(response) {
            var output = response.getReturnValue();
            console.log('output :'+output);
            
            var state = response.getState();
            if (state == "SUCCESS") {
            var toastEvent = $A.get("e.force:showToast");
  		 	 toastEvent.setParams({
        	"title": "Success!",
                 type: 'success',
                 mode: 'pester',
        	"message": "Packaging and Shipping Instruction form created and submitted successfully to PM."
   		 });
   		 toastEvent.fire();
                
      $A.get("e.force:closeQuickAction").fire();
               
            }else if (state === "INCOMPLETE") {
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
        
     }
})