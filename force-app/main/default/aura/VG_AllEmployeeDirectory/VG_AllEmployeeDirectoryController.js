({
    doInit: function(component, event, helper) {
        helper.getSortOptions(component,helper);
        helper.getFilters(component,helper);
        helper.getUsers(component,null,helper);
    },
    showFilterBar: function(component, event, helper) {
        //component.set("v.mobileFilter",document.getElementById('mobileFilterBar').classList.toggle('showFilterBar'));
        document.getElementById('mobileFilterBar').classList.toggle('showFilterBar');
        /* console.log(event.getSource().get("v.value"));
      if(event.getSource().get("v.value")!=filterCall){
          window.onclick = function(event) {
          document.getElementById('mobileFilterBar').classList.toggle('showFilterBar');
         }
      }*/
      
      
      
  },   
    navigateToHome: function(component){
        var navEvt = $A.get("e.force:navigateToURL");        
        navEvt.setParams({
            "url": "/"
        });
        navEvt.fire();
    },
    
    searchUsers: function(component, event, helper) {
        var searchKey = component.find('employeeSearchField').get('v.value');
        var searchTrue=true;
        helper.getUsers(component, searchKey,helper);
    },
    setDeptFilters: function(component, event, helper) {
        var isChecked = event.getSource().get('v.checked');
        var label = event.getSource().get('v.label');
       
        component.setDepartment(isChecked, label);
    },
    setDeptFiltersAPI: function(component, event, helper) {
        
        console.log('DEPARTMENT FILTERS CALLED');
        var selectedDepartments = component.get('v.selectedDepartments');
        var selectedRoles = component.get('v.selectedRoles');
        var selectedLocations = component.get('v.selectedLocations');
        console.log('@@ selectedDepartments'+selectedDepartments.length);
        if (event.getParam('arguments').isChecked && event.getParam('arguments').label) {
             var index = selectedDepartments.indexOf(event.getParam('arguments').label);
            
            if(index == -1) {
             selectedDepartments.push(event.getParam('arguments').label);
            }
        } else {
            var index = selectedDepartments.indexOf(event.getParam('arguments').label);
            if(index > -1) {
                selectedDepartments.splice(index, 1);
                console.log('@@ selectedDepartments splice'+selectedDepartments.length);
            }
        }
        if(selectedRoles.length==0 && selectedDepartments.length==0 && selectedLocations.length==0 ){
            component.set("v.doInItCall",true);
        }
        else
            component.set("v.doInItCall",false);
        
        component.set("v.selectedDepartments", selectedDepartments);
        helper.getUsers(component,null,helper);
    },
    setLocFilters: function(component, event, helper) {
        var isChecked = event.getSource().get('v.checked');
        var label = event.getSource().get('v.label');
        component.setLocation(isChecked, label);
    },
    setLocFiltersAPI: function(component, event, helper) {
        console.log('LOCATION FILTERS CALLED');
        var selectedDepartments = component.get('v.selectedDepartments');
        var selectedLocations = component.get('v.selectedLocations');
        var selectedRoles = component.get('v.selectedRoles');
        if (event.getParam('arguments').isChecked && event.getParam('arguments').label) {
            selectedLocations.push(event.getParam('arguments').label);
        } else {
            var index = selectedLocations.indexOf(event.getParam('arguments').label);
            if(index > -1) {
                selectedLocations.splice(index, 1);
            }
        }
        if(selectedRoles.length==0 && selectedDepartments.length==0 && selectedLocations.length==0 ){
            component.set("v.doInItCall",true);
        }
        else
            component.set("v.doInItCall",false);
        
        component.set("v.selectedLocations", selectedLocations);
        console.log(component.get("v.selectedLocations"));
        helper.getUsers(component,null,helper);
    },
    setRolesFilters :function(component, event, helper) {
        var isChecked = event.getSource().get('v.checked');
        var label = event.getSource().get('v.label');
        component.setRole(isChecked, label);
    },
    setRoleFiltersAPI: function(component, event, helper) {
        console.log('Role FILTERS CALLED');
        var selectedRoles = component.get('v.selectedRoles');
        var selectedDepartments = component.get('v.selectedDepartments');
        var selectedLocations = component.get('v.selectedLocations');
        if (event.getParam('arguments').isChecked && event.getParam('arguments').label) {
            selectedRoles.push(event.getParam('arguments').label);
        } else {
            var index = selectedRoles.indexOf(event.getParam('arguments').label);
            if(index > -1) {
                selectedRoles.splice(index, 1);
            }
        }
        if(selectedRoles.length==0 && selectedDepartments.length==0 && selectedLocations.length==0 ){
            
            component.set("v.doInItCall",true);
        }
        else
            component.set("v.doInItCall",false);
        
        component.set("v.selectedRoles", selectedRoles);
        console.log('@@ selceted roles'+component.get("v.selectedRoles"));
        helper.getUsers(component,null,helper);
    },
    
    showmore: function(component, event, helper) {
        component.set("v.showmore", 1000);
        var Users = component.get("v.users");
        component.set("v.users", Users);
    },
    showless: function(component, event, helper) {
        component.set("v.showmore", 10);
        var Users = component.get("v.users");
        component.set("v.users", Users);
    },
    sort: function(component, event, helper) {
        var curSortField = component.get("v.sortField");
        var curSortDir = component.get("v.sortDirection");
        
        var curSelection = event.currentTarget;
        var selectedField = curSelection.dataset.value;
        if (selectedField === curSortField) {
            if (curSortDir === "ASC") {
                curSortDir = "DESC";
            } else {
                curSortDir = "ASC";
            }
            
        } else {
            curSortField = selectedField;
            curSortDir = "ASC";
        }
        component.set("v.sortField", curSortField);
        component.set("v.sortDirection", curSortDir);
        helper.getUsers(component,null,helper);
    },
    goToURL : function(component, event, helper) {
        
        var curItem = event.currentTarget;
        
        var userId = curItem.dataset.url;
        // alert(userId);
        /* var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
              "recordId": userId
            });
            navEvt.fire(); */
         
         
         var navEvt = $A.get("e.force:navigateToURL");
         //alert(navEvt  +'  '+component.get("v.viewAllURL"));
         navEvt.setParams({
             "url": "/profile/"+userId
         });
         navEvt.fire();
     },
    showMore: function(component, event, helper) {
        var isChecked;
        var label = event.getSource().get('v.name');
        
        var showMore = component.get('v.showMore');
       
        if(!showMore){
            component.set("v.showMore",true);
            isChecked=true;
            var chkBoxcmp = component.find("deptfilterCheckbox");
            if(!$A.util.isUndefinedOrNull(chkBoxcmp)){
               ;
                if(chkBoxcmp.length > 1){
                     
                    for(var i=0;i<chkBoxcmp.length;i++){
                         
                        if(chkBoxcmp[i].get("v.label")==label){
                            chkBoxcmp[i].set("v.checked",true);
                            break;
                        }
                    }
                }  else {
                    if(chkBoxcmp.get("v.label")==label){
                        chkBoxcmp.set("v.checked",true);
                    }
                }
            }
        }
        else{
           component.set("v.showMore",false);
            isChecked=false;
        }
        
        // alert(label);
        component.setDepartment(isChecked, label);
    },
})