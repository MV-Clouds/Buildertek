({
	doInit : function(component, event, helper) {
        
        var pageRef = component.get("v.pageReference");
        var stateolds = pageRef.state; // state holds any query params
        var base64Context = stateolds.inContextOfRef;

        if (base64Context.startsWith("1\.")) {
            base64Context = base64Context.substring(2);
        }
        var addressableContext = JSON.parse(window.atob(base64Context));
        var recordId = addressableContext.attributes.recordId;
        var oerRecordId = component.get("v.recordId");
        var action = component.get("c.returnOERRecord"); 
       		 action.setParams({
           	 "oerRecId" : recordId
       		 });
        console.log(oerRecordId);
         action.setCallback(this, function(response) {
            var output = response.getReturnValue();
            console.log('output :'+output);
            
            var state = response.getState();
            if (state == "SUCCESS") {
                
		 var createRecordEvent = $A.get('e.force:createRecord');
       
            createRecordEvent.setParams({
                'entityApiName': 'Packaging_and_Shipping_Instruction__c',
                'defaultFieldValues': {
                    'Order_Entry_Release__c' : recordId,
                    'Deal_Desk_Analyst__c'   : output.Opportunity__r.Sales_Ops_Owner__c,
                    'Shipping_City__c'       : output.Shipping_City__c,
                    'Shipping_Country__c'    : output.Shipping_Country__c,
                    'Shipping_Name__c'       : output.Shipping_Name__c,
                    'Shipping_Street1__c'    : output.Shipping_Street_1__c,
                    'Shipping_Street2__c'    : output.Shipping_Street_2__c,
                    'Shipping_Street3__c'    : output.Shipping_Street_3__c,
                    'Shipping_State__c'      : output.Shipping_State_Province__c,
                    'Shipping_Zip__c'        : output.Shipping_Postal_Code__c,
                    'Is_Active__c'           : true,
                }
            });
            createRecordEvent.fire();
               
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