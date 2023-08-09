({
	
	init: function(component, event, helper) {
	    component.set("v.isOpen", true);
	    component.set("v.Spinner",true);
	     var url = location.href;
        var baseURL = url.substring(0, url.indexOf('--', 0));
        component.set("v.BaseURLs",baseURL);
       
	    helper.getEmailPunchLists(component, event, helper);
	    
	},
	
	 /* Created by Model Start */
    openModel: function(component, event, helper) {
        // for Display Model,set the "isOpen" attribute to "true"
        component.set("v.isOpen", true);
    },
    
    closeModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
        // component.set("v.isOpen", false);
        
        var action = component.get("c.getListViews");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var listviews = response.getReturnValue();
                var baseURL = component.get("v.BaseURLs");
                window.open(baseURL+'.lightning.force.com/lightning/lightning/r/'+escape(component.get("v.RecordId"))+'/related/buildertek__Punch_Lists__r/view','_self');
            }
        });
        $A.enqueueAction(action);
    },
    
    
    saveModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle" 
        helper.sendEmailPunchLists(component, event, helper);
       
    },
    
    handleCheck : function(component, event, helper) {
        var checkbox = event.getSource();
        var punchLists = component.get("v.objInfo");
	    for(var i=0 ; i < punchLists.length;i++){
	        if(punchLists[i].buildertekPunchlistRecord.Id == checkbox.get("v.text") && punchLists[i].punchListCheck == false){
	            punchLists[i].punchListCheck = true;
	        }
	        else if(punchLists[i].buildertekPunchlistRecord.Id == checkbox.get("v.text") && punchLists[i].punchListCheck == true){
	             punchLists[i].punchListCheck = false;
	        }
	    }
	    component.set("v.objInfo", punchLists);
    },
    
    selectAll : function(component, event, helper) {        
        var selectedHeaderCheck = event.getSource().get("v.value"); 
		var punchLists = component.get("v.objInfo");
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
            	        punchLists[i].punchListCheck = true;
            	    
                }
            } 
            else{
                for (var i = 0; i < getAllId.length; i++) {
    				component.find("checkContractor")[i].set("v.value", false); 
    				
    				var checkbox = component.find("checkContractor")[i].get("v.text"); 
    				var punchLists = component.get("v.objInfo");
    	                punchLists[i].punchListCheck = false;
               }
           } 
        } 
     
     
    },
    
    
})