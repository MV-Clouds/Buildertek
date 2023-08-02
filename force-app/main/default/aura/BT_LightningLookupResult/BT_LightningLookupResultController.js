({
   selectRecord : function(component, event, helper){      
    // get the selected record from list  
      var getSelectRecord = component.get("v.oRecord");
      var getSelectRecordId = component.get("v.oRecord").Id;
      component.set("v.selectedValue", getSelectRecordId);
      var vx = component.get("v.change");
        //fire event from child and capture in parent
      $A.enqueueAction(vx);
    // call the event   
      var compEvent = component.getEvent("oSelectedRecordEvent");
    // set the Selected sObject Record to the event attribute.  
         compEvent.setParams({"recordByEvent" : getSelectRecord,"recordByEventstring": component.get("v.ObjectAPIName")});  
    // fire the event  
         compEvent.fire();
    },
})