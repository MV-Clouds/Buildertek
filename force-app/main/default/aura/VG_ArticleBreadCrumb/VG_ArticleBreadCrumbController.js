({
	doInit : function(component, event, helper) {
		var rid = component.get("v.recordId");
		
        //var action = component.get("c.getKnowledgeArticleInfo");
        var action = component.get("c.getKnowledgeArticleInfoWithParent");
        action.setParams({recordIds : rid });
		action.setCallback(this, function(response) {
        	var state = response.getState();
			if (state === "SUCCESS") {
                var a = response.getReturnValue();
                
                if (a.articleInfo && a.articleInfo.Title) {
                    component.set("v.ArticleTitle",a.articleInfo.Title);
                }
                if (a.assignmentInfo && a.assignmentInfo.Topic) {
                    component.set("v.ArticleCategory", a.assignmentInfo.Topic);
                }
                console.log('title with assignment'+JSON.stringify(a));
                //component.set('v.myMap',response.getReturnValue());
            	//console.log(a.Title);
                //component.set("v.ArticleTitle",a.Title);                                
            }
        });
        $A.enqueueAction(action);

	},
    navigateToHome: function(component, event, helper) {
    	var navEvt = $A.get("e.force:navigateToURL");        
        navEvt.setParams({
           "url": "/"
         });
       navEvt.fire();
    },
    navigateToArticles: function(component, event, helper) {
    	var navEvt = $A.get("e.force:navigateToURL");        
        navEvt.setParams({
           "url": "/toparticles"
         });
       navEvt.fire();
    }
})