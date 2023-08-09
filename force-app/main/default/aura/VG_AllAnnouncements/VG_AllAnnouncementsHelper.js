({
	getFilters: function(component) {
		 var action = component.get('c.getAllFilters');
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === 'SUCCESS') {
        var parsedResp = response.getReturnValue();
        component.set('v.months', parsedResp.lAnnouncementsGroupedByMonth);
        component.set('v.years', parsedResp.lAnnouncementsGroupedByYear);
      }
    });
    $A.enqueueAction(action);
	},
  
     getAnnouncements: function(component, searchKey) {
         
    var selectedMonths = component.get("v.selectedMonths");
    var selectedYears = component.get("v.selectedYears");
    var curSortField = component.get("v.sortField");
    var curSortDirection = component.get("v.sortDirection");
        //  var curPageName = component.get("v.siteName");
   
        //  alert(searchKey +'----searchKey---' );
       //  alert(selectedMonths +'----months---' );
       // alert(curPageName +'----curPageName---' );
    if(searchKey) {
        component.set('v.keyword', searchKey);
    }
    var action = component.get("c.getAllAnnouncements");
    action.setParams({
     //  "siteName":curPageName,
      "searchKey": searchKey,
      "monthFilters": selectedMonths,
      "yearFilters": selectedYears,
      "showmore": 'false',
      "sortBy": curSortField,
      "sortOrder": curSortDirection
    });
    action.setCallback(this, function(data) {
      component.set("v.Announcements", data.getReturnValue());
        console.log( JSON.stringify(component.get("v.Announcements")));
      var Announcements = component.get("v.Announcements");
       // alert(  Announcements.length);
    console.log(JSON.stringify(Announcements));
     
    });
    $A.enqueueAction(action);
  }
})