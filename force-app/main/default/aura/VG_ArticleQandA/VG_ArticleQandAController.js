({
	doInit : function(component, event, helper) {

		var rid = component.get("v.recordId");                
		console.log(rid);
        var action = component.get("c.getQandAKnowledgeArticleInfo");
        action.setParams({recordIds : rid });
		action.setCallback(this, function(response) {
        	var state = response.getState();
			if (state === "SUCCESS") {
                var a = response.getReturnValue();                
                component.set("v.QandA",response.getReturnValue());            	              
            }
        });
        $A.enqueueAction(action);
	}
})