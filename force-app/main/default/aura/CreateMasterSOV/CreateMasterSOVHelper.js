({
	fetchSOVs: function (component, event, helper){
        var action = component.get("c.getSOVs");         
        action.setCallback(this, function (result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS") {
                var resultData = result.getReturnValue();
                component.set("v.sovsList", resultData);                
            }
        });  
        $A.enqueueAction(action);
    },

    fetchSOVLines: function (component, event, helper){
        component.set("v.Spinner",true);
        var sovids  = component.get("v.listOfSelectedSOVIds");
        //alert(component.get("v.listOfSelectedSOVIds"));
        var action = component.get("c.getSOVLines"); 
        action.setParams({
            "sovids" : sovids            
        });        
        action.setCallback(this, function (result) {
            var state = result.getState();
            //alert(state);
            if (component.isValid() && state === "SUCCESS") {
                var resultData = result.getReturnValue();
                //alert(resultData);
                component.set("v.showSOVLines",true);
                component.set("v.showSOVs",false);
                component.set("v.sovlinesList", resultData);  
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            }
            component.set("v.Spinner",false);
        });  
        $A.enqueueAction(action);
    },


    generateMasterSOV: function (component, event, helper){
        //alert(component.get("v.masterSOVId"));
        //alert(component.get("v.listOfSelectedSOVLineIds"));
        var sovlineslist = component.get("v.listOfSelectedSOVLineIds");
        var action = component.get("c.createMasterSOV"); 
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

})