({
   onfocus : function(component,event,helper){
       $A.util.addClass(component.find("mySpinner"), "slds-show");
        var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
        // Get Default 5 Records order by createdDate DESC  
       if(!component.get("v.SearchKeyWord")){
           var getInputkeyWord = '';
       }else{
           var getInputkeyWord = component.get("v.SearchKeyWord");
       }
         
         helper.searchHelper(component,event,getInputkeyWord);
    },
    onblur : function(component,event,helper){  
        window.setTimeout(
            $A.getCallback(function() {
                component.set("v.listOfSearchRecords", null );
                console.log('list of records' + component.get("v.listOfSearchRecords"));
                var forclose = component.find("searchRes");
                $A.util.addClass(forclose, 'slds-is-close');
                $A.util.removeClass(forclose, 'slds-is-open');    
            }), 1000
        );
    },
    clearOldValues : function(component, event, helper) {
        var getInputkeyWord = component.get("v.SearchKeyWord");
        if(getInputkeyWord == undefined){
            var getSelectedRecord = '{"Id":"","Name":""}';
            var result = JSON.parse(getSelectedRecord);
            var compEvent = component.getEvent("SelectedRecordEvent");
            compEvent.setParams({"recordByEvent" : {},"recordByEventstring": component.get("v.objectAPIName") });  
            compEvent.fire();
        }else if(getInputkeyWord.length == 0){
            var getSelectedRecord = '{"Id":"","Name":""}';
            var result = JSON.parse(getSelectedRecord);
            var compEvent = component.getEvent("SelectedRecordEvent");
            compEvent.setParams({"recordByEvent" : {},"recordByEventstring": component.get("v.objectAPIName") });  
            compEvent.fire();
        }
    },
    keyPressController : function(component, event, helper) {
       // get the search Input keyword   
         var getInputkeyWord = component.get("v.SearchKeyWord");
       // check if getInputKeyWord size id more then 0 then open the lookup result List and 
       // call the helper 
       // else close the lookup result List part. 
       if( getInputkeyWord == undefined ){
             var forOpen = component.find("searchRes");
               $A.util.addClass(forOpen, 'slds-is-open');
               $A.util.removeClass(forOpen, 'slds-is-close');
           helper.searchHelper(component,event,getInputkeyWord);
        }else if  ( getInputkeyWord.length > 0 ){
             var forOpen = component.find("searchRes");
               $A.util.addClass(forOpen, 'slds-is-open');
               $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component,event,getInputkeyWord);
        }
        else{ 
             component.set("v.listOfSearchRecords", null ); 
             console.log('list of records' + component.get("v.listOfSearchRecords"));

             var forclose = component.find("searchRes");
               $A.util.addClass(forclose, 'slds-is-close');
               $A.util.removeClass(forclose, 'slds-is-open');
          }
	},
    
  // function for clear the Record Selaction 
    clear :function(component,event,helper){
        //alert('Hiiiiii');
         var pillTarget = component.find("lookup-pill");
         var lookUpTarget = component.find("lookupField"); 
        
         $A.util.addClass(pillTarget, 'slds-hide');
         $A.util.removeClass(pillTarget, 'slds-show');
        
         $A.util.addClass(lookUpTarget, 'slds-show');
         $A.util.removeClass(lookUpTarget, 'slds-hide');
         
         component.set("v.SearchKeyWord",'');
         component.set("v.listOfSearchRecords", null );
         console.log('list of records' + component.get("v.listOfSearchRecords"));

         component.set("v.selectedRecord", {} );  
         var getInputkeyWord = component.get("v.SearchKeyWord");
        if(getInputkeyWord == undefined){
             var getSelectedRecord = '{"Id":"","Name":""}';
            var result = JSON.parse(getSelectedRecord);
            var compEvent = component.getEvent("SelectedRecordEvent");
            compEvent.setParams({"recordByEvent" : {},"recordByEventstring": component.get("v.objectAPIName") });  
            compEvent.fire();
        }else if(getInputkeyWord.length == 0){
            var getSelectedRecord = '{"Id":"","Name":""}';
            var result = JSON.parse(getSelectedRecord);
            var compEvent = component.getEvent("SelectedRecordEvent");
            compEvent.setParams({"recordByEvent" : {},"recordByEventstring": component.get("v.objectAPIName") });  
            compEvent.fire();
        }
        component.set('v.childValue' , '');
         
        
    },
    
  // This function call when the end User Select any record from the result list.   
    handleComponentEvent : function(component, event, helper) {
    // get the selected Account record from the COMPONETN event 	 
       var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        console.log("##########record By Event",JSON.stringify(selectedAccountGetFromEvent)); 
	   component.set("v.selectedRecord" , selectedAccountGetFromEvent);
	   
       
        var forclose = component.find("lookup-pill");
           $A.util.addClass(forclose, 'slds-show');
           $A.util.removeClass(forclose, 'slds-hide');
  
        var forclose = component.find("searchRes");
           $A.util.addClass(forclose, 'slds-is-close');
           $A.util.removeClass(forclose, 'slds-is-open');
        
        var lookUpTarget = component.find("lookupField");
            $A.util.addClass(lookUpTarget, 'slds-hide');
            $A.util.removeClass(lookUpTarget, 'slds-show');
       
        var compEvent = component.getEvent("SelectedRecordEvent");
        compEvent.setParams({"recordByEvent" : selectedAccountGetFromEvent,"recordByEventstring": ''}); 
        compEvent.fire();        
      
	},
	
	handlecmp : function(component, event, helper) {
	    //alert('Hiiiii Pavan');
	    $A.enqueueAction(component.get('c.clear'));
	},
	
	getSelectedLookupValue : function(component, event, helper) {
	    var selectValue = component.get("v.selectedRecord").Id;
	    component.set("v.selectedLookupValue", selectValue);
	    var vx = component.get("v.method");
        //fire event from child and capture in parent
        $A.enqueueAction(vx);
	},
    
    handleChildBudgetLineLookupEvent : function(component, event, helper) {
	    
       /* var product = JSON.parse(JSON.stringify(event.getParam("message")));
        console.log('product-->',product);
        
        if(product.Id){
             component.set("v.selectedRecord" , product);
            component.set("v.selectedLookupValue", product.Id);
            var storeResponse = [];
            storeResponse.push(product) 
            component.set("v.listOfSearchRecords", storeResponse);
        }
        
        var vx = component.get("v.method");
        $A.enqueueAction(vx);*/
        console.log(JSON.parse(JSON.stringify(event.getParam("message"))))
        console.log(JSON.parse(JSON.stringify(component.get("v.selectedRecord")))); 
        console.log(component.get("v.massBudgetLineIndex"))
        var messageFromBudgetLine = JSON.parse(JSON.stringify(event.getParam("message")))
        var indexbudgetLine = component.get("v.massBudgetLineIndex")
        if(Object.keys(messageFromBudgetLine).length){
            if(indexbudgetLine == messageFromBudgetLine.index){
                var pillTarget = component.find("lookup-pill");
                var lookUpTarget = component.find("lookupField"); 
                
                $A.util.addClass(pillTarget, 'slds-hide');
                $A.util.removeClass(pillTarget, 'slds-show');
                
                $A.util.addClass(lookUpTarget, 'slds-show');
                $A.util.removeClass(lookUpTarget, 'slds-hide');
                
                component.set("v.SearchKeyWord",'');
                component.set("v.listOfSearchRecords", null );
                console.log('list of records' + component.get("v.listOfSearchRecords"));

                component.set("v.selectedRecord", {} );  
                var getInputkeyWord = component.get("v.SearchKeyWord");
                if(getInputkeyWord == undefined){
                    var getSelectedRecord = '{"Id":"","Name":""}';
                    var result = JSON.parse(getSelectedRecord);
                    var compEvent = component.getEvent("SelectedRecordEvent");
                    compEvent.setParams({"recordByEvent" : {},"recordByEventstring": component.get("v.objectAPIName") });  
                    compEvent.fire();
                }else if(getInputkeyWord.length == 0){
                    var getSelectedRecord = '{"Id":"","Name":""}';
                    var result = JSON.parse(getSelectedRecord);
                    var compEvent = component.getEvent("SelectedRecordEvent");
                    compEvent.setParams({"recordByEvent" : {},"recordByEventstring": component.get("v.objectAPIName") });  
                    compEvent.fire();
                }
            }
        }
        
        
        
	},
    
    
    
})