({
	getTiles: function(component, helper) {
	    var action = component.get("c.retrieveContent");
         action.setParams({type:"Tiles",
                          siteName:component.get('v.siteName'),
                          includePreview:component.get('v.includePreview')});
      //  action.setParams({type:"Tile"});
        action.setCallback(this, function(response) {
            var state = response.getState();
            var tileContent = JSON.parse(response.getReturnValue());
            var tileArray=[];
            if (tileContent !== null && tileContent !== undefined) 
            {  
                for(var i = 0; i < tileContent.length; i++){
                    tileArray.push(tileContent[i].content);
                
                }
            }
            component.set("v.tiles",tileArray) ;               
        });
        $A.enqueueAction(action);
	},
	getUrlPrefix: function(component)
	{
	 var actionBase = component.get("c.getPrefix");	
        actionBase.setCallback(this, function(response) {
            var state = response.getState();
            var baseUrlResponse = response.getReturnValue();
            component.set("v.urlPrefix",baseUrlResponse) ;
    		
        });
        $A.enqueueAction(actionBase);
	},
})