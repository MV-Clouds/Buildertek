({
    doInit : function(component, event, helper) {
        component.set("v.Spinner", true);
        helper.initHelper(component, event, helper);
    }, 

    handleClick : function(component, event, helper){
        var idx = event.getSource().get("v.value");
        component.set("v.isModalOpen", true);
        var productWrapper = component.get('v.productWrapper');
        var productValue = productWrapper[idx].product;
        component.set("v.productValue", productValue);
    }, 

    changePriceBook: function (component, event, helper) {
        component.set("v.Spinner", true);
        component.set("v.searchNameFilter", '');
        component.set("v.searchTypeFilter", '');
        component.set("v.searchManufacturerFilter", '');
        component.set("v.searchFamilyFilter", '');
        component.set("v.priceBookFilter", true);
        helper.searchHelper(component, event, helper);
    },
    
    doSearch: function (component, event, helper) {
        helper.searchHelper(component, event, helper);
    },
    
    closeModel: function(component, event, helper) {
        component.set("v.isModalOpen", false);
    },

    onUpgrade: function (component, event, helper){
        component.set("v.Spinner", true);
        component.set("v.isModalOpen", false);
        var optionValue = component.get("v.optionValue");
        var productValue = component.get("v.productValue");
        var action = component.get("c.upgradeOption");
        action.setParams({
            optionValue : optionValue,
            productValue: productValue
        });
        action.setCallback(this, function (response) {
            component.set("v.Spinner", false);
            var state = response.getState();
            console.log('Status => '+state);
            if (state == 'SUCCESS') {
                var result = response.getReturnValue();
                helper.showToast("Success", "Success", "Option Upgrade Sucessfully", "5000");
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": result,
                    "slideDevName": "Detail"
                });
                navEvt.fire();
            } else{
                helper.showToast("Error", "Error", "Something Went Wrong", "5000");
            }
        });
        $A.enqueueAction(action);
    }, 

    onPrevious: function (component, event, helper){
        component.set("v.pageNumber", component.get("v.pageNumber")-1);
        component.set("v.priceBookFilter", true);
        helper.paginationHelper(component, event, helper);
    }, 

    onNext: function (component, event, helper){
        component.set("v.pageNumber", component.get("v.pageNumber")+1);
        component.set("v.priceBookFilter", true);
        helper.paginationHelper(component, event, helper);
    }, 

    onImageClick: function (component, event, helper){
        var docsInx = event.getSource().get("v.id");
        var indexLst = docsInx.split("-");
        console.log('indexLst => '+indexLst);
        var productWrapper = component.get("v.productWrapper");
        var docsList = productWrapper[indexLst[0]].contentDocsList;
        component.set("v.ImageList", docsList);
        component.set("v.ImageIndex", parseInt(indexLst[1]));
        component.set("v.ImageModal", true);
    }, 

    closeImageModal: function (component, event, helper){
        var targer = event.target;
        if (targer != undefined) {
            var id = event.target.id;
            if (id != 'imgDiv' && id != 'imgMainDiv') {
                component.set("v.ImageModal", false);
                component.set("v.ImageIndex", 0);
            } 
        }
    }, 

    closeImage: function (component, event, helper){
        component.set("v.ImageModal", false);
        component.set("v.ImageIndex", 0);
    }, 

    previousImage: function (component, event, helper){
        component.set("v.ImageIndex", component.get("v.ImageIndex")-1);
    }, 

    nextImage: function (component, event, helper){
        component.set("v.ImageIndex", component.get("v.ImageIndex")+1);
    }, 

    searchProductFamily: function (component, event, helper){
        var searchFamilyValue = component.get("v.searchFamilyFilter");
        component.set("v.oldSearchFamilyFilter", searchFamilyValue);

        var action = component.get("c.getProductFamily");
        action.setParams({
            searchFamilyValue: searchFamilyValue
        });
        action.setCallback(this, function (response) {
            var result = response.getReturnValue();
            component.set("v.ProductFamilyList", result);
            component.set("v.displayFamilyList", true);
        });
        $A.enqueueAction(action);
    }, 

    searchProductCategory: function (component, event, helper){
        var searchCategoryValue = component.get("v.searchCategoryFilter");
        component.set("v.oldSearchCategoryFilter", searchCategoryValue);

        var action = component.get("c.getProductCategory");
        action.setParams({
            searchCategoryValue: searchCategoryValue
        });
        action.setCallback(this, function (response) {
            var result = response.getReturnValue();
            component.set("v.ProductCategoryList", result);
            component.set("v.displayCategoryList", true);
        });
        $A.enqueueAction(action);
    }, 

    searchProductType: function (component, event, helper){
        var searchTypeValue = component.get("v.searchTypeFilter");
        component.set("v.oldSearchTypeFilter", searchTypeValue);

        var action = component.get("c.getProductType");
        action.setParams({
            searchTypeValue: searchTypeValue
        });
        action.setCallback(this, function (response) {
            var result = response.getReturnValue();
            component.set("v.ProductTypeList", result);
            component.set("v.displayTypeList", true);
        });
        $A.enqueueAction(action);
    }, 

    searchProductName: function (component, event, helper){
        var searchNameValue = component.get("v.searchNameFilter");
        component.set("v.oldSearchNameFilter", searchNameValue);

        var action = component.get("c.getProductName");
        action.setParams({
            searchNameValue: searchNameValue
        });
        action.setCallback(this, function (response) {
            var result = response.getReturnValue();
            component.set("v.ProductNameList", result);
            component.set("v.displayNameList", true);
        });
        $A.enqueueAction(action);
    }, 

    searchManufacturer: function (component, event, helper){
        var searchManufacturerValue = component.get("v.searchManufacturerFilter");
        component.set("v.oldSearchManufacturerFilter", searchManufacturerValue);

        var action = component.get("c.getManufacturer");
        action.setParams({
            searchManufacturerValue: searchManufacturerValue
        });
        action.setCallback(this, function (response) {
            var result = response.getReturnValue();
            component.set("v.ManufacturerList", result);
            component.set("v.displayManufacturerList", true);
        });
        $A.enqueueAction(action);
    }, 

    clickHandler0: function (component, event, helper){
        var record = event.currentTarget.dataset.value;
        component.set("v.searchFamilyFilter", record);
    },

    clickHandler1: function (component, event, helper){
        var record = event.currentTarget.dataset.value;
        component.set("v.searchCategoryFilter", record);
    },

    clickHandler2: function (component, event, helper){
        var record = event.currentTarget.dataset.value;
        component.set("v.searchTypeFilter", record);
    },

    clickHandler3: function (component, event, helper){
        var record = event.currentTarget.dataset.value;
        component.set("v.searchNameFilter", record);
    },

    clickHandler4: function (component, event, helper){
        var record = event.currentTarget.dataset.value;
        component.set("v.searchManufacturerFilter", record);
    },

    closeSearchOption: function (component, event, helper){
        component.set("v.displayFamilyList", false);
        component.set("v.displayCategoryList", false);
        component.set("v.displayTypeList", false);
        component.set("v.displayNameList", false);
        component.set("v.displayManufacturerList", false);
    },


})