({
	doInit : function(component, event, helper) {
        component.set('v.fromWhereBudgetIsOpen' , window.location.href);
		var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:BT_NewBudgetItemClone",
            componentAttributes: {
                recordId : component.get("v.recordId"),
                isbudget : component.get("v.isbudget"),
                fromWhereBudgetIsOpen : component.get("v.fromWhereBudgetIsOpen"),

            }
        });
        evt.fire();	
	}
})