({
	callDeleteRecord : function(component, event, helper) {		

        alert ('Current Record Id ' + currentRecordId + '. Now you could pass the current record Id to server to delete the record.' )
	},
    callUpdateRecord : function(component, event, helper) {
        
        var action = component.get("c.geteditRecord");
        action.setCallback(this, function(a){
            if (a.getState() === "SUCCESS") {
                alert(JSON.stringify(a.getReturnValue()[0]));
               // console.log(JSON.stringify(a.getReturnValue());
                //alert("getCheckListCofigRecords SUCCESS");
                
            }
        });
        $A.enqueueAction(action);
        
        var currentRecordId = component.get("v.view.Id");
        var currentRecord = component.get("v.view");
        alert ('Current Record Id ' + currentRecordId + ' and Current Record Object is ' + component.get('v.view') +'. Now you could pass the current object to a modal popup and show the fields accordingly to update the record.' )
	}
})