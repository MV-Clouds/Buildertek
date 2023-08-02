({
	fetchopenissuesdoinitIGU : function(component, event, helper) {
        
		var recordId = component.get( "v.id");
        console.log('recordId----'+recordId);
        var action = component.get("c.resolveIssuesLCForIGU");
        action.setParams({
            caseid : recordId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('---state--'+state);
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('---stringify data---'+JSON.parse(JSON.stringify(result)));
                component.set( "v.listOfIGUIssueWrappers", result );
                component.set( "v.listOfIGUIssueWrappersClone", JSON.parse(JSON.stringify(result)) );
            }
        });
        $A.enqueueAction(action);        
    },//end: fetchopenissuesdoinitIGU
    
    openRecordInNewConsoleTab : function( component, helper, recordId ) {
			
		if( recordId ) {
			var isConsoleNavigation = component.get( "v.isConsoleNavigation" );
			if( isConsoleNavigation ) {
			
				var workspaceAPI = component.find( "workspace" );
				if( workspaceAPI ) {
					
					workspaceAPI.openTab
					({
						recordId : recordId,
						focus : true
					}).then( function( response ) {
						workspaceAPI.getTabInfo
						({
							tabId: response
						}).then(function( tabInfo ) {
							if( tabInfo ) {
								console.log( "The url for this tab is:", tabInfo.url );
							}
						});
					})
					.catch( function( error ) {
					   console.log( 'openRecordInNewConsoleTab-error', error );
					});
				}
			}
			else {
				window.open( '/' + recordId, '_blank' );
			}
		}
    }//end: openRecordInNewConsoleTab()
    ,
     showToastMessage : function( type, title, message ) {
        
        if( type && title && message ) {
            var toastEvent = $A.get( "e.force:showToast" );
            
            if( toastEvent ) {
                toastEvent.setParams({
                    'type' : type,
                    'title' : title,
                    'message': message,
                    'duration' : 8000
                });
                toastEvent.fire();
            }
        }
    },
	statusChanged:function(cmp,event,helper,listname){
      
       var curUsRec = cmp.get("v.issueWrapperdata");
        var wrap = cmp.get("v.listOfIGUIssueWrappers");
        var issuLst = cmp.get("v.listOfIGUIssueWrappers");
        var curIssueRec = issuLst[event.getSource().get('v.label')];
         var action = cmp.get("c.getIssueInfo");
        action.setParams({
            issId : curIssueRec.Id
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('---state--'+state);
            if (state === "SUCCESS") {
                
               var oldissueRec = response.getReturnValue();
               var currentStatus = event.getSource().get('v.value');
               	var oldStatus =oldissueRec.Issue_Status__c;
        var changedIssue = curIssueRec;
           
             if(oldStatus=='Open' && currentStatus=='Resolved' && ( changedIssue.Order_Replacement_Product__c == true)){
            
            helper.showToastMessage( 'error', 'Warning!', 'Status cant be changed from '+oldStatus+' to '+ currentStatus);
            event.getSource().set('v.value',oldStatus);
        }
                if(currentStatus=='Resolved' && ( changedIssue.RMA_Return_Product__c == true) && (changedIssue.Reverse_Shipment_Info__c==undefined || changedIssue.RMA_FA_Status__c=='Select' ||changedIssue.RMA_FA_Status__c=='')){//&& changedIssue.Order_Replacement_Product__c == true
            
            	helper.showToastMessage( 'error', 'Warning!', 'Can Not Change Issue status to resolve please fill   RMA / FA Status && Reverse Shipment Info Before change status');
				event.getSource().set('v.value',oldStatus);
        }
        
        if(oldStatus=='Open' && (currentStatus=='Fulfilled' ||currentStatus=='')){
            
            helper.showToastMessage( 'error', 'Warning!', 'Status cant be changed from '+oldStatus+' to '+ 'Order Shipped');
            event.getSource().set('v.value',oldStatus);
        }
        
        if(oldStatus=='Fulfilled' && (currentStatus=='Open' || currentStatus=='Canceled' ||currentStatus=='')){
            
            helper.showToastMessage( 'error', 'Warning!', 'Status cant be changed from '+'Order Shipped'+' to '+ currentStatus);
            event.getSource().set('v.value',oldStatus);
        }
            }
        });
        $A.enqueueAction(action); 
       
    }
    
})