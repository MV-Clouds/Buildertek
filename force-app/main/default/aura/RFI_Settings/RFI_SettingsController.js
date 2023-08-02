({
	doInit : function(component, event, helper) {
        //helper.getTemplates(component, event, helper);
		var action = component.get("c.getRFISettings");	
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS'){
                var result = response.getReturnValue();
                component.set("v.msaSettings", result);
            }   
        });
        $A.enqueueAction(action);
	},
    
    onCheck1: function(cmp, evt) {
         var checkCmp1 =cmp.find("checkbox").get("v.value");
         var checkCmp2 =cmp.find("checkbox1").get("v.value");
         if(checkCmp1){
           var temp =cmp.find("checkbox1").set("v.value", false);
        }
         
	},
    onCheck2: function(cmp, evt) {
         var checkCmp1 =cmp.find("checkbox").get("v.value");
         var checkCmp2 =cmp.find("checkbox1").get("v.value");
         if(checkCmp1){
           var temp =cmp.find("checkbox").set("v.value", false);
        }
         
	},
    
    edit : function(component, event, helper) {
        component.set("v.isEdit", true);
    },
   
    save : function(component, event, helper) {
    	var action = component.get("c.saveSettings");
        //alert( '&&'+action);
        action.setParams({
            msaSettings : component.get("v.msaSettings")   
        });
        action.setCallback(this, function(response){
            //alert(response.getState());
            if(response.getState() === 'SUCCESS'){
            	//component.set("v.isEdit", false);
                //$A.enqueueAction(component.get("c.doInit")); 
                component.set("v.ismessage", true);    
                setTimeout(() => {
                    //alert("hello");
                    component.set("v.ismessage", false);    
                }, 2000);
            }
                 
        });
        $A.enqueueAction(action);
    },
    
    cancel : function(component, event, helper) {
    	component.set("v.isEdit", false);    
    },
    
})