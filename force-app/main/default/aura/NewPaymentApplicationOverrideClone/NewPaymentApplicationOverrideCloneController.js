({
    doInit: function (component, event, helper) {
        debugger;
        var action40 = component.get("c.getFieldSet");
        action40.setParams({
            objectName: 'buildertek__SOV_Payment_Application__c',
            fieldSetName: 'buildertek__ListOfFields'
        });
        action40.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                
                var listOfFields = JSON.parse(response.getReturnValue());
                // alert(listOfFields);
                console.log(listOfFields);
                component.set("v.listOfFields", listOfFields);
                
                  var action2 = component.get("c.GetadmindetailsforPA");
        action2.setCallback(this, function (result) {
            var state = result.getState();
            if (state === "SUCCESS") {
                var resultData = result.getReturnValue();
                if (resultData != null ) {
                    component.set("v.isadminpa", resultData);
                }
            }
        });  
        $A.enqueueAction(action2);
                //---------------------------------------------------------------------------------------------------------------     
                    var action41 = component.get("c.getFieldSet");
                action41.setParams({
                    objectName: 'buildertek__SOV_Payment_Application__c',
                    fieldSetName: 'buildertek__ListOfFields1'
                });
                action41.setCallback(this, function (response) {
                    if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                        
                        var listOfFields1 = JSON.parse(response.getReturnValue());
                        // alert(listOfFields);
                        console.log(listOfFields1);
                        component.set("v.listOfFields1", listOfFields1); 
                
                //---------------------------------------------------------------------------------------------------------------------
                
                     var action42 = component.get("c.getFieldSet");
                action42.setParams({
                    objectName: 'buildertek__SOV_Payment_Application__c',
                    fieldSetName: 'buildertek__ListOfFields2'
                });
                action42.setCallback(this, function (response) {
                    if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                        
                        var listOfFields2 = JSON.parse(response.getReturnValue());
                        // alert(listOfFields);
                        console.log(listOfFields2);
                        component.set("v.listOfFields2", listOfFields2);
                        
                    } else {
                        console.log('Error');
                    }
                });
                $A.enqueueAction(action42); 
                
                //--------------------------------------------------------------------------------------------------------------------------------------             
                           	} else {
				console.log('Error');
			}
		});
		$A.enqueueAction(action41); 
                
                //-----------------------------------------------------------------------------------------------------------------
            } else {
                console.log('Error');
            }
        });
        $A.enqueueAction(action40);
    },
    
    CloseScreen :  function (component, event, helper) {
        
        //   $A.get("e.force:closeQuickAction").fire();
        
        location.reload(); 
    },
    
    handleSubmit :  function (component, event, helper){
        
        alert('saved')
    }
    
    
})