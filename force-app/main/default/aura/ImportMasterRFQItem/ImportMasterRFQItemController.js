({
	init: function(component, event, helper) {
	    component.set("v.Spinner",true);
        var pageNumber = component.get("v.PageNumber");
        var searchString = '';
        var pageSize = component.get("v.pageSize");
	    helper.importMasterRFQItems(component, event, helper, searchString);
	    helper.getcurr(component, event, helper);
        helper.getmulticur(component, event, helper);
        
	},
    

     handleCheckbox: function (component, event, helper) {
        var checkbox = event.getSource();
        var isChecked = checkbox.get("v.value");
        var recordId = checkbox.get("v.text");
        var checkedRecordIds = component.get("v.checkedRecordIds");
        console.log(`isChecked: ${isChecked} recordId: ${recordId}`);
        if (isChecked) {
            checkedRecordIds.push(recordId);
        } else {
            var index = checkedRecordIds.indexOf(recordId);
            if (index !== -1) {
                checkedRecordIds.splice(index, 1);
            }
        }

        component.set("v.checkedRecordIds", checkedRecordIds);
        console.log('checkedRecordIds', checkedRecordIds);
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
     
    component.set("v.selectedobjInfo", getAllId);
    },

    doCancel : function(component, event, helper) {
        component.get("v.onCancel")();     
    },
    
    
    
    doSave : function(component, event, helper) {
        helper.importRFQItems(component, event, helper);
    },

    next: function (component, event, helper) {
        var sObjectList = component.get("v.objInfo");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var Paginationlist = [];
        var counter = 0;
        for (var i = end + 1; i < end + pageSize + 1; i++) {
            if (sObjectList.length > i) {
                Paginationlist.push(sObjectList[i]);
            }
            counter++;
        }
        start = start + counter;
        end = end + counter;
        component.set("v.startPage", start);
        component.set("v.endPage", end);
        component.set('v.PaginationList', Paginationlist);
        helper.updateCheckboxValues(component);
    },

    previous: function (component, event, helper) {
        var sObjectList = component.get("v.objInfo");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var Paginationlist = [];
        var counter = 0;
        for (var i = start - pageSize; i < start; i++) {
            if (i > -1) {
                Paginationlist.push(sObjectList[i]);
                counter++;
            } else {
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        component.set("v.startPage", start);
        component.set("v.endPage", end);
        component.set('v.PaginationList', Paginationlist);
        helper.updateCheckboxValues(component);
    },

    handleSearch : function(component, event, helper) {
        var searchString = event.getParam("value");
        console.log(searchString);
        helper.importMasterRFQItems(component, event, helper, searchString);
    },

})