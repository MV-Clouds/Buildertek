({
    initHelper: function(component, event, helper){
        // For Set Tab Name
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then((response) => {
            let opendTab = response.tabId;
            workspaceAPI.setTabLabel({
                tabId: opendTab,
                label: "Upgrade"
            });
            workspaceAPI.setTabIcon({
                tabId: opendTab,
                icon: 'custom:custom24',
                iconAlt: 'Update Option'
            });
        });

        var selectedPriceBook = component.get("v.selectedPriceBook");
        var priceBookFilter = component.get("v.priceBookFilter");

        var action = component.get("c.getProductDetails");
        action.setParams({
            recordId : component.get("v.recordId"),
            searchNameValue : '',
            searchTypeValue : '',
            searchManufacturerValue : '',
            searchFamilyValue : '',
            searchCategoryValue : '',
            selectedPriceBook : selectedPriceBook,
            priceBookFilter : priceBookFilter
        });
        action.setCallback(this, function (response) {
            component.set("v.Spinner", false);
            var state = response.getState();
            if (state == 'SUCCESS') {
                var result = response.getReturnValue();
                console.log('Result => ',{result});
                component.set("v.optionWrapper", result);
                component.set("v.orgCurr", result.orgCurr);
                if (result.productCount > 10) {
                    var totalPage = Math.trunc(result.productCount/10)+1;
                    component.set("v.totalPage", totalPage);
                } else{
                    component.set("v.totalPage", 1);
                }
                component.set("v.optionValue", result.option);

                if (result.productWrapperList.length == 0) {
                    component.set("v.nullProduct", true);
                } else{
                    component.set("v.nullProduct", false);
                    helper.paginationHelper(component, event, helper);
                }

                var opts = [];
                opts.push({ key: "None", value: "" });
                if (result.priceBookMap.size != 0){
                    for (var key in result.priceBookMap) {
                        opts.push({ key: key, value: result.priceBookMap[key] });
                    }
                }
                component.set("v.priceBookList", opts);

                if (priceBookFilter == false) {
                    component.set("v.selectedPriceBook", result.projectPriceBook);
                }

            } else{
                var error = response.getError();
                console.log('Error => ', {error});
                helper.showToast("Error", "Error", "Something Went Wrong, Please Refresh Page", "5000");
            }
        });
        $A.enqueueAction(action);   
    },
    
    searchHelper: function(component, event, helper){
        console.log('== searchHelper ==');
        var searchFamilyValue = component.get("v.searchFamilyFilter");
        var searchCategoryValue = component.get("v.searchCategoryFilter");
        var searchTypeValue = component.get("v.searchTypeFilter");
        var searchNameValue = component.get("v.searchNameFilter");
        var searchManufacturerValue = component.get("v.searchManufacturerFilter");

        var oldSearchFamilyValue = component.get("v.oldSearchFamilyFilter");
        var oldSearchCategoryValue = component.get("v.oldSearchCategoryFilter");
        var oldSearchTypeValue = component.get("v.oldSearchTypeFilter");
        var oldSearchNameValue = component.get("v.oldSearchNameFilter");
        var oldSearchManufacturerValue = component.get("v.oldSearchManufacturerFilter");

        if (oldSearchFamilyValue != '' && searchFamilyValue == '') {
            var action = component.get("c.searchProductFamily");
            $A.enqueueAction(action);
        }
        if (oldSearchCategoryValue != '' && searchCategoryValue == '') {
            var action = component.get("c.searchProductCategory");
            $A.enqueueAction(action);
        }
        if (oldSearchTypeValue != '' && searchTypeValue == '') {
            var action = component.get("c.searchProductType");
            $A.enqueueAction(action);
        }
        if (oldSearchNameValue != '' && searchNameValue == '') {
            var action = component.get("c.searchProductName");
            $A.enqueueAction(action);
        }
        if (oldSearchManufacturerValue != '' && searchManufacturerValue == '') {
            var action = component.get("c.searchManufacturer");
            $A.enqueueAction(action);
        }

        var selectedPriceBook = component.get("v.selectedPriceBook");
        var priceBookFilter = component.get("v.priceBookFilter");

        var action = component.get("c.getProductDetails");
        action.setParams({
	        recordId : component.get("v.recordId"),
            searchNameValue : searchNameValue,
            searchTypeValue : searchTypeValue,
            searchManufacturerValue : searchManufacturerValue,
            searchFamilyValue : searchFamilyValue,
            searchCategoryValue : searchCategoryValue,
            selectedPriceBook : selectedPriceBook,
            priceBookFilter : priceBookFilter
	    });
        action.setCallback(this, function (response) {
            component.set("v.Spinner", false);
            var state = response.getState();
            if (state == 'SUCCESS') {
                var result = response.getReturnValue();
                console.log('Result => ',{result});

                component.set("v.optionWrapper", result);
                if (result.productCount > 10) {
                    var totalPage = Math.trunc(result.productCount/10)+1;
                    component.set("v.totalPage", totalPage);
                } else{
                    component.set("v.totalPage", 1);
                }

                if (result.productWrapperList.length == 0) {
                    component.set("v.nullProduct", true);
                } else{
                    component.set("v.nullProduct", false);
                }
                component.set("v.pageNumber", 1);
                helper.paginationHelper(component, event, helper);

                if (searchNameValue == '' && searchTypeValue == '' && searchManufacturerValue == '' && searchFamilyValue == '') {
                    component.set("v.disableBtn", false);
                } else{
                    component.set("v.disableBtn", true);
                }
            } else{
                helper.showToast("Error", "Error", "Something Went Wrong", "5000");
            }
        });
        $A.enqueueAction(action); 

    },
    
    paginationHelper: function(component, event, helper){
        var pageNumber = component.get("v.pageNumber");
        var optionWrapper = component.get("v.optionWrapper");
        var offset = (pageNumber-1) * 10;
        var productWrapper = [];

        for (let i = offset; i < offset+10; i++) {
            var element = optionWrapper.productWrapperList[i];
            if (element != undefined) {
                productWrapper.push(element);
            }
        }

        component.set("v.productWrapper", productWrapper);
    },

    showToast: function(type, title, message, time) {
        try {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": title,
                "type": type,
                "message": message,
                "duration": time
            });
            toastEvent.fire();
        } catch (error) {
            console.log({ error });
        }
    },
})