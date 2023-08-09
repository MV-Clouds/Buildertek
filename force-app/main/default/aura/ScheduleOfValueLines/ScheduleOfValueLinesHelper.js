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
                    component.set("v.isImpVndSOV",false);
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
    
    
    
	 fetchvendorSOVonType : function(component,event,helper,sovId,filtercondition) {
         
        //alert(component.get("v.RejectedToggle")); 
        //alert(component.get("v.ApprovedToggle")); 
        //alert(component.get("v.PendingToggle")); 
        /*if(component.get("v.PendingToggle") == false && component.get("v.ApprovedToggle") == false && component.get("v.RejectedToggle") == false && component.get("v.VendorSubmittedToggle") == false){
            $A.get('e.force:refreshView').fire();
            
        }*/
        
        
        var action = component.get("c.getSOVlineslistbyType");
        action.setParams({
            SOVId: sovId,
            "filter" : filtercondition
        });
        action.setCallback(this, function (response) {
            var  result = response.getReturnValue();
            debugger;
            if (response.getState() == 'SUCCESS') {
                 result.sort((a, b) => {
                                return a.Name - b.Name;
                  });
                var result = response.getReturnValue();
                
                var aggresult = 0;
                
                for(var i=0;i<result.length;i++){
                    result[i].CurrencyIsoCode = component.get("v.ISOCode");
                 if(component.get("v.Iscommunity") == true){
                     
                     
                    if(result[i].buildertek__Vendor_Scheduled_Value__c){
                        //alert(result[i].buildertek__Scheduled_Value__c);
                        aggresult += Number(result[i].buildertek__Vendor_Scheduled_Value__c); 
                    }
                 }else{
                     if(result[i].buildertek__Scheduled_Value__c){
                        //alert(result[i].buildertek__Scheduled_Value__c);
                        aggresult += Number(result[i].buildertek__Scheduled_Value__c); 
                    }
                 }
                }
                //alert(aggresult);
                
                component.set("v.aggvalue",aggresult);
                component.set("v.sovTotal",aggresult);
                
                component.set("v.continuationSheetLines",result);
                
                //alert(result.length);
            } 
            else {
               console.log('Error');
            }
        });
        $A.enqueueAction(action);
        
    },
    
    
    deleteSelected : function(component,event,sovIds){
        
        var action = component.get("c.delSlctRec");
        action.setParams({
            "slctRec": sovIds,
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state =  response.getState();
            if(state == "SUCCESS")
            {
                component.set("v.account",response.getReturnValue());
                 $A.get('e.force:refreshView').fire();
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'SOV Lines are deleted successfully',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'Success',
                    mode: 'dismissible'
                });
                toastEvent.fire();
            }else if (state=="ERROR") {
                console.log(action.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
        
    },
    
    /*  fetchSOVs: function (component, event, helper){
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
                   component.set("v.isImpVndSOV",false);
                  
                }else{
                    component.set("v.isActive", true);
                    console.log("resultData"+JSON.stringify(resultData))
                    component.set("v.sovsList", resultData); 
                
                }
                
            }
        });  
        $A.enqueueAction(action);
    }, */
    
})