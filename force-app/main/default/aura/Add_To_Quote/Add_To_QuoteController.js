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
	        Purchaselists : JSON.stringify(component.get("v.PurchaseOrders")),
            QuoteWraps: component.get("v.QuoteId")
        });
        action.setCallback(this, function (response) {
            component.set("v.Spinner", false);
        	if (response.getState() === "SUCCESS") { 
        	    
        	    $A.get("e.force:closeQuickAction").fire();
        	    var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Purchase Order added successfully.",
                    "type": "success",
                    "duration": 5000
                });
                toastEvent.fire();
        	    
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
    	helper.sortBy(component,helper, "Proejct_PO_Number__c"); 
    	var a=component.get("v.isAsc");
        component.set("v.POName",a);
    },
    
    sortByDescription : function(component, event, helper) {
    	helper.sortBy(component,helper, "Description__c"); 
    	var a=component.get("v.isAsc");
        component.set("v.PODescription",a);
    },
    
    sortByAmount : function(component, event, helper) {
    	helper.sortBy(component,helper, "buildertek__PO_Amount__c");  
    	var a=component.get("v.isAsc");
        component.set("v.POAmount",a);
    }
    
})