({
   loadRecords: function(component, event, helper) {
      $A.get('e.force:refreshView').fire();
      var objectName = component.get("v.selectedObj");
      console.log(objectName);
      $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
      }).fire();

      if(objectName != undefined && objectName != ''){
            var action = component.get("c.getAttachement");
            action.setParams({
               "objectName": objectName,
               "projectId": component.get('v.recordId'),
               "page": component.get("v.page"),
               "pageSize": component.get("v.pageSize")
            });
            action.setCallback(this, function (response) {
               console.log(response.getError());            
               let state=response.getState();
               if(state == 'SUCCESS'){
                  let result=response.getReturnValue();
                  console.log(result);
                  if(result != null && result!= undefined && result != ''){
                     //  const output = Object.values(result.records.reduce((acc, cur) => { 
                     //      acc[cur.LinkedEntityName] = acc[cur.LinkedEntityName] || { LinkedEntityName: cur.LinkedEntity.Name, contentDocumentLinks: [] ,LinkedEntityId:cur.LinkedEntityId };
                     //      acc[cur.LinkedEntityName].contentDocumentLinks.push({ ContentDocumentId: cur.ContentDocumentId});
                     //    //   acc[cur.LinkedEntityName].

                     //      return acc;
                     //  }, {}))
                        component.set('v.attachmentData' , result.records);
                        console.log(component.get('v.attachmentData'));
                        component.set('v.totalPages' , result.totalPages);
                        component.set('v.orgBaseURL' , result.orgBaseURL);
                  }else{
                        component.set('v.attachmentData' , []);
                  }
                  $A.get("e.c:BT_SpinnerEvent").setParams({
                        "action": "HIDE"
                  }).fire();

               }else{
                  component.set('v.attachmentData' , []);

                  $A.get("e.c:BT_SpinnerEvent").setParams({
                        "action": "HIDE"
                  }).fire();
                  // var toastEvent = $A.get("e.force:showToast");
                  // toastEvent.setParams({
                  //       "title": "Error!",
                  //       "type": "error",
                  //       "message": "Something went wrong."  
                  // });
                  // toastEvent.fire();
               }
               
            });
            $A.enqueueAction(action);
      }else{
         component.set('v.attachmentData' , []);
         $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "HIDE"
      }).fire();
      }
   
  }
})