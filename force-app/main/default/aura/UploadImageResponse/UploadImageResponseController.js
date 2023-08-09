({
	doInit : function(component, event, helper) {
        component.set("v.Spinner", true);
		var action = component.get("c.postImage");	
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
             	var result = response.getReturnValue();
                window.setTimeout(
                    $A.getCallback(function() {
                        var nextAction = component.get("c.getImageResponse");
                        nextAction.setParams({
                            resultId : result
                        });
                        nextAction.setCallback(this, function(response){
                            if(response.getState() === "SUCCESS"){
                                var jsonResponse = response.getReturnValue();  
                                component.set("v.readResults", jsonResponse.readResults);
                                component.set("v.pageResults", jsonResponse.pageResults);
                                var pageResults = jsonResponse.pageResults;
                                var rowsList = [];
                                var columnsList = [];
                                for(var i=0;i<pageResults.length;i++){
                                    for(var j=0;j<pageResults[i].tables.length;j++){
                                        for(var k=0;k<pageResults[i].tables[j].rows;k++){
                                            rowsList.push({"rowNumber": k});
                                            for(var l=0;l<pageResults[i].tables[j].columns;l++){
                                                columnsList.push({"rowNumber": k, "columnNumber": l});
                                            }
                                        }
                                        pageResults[i].tables[j].rowsList = rowsList;
                                        pageResults[i].tables[j].columnsList = columnsList;
                                        rowsList = [];
                                        columnsList = [];
                                    }
                                }
                                console.log('pageResults -------> '+JSON.stringify(pageResults));
                                component.set("v.pageResults", pageResults);
                                component.set("v.Spinner", false);
                            } 
                        });
                        $A.enqueueAction(nextAction);
                    }), 6000
                );
            }    
        });
        $A.enqueueAction(action);
	}
})