({
    onfocus : function(component,event,helper){
        //component.find("fieldSelect").set("v.autocomplete","off");
        $A.util.addClass(component.find("mySpinner"), "slds-show");
        var forOpen = component.find("searchRes");
        component.set("v.showDropDownList",true);  //---
        component.set("v.enableBackShadow", true);
        $A.util.addClass(forOpen, 'slds-is-open');
        $A.util.removeClass(forOpen, 'slds-is-close');
        // Get Default 5 Records order by createdDate DESC  
        var getInputkeyWord = '';
        helper.searchHelper(component,event,getInputkeyWord);
        
        //hide drop down on click on body
        window.setTimeout(
            $A.getCallback(function() {
                if(document.getElementsByClassName('wrapper') && component.get("v.fromComp")){
                    document.getElementsByClassName('wrapper')[0].addEventListener("click",function(eve){
                        console.log(eve)
                        if(Object.keys(eve.target)){
                            if(!eve.target.dataset.fromcmp){
                                component.set("v.showDropDownList",false)
                                component.set("v.listOfSearchRecords", null );
                                var forclose = component.find("searchRes");
                                $A.util.addClass(forclose, 'slds-is-close');
                                $A.util.removeClass(forclose, 'slds-is-open');
                            }
                        }
                        
                    })
                    event.stopPropagation()
                }
            }),1)
        
    },
    onblur : function(component,event,helper){ 
        window.setTimeout(
            $A.getCallback(function() {
                component.set("v.listOfSearchRecords", null );
                var forclose = component.find("searchRes");
                $A.util.addClass(forclose, 'slds-is-close');
                $A.util.removeClass(forclose, 'slds-is-open');
            }), 1000
        );
    },
    
    keyPressController : function(component, event, helper) {
        // get the search Input keyword   
        var getInputkeyWord = component.get("v.SearchKeyWord");
        // check if getInputKeyWord size id more then 0 then open the lookup result List and 
        // call the helper 
        // else close the lookup result List part.   
        if( getInputkeyWord.length > 0 ){
            var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component,event,getInputkeyWord);
        }
        else{  
            component.set("v.listOfSearchRecords", null ); 
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
    },
    
    // function for clear the Record Selaction 
    clear :function(component,event,heplper){
        //alert('Clear Lookup');
        var pillTarget = component.find("lookup-pill");
        var lookUpTarget = component.find("lookupField"); 

        if (component.get("v.SelectMultiRecord")){

            var recordId = event.target.id;
            var RecordList = component.get("v.RecordList");
            var newRecordList = [];
            RecordList.forEach(element => {
                if (element.Id != recordId) {
                    newRecordList.push(element);
                }
            });
            // RecordList.pop();
            if (newRecordList.length == 0) {
                $A.util.addClass(pillTarget, 'slds-hide');
                $A.util.removeClass(pillTarget, 'slds-show');
            } else {
                $A.util.addClass(pillTarget, 'slds-show');
                $A.util.removeClass(pillTarget, 'slds-hide');
            }
            component.set("v.RecordList", newRecordList);

            var compEvent = $A.get('e.c:passRecordListEvent');
            compEvent.setParams({
                "recordListByEvent": newRecordList
            });
            compEvent.fire();

            
        } else {
            $A.util.addClass(pillTarget, 'slds-hide');
            $A.util.removeClass(pillTarget, 'slds-show');
        }

        $A.util.addClass(lookUpTarget, 'slds-show');
        $A.util.removeClass(lookUpTarget, 'slds-hide');
        
        component.set("v.SearchKeyWord",null);
        component.set("v.listOfSearchRecords", null );
        component.set("v.selectedRecord", {} ); 
        
        var compEvent = $A.get('e.c:ClearLookupvalueEvent');
        compEvent.setParams({
            "recordByEvent": {}
        });
        compEvent.fire();
        
    },
    
    clearLookupValue : function(component,event,heplper){
        //alert('Clear Lookup');
        var pillTarget = component.find("lookup-pill");
        var lookUpTarget = component.find("lookupField"); 
        
        $A.util.addClass(pillTarget, 'slds-hide');
        $A.util.removeClass(pillTarget, 'slds-show');
        
        $A.util.addClass(lookUpTarget, 'slds-show');
        $A.util.removeClass(lookUpTarget, 'slds-hide');
        
        component.set("v.SearchKeyWord",null);
        component.set("v.listOfSearchRecords", null );
        component.set("v.selectedRecord", {} );   
    },
    
    // This function call when the end User Select any record from the result list.   
    handleComponentEvent : function(component, event, helper) {
        // get the selected Account record from the COMPONETN event 	 
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        component.set("v.selectedRecord" , selectedAccountGetFromEvent); 
        component.set("v.recordName" , selectedAccountGetFromEvent.Name); 
        
        // For multiselect record
        if (component.get("v.SelectMultiRecord")) {
            var RecordList = component.get("v.RecordList");
            RecordList.push(selectedAccountGetFromEvent);
            component.set("v.RecordList", RecordList);

            var forclose = component.find("lookup-pill");
            $A.util.addClass(forclose, 'slds-show');
            $A.util.removeClass(forclose, 'slds-hide');

            // Allow 3 record in multiselect field
            if (RecordList.length == 3) {
                var forclose = component.find("searchRes");
                $A.util.addClass(forclose, 'slds-is-close');
                $A.util.removeClass(forclose, 'slds-is-open');
                
                var lookUpTarget = component.find("lookupField");
                $A.util.addClass(lookUpTarget, 'slds-hide');
                $A.util.removeClass(lookUpTarget, 'slds-show');  
            }

            var testing = component.get("v.RecordList");
            testing.forEach(element => {
                console.log('Id -> ' + element.Id + ' Name -> ' + element.Name);
            });
            var compEvent = $A.get('e.c:passRecordListEvent');
            compEvent.setParams({
                "recordListByEvent": RecordList
            });
            compEvent.fire();

        } else {
            var forclose = component.find("lookup-pill");
            $A.util.addClass(forclose, 'slds-show');
            $A.util.removeClass(forclose, 'slds-hide');
            
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
            
            var lookUpTarget = component.find("lookupField");
            $A.util.addClass(lookUpTarget, 'slds-hide');
            $A.util.removeClass(lookUpTarget, 'slds-show');  
        }
        
        
    },
    
    DisableBackShadow : function(component, helper, event) { //---
        var backshadow = component.get("v.enableBackShadow");
        if(backshadow){
            component.set("v.enableBackShadow", false);
            component.set("v.showDropDownList",false);
            console.log('Hide Dropdown');
        };
    },
})