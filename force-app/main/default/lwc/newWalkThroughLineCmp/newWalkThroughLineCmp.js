import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getFields from '@salesforce/apex/walkThroughController.getFieldSet';
import getRecordType from '@salesforce/apex/walkThroughController.getRecordType';
import saveData from '@salesforce/apex/walkThroughController.saveData';
import getPricebookList from '@salesforce/apex/walkThroughController.getPricebookList';
import getProductfamilyRecords from '@salesforce/apex/walkThroughController.getProductfamilyRecords';
import getProductsthroughPriceBook2 from '@salesforce/apex/walkThroughController.getProductsthroughPriceBook2';

export default class NewWalkThroughLineCmp extends LightningElement {

    @api walkThroughId;
    @api categoryId;

    @track isSaveandNew = false;
    @track recordTypeName;
    @track selectedRecordType;
    @track step1 = false;
    @track step2 = true;

    @track recordTypeOptions = {};
    @track recordTypeOptionsList = [];
    @track fieldsForSelectedRecordType = [];

    @track isProduct = false;
    @track spinner = true;

    // PriceBook
    selectedPriceBook
    priceBookListOrdered;
    searchResults;
    selectedSearchResult;

    // ProductFamily
    selectedProductFamily
    pflistOrdered;
    searchProductFamilyResults;
    selectedPFSearchResult;

    
    objectApiName = 'buildertek__Walk_Through_Line_Items__c';

    connectedCallback() {
        this.getRecordTypeValues();
        this.getFieldsetFields();
    }

    getRecordTypeValues(){
        getRecordType({ ObjectAPIName: this.objectApiName})
        .then(result =>{
            this.recordTypeOptionsList = result;
            this.recordTypeOptions =result.map((item) => Object.assign({}, item, { label: item.Name, value: item.Id }));

            for(var i = 0; i < result.length; i++){
                if(result[i].Name == 'Product'){
                    this.isProduct = true;
                    this.selectedRecordType = result[i].Id;
                    this.recordTypeName = result[i].Name;
                    this.handleNext();
                }
            }
            // this.selectedRecordType = this.recordTypeOptions[0].value;
            // this.recordTypeName = this.recordTypeOptions[0].Name;

        })
        .catch(error => {
            console.error('Error:', error);
        })
    }

    getFieldsetFields(){
        getFields({ objName:this.objectApiName, fieldSetName:'buildertek__NewfromParent'})
        .then(result => {
            this.fieldsForSelectedRecordType = JSON.parse(result);
            //remove "buildertek__Product__c" field from the list

            for(var i = 0; i < this.fieldsForSelectedRecordType.length; i++){
                if(this.fieldsForSelectedRecordType[i].name == 'buildertek__Product__c'){
                    this.fieldsForSelectedRecordType.splice(i,1);

                }
            }
            console.log('Fields:', this.fieldsForSelectedRecordType);
        })
        .catch(error => {
            console.error('Error:', error);
        });
    }


    handleRecordTypeChange(event){
        try {
            console.log('Handle Record Type Selection')
            this.selectedRecordType = event.detail.value;
            var recordTypeLabel = this.recordTypeOptions.find(item => item.value === this.selectedRecordType).label;
            this.recordTypeName = recordTypeLabel;
        } catch (error) {
            console.error('Error:', error);
        }
    }

    handleClose(){
        this.dispatchEvent(new CustomEvent("close"));
    }

    handleSaveAndNew(event){
        this.isSaveandNew = true;
    }

    handleSave(event){
        try{
            event.preventDefault();
            this.spinner = true;
            const fields = {};

            this.fieldsForSelectedRecordType.forEach(field => {
                fields[field.name] = this.template.querySelector(`[data-field="${field.name}"]`).value;
            });

            if (this.recordTypeName === 'Product') {
                if (fields['buildertek__Description__c'] == null || fields['buildertek__Description__c'] == '') {
                    this.spinner = false;
                    this.showToast('Error', 'Please add description', 'error');
                    return;
                } else {
                    if (fields['buildertek__Description__c'].length > 255) {
                        this.spinner = false;
                        this.showToast('Error', 'String length must be less than 255 characters.', 'error');
                        return;
                    } else {
                        fields['RecordTypeId'] = this.selectedRecordType;
                        fields['buildertek__Walk_Through_List__c'] = this.walkThroughId;
                        fields['buildertek__BT_Category__c'] = this.categoryId;
                        fields['buildertek__Product__c'] = this.selectedProductResult ? this.selectedProductResult.value : '';
                        fields['buildertek__Price_Book__c'] = this.selectedPriceBook ;
                    }
                }
            } else if (this.recordTypeName === 'No Product') {
                if (fields['buildertek__Description__c'] == null || fields['buildertek__Description__c'] == '') {
                    this.spinner = false;
                    this.showToast('Error', 'Please enter a Description', 'error');
                    return;
                } else {
                    fields['RecordTypeId'] = this.selectedRecordType;
                    fields['buildertek__Walk_Through_List__c'] = this.walkThroughId;
                    fields['buildertek__BT_Category__c'] = this.categoryId;
                }
            }

            console.log('Fields:', fields);

            saveData({ allData: fields})
            .then(result =>{
                this.spinner = false;
                console.log('result', result);
                if(this.isSaveandNew){
                    console.log('Save and New');
                    this.isSaveandNew = false;
                    this.dispatchEvent(new CustomEvent("refresh"));
                }else{
                    this.dispatchEvent(new CustomEvent("closeandrefresh"));
                }
                this.showToast('Success', 'Record Created Successfully', 'success');
            }).catch(error => {
                this.spinner = false;
                console.error('Error:', error);
            })

        }catch(error){
            this.spinner = false;
            console.error('error', error);
            this.showToast('Error', 'Something Went Wrong', 'error');
        }   
    }

    handleNext(){
        try{
            this.step2 = true;
            this.step1 = false;

            var fieldsForSelectedRecord = this.fieldsForSelectedRecordType;
            fieldsForSelectedRecord.forEach(field => {
                if(field.name === 'buildertek__Product__c' && this.recordTypeName =='Product'){
                    this.isProduct = true;
                }
                if((field.name === 'buildertek__Product__c' || field.name === 'buildertek__Price_Book__c' )){
                    fieldsForSelectedRecord.splice(fieldsForSelectedRecord.indexOf(field), 1);
                }
            });
            this.fieldsForSelectedRecordType = fieldsForSelectedRecord;

            if(this.isProduct){
                getPricebookList({recordId : this.walkThroughId}).then((result) => {
                    this.priceBookListOrdered = result[0].priceWrapList.map((item) => Object.assign({}, item, { label: item.Name, value: item.Id }));
                    this.selectedPriceBook = this.priceBookListOrdered[0].value; 
                    this.getProductFamilyPicklistValues(this.selectedPriceBook);
                })
                .catch(error => {
                    console.error('Error:', error);       
                })
            }

        }catch(error){
            console.error('error', error);
        }
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }

    searchPriceBook(event) {
        this.selectedPriceBook = event.detail.value;
        this.selectedProductResult = null;
        this.template.querySelector(`[data-field='buildertek__Price__c']`).value = 0;
        this.template.querySelector(`[data-field='buildertek__Notes__c']`).value = null;
        this.template.querySelector(`[data-field='buildertek__Description__c']`).value = null;
        this.getProductFamilyPicklistValues(this.selectedPriceBook);
    }
 

    searchProductFamily(event){
        this.selectedProductFamily = event.detail.value;
        this.getProductList(this.selectedPriceBook, this.selectedProductFamily, '');
    }

    getProductFamilyPicklistValues(pricebookId) {
        try {
            this.spinner = true;
            getProductfamilyRecords({ ObjectName: 'Product2', parentId: pricebookId })
                .then(result => {
                    this.pflistOrdered = result.map((item) => Object.assign({}, item, { label: item.productfamilyvalues, value: item.productfamilyvalues}));
                    this.selectedProductFamily = this.pflistOrdered[0].value;
                    this.getProductList(pricebookId, this.selectedProductFamily, '' );
                    this.spinner = false;
                })
                .catch(error => {
                    console.error('Error fetching product family records', error);
                    this.spinner = false;
                });

        } catch(error){
            console.error(error);
        }
    }

    getProductList(pricebookId, productFamilyLabel, searchProducts){
        this.spinner = true;
        getProductsthroughPriceBook2({
            priceBookId: pricebookId, productFamilyLabel : productFamilyLabel , searchProduct : searchProducts
        })
        .then(result => {
            console.log('PFresult --->' );
            console.log(result);
            this.productList = result;
            this.productListMain=result.map((item) => Object.assign({}, item, { label: item.Name, value: item.Id }));
            this.spinner = false;
        }).catch(error => {
            console.error('Error in getProductList', error);
            this.spinner = false;
        })
    }

    productListMain;
    productList;
    searchProductResults;
    selectedProductResult;

    get selectedProductValue(){
        return this.selectedProductResult ? this.selectedProductResult.label : null;
    }


    searchProduct(event){
        const input = event.detail.value.toLowerCase();
        if (input == '') {
            this.selectedProductResult = null;
            this.template.querySelector(`[data-field='buildertek__Price__c']`).value = 0;
            this.template.querySelector(`[data-field='buildertek__Notes__c']`).value = null;
            this.template.querySelector(`[data-field='buildertek__Description__c']`).value = null;
        } else {
            const result = this.productListMain.filter((picklistOption) =>
            picklistOption.label.toLowerCase().includes(input)
            );
            this.searchProductResults = result;
        }
        
    }
    
    selectProductResult(event){
        const selectedValue = event.currentTarget.dataset.value;
        this.selectedProductResult = this.productListMain.find(
            (picklistOption) => picklistOption.value === selectedValue
        );
        this.getUnitPrice();
        this.clearProductResults();
    }

    
    clearProductResults() {
        this.searchProductResults = null;
    }
    
    showProductOptions(){
        if (!this.searchProductResults) {
            this.searchProductResults = this.productListMain;
        }
    }

    getUnitPrice(){
        if(this.selectedProductResult.value){
            this.productList.forEach(item => {
                if(item.Id == this.selectedProductResult.value){
                    this.template.querySelector(`[data-field='buildertek__Price__c']`).value = item.UnitCost || item.UnitPrice;
                    this.template.querySelector(`[data-field='buildertek__Notes__c']`).value = item.Instructions ? this.convertToPlain(item.Instructions) : null;
                    this.template.querySelector(`[data-field='buildertek__Description__c']`).value = item.Description || item.Name;
                }
            })
        }
    }
    
    preventHide(event) {
        event.preventDefault();
    }

    convertToPlain(html){
        var tempDivElement = document.createElement("div");
        tempDivElement.innerHTML = html;
        return tempDivElement.textContent || tempDivElement.innerText || "";
    }


}