({
    fetchcategorytypes : function(component) {
        var action = component.get("c.getNavigationTopics");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               var returnList= response.getReturnValue();
                returnList.sort(function(a,b){
                    if (a.name < b.name)
                        return -1;
                    if (a.name > b.name)
                        return 1;
                    return 0;
                });
                //alert(JSON.stringify(returnList));
                component.set("v.Articlecategory", returnList);
            }
        });
        $A.enqueueAction(action);
    }
  
})