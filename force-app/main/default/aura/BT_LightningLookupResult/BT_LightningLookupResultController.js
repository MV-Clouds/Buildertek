({
   selectRecord : function(component, event, helper){      
    // get the selected record from list  
      var getSelectRecord = component.get("v.oRecord");
      var pricebookEntrybyProd = getSelectRecord.PricebookEntries != null ? getSelectRecord.PricebookEntries[0] : null; 
      delete getSelectRecord.PricebookEntries; // Delete Pricebook entry after store in variable....
      var getSelectRecordId = component.get("v.oRecord").Id;
      component.set("v.selectedValue", getSelectRecordId);
      var vx = component.get("v.change");
        //fire event from child and capture in parent
      $A.enqueueAction(vx);
    // call the event   
      var compEvent = component.getEvent("oSelectedRecordEvent");
    // set the Selected sObject Record to the event attribute.  
         compEvent.setParams({
          "recordByEvent" : getSelectRecord,
          "PricebookEntryrecordByEvent" : pricebookEntrybyProd,
          "recordByEventstring": component.get("v.ObjectAPIName"),
          "phaseIndex" : component.get("v.phaseIndex"),
          "index": component.get("v.index"),
        });  
    // fire the event  
         compEvent.fire();
    },
})