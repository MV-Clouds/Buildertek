({
	doInit : function(component, event, helper) {
		 component.set("v.Spinner", true);
        var recId = component.get("v.recordId");
        var action = component.get("c.getBudgets");
        action.setParams({ExpenseId : recId});
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var result = response.getReturnValue();
                if(result == 'Associated Record'){
                  // component.set("v.isAssociated", true);
                  var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Expense already linked with a Budget or Budget Line.",
                        "type" : "error"
                    });
                    toastEvent.fire();
                    component.set("v.isBudgetRec", false);
                    $A.get("e.force:closeQuickAction").fire();  
                }else{
                    component.set("v.isBudgetRec", true);
                    var pageSize = component.get("v.pageSize");
                    component.set("v.BudgetsList", result);
                    component.set("v.totalRecords", component.get("v.BudgetsList").length);
                    component.set("v.startPage",0);
                    component.set("v.endPage",pageSize-1);
                    var PaginationList = [];
                    for(var i=0; i< pageSize; i++){
                        if(component.get("v.BudgetsList").length> i)
                            PaginationList.push(result[i]);    
                    }
                    //alert('PaginationList Length ------> '+PaginationList.length);
                    component.set('v.PaginationList', PaginationList);
                }
                component.set("v.Spinner", false); 
                
            }
        });
	    $A.enqueueAction(action);
	},
    
    handleCheck : function(component, event, helper) {
        var checkbox = event.getSource();  
        var Submittals = component.get("v.BudgetsList");
	    /*for(var i=0 ; i < Submittals.length;i++){
	        console.log('=========> ',i +' '+ Submittals.length);
	        if(Submittals[i].quoteRecord.Id == checkbox.get("v.text") && Submittals[i].quoteCheck == false){
	            Submittals[i].quoteCheck = true;
	            if(Submittals.length > 1){
	                component.find("checkContractor")[i].set("v.value", true);
	            }
	            else{
	                component.find("checkContractor").set("v.value", true);
	            }
	        }
	        else if(Submittals[i].quoteRecord.Id == checkbox.get("v.text") && Submittals[i].quoteCheck == true){
	             Submittals[i].quoteCheck = false;
	             component.find("checkContractors").set("v.value", false);
	        }
	    }*/
	    
	    for(var i=0 ; i < Submittals.length;i++){
	        if(Submittals[i].budgetRecord != null){
	            if(Submittals[i].budgetRecord.Id == checkbox.get("v.text") && Submittals[i].budgetCheck == false){
    	            Submittals[i].budgetCheck = true;
    	        }
    	        else if(Submittals[i].budgetRecord.Id == checkbox.get("v.text") && Submittals[i].budgetCheck == true){
    	             Submittals[i].budgetCheck = false;
    	        }    
	        }
	        
	    }
    },
    
    selectAll : function(component, event, helper) {        
        var selectedHeaderCheck = event.getSource().get("v.value"); 
		var Submittals = component.get("v.BudgetsList");
        var getAllId = component.find("checkContractor"); 
        if(Submittals != null){
            if(Submittals.length > 1){
                if(! Array.isArray(getAllId)){
                   if(selectedHeaderCheck == true){ 
                      component.find("checkContractor").set("v.value", true); 
                   }else{
                       component.find("checkContractor").set("v.value", false);
                   }
                }
                else{ 
                    if (selectedHeaderCheck == true) {
                        for (var i = 0; i < getAllId.length; i++) {
        					component.find("checkContractor")[i].set("v.value", true); 
        					var checkbox = component.find("checkContractor")[i].get("v.text");  
                    	        Submittals[i].budgetCheck = true;
                    	    
                        }
                    } 
                    else{
                        for (var i = 0; i < getAllId.length; i++) {
            				component.find("checkContractor")[i].set("v.value", false); 
            				
            				var checkbox = component.find("checkContractor")[i].get("v.text"); 
            				var Submittals = component.get("v.BudgetsList");
            	                Submittals[i].budgetCheck = false;
                       }
                   } 
                } 
            }
            else{
                var i=0;
                    if (selectedHeaderCheck == true) {
                        	component.find("checkContractor").set("v.value", true); 
        					var checkbox = component.find("checkContractor").get("v.text");  
                    	        Submittals[i].budgetCheck = true;
                    	    
                        
                    } 
                    else{
                       		component.find("checkContractor").set("v.value", false); 
            				
            				var checkbox = component.find("checkContractor").get("v.text"); 
            				var Submittals = component.get("v.BudgetsList");
            	                Submittals[i].budgetCheck = false;
                       
                   } 
            }
        }
     
    },
	
	closeModel : function(component, event, helper){
	    $A.get("e.force:closeQuickAction").fire();    
	},
    createBudgetline : function(component, event, helper){
        component.set("v.Spinner", true);
	    var budgetsList = component.get("v.BudgetsList");
	    console.log('budgetList ---------> '+(JSON.stringify(budgetsList)));
	    var budgetIds = [];
	    for(var i=0 ; i < budgetsList.length;i++){
	        //alert('quoteCheck -------> '+quotesList[i].quoteCheck);
	        
	        if(budgetsList[i].budgetCheck == true){
	             if(budgetsList[i].budgetRecord != null){
	                budgetIds.push(budgetsList[i].budgetRecord.Id);    
	            }
	        }
	    }
        if(budgetIds.length >1){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Please select only one budget.",
                "type": 'Error'
            });
            toastEvent.fire();
            component.set("v.Spinner", false);
            return;
        }
	    if(budgetIds.length > 0){
	        var action = component.get("c.createBudgetLineFromExpense");  
	        action.setParams({
	            ExpenseId: component.get("v.recordId"),
                BudgetId : budgetIds[0]
	        });
	        action.setCallback(this, function(response){
	            var state = response.getState();
	            console.log('state ---------> '+state);
                if(state == 'SUCCESS'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Budget Line created successfully.",
                        "type": 'Success'
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire();
                    $A.get('e.force:refreshView').fire();
                }
                else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Error while creating Budget Line.",
                        "type": 'Error'
                    });
                    toastEvent.fire();
                }
	        });
	        $A.enqueueAction(action);
	    }else{
	        component.set("v.Spinner", false);
            
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": 'Please select Budget record',
                "type": 'Error',
                "duration": '1000',
				"mode": 'dismissible'
            });
            toastEvent.fire(); 
	    }
	    
	},
    
   

	
})