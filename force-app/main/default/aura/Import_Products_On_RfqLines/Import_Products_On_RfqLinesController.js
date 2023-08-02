({
    doInit : function(component, event, helper) {
        component.set("v.Spinner", true);
        var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.pageSize");
        var productFamilyValue = component.get("v.searchProductFamilyFilter");
        var productValue = component.get("v.searchProductFilter").Name;
        var productCategoryValue = component.get("v.searchCategoryFilter");
        var productTypeValue = component.get("v.searchProductTypeFilter");
        var tradeValue = component.get("v.searchTradeTypeFilter");
        var priceBook = component.get("v.searchPriceBookFilter");
        var vendor = component.get("v.searchVendorFilter");
        var recId = component.get("v.mainObjectId");
    
        
        
        var pbAction = component.get("c.pricebookList");
        pbAction.setParams({
            recordId:recId
        });
        pbAction.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                let result=response.getReturnValue();
                console.log({result});
                let projectHavePricebook=result[0].defaultValue;
                let pricebookList= result[0].priceWrapList;
                var pricebookOptions = [];


                if(Object.keys(projectHavePricebook).length !=0){
                    pricebookOptions.push({ key: projectHavePricebook.Name, value: projectHavePricebook.Id });
                    result[0].priceWrapList.forEach(function(element){
                        if(projectHavePricebook.Id !== element.Id){
                            pricebookOptions.push({ key: element.Name, value: element.Id });
                        }else{
                            pricebookOptions.push({ key: "None", value: "" });

                        }
                    });
                    component.set('v.searchPriceBookFilter' , projectHavePricebook.Id);

                }else{
                    pricebookOptions.push({ key: "None", value: "" });
                    result[0].priceWrapList.forEach(function(element){
                        pricebookOptions.push({ key: element.Name, value: element.Id });
                    });
                }
                if(component.get('v.searchPriceBookFilter')!= undefined){
                    helper.changeEventHelper(component, event, helper);
                }else{
                    component.set("v.Spinner", false);

                }
                component.set("v.pbList",pricebookOptions);
            }else{
                component.set("v.Spinner", false);
            }     
        });
        
        $A.enqueueAction(pbAction);

        var action = component.get("c.getTradeTypes"); 
        action.setParams({
            "RFQRecId" : recId
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                console.log({priceBook});
                console.log(component.get('v.searchPriceBookFilter'));
                component.set("v.rfqtradeType", response.getReturnValue()); 
                helper.getRfqList(component, event, helper, pageNumber, pageSize, productFamilyValue, tradeValue, productTypeValue, productValue, productCategoryValue, component.get('v.searchPriceBookFilter'),vendor);
            }     
        });
        $A.enqueueAction(action);   
       
    
        
		 
    },
    changefamily: function (component, event, helper) {
		var product = component.get('v.selectedLookUpRecord');
		var compEvent = $A.get('e.c:BT_CLearLightningLookupEvent');
		compEvent.setParams({
			"recordByEvent": product
		});
		compEvent.fire();
	},
    changeEvent: function (component, event, helper) {
        helper.changeEventHelper(component, event, helper);
	},

    handleComponentEvent : function(component, event, helper){
        var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.pageSize");
        var productFamilyValue = component.get("v.searchProductFamilyFilter");
        var productValue = component.get("v.searchProductFilter").Name;
        var productCategoryValue = component.get("v.searchCategoryFilter");
        var productTypeValue = component.get("v.searchProductTypeFilter");
        var tradeValue = component.get("v.searchTradeTypeFilter");
        var priceBook = component.get("v.searchPriceBookFilter");
        var vendor = component.get("v.searchVendorFilter");
        var recId = component.get("v.mainObjectId");
       helper.getRfqList(component, event, helper, pageNumber, pageSize, productFamilyValue, tradeValue, productTypeValue, productValue, productCategoryValue, priceBook,vendor);
                             
         
    },
    getproductlist : function (component, event, helper) {
        var action = component.get("c.getprodlist"); 
        action.setParams({
            "RFQRecId" : recId
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
            	component.set("v.searchProductFilter", response.getReturnValue()); 
            }     
        });
        $A.enqueueAction(action); 
        
    },
    // handleNext: function (component, event, helper) {
       
  
    //     var pageNumber = component.get("v.PageNumber");
    //     var pageSize = component.get("v.pageSize");
    //      pageNumber++;
    //     var productFamilyValue = component.get("v.searchProductFamilyFilter");
    //     var productValue = component.get("v.searchProductFilter").Name;
    //     var productCategoryValue = component.get("v.searchCategoryFilter");
    //     var productTypeValue = component.get("v.searchProductTypeFilter");
    //     var tradeValue = component.get("v.searchTradeTypeFilter");
    //     var priceBook = component.get("v.searchPriceBookFilter");
    //     var vendor = component.get("v.searchVendorFilter");
    //     helper.getRfqList(component, event, helper, pageNumber, pageSize, productFamilyValue, tradeValue, productTypeValue, productValue, productCategoryValue, priceBook,vendor);
    //      console.log("List of Ids : ",component.get("v.listOfSelectedRFQIds"))
    // },
    
    // handlePrev: function (component, event, helper) { 
    //     var pageNumber = component.get("v.PageNumber");
    //     var pageSize = component.get("v.pageSize");
    //      pageNumber--;
    //     var productFamilyValue = component.get("v.searchProductFamilyFilter");
    //     var productValue = component.get("v.searchProductFilter").Name;
    //     var productCategoryValue = component.get("v.searchCategoryFilter");
    //     var productTypeValue = component.get("v.searchProductTypeFilter");
    //     var tradeValue = component.get("v.searchTradeTypeFilter");
    //     var priceBook = component.get("v.searchPriceBookFilter");
    //     var vendor = component.get("v.searchVendorFilter");
    //     helper.getRfqList(component, event, helper, pageNumber, pageSize, productFamilyValue, tradeValue, productTypeValue, productValue, productCategoryValue, priceBook,vendor);
    //      console.log("List of Ids : ",component.get("v.listOfSelectedRFQIds"))

    // },
    selectRfq: function (component, event, helper) {
        console.log('rfq');
        let PaginationLst= component.get('v.PaginationList');

        const allActive = PaginationLst.every(function(obj) {
            return obj.isChecked === true;
         });
         if(allActive){
            component.find("selectAllRFQ").set("v.value", true);

         }else{
            component.find("selectAllRFQ").set("v.value", false);

         }
    },

    selectAllRfq : function (component, event, helper) {

        var checkValue = event.getSource().get("v.value");
        var listOfAllRFQ = component.get("v.rfqRecordList");
        var PaginationList = component.get("v.PaginationList");
        let headerIndex=event.getSource().get('v.name');

        if(headerIndex=== component.get('v.currentPage')){
            console.log('currentPage');
        }
        console.log({PaginationList});

        PaginationList.forEach(function(element){
            element.isChecked=checkValue;

        });
        component.set("v.PaginationList" , PaginationList);
    },
    
    addToRfqLines: function (component, event, helper) {
        var allSelectedIds = component.get("v.allSelectedIds");
        var rfqRecordList = component.get("v.rfqRecordList");

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
        var productIds=component.get("v.allSelectedIds");

        var RfqId = component.get("v.recordId");
        var Spinner = component.get("v.spinner");
        if(productIds.length>0){
            helper.addProductToRfqLines(component, event, helper, productIds, RfqId);
        }else{
            helper.showErrorToast(component,event,helper,'Error!','Please Select Product Lines.');
        }
    },
    
    closeModal: function (component, event, helper) {
        component.get("v.onCancel")();
    },
    
    doRfqSearch: function (component, event, helper) {
        if(productCategoryValue){
            var categoryAction = component.get(c.showDropDownCategory);
            $A.enqueueAction(categoryAction);
        }
         var pageNumber = 1;//component.get("v.PageNumber");
        var pageSize = 20;//component.get("v.pageSize");
        var productFamilyValue = component.get("v.searchProductFamilyFilter");
        var productValue = component.get("v.searchProductFilter").Name;
        var productCategoryValue = component.get("v.searchCategoryFilter");
        var productTypeValue = component.get("v.searchProductTypeFilter");
        var tradeValue = component.get("v.searchTradeTypeFilter");
        var priceBook = component.get("v.searchPriceBookFilter");
        var vendor = component.get("v.searchVendorFilter");
        helper.getRfqList(component, event, helper, pageNumber, pageSize, productFamilyValue, tradeValue, productTypeValue, productValue, productCategoryValue, priceBook,vendor);

        
    },
    selectRecordOption : function (component, event, helper) {
        event.preventDefault();
        event.stopPropagation();
        component.set("v.searchCategoryFilter",event.target.innerText);
        var forOpen = component.find("searchCategoryRes_1");
        if(forOpen){
            forOpen.getElement().style.display = 'none';
        }
    },
    selectRecordOptionforproducttype : function (component, event, helper) {
        event.preventDefault();
        event.stopPropagation();
        component.set("v.searchProductTypeFilter",event.target.innerText);
        var forOpen = component.find("searchCategoryRes_2");
        if(forOpen){
            forOpen.getElement().style.display = 'none';
        }
    },
    selectRecordOptionfortradetype : function (component, event, helper) {
        event.preventDefault();
        event.stopPropagation();
        component.set("v.searchTradeTypeFilter",event.target.innerText);
        var forOpen = component.find("searchCategoryRes_3");
        if(forOpen){
            forOpen.getElement().style.display = 'none';
        }
    },
    selectRecordOptionforvendor : function (component, event, helper) {
        event.preventDefault();
        event.stopPropagation();
        component.set("v.searchVendorFilter",event.target.innerText);
        var forOpen = component.find("searchCategoryRes_4");
        
        if(forOpen){
            forOpen.getElement().style.display = 'none';
        }
    },
    showDropDownCategory : function (component, event, helper) {      
      var auraId = event.getSource().getLocalId();
        var auraIdName = auraId.split('_')[0];
        var index = auraId.split('_')[1];
        var forOpen = component.find(auraIdName+'Res_'+index);
        for(var i=1;i<=4;i++){
            if(i != index){
                var forClose = component.find(auraIdName+'Res_'+i);
                if(forClose){
                     forClose.getElement().style.display = 'none';
                }
               
            }
        }
        forOpen.getElement().style.display = 'block'
         var getInputkeyWord = '';
         event.stopPropagation();
        event.preventDefault();
    },
    hideDropDownCategory : function (component, event, helper) {
        event.preventDefault();
        var eve = event.getSource();
        console.log(event.target)
        if(eve.getLocalId() == 'searchCategory_1'){
            window.setTimeout(
                $A.getCallback(function() {
                    var forOpen = component.find('searchCategoryRes_1');
                     if(forOpen){
                        forOpen.getElement().style.display = 'none';
                    }
                }), 1000
            );
        }
        if(eve.getLocalId() == 'searchCategory_2'){
            window.setTimeout(
                $A.getCallback(function() {
                    var forOpen = component.find('searchCategoryRes_2');
                     if(forOpen){
                        forOpen.getElement().style.display = 'none';
                    }
                }), 1000
            );
        }
        if(eve.getLocalId() == 'searchCategory_3'){
            window.setTimeout(
                $A.getCallback(function() {
                    var forOpen = component.find('searchCategoryRes_3');
                     if(forOpen){
                        forOpen.getElement().style.display = 'none';
                    }
                }), 1000
            );
        }
        if(eve.getLocalId() == 'searchCategory_4'){
            window.setTimeout(
                $A.getCallback(function() {
                    var forOpen = component.find('searchCategoryRes_4');
                    if(forOpen){
                        forOpen.getElement().style.display = 'none';
                    }
                }), 1000
            );
        }
        var getInputkeyWord = '';
       
    },
    navigation: function(component, event, helper) {
        var sObjectList = component.get("v.rfqRecordList");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var whichBtn = event.getSource().get("v.name");
        console.log({whichBtn});
        // check if whichBtn value is 'next' then call 'next' helper method
        if (whichBtn == 'next') {
            component.set("v.currentPage", component.get("v.currentPage") + 1);
            helper.next(component, event, sObjectList, end, start, pageSize);
        }
        // check if whichBtn value is 'previous' then call 'previous' helper method
        else if (whichBtn == 'previous') {
            component.set("v.currentPage", component.get("v.currentPage") - 1);
            helper.previous(component, event, sObjectList, end, start, pageSize);
        }
    },
})