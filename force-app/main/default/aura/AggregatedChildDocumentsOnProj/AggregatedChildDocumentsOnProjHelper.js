({
   ChildObjectNameHelper:function(component, event, helper){
    
      var action=component.get('c.getChildObectName');
      action.setCallback(this, function (response) {
          console.log(response.getError());            
          let state=response.getState();
          if(state == 'SUCCESS'){
              let result=response.getReturnValue();
              console.log(result);

              var objectNameMap = [];

              for(var key in result){
                  if(key.includes('buildertek')){
                      objectNameMap.push({key: key, value: result[key]});
                  }
              }
              component.set('v.childObjectNameMap' ,objectNameMap );
              console.log(component.get('v.childObjectNameMap'));

          }else{
              var toastEvent = $A.get("e.force:showToast");
              toastEvent.setParams({
                  "title": "Error!",
                  "type": "error",
                  "message": "Something went wrong."  
              });
              toastEvent.fire();
          }

          $A.get("e.c:BT_SpinnerEvent").setParams({
              "action": "HIDE"
          }).fire();
      });
      $A.enqueueAction(action);

   },
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
            });
            action.setCallback(this, function (response) {
               console.log(response.getError());            
               let state=response.getState();
               if(state == 'SUCCESS'){
                  let result=response.getReturnValue();
                  console.log(result);
                  if(result != null && result!= undefined && result != ''){
                     console.log(result);

                      const reduceData = Object.values(result.reduce((acc, cur) => { 
                          acc[cur.ParentId] = acc[cur.ParentId] || { ParentId: cur.ParentId, contentDocumentLinks: [], ParentName:cur.ParentName};
                          acc[cur.ParentId].contentDocumentLinks.push({ ContentDocumentId: cur.ContentDocumentId , orgBaseURL:cur.orgBaseURL});
                          return acc;
                      }, {}));
                     component.set('v.attachmentData' , reduceData);



                     var getAttachedDocsLength=component.get('v.attachmentData').length;
                     var totalPages=Math.ceil(getAttachedDocsLength/5);
                     var page=component.get('v.page');
                     var pageSize=component.get('v.pageSize');
                     const trimStart = (page - 1) * pageSize;
                     const trimEnd = trimStart + pageSize;
                     var filterData=[...reduceData.slice(trimStart , trimEnd)];
                     component.set('v.filterAttachedData' , filterData);
                     component.set('v.totalPages' , totalPages);
                     console.log({trimStart});
                     console.log({trimEnd});

                  }else{
                        component.set('v.filterAttachedData' , []);
                  }

                  $A.get("e.c:BT_SpinnerEvent").setParams({
                        "action": "HIDE"
                  }).fire();

               }else{
                  component.set('v.filterAttachedData' , []);

                  $A.get("e.c:BT_SpinnerEvent").setParams({
                        "action": "HIDE"
                  }).fire();
               }
               
            });
            $A.enqueueAction(action);
      }else{
         component.set('v.filterAttachedData' , []);
         $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "HIDE"
      }).fire();
      }
   
  }
})