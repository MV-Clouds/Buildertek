({
    doInit : function(component, event, helper) {
        component.set('v.mycolumns', [
            {label: 'Package Name', fieldName: 'buildertek__Package_Name__c', type: 'text'},
            {label: 'Type', fieldName: 'buildertek__Type__c', type: 'text'}
        ]);
     //   component.set('v.isModalOpen',true); 
        var action2 = component.get('c.getPackage');
        action2.setCallback(this, function(response) {
           if(response.getState() === "SUCCESS"){ 
               var result = response.getReturnValue();
               component.set('v.listPackage',result);
           }
        });
        $A.enqueueAction(action2); 
        
   /*      var action3 = component.get('c.getPicklist');
        action3.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS"){
                var result = response.getReturnValue();
                component.set("v.PickListValuesList",result);
            }
        });
        $A.enqueueAction(action3); */
        
        
    },
    closeModel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    handleClick : function(component, event, helper) {
        component.set("v.Spinner",true);
        debugger;
        var action = component.get('c.insertPackage');
        action.setParams({
            name : component.get('v.PackageName'),
            type :component.get('v.Type') 
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
               component.set('v.isModalOpen',false);
                component.set('v.isPopOpen',open);
                var result = response.getReturnValue();
                component.set("v.CreatedRecordId",result);
                 component.set("v.Spinner",false);
            }
              
        });
        var allValid = component.find('fieldId').reduce(function (validSoFar, inputCmp) {
        inputCmp.showHelpMessageIfInvalid();
        return validSoFar && !inputCmp.get('v.validity').valueMissing;
     }, true);
       
        if(allValid) {
            $A.enqueueAction(action);
        }else{
            
        }
        
        
        
        
    },
      closePopup : function(component, event, helper) {
       		 $A.get("e.force:closeQuickAction").fire();
    },
    
     getSeletedPAIds: function (component, event) {
        
        var selectedRows = event.getParam('selectedRows');
        var y =[];
        component.set("v.listOfSelectedIds",y);
        var selectedRowList =component.get("v.listOfSelectedIds")
        
        // Display that fieldName of the selected rows
        for (var i = 0; i < selectedRows.length; i++){
            if(selectedRowList.indexOf(selectedRows[i].Id) < 0){
                selectedRowList.push(selectedRows[i].Id)
            }
            component.set("v.listOfSelectedIds",selectedRowList)
           
           // alert("You selected: " + selectedRows[i].Id);
        }
        
    },
    importTakeoffLinesFromPackage : function(component, event, helper) {
      //  alert (!component.get('v.listOfSelectedIds'));
        var check = component.get('v.listOfSelectedIds');
        if(check.length > 0)
              
        {
    		  component.set("v.Spinner",true);
         var action = component.get('c.ImportLines');
        action.setParams({
           "RecId" : component.get('v.CreatedRecordId'),
            "SelectedRecordIds" :component.get('v.listOfSelectedIds') 
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                var result = response.getReturnValue();
                console.log(result);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type" : "success",
                    "message": "Lines imported successfully."
                });
                toastEvent.fire();
                
            /*    var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": component.get('v.CreatedRecordId'),
                    "slideDevName": "detail"
                });
                navEvt.fire(); */
              component.set("v.Spinner",false);
                 $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
            }
              
        });
        $A.enqueueAction(action);
        }
        else
        {
             var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error',
            message:'Please Select Package',
          //  duration:' 5000',
         //   key: 'info_alt',
            type: 'error',
          //  mode: 'pester'
        });
        toastEvent.fire();
        }
        
    }
    
    
})