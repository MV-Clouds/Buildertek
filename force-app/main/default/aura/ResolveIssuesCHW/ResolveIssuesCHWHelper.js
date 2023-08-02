({    
    fetchopenissuesdoinitCSS : function(component, event, helper){
        var recordId = component.get( "v.id");
        
        var action = component.get("c.resolveIssuesLCForCSS");
        action.setParams({
            caseid : recordId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('---state--'+state);
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('---stringify data---'+JSON.stringify(result));
                //console.log( 'controllerres----'+result );
                component.set( "v.listOfLogIssueWrappersCSS", result);
                component.set( "v.listOfLogIssueWrappersCSSClone", JSON.parse(JSON.stringify(result)));
                component.set( "v.cloneRecords", result);
                
            }
        });
        $A.enqueueAction(action); 
    },//end: fetchopenissuesdoinitCSS()
    
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
    statusChanged:function(component,event,helper,listName){
        
       // var curIssueRec = component.get("v.listOfLogIssueWrappersCSS")[event.getSource().get('v.label')];
      //  var curUsRec = component.get("v.listOfLogIssueWrappersCSS");
        var issuLst = component.get("v.listOfLogIssueWrappersCSS");
        var curIssueRec = issuLst[event.getSource().get('v.label')];
      
         var action = component.get("c.getIssueInfo");
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
       /* if(changedIssue.Issue_Status__c === undefined){
            oldStatus = 'Open';
        }else{
            oldStatus =  changedIssue.Issue_Status__c;
        }*/
        if(oldStatus=='Open' && currentStatus=='Resolved' && ( changedIssue.Product_Replacement__c == true)){
            
            helper.showToastMessage( 'error', 'Warning!', 'Status cant be changed from '+oldStatus+' to '+ currentStatus);
            event.getSource().set('v.value',oldStatus);
        }
                if(currentStatus=='Resolved' && ( changedIssue.Product_Return__c == true) && (changedIssue.Reverse_Shipment_Info__c==undefined || changedIssue.RMA_FA_Status__c=='Select' ||changedIssue.RMA_FA_Status__c=='')){//&& changedIssue.Product_Replacement__c == true
            
            	helper.showToastMessage( 'error', 'Warning!', 'Can Not Change Issue status to resolve please fill   RMA / FA Status && Reverse Shipment Info Before change status');
				event.getSource().set('v.value',oldStatus);
        }
        
        if(oldStatus=='Open' && (currentStatus=='Order Shipped' ||currentStatus=='' || currentStatus=='Replacement Rejected')){
            
            helper.showToastMessage( 'error', 'Warning!', 'Status cant be changed from '+oldStatus+' to '+ 'Order Shipped');
            event.getSource().set('v.value',oldStatus);
        }
        
        if(oldStatus=='Order Shipped' && (currentStatus=='Open' || currentStatus=='Canceled' ||currentStatus=='')){
            
            helper.showToastMessage( 'error', 'Warning!', 'Status cant be changed from '+'Order Shipped'+' to '+ currentStatus);
            event.getSource().set('v.value',oldStatus);
        }
                 if(oldStatus=='Replacement Rejected' && (currentStatus=='Resolved' || currentStatus=='Order Shipped' ||currentStatus=='')){
            
            helper.showToastMessage( 'error', 'Warning!', 'Status cant be changed from '+oldStatus+' to '+ currentStatus);
            event.getSource().set('v.value',oldStatus);
        }
            }
        });
        $A.enqueueAction(action); 
       
    }
})