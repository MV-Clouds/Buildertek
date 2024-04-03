import { LightningElement, api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getDataForDataTable from "@salesforce/apex/fileUploadAndRenameController.getDataForDataTable";
import { CloseActionScreenEvent } from "lightning/actions";
import { loadStyle } from 'lightning/platformResourceLoader';
import CustomDatatableResource from '@salesforce/resourceUrl/CustomDatatable'


const COLUMNS = [
    { label: 'Title', initialWidth: 500, fieldName: 'title', editable: true, hideDefaultActions: true },
    { label: 'Image', fieldName: 'image', type: 'customImage', hideDefaultActions: true },
];

export default class FileUploadAndRename extends LightningElement {
    columns = COLUMNS;
    loaded = false;
    @track isFirstPage = true;
    @track isFileNotUpload = true;
    @track label = 'Next';
    @track fileList;
    @api recordId;
    @track files = [];
    @api thumbnail;
    @track documentIds = [];
    saveDraftValues = [];
    rowOffset = 0;
    hasLoadedStyle = false;

    get acceptedFormats() {
        return [".heic", ".png", ".jpg", ".jpeg"];
    }

    renderedCallback() {

        if (!this.hasLoadedStyle) {
            this.hasLoadedStyle = true;
            Promise.all([
                loadStyle(this, CustomDatatableResource),
            ]).then(() => { })
        }
    }

    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        console.log('uploaded Files ', { uploadedFiles });
        // this.files = uploadedFiles;
        this.isFileNotUpload = false;
        let documentIds = [];
        for (let i = 0; i < uploadedFiles.length; i++) {
            console.log('documentId ', uploadedFiles[i].documentId);
            documentIds.push(uploadedFiles[i].documentId);
        }
        console.log('documentIds ', documentIds);
        this.documentIds = [...documentIds];
        console.log('this.documentIds ', JSON.parse(JSON.stringify(this.documentIds)));
        this.dispatchEvent(
            new ShowToastEvent({
                title: "Success!",
                message: uploadedFiles.length + " Files Uploaded Successfully.",
                variant: "success"
            })
        );
    }

    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    nextPage() {
        try {
            if (this.label != 'Save') {
                this.isFirstPage = false;
                this.label = 'Save';
                getDataForDataTable({ contentDocumentIds: this.documentIds })
                    .then(result => {
                        console.log('result ', result);
                        this.files = result;
                    })
                    .catch(error => {
                        console.log('error ', error);
                    })
            } else {
                let draftValues = this.template.querySelector('lightning-datatable').draftValues;
                console.log('draftValues ', draftValues);
            }
        } catch (error) {
            console.log('error ',error);
        }
    }

    handleSave(event) {
        console.log('handleSave is calling ');
        this.saveDraftValues = event.detail.draftValues;
    }
}