({
	 createAccount : function(component, event, helper) {
        var newAcc = component.get("v.FolderMapping");
        var action = component.get("c.saveAccount");
        
        action.setParams({ 
            "acc": JSON.parse(JSON.stringify(newAcc))
        });
        
        action.setCallback(this, function(res){
            console.log(res)
        });
        
        $A.enqueueAction(action)
    }
})