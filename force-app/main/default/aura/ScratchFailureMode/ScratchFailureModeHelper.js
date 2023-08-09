({
    saveSelection : function( component, event, helper ) {
        var sRec = component.get("v.selectedIssue");
        if(component.get("v.componentName") === 'IGU'){
            var FMProvideDetailsIGUEvt = component.getEvent( "FMProvideDetailsIGUEvt" );
            if( !FMProvideDetailsIGUEvt ) {
                return;
            }
            
            FMProvideDetailsIGUEvt.setParams({
                'selectedIssue' : sRec,
                'ValuesProvided' : true
            });
            FMProvideDetailsIGUEvt.fire();
        }else if(component.get("v.componentName") === 'CHW'){
            var FMProvideDetailsCHWEvt = component.getEvent( "FMProvideDetailsCHWEvt" );
            if( !FMProvideDetailsCHWEvt ) {
                return;
            }
            
            FMProvideDetailsCHWEvt.setParams({
                'selectedIssue' : sRec
            });
            FMProvideDetailsCHWEvt.fire();
        }else if(component.get("v.componentName") === 'PMUpdate'){
            var PMProvideDetailsIGUEvt = component.getEvent( "PMProvideDetailsIGUEvt" );
            if( !PMProvideDetailsIGUEvt ) {
                return;
            }
            
            PMProvideDetailsIGUEvt.setParams({
                'selectedIssue' : sRec
            });
            PMProvideDetailsIGUEvt.fire();
        }else{
            var wrapRec = component.get("v.LogIssueWrapper");
            var FMProvideDetailsEvt = component.getEvent( "FMProvideDetailsEvt" );
            if( !FMProvideDetailsEvt ) {
                return;
            }
            
            FMProvideDetailsEvt.setParams({
                'LogIssueWrapper' : wrapRec,
                'recordIndex' : component.get("v.recordIndex"),
                'ListName' : component.get("v.ListName"),
                'ValuesProvided' : true
            });
            FMProvideDetailsEvt.fire();
        }
        
        this.closeModal( component );
    },
    closeModal : function( component ) {
        component.destroy();
    },
    showToastMessage: function (type, title, message) {
        
        if (type && title && message) {
            var toastEvent = $A.get("e.force:showToast");
            
            if (toastEvent) {
                toastEvent.setParams({
                    'type': type,
                    'title': title,
                    'message': message,
                    'duration': 8000
                });
                toastEvent.fire();
            }
        }
    },
})