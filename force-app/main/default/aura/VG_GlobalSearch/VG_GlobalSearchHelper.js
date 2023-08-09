({	
	searchArticles: function(component, str) {						
		var minChars = 3;        
        if (str.length >= minChars) {          
            var action = component.get("c.searchArticle");
			action.setParams({ "searchStr" : str, "recordLimit":"5" });

			action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var records = response.getReturnValue();             
                console.log('article records'+records);
                if(records){
					component.set("v.Articles", records);
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
        	component.set("v.Articles", []);   
        }       

	},
	searchPeople : function(component,str) {       		
		var startsWith = false;
        // alert(searchText);
		var minChars = 1;                
        if (str.length >= minChars) {
            var action = component.get("c.searchPeople");
            action.setParams({
							"searchStr": str,
                            "recordLimit": "5"}); 
                           
            action.setCallback(this, function(a){
            var state = a.getState();
            if (state === "SUCCESS") {
                var records = a.getReturnValue();
                console.log(records);                          
                if(records){
                	component.set("v.People", records);
                }               
            }
            });
            $A.enqueueAction(action);          
        } else {
        	component.set("v.People", []);   
        }       
    },
	searchAnnouncements : function(component,str) {       		
		var startsWith = false;
        // alert(searchText);
		var minChars = 1;                
        if (str.length >= minChars) {
            var action = component.get("c.searchAnnouncements");
            action.setParams({
							"searchStr": str,
                            "recordLimit": "5"});
                           
            action.setCallback(this, function(a){
            var state = a.getState();
            if (state === "SUCCESS") {
                var records = a.getReturnValue();
             	//alert(records);
                console.log('Announcements'+records);
                if(records){
                component.set("v.Announcements", records);
                }               
            }
            });
            $A.enqueueAction(action);          
        } else {
        	component.set("v.Announcements", []);   
        }       
    },
	searchEvents: function(component, str) {
        
		var minChars = 1;               
        if (str.length >= minChars) {          
            var action = component.get("c.getEventsBySearchTerm");
			action.setParams({ "searchTerm" : str, "numOfRecords":"2" });
			
			action.setCallback(this, function(response) {
            var state = response.getState();
                //alert('in events'+state);
            if (state === "SUCCESS") {
                var records = response.getReturnValue();
             
                console.log('event records'+records);
                if(records){
                component.set("v.Events", records);
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
        	component.set("v.Events", []);   
        }       

	}    
})