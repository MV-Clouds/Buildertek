({

    
    getcurr : function (component, event, helper) {
        var action = component.get("c.getcurrency");
        action.setCallback(this, function (response) {
            var state = response.getState();
             if (state === "SUCCESS") {
                   component.set("v.currencycode",response.getReturnValue());
			} 
		});
		$A.enqueueAction(action);		
    },
	
    
    // Fetch the accounts from the Apex controller
      fetchSOVLinesList: function(component,event,helper,sovId) {
          debugger;
          console.log("Inside helper getAccountListHelper method");
          //call apex class method
          var action = component.get("c.getVendorSOVLines");
          var a= sovId;
         
          console.log("Record ID is: "+a);
          
          action.setParams({
              SOVId : a,
              
              
          });
          
          action.setCallback(this, function(response) {
              console.log('Inside setcallback method of helper');
              var state = response.getState();
              if(state === "SUCCESS"){
                  //set the wrapperClass attribute of component
                  //component.set('v.wrapperClass',response.getReturnValue());
                  var result = response.getReturnValue();
                  
                  var VendorSOVLinesList = result.VendorSOVLinesList;
                  
                  var TotalSovLinesCount = result.VendorSOVLinesList.length;
                  var approvedSovLinesCount = result.ApprovedSOVLinesCount;
                  
                  if(TotalSovLinesCount == approvedSovLinesCount){
                      component.set("v.hideheadCheck", true);
                  }
                
                  
                  component.set("v.SOVName", result.sovName);
                  var allids = [];
                    var aggresult = 0;  
                  for(var i=0;i<VendorSOVLinesList.length;i++){
                      allids.push(VendorSOVLinesList[i].Id);
                      
                      if(VendorSOVLinesList[i].buildertek__Scheduled_Value__c){
                        //alert(result[i].buildertek__Scheduled_Value__c);
                        aggresult += Number(VendorSOVLinesList[i].buildertek__Scheduled_Value__c); 
                    }
                  }
                  component.set("v.aggvalue",aggresult);
                  component.set("v.sovLineListIds",allids);
                 
                  component.set("v.sovLineList",VendorSOVLinesList);
                 
              }
          });
   		console.log('Exiting helper');
        $A.enqueueAction(action);
      },
    fetchvendorSOVonType : function(component,event,helper,sovId,filtercondition) {
        //alert(component.get("v.RejectedToggle")); 
        //alert(component.get("v.ApprovedToggle")); 
        //alert(component.get("v.PendingToggle")); 
        /*if(component.get("v.PendingToggle") == false && component.get("v.ApprovedToggle") == false && component.get("v.RejectedToggle") == false && component.get("v.VendorSubmittedToggle") == false){
            $A.get('e.force:refreshView').fire();
            
        }*/
        
        
        var action = component.get("c.getSOVlineslistbyType");
        action.setParams({
            SOVId: sovId,
            "filter" : filtercondition
        });
        action.setCallback(this, function (response) {
            var  result = response.getReturnValue();
            debugger;
            if (response.getState() == 'SUCCESS') {
                var result = response.getReturnValue();
                var aggresult = 0;
                for(var i=0;i<result.length;i++){
                    if(result[i].buildertek__Scheduled_Value__c){
                        //alert(result[i].buildertek__Scheduled_Value__c);
                        aggresult += Number(result[i].buildertek__Scheduled_Value__c); 
                    }
                }
                //alert(aggresult);
                component.set("v.aggvalue",aggresult);
                component.set("v.sovLineList",result);
                //alert(result.length);
            } 
            else {
               console.log('Error');
            }
        });
        $A.enqueueAction(action);
        
    },
    getSOVStatus : function(component,event,helper,sovId) {
        var action = component.get("c.getSOVdata");
        action.setParams({
            SOVId: sovId,
            
        });
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS') {
                var result = response.getReturnValue();
                component.set("v.SOVstatus",result.buildertek__Status__c);
                component.set("v.SOVType",result.buildertek__Type__c);
                //alert(result.buildertek__Status__c);
            }
        });
        $A.enqueueAction(action);
    }
    
    
})