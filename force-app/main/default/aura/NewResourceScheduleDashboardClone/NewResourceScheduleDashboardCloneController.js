({
	doInit : function(component, event, helper) {
        
		$A.createComponent(
            'c:NewResourceScheduledashboard',{},
            function(newCmp, status, errorMessage){
                if (status === "SUCCESS") {
                    var body = component.get("v.body");
                    body.push(newCmp);
                    component.set("v.body", body);
                    //alert(component.find('selfReportComponent'));
                    //var dynamicComponentEvent = component.getEvent("dynamicComponentEvent");
                    //dynamicComponentEvent.fire();
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                }
                else if (status === "ERROR") {
                    if(component.get('v.displayErrorMsg')){
                        let errorMessage = component.get('v.displayErrorMsg');
                        //helper.displayError(errorMessage, component);
                        $A.get("e.force:closeQuickAction").fire();
                        console.log("Error: " + errorMessage);
                    }else{
                        console.log("Error: " + errorMessage);
                    }
                    
                }
            }
        );
	}
})