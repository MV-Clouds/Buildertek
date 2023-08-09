({
	init: function(component, event, helper) {
	    component.set("v.Spinner",true);
	    helper.importMasterRFQItems(component, event, helper);
	    helper.getcurr(component, event, helper);
        helper.getmulticur(component, event, helper);
	},
    
     handleCheck : function(component, event, helper) {
        var checkbox = event.getSource();
       //alert(checkbox);
          var getAllId = component.find("checkContractor");
        var Submittals = component.get("v.objInfo");
          var selectedRfqIds  = component.get("v.selectedobjInfo");
        // alert(selectedRfqIds);
       //  var man = component.get("v.recordid");
        // alert(getAllId.length);
        // alert(JSON.stringify(Submittals));
	    for(var i=0 ; i < Submittals.length;i++){
           // alert(Submittals.length);
	        if(Submittals[i].MasterRFQItem.Id == checkbox.get("v.text") && Submittals[i].SubmittalCheck == false){
               // alert( JSON.stringify(Submittals[i].MasterRFQItem.Id == checkbox.get("v.text")));
               // alert(Submittals[i].SubmittalCheck == false);
	            Submittals[i].SubmittalCheck = true;
	        }
	        else if(Submittals[i].MasterRFQItem.Id == checkbox.get("v.text") && Submittals[i].SubmittalCheck == true){
              //  alert("hai");
	             Submittals[i].SubmittalCheck = false;
            }
        }
         if(selectedRfqIds.indexOf(checkbox.get("v.text")) > -1){
             var index = selectedRfqIds.indexOf(checkbox.get("v.text"));
             selectedRfqIds.splice(index,1);
         }
     },
    
    selectAll : function(component, event, helper) {     
         
        var selectedHeaderCheck = event.getSource().get("v.value"); 
		var Submittals = component.get("v.objInfo");
        var getAllId = component.find("checkContractor");
       // alert(getAllId.length);
        if (getAllId != undefined) {
            if (Submittals.length > 1) {
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
            }else{
                var i = 0;
				if (selectedHeaderCheck == true) {
                    component.find("checkContractor").set("v.value", true); 
                    component.set("v.selectedCount", 1);
					Submittals[i].SubmittalCheck = true;
				} else {
                    component.find("checkContractor").set("v.value", false);
                    component.set("v.selectedCount", 0);
                    Submittals[i].SubmittalCheck = false;
				}
            }   
        }
     
     
    },
    doCancel : function(component, event, helper) {
        component.get("v.onCancel")();     
    },
    
    
    
    doSave : function(component, event, helper) {
        
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle" 
        helper.importRFQItems(component, event, helper);
        
    },
})