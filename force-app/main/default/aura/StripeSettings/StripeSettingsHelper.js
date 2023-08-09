({
	getTemplates : function(component, event, helper) {
		var action = component.get("c.getPages");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {   
                var options = [];
                var allValues = response.getReturnValue();
                for(var i=0;i<allValues.length;i++){
                    if(allValues[i].NamespacePrefix != undefined){
                    	allValues[i].Name = allValues[i].NamespacePrefix+'__'+allValues[i].Name;	    
                    }
                	options.push({
                        "label" : allValues[i].Name,
                        "value" : allValues[i].Name
                    });    
                }
                component.set("v.results", options);
            }                    
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } 
                else {
                    console.log("Unknown Error");
                }
            }
        });
        $A.enqueueAction(action);	
	},
    
    searchTemplate : function(component, event, helper) {
        var input, filter, ul, li, a, i, txtValue;
        input = document.getElementById("myInput");
        filter = input.value.toUpperCase();
        //alert('filter -------> '+filter);
        ul = document.getElementById("myUL");
        //alert('ul -------> '+ul);
        li = ul.getElementsByTagName("li");
        //alert('li -------> '+li);
        for (i = 0; i < li.length; i++) {
            a = li[i].getElementsByTagName("span")[2];
            txtValue = a.textContent || a.innerText;
            //alert('txtValue ----> '+txtValue.toUpperCase().indexOf(filter));
            if (txtValue.toUpperCase().indexOf(filter) > -1) {
                li[i].style.display = "";
            } else {
                li[i].style.display = "none";
            }
        }
    },
    searchPDFTemplate : function(component, event, helper) {
        var input, filter, ul, li, a, i, txtValue;
        input = document.getElementById("myInput1");
        filter = input.value.toUpperCase();
        //alert('filter -------> '+filter);
        ul = document.getElementById("myUL1");
        //alert('ul -------> '+ul);
        li = ul.getElementsByTagName("li");
        //alert('li -------> '+li);
        for (i = 0; i < li.length; i++) {
            a = li[i].getElementsByTagName("span")[2];
            txtValue = a.textContent || a.innerText;
            //alert('txtValue ----> '+txtValue.toUpperCase().indexOf(filter));
            if (txtValue.toUpperCase().indexOf(filter) > -1) {
                li[i].style.display = "";
            } else {
                li[i].style.display = "none";
            }
        }
    }
})