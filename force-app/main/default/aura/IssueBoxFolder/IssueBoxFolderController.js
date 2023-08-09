({
	closeModal : function(component, event, helper) {
		// when a component is dynamically created in lightning, we use destroy() method to destroy it.
		component.destroy();
	},
 
	// action to execute when save button is clicked
	
})