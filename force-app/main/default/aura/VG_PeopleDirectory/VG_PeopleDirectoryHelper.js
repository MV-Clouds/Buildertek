({ 
     
    serverSearch : function(component) {
		var searchText = component.find("searchInput").get("v.value");
		var startsWith = false;
        
		var minChars = 1;        
        
        if (searchText.length >= minChars) {
            var action = component.get("c.searchRecords");
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
            $A.enqueueAction(action);          
        } else {
        	component.set("v.matchedRecords", []);   
        }       
    }    
})