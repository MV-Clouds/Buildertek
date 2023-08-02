({
	getQuickLinks: function(component, helper) {
	    var action = component.get("c.retrieveContent"); 
        action.setParams({type:"Quick_Links",
                          siteName:component.get('v.siteName'),
                          includePreview:component.get('v.includePreview')});
        action.setCallback(this, function(response) {
            var state = response.getState();
            var quickLinkContent = JSON.parse(response.getReturnValue());
            var quickLinksArray=[];
             var moreQuickLinksArray=[];
            if (quickLinkContent !== null && quickLinkContent !== undefined) 
            {  
                for(var i = 0; i <quickLinkContent.length; i++){
                    if(i<=4){
                        quickLinksArray.push(quickLinkContent[i].content);}
                    else{                        
                        moreQuickLinksArray.push(quickLinkContent[i].content);
					}
                }
               // alert(moreQuickLinksArray);
            }
            component.set("v.quickLinks",quickLinksArray) ; 
            component.set("v.moreQuickLinks",moreQuickLinksArray) ; 
        });
        $A.enqueueAction(action);
	},
    	
})