({
    
     doInit: function (component, event, helper) {         
         var action = component.get("c.getLookupName");
         action.setParams({
             "recId": component.get('v.recordId')             
         });
         action.setCallback(this, function(response) {
             var state = response.getState();
             //alert(state);
             if (state === "SUCCESS") {
                 var returnvalue = response.getReturnValue();
				component.set("v.LookupFieldName",returnvalue);  
                 //alert(component.get("v.LookupFieldName"));
             }
         }); 
         $A.enqueueAction(action);
         
    },
    
    
	// common reusable function for toggle sections
    toggleSection : function(component, event, helper) {
        // dynamically get aura:id name from 'data-auraId' attribute
        var sectionAuraId = event.target.getAttribute("data-auraId");
        // get section Div element using aura:id
        var sectionDiv = component.find(sectionAuraId).getElement();
        /* The search() method searches for 'slds-is-open' class, and returns the position of the match.
         * This method returns -1 if no match is found.
        */
        var sectionState = sectionDiv.getAttribute('class').search('slds-is-open'); 
        
        // -1 if 'slds-is-open' class is missing...then set 'slds-is-open' class else set slds-is-close class to element
        if(sectionState == -1){
            sectionDiv.setAttribute('class' , 'slds-section slds-is-open');
        }else{
            sectionDiv.setAttribute('class' , 'slds-section slds-is-close');
        }
    },
    
    addRow: function(component, event, helper) {
        if (helper.validateList(component, event)) {
        	helper.addRecord(component, event);
        }
    },
     
    removeRow: function(component, event, helper) {
        //Get the account list
        var actionItemsList = component.get("v.actionItemsList");
        //Get the target object
        var selectedItem = event.currentTarget;
        //alert(selectedItem);
        //Get the selected item index
        var index = selectedItem.dataset.record;
        //alert(index);
        actionItemsList.splice(index, 1);
        component.set("v.actionItemsList", actionItemsList);
    },
     
    save: function(component, event, helper) {
        if (helper.validateList(component, event)) {
            helper.saveActionItemsList(component, event);
        }
    },
    
    handleOnChange : function(component,event,helper){
        var addrows= component.get("v.actionItemsList");
        //alert(JSON.stringify(addrows)) 
    },
     
    searchPicklist : function(component,event,helper){
        var selectedItem = event.currentTarget;
        //alert(selectedItem);
        //Get the selected item index
        var index = selectedItem.dataset.record;
        component.set("v.isOwnerLookupOpen",true);
        component.set("v.selectedIndex",index);
        //alert(index);
        //var actionItemsList = component.get("v.actionItemsList");
        //actionItemsList[index].buildertek__Description__c = 'test';
        //alert(actionItemsList[index].buildertek__Description__c);        
    },
    
     handleSubmit: function (component, event, helper) {  
         var fields = event.getParam("fields");      
         alert(component.get('v.toggleClicked'));
         var lookupname = component.get("v.LookupFieldName");
         //alert(lookupname);
         fields[lookupname] = component.get('v.recordId');
         // alert(fields[lookupname]);
         var addrows= component.get("v.actionItemsList");
		//alert('addrows.length------  '+addrows.length);
         if(fields['buildertek__Subject__c']!='' ){
             // var getcon = '';
             component.set("v.IsSpinner",true);
        
             event.preventDefault(); // Prevent default submit
        	component.find('recordViewForm').submit(fields); // Submit form     
         }else{
             var toastEvent = $A.get("e.force:showToast");
             toastEvent.setParams({
                 title : "Error!",
                 message : 'Please enter required fields',
                 type: 'error',
                 duration: '10000',
                 key: 'info_alt',
                 mode: 'pester'
             });
             toastEvent.fire();
         }
        
         console.log('after submit');
    },

    onRecordSuccess: function (component, event, helper) {
        //alert(JSON.stringify(component.get("v.selectedFiles")));
        component.set("v.IsSpinner",false);
        console.log('onRecordSuccess');
        //alert('sucess');
        /*var urlString = window.location.href;
        var baseURL = urlString.substring(0, urlString.indexOf("/s"));*/
        var payload = event.getParams().response;
        var eventId = (payload.id).replace('"','').replace('"',''); 
         component.set("v.MeetingId",eventId);
		//alert(eventId);     
        var actionItemsList = component.get("v.actionItemsList");
        //alert(actionItemsList.length);
        if(actionItemsList.length>0){
           // if (helper.validateList1(component, event)) {
           component.set("v.isOwnerLookupOpen",true);
            //alert(JSON.stringify(component.get("v.actionItemsList")));
	        //helper.saveActionItemsList1(component, event, helper,eventId);
            //}else{
                //alert(JSON.stringify(component.get("v.actionItemsList")));
	       // helper.saveActionItemsList(component, event, helper,eventId);
            //}
        }else{            
             var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : "Success!",
                    message : 'New meeting created successfully',
                    type: 'success',
                    duration: '10000',
                    key: 'info_alt',
                    mode: 'pester'
                });
                toastEvent.fire();
            
            var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": eventId,
                    "slideDevName": "related"
                });
                navEvt.fire();
        }
        
    },
    closeModel: function (component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get('v.recordId'),
            "slideDevName": "related"
        });
        navEvt.fire();
    },

   
    
    handleComponentEvent : function(component, event, helper) {
        var ownerId = event.getParam("ownerId");
        //alert(ownerId);
        var rowIndex = event.getParam("datarowIndex");
        //alert(rowIndex);
        var actionItemsList = component.get("v.actionItemsList");
        actionItemsList[rowIndex].buildertek__Owner__c = ownerId;
        //alert(actionItemsList[rowIndex].buildertek__Owner__c);
        
    },
    
    submitDetails:  function(component, event, helper) {
        var meetingRecId=component.get("v.MeetingId");
        //alert('meetingRecId --------'+meetingRecId);
        component.set("v.IsSpinner",true);
        component.set("v.isOwnerLookupOpen",false);
        helper.saveActionItemsList(component, event, helper,meetingRecId);
    },
     closeAlert: function (component, event, helper) {
          var meetingRecId=component.get("v.MeetingId");
       // alert('meetingRecId --------'+meetingRecId);
        component.set("v.isOwnerLookupOpen",false);
         if(meetingRecId){
          var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : "Success!",
                    message : 'New meeting created successfully',
                    type: 'success',
                    duration: '10000',
                    key: 'info_alt',
                    mode: 'pester'
                });
                toastEvent.fire();
               var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": meetingRecId,
                    "slideDevName": "related"
                });
                navEvt.fire();
        
         }else{
             var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : "Fail!",
                    message : 'Fail to create meeting!',
                    type: 'error',
                    duration: '10000',
                    key: 'info_alt',
                    mode: 'pester'
                });
                toastEvent.fire();
         }
         
    },
    
    
    
    
    
    
})