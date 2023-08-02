/*
* Copyright 2011-2018, @ thoriyas technologies.
* All rights reserved
*/

/* Lightning CLI rule */
({
	doInit : function(component, event, helper) {
        helper.doInit(component, event, helper);
	},
	refreshTree: function(component, event, helper) {
		if(event.getParam("key") === 'ALL_TREE') {
			helper.doInit(component, event, helper);
		}
	}
})