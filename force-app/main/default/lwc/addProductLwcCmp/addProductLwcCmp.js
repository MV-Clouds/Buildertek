import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle } from 'lightning/platformResourceLoader';
import myResource from '@salesforce/resourceUrl/addProductLwcOnQuoteExternalCss';
import fetchPricebookList from '@salesforce/apex/QuoteDAO.getPricebookList';
import fetchProductFamilyList from '@salesforce/apex/QuoteDAO.getProductFamily';
import fetchTableDataList from '@salesforce/apex/QuoteDAO.getProductsthroughPriceBook2';
import fetchQuoteLineGroupList from '@salesforce/apex/QuoteDAO.getQuoteLineGroups';
import performDMLForQuoteLine from '@salesforce/apex/QuoteDAO.QuoteLinesInsert';
import fetchVendorsList from '@salesforce/apex/QuoteDAO.getVendors';
import fetchProductsThroughVendorList from '@salesforce/apex/QuoteDAO.getProductsthroughVendor';


const columns = [
	{ label: 'Product Name', fieldName: 'Name', type: 'text', sortable: false, hideDefaultActions: true },
	{ label: 'Product Family', fieldName: 'Family', type: 'text', hideDefaultActions: true },
	{ label: 'Product Description', fieldName: 'Description', type: 'text', hideDefaultActions: true },
	{ label: 'Notes', fieldName: 'Notes', type: 'text', hideDefaultActions: true },
	{ label: 'Cost Code', fieldName: 'CostCode', type: 'text', hideDefaultActions: true },
	{ label: 'Vendor', fieldName: 'Vendor', type: 'text', hideDefaultActions: true },
	{
		label: 'Unit Cost', fieldName: 'UnitCost', type: 'currency',
		typeAttributes: { currencyCode: { fieldName: 'CurrencyIso' }, currencyDisplayAs: "code" }, cellAttributes: { alignment: 'left' }, hideDefaultActions: true
	},
	{
		label: 'List Price', fieldName: 'UnitPrice', type: 'currency',
		typeAttributes: { currencyCode: { fieldName: 'CurrencyIso' }, currencyDisplayAs: "code" }, cellAttributes: { alignment: 'left' }, hideDefaultActions: true
	}
];

const columnsForVendorsDataTable = [
	{ label: 'Pricebook', fieldName: 'PriceBookName', type: 'text', sortable: false, hideDefaultActions: true },
	{ label: 'Product Name', fieldName: 'Name', type: 'text', sortable: false, hideDefaultActions: true },
	{ label: 'Product Family', fieldName: 'Family', type: 'text', hideDefaultActions: true },
	{ label: 'Product Description', fieldName: 'Description', type: 'text', hideDefaultActions: true },
	{ label: 'Notes', fieldName: 'Notes', type: 'text', hideDefaultActions: true },
	{ label: 'Cost Code', fieldName: 'CostCode', type: 'text', hideDefaultActions: true },
	{ label: 'Vendor', fieldName: 'Vendor', type: 'text', hideDefaultActions: true },
	{
		label: 'Unit Cost', fieldName: 'UnitCost', type: 'currency',
		typeAttributes: { currencyCode: { fieldName: 'CurrencyIso' }, currencyDisplayAs: "code" }, cellAttributes: { alignment: 'left' }, hideDefaultActions: true
	},
	{
		label: 'List Price', fieldName: 'UnitPrice', type: 'currency',
		typeAttributes: { currencyCode: { fieldName: 'CurrencyIso' }, currencyDisplayAs: "code" }, cellAttributes: { alignment: 'left' }, hideDefaultActions: true
	}
];

const columnsForVendorList = [
	{ label: 'VENDOR NAME', fieldName: 'Name', type: 'text', sortable: false, hideDefaultActions: true },
];

export default class AddProductLwcCmp extends LightningElement {
    @api quoteId;
    showSpinner = false;
    isForVendorFlow = false;
    isComboScreen = true;
    isPriceBookSelected = false;
    isVendorSelected = false;
    isVendorSelectionScreen = false;
    isProductSelectedFromPricebook = false;
    isBackForPricebook = false;
    isBackForVendor = false;
    btnName = 'Next';
    btnValue = 'Next';
    btnNameVendorFlow = 'Next';
    btnValueVendorFlow = 'Next';
    columns = columns;
    columnsForVendorList = columnsForVendorList;
    columnsForVendorsDataTable = columnsForVendorsDataTable;
    priceBookValue = '';
    productFamilyValue;
    @api productFamilyFromParent;
    pickerValue = 'pricebook';
    filteredData = [];
    filteredData2 = [];
    data = [];
    quoteLineGroupList = [];
    noGroupingObj = {};
    pricebookOptions = [];
    productFamilyOptions = [];
    vendorList = [];
    vendorId;
    @track selectedQuoteLineRecords = [];
    heading_title = 'Choose Filter';

    @wire(fetchQuoteLineGroupList)
    wiredQuoteLineGroup({ error, data }) {
        if (data) {
            data.forEach(ele => {
                let obj = {};
                obj.id = ele.Id;
                obj.title = ele.Name;
                obj.subtitle = 'Grouping';
                if (ele.Name == 'No Grouping') {
                    this.noGroupingObj = obj;
                }
                this.quoteLineGroupList.push(obj);
            });
            console.log('check your grouping here ',JSON.parse(JSON.stringify(this.quoteLineGroupList)));
            this.error = undefined;
        } else if (error) {
            console.log('check your error here ',JSON.parse(JSON.stringify(error)));
            this.error = error;
            this.quoteLineGroupList = undefined;
        }
    }

    get options() {
        return [
            { label: 'PriceBook', value: 'pricebook' },
            { label: 'Vendor', value: 'vendor' },
        ];
    }

    connectedCallback() {
		loadStyle(this, myResource);
        console.log('check your productFamilyFromParent ',this.productFamilyFromParent);
        this.productFamilyValue = this.productFamilyFromParent || '-- All Product Family --';
	}

    handleChangeInPicker(event) {
        this.pickerValue = event.detail.value;
    }

    handlePricebookChangeForVendor(event){
        console.log('calling handlePricebookChangeForVendor');
        this.priceBookValue = event.detail.value;
        this.productFamilyValue = '-- All Product Family --';
        this.filteredData3 = [];
        let searchKey = event.target.value;
		searchKey = searchKey.toLowerCase();
        if (searchKey == '-- all pricebook --' || searchKey == '' || searchKey == undefined) {
			this.filteredData = this.data;
			return;
		}
        this.filteredData = this.data.filter(ele => {
            return ele.PriceBookName?.toLowerCase().includes(searchKey);
        });
        this.filteredData2 = this.filteredData;
    }

    handleProductFamilyChangeForVendor(event){
        try {
            this.productFamilyValue = event.detail.value;
            let searchKey = event.target.value
            searchKey = searchKey.toLowerCase();

            if (this.priceBookValue?.toLowerCase() === '-- all pricebook --' || this.priceBookValue == '' || this.priceBookValue == undefined) {
                if (searchKey == '-- all product family --' || searchKey == '' || searchKey == undefined) {
                    this.filteredData = this.data;
                    this.filteredData3 = [];
                } else {
                    this.filteredData = this.data.filter(ele => {
                        return ele.Family?.toLowerCase().includes(searchKey);
                    });
                    this.filteredData3 = this.filteredData;
                }
                return;
            }

            if (searchKey == '-- all product family --' || searchKey == '' || searchKey == undefined) {
                this.filteredData = this.filteredData2;
                this.filteredData3 = this.filteredData;
                return;
            }

            this.filteredData = this.filteredData2.filter(ele => {
                return ele.Family?.toLowerCase().includes(searchKey);
            });
            this.filteredData3 = this.filteredData;

        } catch (error) {
            console.log('error ',error);
        }
    }

    handleProductNameSearchForVendor(event){
        console.log('calling handleProductNameSearchForVendor');
        let searchKey = event.target.value
        searchKey = searchKey.toLowerCase();

        if (searchKey == '') {
            if (this.filteredData3?.length > 0) {
                this.filteredData = this.filteredData3;
                return;
            }else if (this.filteredData2?.length > 0) {
                this.filteredData = this.filteredData2;
                return;
            }
            this.filteredData = this.data;
            return;
        }
        this.filteredData = this.filteredData.filter(ele => {
            return ele.Name?.toLowerCase().includes(searchKey);
        });
    }

    async handlePricebookChange(event) {
        try {
            this.showSpinner = true;
            this.priceBookValue = event.detail.value;
            this.productFamilyValue = '-- All Product Family --';
            await this.callApexForProdcutFamilyList();
            this.showSpinner = false;
        } catch (error) {
            console.log('error ',error);
        }
    }

    handleProductFamilyChange(event) {
        this.productFamilyValue = event.detail.value;
        let searchKey = event.target.value
		searchKey = searchKey.toLowerCase();
		if (searchKey == '-- all product family --' || searchKey == '' || searchKey == undefined) {
			this.filteredData = this.data;
			return;
		}
        this.filteredData = this.data.filter(ele => {
            return ele.Family?.toLowerCase().includes(searchKey);
        });
        this.filteredData2 = this.filteredData;
    }

    async goToNextScreen(){
        console.log('calling goToNextScreen', JSON.stringify(this.pickerValue));
        this.showSpinner = true;

        if (this.btnValue === 'Next') {
            this.isComboScreen = false;
            if (this.pickerValue === 'pricebook') {
                this.template.querySelector('.customWidth').classList.add('myCustomStyle');
                await this.callApexForPricebookList();
                await this.callApexForProdcutFamilyList();
                this.heading_title = 'Products';
                this.filterProducts();
                this.isPriceBookSelected = true;
            } else if(this.pickerValue === 'vendor') {
                await this.callApexForVendorsList();
                this.heading_title = 'Vendors';
                this.isForVendorFlow = true;
                this.isVendorSelectionScreen = true;
            }
            this.btnName = 'Next';
            this.btnValue = 'Edit';
			this.showSpinner = false;
        } else if (this.btnValue === 'Edit') {
            this.doEditOperationForPriceBook();
			this.showSpinner = false;
        } else if (this.btnValue === 'Save') {
            if (this.selectedQuoteLineRecords?.length == 0) {
                this.showSpinner = false;
				this.showToastMsg('Error', 'Please select at least one Product.', 'error');
				return;
			}
            console.log('check your selectedQuoteLineRecords here ',JSON.parse(JSON.stringify(this.selectedQuoteLineRecords)));
            await this.saveQuoteLineItems();
            this.showSpinner = false;
        }
    }

    filterProducts() {
        let searchKey = this.productFamilyValue;
        searchKey = searchKey.toLowerCase();
    
        let isExist = this.productFamilyOptions.find(ele => ele.value.toLowerCase() === searchKey);
    
        if (!isExist) {
            searchKey = '-- all product family --';
            this.productFamilyValue = '-- All Product Family --';
        }
    
        if (searchKey === '-- all product family --' || searchKey === '' || searchKey === undefined) {
            this.filteredData = this.data;
            return;
        }
    
        this.filteredData = this.data.filter(ele => {
            return ele.Family?.toLowerCase().includes(searchKey);
        });
        this.filteredData2 = this.filteredData;
    }

    async goToNextScreenVendorFlow(){
        console.log('calling goToNextScreenForVendorFlow',this.productFamilyValue);
        this.showSpinner = true;
        if (this.btnValueVendorFlow === 'Next') {
            if (this.vendorId == undefined || this.vendorId == '') {
                this.showSpinner = false;
				this.showToastMsg('Error', 'Please select at least one Vendor.', 'error');
				return;
			}
            this.isVendorSelectionScreen = false;
            this.isVendorSelected = true;
            this.isBackForVendor = true;
            this.template.querySelector('.customWidth').classList.remove('myCustomStyle2');
            this.template.querySelector('.customWidth').classList.add('myCustomStyle');
            await this.callApexForProductsThroughVendorsList();
            this.btnValueVendorFlow = 'Edit';
            this.showSpinner = false;
        } else if (this.btnValueVendorFlow === 'Edit') {
            this.doEditOperationForVendor();
            this.showSpinner = false;
        } else if (this.btnValueVendorFlow === 'Save') {
            if (this.selectedQuoteLineRecords?.length == 0) {
                this.showSpinner = false;
				this.showToastMsg('Error', 'Please select at least one Product.', 'error');
				return;
			}
            await this.saveQuoteLineItems();
            this.showSpinner = false;
        }
        this.filterProductFamilyForVendor();
    }

    filterProductFamilyForVendor() {
        let searchKey = this.productFamilyValue.toLowerCase();

        let isExist = this.data.some(ele => ele.Family?.toLowerCase() === searchKey);

        if (!isExist) {
            searchKey = '-- all product family --';
            this.productFamilyValue = '-- All Product Family --';
        }

        if (!this.priceBookValue || this.priceBookValue.toLowerCase() === '-- all pricebook --') {
            if (searchKey === '-- all product family --') {
                this.filteredData = this.data;
            } else {
                this.filteredData = this.data.filter(ele => ele.Family?.toLowerCase().includes(searchKey));
            }
            this.filteredData3 = this.filteredData;
            return;
        }

        if (searchKey === '-- all product family --') {
            this.filteredData = this.filteredData2;
        } else {
            this.filteredData = this.filteredData2.filter(ele => ele.Family?.toLowerCase().includes(searchKey));
        }
        this.filteredData3 = this.filteredData;
    }    

    doEditOperationForPriceBook() {
        let selectedRecords = this.template.querySelector("lightning-datatable").getSelectedRows();
			let selectedQuoteLineRecords = [];
			if (selectedRecords?.length == 0) {
                this.showSpinner = false;
				this.showToastMsg('Error', 'Please select at least one Product.', 'error');
				return;
			}

			selectedRecords.forEach(row => {
                let listTopassInChild = [];
                let defaultGrouping = this.quoteLineGroupList.find(ele => ele.title == row.Family);
                if (defaultGrouping) {
                    listTopassInChild.push(defaultGrouping);
                } else{
                    listTopassInChild.push(this.noGroupingObj);
                }

				let obj = {};
				obj.Id = row.rowId;
				obj.Name = row.Name;
				obj.buildertek__Unit_Price__c = row.UnitPrice;
				obj.buildertek__Unit_Cost__c = row.UnitCost ? row.UnitCost : row.UnitPrice;
				obj.buildertek__Grouping__c = defaultGrouping ? defaultGrouping.id : this.noGroupingObj.id;
				obj.buildertek__Additional_Discount__c = row.Discount ? row.Discount : 0;
				obj.buildertek__Cost_Code__c = row.CostCode;
				obj.buildertek__Margin__c = row.Margin ? row.Margin : 0;
				obj.buildertek__Markup__c = row.MarkUp ? row.MarkUp : 0;
				obj.buildertek__Product__c = row.Id;
				obj.buildertek__Quantity__c = 1;
				obj.buildertek__Size__c = row.Size;
				obj.buildertek__Description__c = row.Description ? row.Description : row.Name;
				obj.buildertek__Product_Family__c = row.Family ? row.Family : 'No Grouping';
				obj.buildertek__Notes__c = row.Notes;
				obj.buildertek__UOM__c = row.QuantityUnitOfMeasure;
                obj.groupingValue = listTopassInChild;
				selectedQuoteLineRecords.push(obj);
			});

        this.selectedQuoteLineRecords = [...selectedQuoteLineRecords]
        this.isPriceBookSelected = false;
        this.isVendorSelected = false;
        this.removeClasses();
        this.isProductSelectedFromPricebook = true;
        this.isBackForPricebook = true;
        this.heading_title = 'Edit Selected Quote Line Items';
        this.btnName = 'Save';
        this.btnValue = 'Save';
        this.btnNameVendorFlow = 'Save';
        this.btnValueVendorFlow = 'Save';
    }

    doEditOperationForVendor() {
        let selectedRecords = this.template.querySelector("lightning-datatable").getSelectedRows();
			let selectedQuoteLineRecords = [];
			if (selectedRecords?.length == 0) {
                this.showSpinner = false;
				this.showToastMsg('Error', 'Please select at least one Product.', 'error');
				return;
			}

			selectedRecords.forEach(row => {
                let listTopassInChild = [];
                let defaultGrouping = this.quoteLineGroupList.find(ele => ele.title == row.Family);
                if (defaultGrouping) {
                    listTopassInChild.push(defaultGrouping);
                } else{
                    listTopassInChild.push(this.noGroupingObj);
                }

				let obj = {};
				obj.Id = row.rowId;
				obj.Name = row.Name;
				obj.buildertek__Unit_Price__c = row.UnitPrice;
				obj.buildertek__Unit_Cost__c = row.UnitCost ? row.UnitCost : row.UnitPrice;
				obj.buildertek__Grouping__c = defaultGrouping ? defaultGrouping.id : this.noGroupingObj.id;
				obj.buildertek__Additional_Discount__c = row.Discount ? row.Discount : 0;
				obj.buildertek__Cost_Code__c = row.CostCode;
				obj.buildertek__Margin__c = row.Margin ? row.Margin : 0;
				obj.buildertek__Markup__c = row.MarkUp ? row.MarkUp : 0;
				obj.buildertek__Product__c = row.Id;
				obj.buildertek__Quantity__c = 1;
				obj.buildertek__Size__c = row.Size;
				obj.buildertek__Description__c = row.Description ? row.Description : row.Name;
				obj.buildertek__Product_Family__c = row.Family ? row.Family : 'No Grouping';
				obj.buildertek__Notes__c = row.Notes;
				obj.buildertek__UOM__c = row.QuantityUnitOfMeasure;
                obj.groupingValue = listTopassInChild;
				selectedQuoteLineRecords.push(obj);
			});

        this.selectedQuoteLineRecords = [...selectedQuoteLineRecords]
        this.isPriceBookSelected = false;
        this.isVendorSelected = false;
        this.removeClasses();
        this.isProductSelectedFromPricebook = true;
        this.heading_title = 'Edit Selected Quote Line Items';
        this.btnName = 'Save';
        this.btnValue = 'Save';
        this.btnNameVendorFlow = 'Save';
        this.btnValueVendorFlow = 'Save';
    }

    removeQuoteLine(event){
        try {
            console.log('calling removeQuoteLine');
            let rowId =  event.target.dataset;
            for (let i = 0; i < this.selectedQuoteLineRecords.length; i++) {
                let ele = this.selectedQuoteLineRecords[i];
                if (ele.Id == rowId.id) {
                    this.selectedQuoteLineRecords.splice(i, 1);
                    break;
                }
            }
        } catch (error) {
            console.log('error ',error);
        }
    }

    hideModalBox() {
        this.dispatchEvent(new CustomEvent('closechildscreen', { detail: { refresh: false } }));
    }

    goBackToPriceBookDatatable(){
        this.isPriceBookSelected = true;
        this.isVendorSelected = false;
        this.isProductSelectedFromPricebook = false;
        this.isBackForPricebook = false;
        this.heading_title = 'Products';
        this.btnName = 'Next';
        this.btnValue = 'Edit';
        this.addClasses();
    }

    goBackToVendorDatatable(){
        console.log('calling goBackToVendorDatatable');
        if (this.btnValueVendorFlow === 'Edit') {
            this.removeClasses();
            this.template.querySelector('.customWidth').classList.remove('myCustomStyle');
            this.template.querySelector('.customWidth').classList.add('myCustomStyle2');
            this.isVendorSelectionScreen = true;
            this.isVendorSelected = false;
            this.isProductSelectedFromPricebook = false;
            this.isBackForVendor = false;
            this.heading_title = 'Vendors';
            this.btnNameVendorFlow = 'Next';
            this.btnValueVendorFlow = 'Next';
            this.vendorId = undefined;
        } else if (this.btnValueVendorFlow === 'Save') {
            this.addClasses();
            this.isVendorSelectionScreen = false;
            this.isVendorSelected = true;
            this.isProductSelectedFromPricebook = false;
            this.isBackForVendor = true;
            this.heading_title = 'Products';
            this.btnNameVendorFlow = 'Next';
            this.btnValueVendorFlow = 'Edit';
        }
        this.callApexForVendorsList();
        this.productFamilyValue = this.productFamilyFromParent || '-- All Product Family --';
    }

    handleSelected(event) {
		let rowId =  event.target.dataset;
		let selectedGrouping = event.detail;
		for (let i = 0; i < this.selectedQuoteLineRecords.length; i++) {
			let ele = this.selectedQuoteLineRecords[i];
			if (ele.Id == rowId.id) {
				ele.buildertek__Grouping__c = selectedGrouping.length > 0 ? selectedGrouping[0].id : null;
				break;
			}
		}
	}

    handleInputChange(event) {
		const { id, field } = event.target.dataset;
		const value = event.target.value;
		const updatedItem = this.selectedQuoteLineRecords.find(item => item.Id === id);
		if (updatedItem) {
			updatedItem[field] = value;
		}
    }

    handleKeyUp(evt) {
		let searchKey = evt.target.value
		searchKey = searchKey.toLowerCase();

		if (searchKey == '' && this.productFamilyValue != '-- All Product Family --' && this.productFamilyValue != '') {
			this.filteredData = this.filteredData2;
			return;
		} else if(searchKey == '') {
            this.filteredData = this.data;
            return;
        }

		if (evt.target.name == 'enter-name') {
            if (this.productFamilyValue != '-- All Product Family --' && this.productFamilyValue != '') {
                this.filteredData = this.filteredData2.filter(ele => {
                    return ele.Name?.toLowerCase().includes(searchKey);
                });
            } else {
                this.filteredData = this.data.filter(ele => {
                    return ele.Name?.toLowerCase().includes(searchKey);
                });
            }
		} else if (evt.target.name == 'enter-Vendor') {
            if (this.productFamilyValue != '-- All Product Family --' && this.productFamilyValue != '') {
                this.filteredData = this.filteredData2.filter(ele => {
                    return ele.Vendor?.toLowerCase().includes(searchKey);
                });
            } else {
                this.filteredData = this.data.filter(ele => {
                    return ele.Vendor?.toLowerCase().includes(searchKey);
                });
            }
		}
	}

    removeClasses() {
        const modalContent = this.template.querySelector('.myCls');
        if (modalContent) {
            modalContent.classList.remove('slds-p-around_medium');
        }
    }

    addClasses() {
        const modalContent = this.template.querySelector('.myCls');
        if (modalContent) {
            modalContent.classList.add('slds-p-around_medium');
        }
    }

    // vendor datatable single record selection logic
    handleRowSelection = event => {
        try {
            var selectedRows = event.detail.selectedRows;
            if (selectedRows.length == 0) {
                this.vendorId = '';
                return;
            }
            console.log(' selectedRows ',JSON.parse(JSON.stringify(selectedRows)));
            if (selectedRows.length > 1) {
                var el = this.template.querySelector('lightning-datatable');
                this.vendorId = selectedRows[1].Id;
                selectedRows = el.selectedRows = el.selectedRows.slice(1);
                event.preventDefault();
                // Need to get vendorId from the datatable
                return;
            }
            this.vendorId = selectedRows[0].Id;
        } catch (error) {
            console.log('error in handle Row selection ',error);
        }
    }

    //handle search in vendorList screen
    handleKeyUpForVendors(evt){
        console.log('calling handleKeyUpForVendors');
        let searchKey = evt.target.value
		searchKey = searchKey.toLowerCase();

		if (searchKey == ''){
            this.vendorList = this.data;
            const dataTable = this.template.querySelector('lightning-datatable');
            if (dataTable) {
                dataTable.selectedRows = [];
            }
            this.vendorId = null;
            return;
        }

        this.vendorList = this.data.filter(ele => {
            return ele.Name?.toLowerCase().includes(searchKey);
        });
    }

    // apex callouts
    async callApexForPricebookList() {
        try {
            const result = await fetchPricebookList({ recordId: this.quoteId });
            console.log('result', JSON.stringify(result));
            this.priceBookValue = result[0]?.defaultValue.Id;
            this.pricebookOptions = result[0]?.priceWrapList.map(item => ({ label: item.Name, value: item.Id }));
            this.isShowMargin = result[0]?.showmargin;

        } catch (error) {
            console.log('error in callApexForPricebookList ', {error});
            let { errorMessage, errorObject} = this.returnErrorMsg(error);
            this.showToastMsg('Error', errorMessage, 'error');
        }
    }

    async callApexForProdcutFamilyList() {
        try {
            let priceBookId = this.priceBookValue;
            const result = await fetchProductFamilyList({ pbookId: priceBookId });
            result.unshift('-- All Product Family --');
            console.log('result', JSON.stringify(result));
            this.productFamilyOptions = result.map(item => ({ label: item, value: item }));
            await this.callApexForTableDataList();
        } catch (error) {
            console.log('error in callApexForProdcutFamilyList ', {error});
            let { errorMessage, errorObject} = this.returnErrorMsg(error);
            this.showToastMsg('Error', errorMessage, 'error');
        }
    }

    async callApexForTableDataList() {
        try {
            let priceBookId = this.priceBookValue;
            const result = await fetchTableDataList({ pbookId: priceBookId });
            console.log('result', JSON.stringify(result));
            this.data = result;
            this.filteredData = result;

        } catch (error) {
            console.log('error in callApexForTableDataList ', {error});
            let { errorMessage, errorObject} = this.returnErrorMsg(error);
            this.showToastMsg('Error', errorMessage, 'error');
        }
    }

    async callApexForVendorsList() {
        try {
            const result = await fetchVendorsList({});
            console.log('result', JSON.stringify(result));
            this.vendorList = result.vendorList;
            this.data = result.vendorList;

        } catch (error) {
            console.log('error in callApexForVendorsList ', {error});
            let { errorMessage, errorObject} = this.returnErrorMsg(error);
            this.showToastMsg('Error', errorMessage, 'error');
        }
    }

    async callApexForProductsThroughVendorsList() {
        try {
            console.log('check your vendor id ', JSON.parse(JSON.stringify(this.vendorId)));
            const result = await fetchProductsThroughVendorList({ vendorId: this.vendorId});
            console.log('result', JSON.stringify(result));
            let pricebookSet = new Set();
            result.forEach(element => {
                if (element.PriceBookName != undefined && element.PriceBookName != '') {
                    pricebookSet.add(element.PriceBookName);
                }
            });

            this.pricebookOptions = pricebookSet.size > 0 ? Array.from(pricebookSet).map(item => ({ label: item, value: item })) : [];
            this.pricebookOptions.unshift({ label: '-- All PriceBook --', value: '-- All PriceBook --' });
            this.priceBookValue = '-- All PriceBook --';

            let productFamilySet = new Set();
            result.forEach(element => {
                if (element.Family != undefined && element.Family != '') {
                    productFamilySet.add(element.Family);
                }
            });

            this.productFamilyOptions = productFamilySet.size > 0 ? Array.from(productFamilySet).map(item => ({ label: item, value: item })) : [];
            this.productFamilyOptions.unshift({ label: '-- All Product Family --', value: '-- All Product Family --' });
            this.productFamilyValue = this.productFamilyValue || '-- All Product Family --';

            this.filteredData = result;
            this.data = result;

        } catch (error) {
            console.log('error in callApexForProductsThroughVendorsList ', {error});
            let { errorMessage, errorObject} = this.returnErrorMsg(error);
            this.showToastMsg('Error', errorMessage, 'error');
        }
    }

    async saveQuoteLineItems() {
        try {
            let quoteLineItems = this.selectedQuoteLineRecords;
            let quoteId = this.quoteId;
            let result = await performDMLForQuoteLine({ Quotelines: quoteLineItems, QuoteId: quoteId });
            console.log('result', JSON.parse(JSON.stringify(result)));
            this.showToastMsg('Success', 'Quote Line Items saved successfully.', 'success');
            this.dispatchEvent(new CustomEvent('closechildscreen', { detail: { refresh: true } }));
        } catch (error) {
            console.log('error in saveQuoteLineItems ', {error});
            let { errorMessage, errorObject} = this.returnErrorMsg(error);
            this.showToastMsg('Error', errorMessage, 'error');
        }
    }

    showToastMsg(title, message, variant) {
		this.dispatchEvent(
			new ShowToastEvent({
				title: title,
				message: message,
				variant: variant
			})
		);
	}

    returnErrorMsg(error) {
        // console.error('An error occurred:', error);
    
        let errorMessage = 'Unknown error';
        if (error && error.body) {
            if (error.body.message) {
                errorMessage = error.body.message;
            } else if (error.body.pageErrors && error.body.pageErrors.length > 0) {
                errorMessage = error.body.pageErrors[0].message;
            }
        } else if (error && error.message) {
            errorMessage = error.message;
        }
    
        return { errorMessage, errorObject: error };
    }
}