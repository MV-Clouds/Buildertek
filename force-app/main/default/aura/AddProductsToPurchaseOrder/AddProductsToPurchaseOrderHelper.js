({
    showErrorToast: function (component, event, helper, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
           
            message: message,
            duration: "5000",
            key: "info_alt",
            type: "error",
            mode: "pester",
        });
        toastEvent.fire();
    },
    showSuccessToast: function (component, event, helper, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            duration: "5000",
            key: "info_alt",
            type: "success",
            mode: "pester",
        });
        toastEvent.fire();
    },
     addProductsToPO :function (component, event, helper, productIds, RfqId) {
         var myPageRef = component.get("v.pageReference");
        var recordId = myPageRef.state.buildertek__parentId;
         //alert('recordId in helper'+recordId)
        if(!recordId){
            recordId = component.get("v.recordId");
        }
        var action = component.get("c.addProductToPO");
         component.set("v.Spinner", true);
            component.set("v.showMessage", true);
        //alert('working')
        action.setParams({
            "productIds" : productIds,
            "RfqId" : recordId
        });
        action.setCallback(this,function(response){
          
            if(response.getState() == "SUCCESS"){
                console.log(response);
                 var workspaceAPI = component.find("workspace");
                    workspaceAPI.getFocusedTabInfo().then(function (response) {
                        var focusedTabId = response.tabId;
                        workspaceAPI.closeTab({
                            tabId: focusedTabId
                        });
                    }).catch(function (error) {
                        console.log('Error', JSON.stringify(error));
                    }); 
                var recId = response.getReturnValue();
               // alert(recId);
                
                            
                helper.showSuccessToast(component,event,helper, "Success!",'Purchase Order Lines Imported Successfully ');
                $A.get("e.force:closeQuickAction").fire();
                 setTimeout(function(){ location.reload(); }, 1800);
                 component.set("v.Spinner", false);
                component.set("v.showMessage", false);
                $A.get("e.force:navigateToSObject").setParams({
                    "recordId": recordId,
                    "slideDevName": "detail"
                }).fire();
                
            //}else{
              // var urlEvent = $A.get("e.force:navigateToURL");
                            //urlEvent.setParams({
                                //"url": '/lightning/r/buildertek__Purchase_Order_Items__r/'+recordId+'/related/buildertek__AddProductsToPurchaseOrder?buildertek__parentId=&uid=1621403805112' 
            }else{
                helper.showErrorToast(component,event,helper,"Error occurs","Something went wrong!");
            }
        });
        $A.enqueueAction(action);
    },
    getRfqList: function (component, event, helper, pageNumber, pageSize, productFamilyValue, tradeValue, productTypeValue, productValue, productCategoryValue, priceBook){
        var action = component.get("c.getProducts");
       
        var recId = component.get("v.recordId");
        action.setParams({
            "pageNumber" : pageNumber,
            "pageSize": pageSize,
            "RFQRecId" : recId,
            "productFamily" : productFamilyValue.trim(),
            "tradeType":tradeValue.trim(),
            "productType" : productTypeValue.trim(),
            "Product" : productValue.trim(),
            "category" : productCategoryValue.trim(),
            "priceBook" : priceBook.trim()
            
        });
        action.setCallback(this, function (result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS") {
                var resultData = result.getReturnValue();
                
                component.set("v.rfqRecordList", resultData.recordList);
                component.set("v.PageNumber", resultData.pageNumber);
                component.set("v.TotalRecords", resultData.totalRecords);
                component.set("v.RecordStart", resultData.recordStart);
                component.set("v.RecordEnd", resultData.recordEnd);
                component.set(
                    "v.TotalPages",
                    Math.ceil(resultData.totalRecords / pageSize)
                );
            }
        });  
        $A.enqueueAction(action);
    } 
})