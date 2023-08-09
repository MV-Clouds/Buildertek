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
    
    
    
     fetchSOVLinesList: function(component,event,helper,recordId) {
          debugger;
          console.log("Inside helper getAccountListHelper method");
          //call apex class method
          var action = component.get("c.getVendorSOVLines");
          var a= recordId;
         
          console.log("Record ID is: "+a);
          
          action.setParams({
              SOVId : a
          });
          
          action.setCallback(this, function(response) {
              debugger;
              console.log('Inside setcallback method of helper');
              var state = response.getState();
              if(state === "SUCCESS"){
                 
                  var result = response.getReturnValue();
                  
                  var VendorSOVLinesList = result.VendorSOVLinesList;
                  
                 
                  component.set("v.sovLineList",VendorSOVLinesList);
                  
                  
                  
                  var allids = [];
                  for(var i=0;i<VendorSOVLinesList.length;i++){
                      allids.push(VendorSOVLinesList[i].Id);
                    
                  }
                  component.set("v.sovLineListIds",allids);
                  
                  
                 
              }
          });
   		console.log('Exiting helper');
        $A.enqueueAction(action);
      },
    
})