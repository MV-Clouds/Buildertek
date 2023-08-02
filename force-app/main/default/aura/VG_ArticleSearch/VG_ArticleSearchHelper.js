({
    getAllRecords : function(component) {
        var action = component.get("c.getAllRecords");
        action.setParams({"objectName": component.get("v.objectName"), 
                          "searchField": component.get("v.searchField"),
                          "selectFields": component.get("v.selectFields")}); 
                       
        action.setCallback(this, function(a){
            var allRecords = a.getReturnValue();
     
            component.set("v.allRecords", allRecords);
        });
         $A.enqueueAction(action);
    }, 
    serverSearch : function(component) {
		var searchText = component.find("searchInput").get("v.value");
		
		var minChars = 3;        
        
        if (searchText.length >= minChars) {
           /* var action = component.get("c.searchRecords");
            action.setParams({"objectName": component.get("v.objectName"), 
                              "searchField": component.get("v.searchField"),
                              "searchTerm": searchText,
                              "startsWith": startsWith,
                             "selectFields": component.get("v.selectFields")}); 
                           
            action.setCallback(this, function(a){
                var state = a.getState();
            if (state === "SUCCESS") {
                var records = a.getReturnValue();
             
                
                if(records){
                component.set("v.matchedRecords", records);
                }
               
            }
            });
            $A.enqueueAction(action); */
            var action = component.get("c.searchArticles");
        action.setParams({ "queryString" : searchText, "lang":'en_US',"recordLimit":"7" });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var records = response.getReturnValue();
             
                
                if(records){
                component.set("v.matchedRecords", records);
                }
             }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
        } else {
        	component.set("v.matchedRecords", []);   
        }       
    }    
})