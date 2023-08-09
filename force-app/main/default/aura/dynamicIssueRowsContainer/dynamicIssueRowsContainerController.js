/*
	@ PURPOSE : 1. CONTROLS THE LIGHTNING COMPONENT => dynamicIssueRowsContainer.xml
				2. CONTROLS EVENTS FIRED FROM SCREEN/COMPONENT.
	@ Name    : dynamicIssueRowsContainerController.js
*/
({
    doInit: function( component, event, helper ) {
        
		var recordWorkOrder = JSON.parse( JSON.stringify( component.get( "v.recordWorkOrder" ) ) );
		if( recordWorkOrder ) {
            if( !recordWorkOrder.CaseId ) {
                helper.showToastMessage( 'error', 'Error!', $A.get( "$Label.c.Case_Id_Not_Found_Try_Again" ) );
                return;
            }
		}
        else {
            helper.showToastMessage( 'error', 'Error!', $A.get( "$Label.c.Work_Order_Id_Not_Found_Try_Again" ) );
            return;
        }
		
		helper.createObjectData( component );
    },
    
    addNewRow: function( component, event, helper ) { 
     
		helper.createObjectData( component );
    },
    
    removeRow: function( component, event, helper ) { 
        
		helper.removeRow( component, event, helper );
    },
    
	save : function( component, event, helper ) {
        
		helper.save( component, helper )
    },
	
	cancel : function( component, event, helper ) {
        
		helper.cancel( component, helper )
    },
})