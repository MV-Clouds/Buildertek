({
    getFilters: function(component,helper) { 
        /* Changed logic to retrieve filter logic via Aggregate Query in Apex instead of processing via
    Javascript in order to separate filter logic from get users. */
      var action = component.get('c.getAllFilters');
      helper.showSpinner(component);
      action.setCallback(this, function(response) {
          var state = response.getState();
          if (state === 'SUCCESS') {
              var parsedResp = response.getReturnValue();
              component.set('v.departments', parsedResp.lUsersGroupedByDep);
              component.set('v.filterDepartments', parsedResp.lUsersGroupedByDep);
              console.log('@@ '+JSON.stringify(parsedResp.lUsersGroupedByDep));
              component.set('v.locations', parsedResp.lUsersGroupedByLoc);
              console.log('@@ '+JSON.stringify(parsedResp.lUsersGroupedByLoc));
              component.set('v.roles', parsedResp.lUsersGroupedByRoles);
              console.log('@@ '+JSON.stringify(parsedResp.lUsersGroupedByRoles));
              
          }
          helper.hideSpinner(component);
      });
      $A.enqueueAction(action);
      // var Users = component.get("v.users");
      // var depTemp = [];
      // var locTemp = [];
      //
      // for (var Usr in Users) {
      //   var temp = Users[Usr];
      //   for (var field in temp) {
      //     if (field === "Department" && temp[field] != null) {
      //       if (!(temp[field] in depTemp)) {
      //         depTemp.push(temp[field]);
      //       }
      //     }
      //     if (field === "City" && temp[field] != null) {
      //       if (!(temp[field] in locTemp)) {
      //         locTemp.push(temp[field]);
      //       }
      //     }
      //   }
      // }
      // //removing duplicate departments
      // var depfilter = [];
      // for (var i = 0; i < depTemp.length; i++) {
      //   var current = depTemp[i];
      //   if (depfilter.indexOf(current) < 0) depfilter.push(current);
      // }
      // component.set("v.departments", depfilter);
      //
      // //removing duplicate locations
      // var locfilter = [];
      // for (var i = 0; i < locTemp.length; i++) {
      //   var current2 = locTemp[i];
      //   if (locfilter.indexOf(current2) < 0) locfilter.push(current2);
      // }
      // component.set("v.locations", locfilter);
  },
    searchKeyChange: function(component,helper) {
        var myEvent = component.getEvent("searchEvent");
        myEvent.setParams({
            "searchKey": component.find('employeeSearchField').get('v.value')
        });
        myEvent.fire();
    },
    getSortOptions: function(component,helper) {
        
        var action = component.get("c.getSortOptions");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            var sortOptions = JSON.parse(response.getReturnValue());
            
            
            component.set("v.sortOptions", sortOptions);
            
            
        });
        
        $A.enqueueAction(action);
        
    },
    getUsers: function(component, searchKey, helper) {
        var selectedDepartments = component.get("v.selectedDepartments");
        var selectedLocations = component.get("v.selectedLocations");
        var curSortField = component.get("v.sortField");
        var curSortDirection = component.get("v.sortDirection");
        var doInItCall=component.get("v.doInItCall");
        var selectedRoles=component.get("v.selectedRoles");
        console.log('@@ selectedRoles'+selectedRoles);
        var selectedDep=[];
        if(searchKey) {
            component.set('v.keyword', searchKey);
        }
        var action = component.get("c.getAllUsers");
        action.setParams({
            "searchKey": searchKey,
            "depFilters": selectedDepartments,
            "locFilters": selectedLocations,
            "showmore": doInItCall,
            "sortBy": 'Employee_Department__c',
            "sortOrder": 'desc',
            "roleFilter": selectedRoles
        });
        helper.showSpinner(component);
        action.setCallback(this, function(data) {
            var res= data.getReturnValue();
            var usersList = [];
            for ( var key in  res) {
             usersList.push({department:key, users:res[key]});
            }

            component.set("v.users",usersList );
           // var Users = component.get("v.users");
            
            
           /* for(var i=0;i<Users.length;i++){
                if(selectedDep.length!=0){
                    console.log('@@ i value  @@'+i);
                    var dep=Users[i].Employee_Department__c;
                    console.log('@@ dep  @@'+dep);
                    var index = selectedDep.indexOf(dep);
                    console.log('@@ index  @@'+index);
                    if(index == -1) {
                        selectedDep.push(Users[i].Employee_Department__c);
                        console.log('@@ selectedDep  @@'+selectedDep);
                    }
                }
                else{
                    selectedDep.push(Users[i].Employee_Department__c); 
                    
                }
                
            }
            
            console.log('selectedDep in after search  @@'+selectedDep);
            component.set("v.userCount", Users.length);
            component.set("v.selectedDep", selectedDep);*/
            //console.log(JSON.stringify(Users));
            helper.hideSpinner(component);
            component.set("v.initialized",true);
        });
        $A.enqueueAction(action); 
    },
    
    showSpinner: function (component) {
        component.set("v.showSpinner",true);
    },
    
    hideSpinner: function (component) {
        component.set("v.showSpinner",false);
        
    }
    
})