({
	init: function(component, event, helper) {
	    component.set("v.Spinner",true);
	    helper.importMasterContinuaionSheets(component, event, helper);
	    
	},
    
     handleCheck : function(component, event, helper) {
        var checkbox = event.getSource();  
        var Submittals = component.get("v.objInfo");
	    for(var i=0 ; i < Submittals.length;i++){
	        if(Submittals[i].MasterRFQItem.Id == checkbox.get("v.text") && Submittals[i].SubmittalCheck == false){
	            Submittals[i].SubmittalCheck = true;
	        }
	        else if(Submittals[i].MasterRFQItem.Id == checkbox.get("v.text") && Submittals[i].SubmittalCheck == true){
	             Submittals[i].SubmittalCheck = false;
	        }
	    }
    },
    
    selectAll : function(component, event, helper) {        
        var selectedHeaderCheck = event.getSource().get("v.value"); 
		var Submittals = component.get("v.objInfo");
        var getAllId = component.find("checkContractor"); 
        if(! Array.isArray(getAllId)){
           if(selectedHeaderCheck == true){ 
              component.find("checkContractor").set("v.value", true); 
              component.set("v.selectedCount", 1);
           }else{
               component.find("checkContractor").set("v.value", false);
               component.set("v.selectedCount", 0);
           }
        }
        else{ 
            if (selectedHeaderCheck == true) {
                for (var i = 0; i < getAllId.length; i++) {
					component.find("checkContractor")[i].set("v.value", true); 
					var checkbox = component.find("checkContractor")[i].get("v.text");  
            	        Submittals[i].SubmittalCheck = true;
            	    
                }
            } 
            else{
                for (var i = 0; i < getAllId.length; i++) {
    				component.find("checkContractor")[i].set("v.value", false); 
    				
    				var checkbox = component.find("checkContractor")[i].get("v.text"); 
    				var Submittals = component.get("v.objInfo");
    	                Submittals[i].SubmittalCheck = false;
               }
           } 
        } 
     
     
    },
    doCancel : function(component, event, helper) {
       $A.get("e.force:closeQuickAction").fire();
    },
    
    doSave : function(component, event, helper) {
         
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle" 
        helper.importContinuationItems(component, event, helper);
       
    },
})