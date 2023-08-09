({
	fetchCourseSessions : function(component, event, helper) {
       
        var action = component.get("c.fetchCourseSession");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.coursesessionList", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    expandCollapseGroups : function(component, event, helper) {
      //  alert("grpindex------------"+event.currentTarget.dataset.grpindex);
     //  alert("rowid---------------"+event.currentTarget.dataset.rowid);
       
 $A.enqueueAction(action);   
}
})