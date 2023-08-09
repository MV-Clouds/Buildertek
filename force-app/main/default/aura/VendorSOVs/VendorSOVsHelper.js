({
    
    getcurr : function (component, event, helper) {
        var action = component.get("c.getcurrency");
        action.setCallback(this, function (response) {
            var state = response.getState();
             if (state === "SUCCESS") {
                   component.set("v.currencycode",response.getReturnValue());
			} 
		});
		$A.enqueueAction(action);		
    },
    
    
    fetchSOVs: function (component, event, helper){
        debugger;
        var action = component.get("c.getSOVs"); 
        action.setParams({
            "recordId": component.get("v.recordId")
            
        });        
        action.setCallback(this, function (result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS") { 
                var resultData = result.getReturnValue();
                debugger;
                if(resultData == ""){
                    $A.get("e.force:closeQuickAction").fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : "Error!",
                        message : 'There are No Company Approved Vendor SOVs for this Project',
                        type: 'error',
                        duration: '1000',
                        key: 'info_alt',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                }else{
                    component.set("v.isActive", true);
                    console.log("resultData"+JSON.stringify(resultData))
                    component.set("v.sovsList", resultData); 
                }
                
                
            }
        });  
        $A.enqueueAction(action);
    },
    
    generateMasterSOV: function (component, event, helper){
        //alert(component.get("v.masterSOVId"));
        //alert(component.get("v.listOfSelectedSOVLineIds"));
        var sovlineslist = component.get("v.listOfSelectedSOVLineIds");
        var action = component.get("c.createMasterSOV1"); 
        action.setParams({
            "recId" : component.get("v.masterSOVId"),
            "sovlineids" : sovlineslist,
            "sovIds": component.get("v.listOfSelectedSOVIds")
        });        
        action.setCallback(this, function (result) {
            var state = result.getState();
            //alert(state);
            if (component.isValid() && state === "SUCCESS") {
                var resultData = result.getReturnValue();
                //alert(resultData);
                
            }
        });  
        $A.enqueueAction(action);
    },
    
    generateMasterSOVLines: function (component, event, newRecId, helper){
        var SOVIds=component.get("v.listOfSelectedSOVIds");
        // alert('SOVIds------------'+SOVIds);
        //alert('newRecId--------'+newRecId);
        var action = component.get("c.createSOVLines");
        action.setParams({
            selectedSOV : SOVIds,
            newSOV : component.get("v.recordId")
        })
        action.setCallback(this, function (response) {
            var fieldSetObj = response.getReturnValue();
            var state = response.getState();
            if (state === "SUCCESS") {
                //alert('sucess');
            }
            
            //component.set("v.rfiList",fieldSetObj);
        })
        $A.enqueueAction(action);
    },
    
    
    
})