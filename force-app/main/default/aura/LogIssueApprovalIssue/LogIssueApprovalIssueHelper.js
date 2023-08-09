({
	doInit : function( component, helper, listOfSubmittedIssues ) {
		console.log('3333'+listOfSubmittedIssues);
		//console.log( 'doInit-listOfSubmittedIssues', listOfSubmittedIssues );
		 var issueList = [];
        
        issueList=listOfSubmittedIssues;
        
        console.log('====9==='+issueList)
		var serverAction = component.get( "c.fetchIssuesSubmittedForApproval" );
		if( !serverAction ) {
			return;
		}
		component.set( "v.showSpinner", true );
			
		serverAction.setParams({ 
            "strJsonOfListOfApprovalIssues" : issueList});
							  
		serverAction.setCallback( this, function( response ) {
			
			component.set( "v.showSpinner", false );
			
			var state = response.getState();
			if ( state === "SUCCESS" ) {
				
				var result =  response.getReturnValue();
				console.log( "doInit", result );
				var subrecords=[];
                var notsubrecords=[];
                var recordIssue;
				for (var index = 0; index < result.length; index++) {
            recordIssue = result[index];
        
                  if(recordIssue.In_Approval__c==false && recordIssue.Issue_Status__c =='Open')
                  {
                      notsubrecords.push(recordIssue);
                  }
                    if(recordIssue.In_Approval__c==true || recordIssue.Issue_Status__c !='Open')
                    {
                      subrecords.push(recordIssue);  
                    }
                }
          
				component.set( "v.listOfnotSubIssues", notsubrecords );
                component.set( "v.listOfSubIssues", subrecords );
               
				//	helper.showToastMessage( 'error', 'Error!', result.message );
				
			}
			else {
				helper.showToastMessage( 'error', 'Error!',$A.get("$Label.c.Something_Went_Wrong_Please_Contact_Admin") );
			}
		});
			
		$A.enqueueAction( serverAction );
	},
    
    showToastMessage : function( type, title, message ) {
        
        if( type && title && message ) {
            var toastEvent = $A.get( "e.force:showToast" );
            
            if( toastEvent ) {
                toastEvent.setParams({
                    'type' : type,
                    'title' : title,
                    'message': message,
                    'mode' : 'dismissible',
					'duration' : 7000
                });
                toastEvent.fire();
            }
        }
    },
    closeModal : function( component ) {
        
        var submitedtype = component.get("v.submitedtype");
          if(submitedtype===2)
            {
                var compEvent = component.getEvent("SubmitedRedrirect");
     compEvent.fire();
            }
       else if((component.get("v.componentName") === 'IGU') || (component.get("v.componentName") === 'CHW')){
           component.destroy();
          
        }else{
            
             $A.get('e.force:refreshView').fire();
            component.destroy();
        }
		
		
	},
    
    
})