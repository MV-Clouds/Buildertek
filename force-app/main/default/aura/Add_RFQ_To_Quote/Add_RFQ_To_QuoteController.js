({
	doInit : function(component, event, helper) {
	    
		helper.getPurchaseOrder(component, event, helper);
		
		helper.getQuote(component, event, helper);
	},
	
	onCheck : function(component, event, helper) {
	},
	
	
	onkeyCheck : function(component, event, helper) {
	    
	},
	
	AddPurchase : function(component, event, helper){
	    component.set("v.Spinner", true);
	    var QuotesIds = component.get("v.Quotes")
	    for(var i=0;i< QuotesIds.length;i++){
	        if(QuotesIds[i].Quotecheckbox == true){
	            component.set("v.QuoteId",QuotesIds[i].getQuotelist.Id);
	        }
	    }
	   
	    var action = component.get("c.AddPurchaseOrders");
	    action.setParams({
	        Purchaselists : JSON.stringify(component.get("v.RFQList")),
            QuoteWraps: component.get("v.QuoteId")
        });
        action.setCallback(this, function (response) {
           
        	if (response.getState() === "SUCCESS") { 
        	    component.set("v.Spinner", false);
        	    $A.get("e.force:closeQuickAction").fire();
        	    $A.get('e.force:refreshView').fire();
        	    var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "RFQ added successfully",
                    "type": "success",
                    "duration": 5000
                });
                toastEvent.fire();
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                  "recordId": component.get("v.QuoteId"),
                  "slideDevName": "detail"
                });
                navEvt.fire();
        	    
        	} else {
        		
        	}
        });  
        $A.enqueueAction(action);
	},
	
	onGroup : function(component, event, helper){
	    
	},
	
	SearchFunction : function(component, event, helper){
	   
	   /* window.setTimeout(function (){
	        var input, filter, table, tr, td, i;
            input = component.get("v.Searchstring");
            if(input != undefined){
                
                filter = input.toUpperCase();
                table = document.getElementById("myTable"); 
                tr = table.getElementsByTagName("tr");
                for (i = 0; i < tr.length; i++) {
            	    td = tr[i].getElementsByTagName("td")[1];  
            	    if (td) {
            	        if (td.innerHTML.toUpperCase().indexOf(filter) > -1) {
            		        tr[i].style.display = "";
            	        } 
            	        else {
            		        tr[i].style.display = "none";
            	        }
        	        } 
        	    }
            }
	    },500);*/
	    
	    var input, filter, table, tr, td, i,a;
    	input = document.getElementById("filterInput");
    	filter = input.value.toUpperCase();
    	table = document.getElementById("myTable");
    	tr = table.getElementsByTagName("tr");
    	for (i = 0; i < tr.length; i++) {
    		td = tr[i].getElementsByTagName("td")[1];
    		if (td) {
    			a=td;
    			if (a.innerHTML.toUpperCase().indexOf(filter) > -1) {
    				tr[i].style.display = "";
    			} else {
    				tr[i].style.display = "none";
    			}
    		}       
    	}
	    
	},
	
	
	QuoteSearchFunction : function(component, event, helper){
	    /*window.setTimeout(function (){
	        var input, filter, table, tr, td, i;
            input = component.get("v.Quotestring");
            if(input != undefined){
                filter = input.toUpperCase();
                table = document.getElementById("myTables"); 
                tr = table.getElementsByTagName("tr");
                for (i = 0; i < tr.length; i++) {
            	    td = tr[i].getElementsByTagName("td")[1];  
            	    if (td) {
            	        if (td.innerHTML.toUpperCase().indexOf(filter) > -1) {
            		        tr[i].style.display = "";
            	        } 
            	        else {
            		        tr[i].style.display = "none";
            	        }
        	        } 
        	    }
            }
	    },500);*/
	    
	    var input, filter, table, tr, td, i,a;
    	input = document.getElementById("quoteFilterInput");
    	filter = input.value.toUpperCase();
    	table = document.getElementById("myTables");
    	tr = table.getElementsByTagName("tr");
    	for (i = 0; i < tr.length; i++) {
    		td = tr[i].getElementsByTagName("td")[1];
    		
    		if (td) {
    			a=td;
    			if (a.innerHTML.toUpperCase().indexOf(filter) > -1) {
    				tr[i].style.display = "";
    			} else {
    				tr[i].style.display = "none";
    			}
    		}       
    	}
	},
	
	sortByName: function(component, event, helper) {
    	helper.sortBy(component,helper, "Name"); 
    	var a=component.get("v.isAsc");
        component.set("v.RFQName",a);
    },
    
    sortByDescription : function(component, event, helper) {
    	helper.sortBy(component,helper, "Description__c"); 
    	var a=component.get("v.isAsc");
        component.set("v.RFQDescription",a);
    },
    
    sortByAmount : function(component, event, helper) {
    	helper.sortBy(component,helper, "buildertek__Vendor_Quote__c");  
    	var a=component.get("v.isAsc");
        component.set("v.RFQAmount",a);
    }
    
})