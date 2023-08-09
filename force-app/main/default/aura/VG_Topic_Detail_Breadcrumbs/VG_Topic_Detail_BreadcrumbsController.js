({
	doInit : function(component, event, helper) {
		var rid = component.get("v.recordId");
		console.log('topic ID main '+rid);
        //var action = component.get("c.getKnowledgeArticleInfo");
        var action = component.get("c.getTopicHierarchy");
        action.setParams({recordIds : rid });
		action.setCallback(this, function(response) {
        	var state = response.getState();
            console.log('state'+state);
			if (state === "SUCCESS") {
                var a = response.getReturnValue();
                component.set('v.hierarchyList', response.getReturnValue());
                //component.set('v.myMap',response.getReturnValue());
            	//console.log(a.Name);
                //component.set("v.TopicTitle",a.Name);                                
            }
        });
        $A.enqueueAction(action);

	},
    navigateTotoparticles: function(component){
        var navEvt = $A.get("e.force:navigateToURL");        
        navEvt.setParams({
            "url": "/toparticles"
        });
        navEvt.fire();
    },
    navigateToHome: function(component, event, helper) {
    	var navEvt = $A.get("e.force:navigateToURL");        
        navEvt.setParams({
           "url": "/"
         });
       navEvt.fire();
    }
})