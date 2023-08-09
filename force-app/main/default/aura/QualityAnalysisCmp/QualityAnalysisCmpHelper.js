/*
	@ PURPOSE : PROVIDES SERVICE TO => QualityAnalysisCmpController.js
	@ Name    : QualityAnalysisCmpHelper.js
*/
({
    showToastMessage : function( type, title, message ) {
        
        if( type && title && message ) {
            var toastEvent = $A.get( "e.force:showToast" );
            
            if( toastEvent ) {
                toastEvent.setParams({
                    'type' : type,
                    'title' : title,
                    'message': message				
                });
                toastEvent.fire();
            }
        }
    },
	
	closeModal : function( component ) {
		
		component.destroy();
	},
	
	save : function( component, event, helper ) {
		
		var recordIssue = JSON.parse( JSON.stringify( component.get( "v.recordIssue" ) ) );
        var fromComponent=component.get("v.fromComponent");
        if(!fromComponent){
            if( !recordIssue || !recordIssue.Replaced_SWC__c ||
			!recordIssue.Lite_Damaged__c || !recordIssue.Replaced_WC__c ||
			!recordIssue.Visible_BB_Damage__c || !recordIssue.Replaced_IGU_Cable__c ||
			!recordIssue.Reflection_Color_Observed__c || !recordIssue.Reflection_Color_Degree__c
		) {
			helper.showToastMessage( 'error', 'Details Missing', 'Please provide Quality Analysis details.' );
			return;
		}
        }else{
             if( !recordIssue || !recordIssue.Replaced_SWC ||
			!recordIssue.Lite_Damaged || !recordIssue.Replaced_WC ||
			!recordIssue.Visible_BB_Damage || !recordIssue.Replaced_IGU_Cable ||
			!recordIssue.Reflection_Color_Observed || !recordIssue.Reflection_Color_Degree
		) {
			helper.showToastMessage( 'error', 'Details Missing', 'Please provide Quality Analysis details.' );
			return;
		}
        }
		
		
		var qualityAnalysisModalEvt = component.getEvent( "qualityAnalysisModalEvt" );
		console.log( 'save-qualityAnalysisModalEvt', qualityAnalysisModalEvt );
		if( !qualityAnalysisModalEvt ) {
			return;
		}
		
		var recordIndex = component.get( "v.recordIndex" );
		var listName = component.get( "v.listName" );
		
		qualityAnalysisModalEvt.setParams({
			'recordIndex' : recordIndex,
			'listName' : listName,
			'recordIssue' : recordIssue
		});
		
		qualityAnalysisModalEvt.fire();
		
		helper.closeModal( component );
	},
})