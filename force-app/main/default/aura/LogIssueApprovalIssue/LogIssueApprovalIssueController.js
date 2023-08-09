({
	doInit : function(component, event, helper) {
   	var listOfSubmittedIssues = JSON.parse( JSON.stringify( component.get( "v.listOfSubmittedIssues" ) ) );
		helper.doInit( component, helper, listOfSubmittedIssues ); 
	},
    
    closeModal : function( component, event, helper ) {
		helper.closeModal( component );
	},
})