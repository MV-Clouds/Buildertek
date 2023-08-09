({
    doInit : function(component, event, helper) {
        var qid= component.get("v.recordId");        
        var action = component.get("c.getQuote");
        action.setParams
        ({ 
            quoteId : component.get("v.recordId")
            //Passing parameter
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.quote", response.getReturnValue());
                console.log(response.getReturnValue());
            }
        });
        $A.enqueueAction(action); 
    },
    closeModel : function(component, event, helper){
	    $A.get("e.force:closeQuickAction").fire();    
	},
    handleClick :function(component, event, helper){
      
        component.set("v.Spinner", true);
        var qid= component.get("v.recordId");      
        var vnum=component.get("v.versionValue");
        var action = component.get("c.cloneQuote");
        if(vnum!=null){
        action.setParams
        ({ 
            quoteId : component.get("v.recordId"),
            versionValue :component.get("v.versionValue"),
            reason :component.get("v.reason")
            //Passing parameter
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result=response.getReturnValue();
            if (state === "SUCCESS") {
                component.set("v.Spinner", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'Quote Cloned Successfully',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();                 
                window.location.href ='/lightning/r/buildertek__Quote__c/'+result+'/view';
               
            }
            else{
                component.set("v.Spinner", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message:'Fail to Clone Quote',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
            }
            
        });
        $A.enqueueAction(action); 
        }
        else{
         
                  component.set("v.Spinner", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message:'Please fill the required field.',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
            }
             
            
        
      
    },
    
})