({
    showErrorToast: function(component, event, helper, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            duration: "5000",
            key: "info_alt",
            type: "error",
            mode: "pester",
        });
        toastEvent.fire();
        component.set("v.Spinner", false);

    },
    showSuccessToast: function(component, event, helper, title, message) {
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

    addProductToRfqLines: function(component, event, helper, productIds, RfqId) {
        console.log({productIds});
        var action = component.get("c.addProductToRfq");
        component.set("v.Spinner", true);
        component.set("v.showMessage", true);
        action.setParams({
            "productIds": productIds,
            "RfqId": component.get("v.mainObjectId")
        });
        action.setCallback(this, function(response) {

            console.log(response.getState());
            console.log(response.getError());
            console.log(response.getReturnValue());


            if (response.getState() == "SUCCESS") {
                var recId = response.getReturnValue();
                // alert(recId);
                helper.showSuccessToast(component, event, helper, "Success!", 'Successfully added Rfq Line');
                $A.get("e.force:closeQuickAction").fire();
                // setTimeout(function() { location.reload(); }, 1000);
                component.set("v.Spinner", false);
                component.set("v.showMessage", false);


                var recordId = component.get("v.mainObjectId");
                $A.get("e.force:navigateToSObject").setParams({
                    "recordId": recordId

                }).fire();

                var workspaceAPI = component.find("workspace");
                workspaceAPI.getFocusedTabInfo().then(function(response) {
                    var focusedTabId = response.tabId;
                    workspaceAPI.refreshTab({
                            tabId: focusedTabId,
                            includeAllSubtabs: true
                    });
                })
                .catch(function(error) {
                    console.log(error);
                });

            } else {
                helper.showErrorToast(component, event, helper, "Error occurs", "Something went wrong!");
                component.set("v.Spinner", false);

                var recordId = component.get("v.mainObjectId");
                $A.get("e.force:navigateToSObject").setParams({
                    "recordId": recordId

                }).fire();

                var workspaceAPI = component.find("workspace");
                workspaceAPI.getFocusedTabInfo().then(function(response) {
                    var focusedTabId = response.tabId;
                    workspaceAPI.refreshTab({
                            tabId: focusedTabId,
                            includeAllSubtabs: true
                    });
                })
                .catch(function(error) {
                    console.log(error);
                });

            }
        });
        $A.enqueueAction(action);
    },
    getRfqList: function(component, event, helper, pageNumber, pageSize, productFamilyValue, tradeValue, productTypeValue, productValue, productCategoryValue, priceBook, vendor) {
        var allSelectedIds = component.get("v.allSelectedIds");
        console.log({allSelectedIds});
        var rfqRecordList = component.get("v.rfqRecordList");
        console.log({rfqRecordList});


        if (allSelectedIds.length == 0) {
            var currentSelectedIds = [];
            rfqRecordList.forEach(element => {
                if(element.isChecked == true){
                    currentSelectedIds.push(element.product.Id);
                }
            });
            allSelectedIds = currentSelectedIds;
        } else{
            var newUnselectedIds = [];
            rfqRecordList.forEach(element => {
                if (allSelectedIds.includes(element.product.Id)) {
                    if (element.isChecked == true) {
                        allSelectedIds.push(element.product.Id);
                    } else {
                        newUnselectedIds.push(element.product.Id);
                    }
                } else{
                    if (element.isChecked == true) {
                        allSelectedIds.push(element.product.Id);
                    } 
                }
            });

            var currentSelectedIds = allSelectedIds.filter( function( Id ) {
                return !newUnselectedIds.includes( Id );
            });

            allSelectedIds = currentSelectedIds;
        }
        component.set("v.allSelectedIds", currentSelectedIds);
        console.log('sakina test');
        console.log({productFamilyValue});

        var action = component.get("c.getProducts");
        var tradetype = component.get("v.rfqtradeType");
        var recId = component.get("v.recordId");
        action.setParams({
            "RFQRecId": recId,
            "productFamily": productFamilyValue,
            "tradeType": tradeValue,
            "productType": productTypeValue,
            "Product": productValue,
            "category": productCategoryValue,
            "priceBook": priceBook,
            "vendor": vendor,
            "rfqtradeType": tradetype,

        });
        action.setCallback(this, function(result) {
            var state = result.getState();
            console.log({state});
            console.log(result.getError());

            if (component.isValid() && state === "SUCCESS") {
                var resultData = result.getReturnValue();
                console.log({resultData});
                var records = resultData.recordList;
                if (allSelectedIds.length > 0) {
                    records.forEach(element => {
                        if (allSelectedIds.includes(element.product.Id)) {
                            element.isChecked = true;
                        }
                    });
                }
                component.set("v.rfqRecordList", records);



                var pageSize = component.get("v.pageSize");
                var totalRecordsList = records;
                var totalLength = totalRecordsList.length ;
                component.set("v.totalRecordsCount", totalLength);
                component.set("v.startPage",0);
                component.set("v.endPage",pageSize-1);

                var PaginationLst = [];
                for(var i=0; i < pageSize; i++){
                    if(component.get("v.rfqRecordList").length > i){
                        PaginationLst.push(records[i]);    
                    } 
                }
                component.set('v.PaginationList', PaginationLst);

                const allActive = PaginationLst.every(function(obj) {
                    return obj.isChecked === true;
                });
                 
                if(PaginationLst.length > 0){
                    if(allActive){
                        component.find("selectAllRFQ").set("v.value", true);
                    }else{
                       component.find("selectAllRFQ").set("v.value", false);
                    }
                }else{
                    component.find("selectAllRFQ").set("v.value", false);
                }
                
                component.set("v.TotalPages", Math.ceil(totalLength / pageSize)); 
                console.log({resultData});
                if (resultData.categoryList && resultData.categoryList.length > 5) {
                    component.set("v.rfqCategoryList", resultData.categoryList.slice(0, 5));
                } else if (resultData.categoryList) {
                    component.set("v.rfqCategoryList", resultData.categoryList);
                }
                if (resultData.producttypeList && resultData.producttypeList.length > 5) {
                    component.set("v.rfqproducttypeList", resultData.producttypeList.slice(0, 5));
                } else if (resultData.producttypeList) {
                    component.set("v.rfqproducttypeList", resultData.producttypeList);
                }
                if (resultData.tradetypeList && resultData.tradetypeList.length > 5) {
                    component.set("v.rfqtradetypeList", resultData.tradetypeList.slice(0, 5));
                } else if (resultData.tradetypeList) {
                    component.set("v.rfqtradetypeList", resultData.tradetypeList);
                }
                if (resultData.vendorList && resultData.vendorList.length > 5) {
                    component.set("v.rfqvendorList", resultData.vendorList.slice(0, 5));
                } else if (resultData.vendorList) {
                    component.set("v.rfqvendorList", resultData.vendorList.slice(0, 5));
                }

               
                
            }
        });
        $A.enqueueAction(action);

        
    },
    changeEventHelper: function (component, event, helper) {
        console.log('changeEventHelper');
        component.set("v.Spinner", true);

		var productAction = component.get("c.productfamilyList");
        productAction.setParams({
            ObjectName : "Product2",
            parentId: component.get("v.searchPriceBookFilter")
        });
        productAction.setCallback(this, function(response){
            console.log(response.getError());
            if(response.getState() === "SUCCESS"){
                
                component.set("v.Spinner", false);
                console.log(response.getReturnValue());
                console.log('TESTING');

				component.set("v.listofproductfamily",response.getReturnValue());
                if (component.get("v.listofproductfamily").length > 0) {
                    if(component.get("v.listofproductfamily").length == 1){
                        component.set("v.searchProductFamilyFilter", component.get("v.listofproductfamily")[0].productfamilyvalues);
                    }else{
                        component.set("v.searchProductFamilyFilter", '');
                    }
				}

                
                
            }else{
                component.set("v.Spinner", false);
            }     
        });
        $A.enqueueAction(productAction);
	},
    next : function(component,event,sObjectList,end,start,pageSize){
        var Paginationlist = [];
        var counter = 0;
        for(var i = end + 1; i < end + pageSize + 1; i++){
            if(sObjectList.length > i){ 
                Paginationlist.push(sObjectList[i]);  
            }
            counter ++ ;
        }
        start = start + counter;
        end = end + counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.PaginationList', Paginationlist);

        const allActive = Paginationlist.every(function(obj) {
            return obj.isChecked === true;
         });
         if(allActive){
            component.find("selectAllRFQ").set("v.value", true);

        }else{
           component.find("selectAllRFQ").set("v.value", false);

        }
         

      
    },
    previous : function(component,event,sObjectList,end,start,pageSize){

        var Paginationlist = [];
        var counter = 0;
        for(var i= start-pageSize; i < start ; i++){
            if(i > -1){
                Paginationlist.push(sObjectList[i]); 
                counter ++;
            }else{
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.PaginationList', Paginationlist);
        const allActive = Paginationlist.every(function(obj) {
            return obj.isChecked === true;
         });
         if(allActive){
            component.find("selectAllRFQ").set("v.value", true);

        }else{
           component.find("selectAllRFQ").set("v.value", false);

        }
    },
})