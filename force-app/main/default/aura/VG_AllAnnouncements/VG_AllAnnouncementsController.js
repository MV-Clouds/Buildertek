({
	doInit : function(component, event, helper) {
		
		// var oId = window.location.href.split("=").pop();
        //alert('---oId----'+oId);
       // console.log('---page name----'+oId);
       // if (oId != null) {
          
       // component.set("v.siteName", oId);
         
   // }
    	helper.getFilters(component);
    	helper.getAnnouncements(component);
	},
  

    navigateToAllAnnouncements: function(component){
       
        var navEvt = $A.get("e.force:navigateToURL");        
        navEvt.setParams({
           "url": "/all-announcements"
         });
       navEvt.fire();
    },
     navigateToHome: function(component){
        var navEvt = $A.get("e.force:navigateToURL");        
        navEvt.setParams({
           "url": "/"
         });
       navEvt.fire();
    },
    
    searchAnnouncements: function(component, event, helper) {
        var searchKey = component.find('employeeSearchField').get('v.value');
        helper.getAnnouncements(component, searchKey);
  	},
    showFilterBar: function(component, event, helper) {
    document.getElementById('mobileFilterBar').classList.toggle('showFilterBar');
  }, 
    setMonFilters: function(component, event, helper) {
    var isChecked = event.getSource().get('v.checked');
    var label = event.getSource().get('v.label');
         var name = event.getSource().get('v.name');
      //  alert(name);
    component.setMonth(isChecked, name);
  },
     setMonFiltersAPI: function(component, event, helper) {
    console.log('MOnth FILTERS CALLED');
    var selectedMonths = component.get('v.selectedMonths');
          console.log(selectedMonths);
    if (event.getParam('arguments').isChecked && event.getParam('arguments').name) {
      selectedMonths.push(event.getParam('arguments').name);
    } else {
      var index = selectedMonths.indexOf(event.getParam('arguments').name);
      if(index > -1) {
        selectedMonths.splice(index, 1);
      }
    }
         helper.getAnnouncements(component);},
    
    setYearFilters: function(component, event, helper) {
    var isChecked = event.getSource().get('v.checked');
    var label = event.getSource().get('v.label');
   //    alert('---label---'+label);
    component.setYear(isChecked, label);
  },
     setYearFiltersAPI: function(component, event, helper) {
    console.log('Year FILTERS CALLED');
    var selectedYears = component.get('v.selectedYears');
         console.log(selectedYears);
    if (event.getParam('arguments').isChecked && event.getParam('arguments').label) {
      selectedYears.push(event.getParam('arguments').label);
    } else {
      var index = selectedYears.indexOf(event.getParam('arguments').label);
      if(index > -1) {
        selectedYears.splice(index, 1);
      }
    }
         helper.getAnnouncements(component);},
})