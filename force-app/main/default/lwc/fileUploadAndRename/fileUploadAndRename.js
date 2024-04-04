import { LightningElement, api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getDataForDataTable from "@salesforce/apex/fileUploadAndRenameController.getDataForDataTable";
import updateFileName from "@salesforce/apex/fileUploadAndRenameController.updateFileName";
import deleteFiles from "@salesforce/apex/fileUploadAndRenameController.deleteFiles";


const COLUMNS = [
    { label: 'Title', initialWidth: 300, fieldName: 'title', editable: true, hideDefaultActions: true },
    { label: 'Image', fieldName: 'image', type: 'customImage', hideDefaultActions: true },
];

export default class FileUploadAndRename extends LightningElement {
    columns = COLUMNS;
    loaded = false;
    deleteFiles = true;
    @track showDataTable = false;
    @track fileNotUpload = true;
    @api recordId;
    @track files = [];
    saveDraftValues = [];
    rowOffset = 0;
    hasLoadedStyle = false;

    get acceptedFormats() {
        return [".heic", ".png", ".jpg", ".jpeg", ".pdf", ".gif", ".doc", ".docx"];
    }

    handleUploadFinished(event) {
        this.showDataTable = true;
        this.fileNotUpload = false;
        const uploadedFiles = event.detail.files;

        let documentIds = [];
        for (let i = 0; i < uploadedFiles.length; i++) {
            documentIds.push(uploadedFiles[i].documentId);
        }

        getDataForDataTable({ contentDocumentIds: documentIds })
            .then(result => {
                this.files = result;
            })
            .catch(error => {
                console.log('error ', error);
            })
    }

    closeAction() {
        if (this.files.length > 0 && this.deleteFiles) {
            let docIds = [];

            this.files.forEach(file => {
                docIds.push(file.ContentDocumentId);
            });

            deleteFiles({ docIds: docIds, recordId: this.recordId})
                .then(result => {

                })
                .catch(error => {
                    console.log('error ', error);
                })
        }

        const closeEvent = new CustomEvent('closequickaction', {
            bubbles: true,
            composed: true,
            detail: { payload: 'Close Action Payload' }
        });

        this.dispatchEvent(closeEvent);
    }

    nextPage() {
        try {

            let draftValues = this.template.querySelector('c-custom-image-data-table').draftValues;
            for (let i = 0; i < draftValues.length; i++) {
                if (draftValues[i].title === '' || draftValues[i].title === null || draftValues[i].title === undefined) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Error!",
                            message: "Please Enter Title.",
                            variant: "error"
                        })
                    );
                    return;
                }
            }

            let updatedFiles = [];
            draftValues.forEach(row => {
                updatedFiles.push({
                    Id: row.id,
                    Title: row.title
                });
            });

            updateFileName({ listData: JSON.stringify(updatedFiles) })
                .then(result => {
                    this.deleteFiles = false;

                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Success!",
                            message: "Files Updated Successfully.",
                            variant: "success"
                        })
                    );

                    this.closeAction();
                })
                .catch(error => {
                    console.log('error ', error);
                })

        } catch (error) {
            console.log('error ', error);
        }
    }
}