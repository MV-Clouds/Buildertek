({
	doinit: function(component, event, helper) {
        
    },
	
	defaultCloseAction : function(component, event, helper) {
        component.destroy();
    },
    
    addSelectedItems: function(component, event, helper) {
    	component.get("v.leftSideComponent")[0].addSelectedRecords();
    	component.get("v.rightSideComponent")[0].refreshData();
		$A.enqueueAction(component.get("v.parentComponentAction"));
    },
    
    removeSelectedItems: function(component, event, helper) {
    	component.get("v.rightSideComponent")[0].deleteSelectedRecord();
    	component.get("v.leftSideComponent")[0].refreshData();
		$A.enqueueAction(component.get("v.parentComponentAction"));
    }
})