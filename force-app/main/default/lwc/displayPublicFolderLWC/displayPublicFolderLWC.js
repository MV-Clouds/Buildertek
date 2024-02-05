import { LightningElement, api, track } from 'lwc';
import getDataFromFolder from '@salesforce/apex/displayPublicFolderCls.getDataFromFolder';
import getDisplayImageData from '@salesforce/apex/displayPublicFolderCls.getDisplayImageData';

export default class DisplayPublicFolderLWC extends LightningElement {
    @api folderId;

    @track showspinner = false;
    @track folderWrap = {};
    @track folderDetails = {};
    @track noFiles = false;
    @track listFiles = [];
    @track InitialLoad = true;
    @track siteUrl;
    @track documentId;
    @track orgId;
    @track width;
    @track height;
    
    get imageUrl() {
            return `${this.siteUrl}/servlet/servlet.ImageServer?id=${this.documentId}&oid=${this.orgId}`;
        }
    connectedCallback() {
        this.fetchFolderData();
        getDisplayImageData()
            .then(result => {
                console.log('Result ==> ', result);
                this.width = result.width;
                this.height = result.height;
                this.siteUrl = result.siteUrl;
                this.documentId = result.documentId;
                this.orgId = result.orgId;
            })
            .catch(error => {
                console.error('Error => ', error);
            });
    }

    fetchFolderData() {
        console.log('folderId ==> ' + this.folderId);
        this.showspinner = true;

        getDataFromFolder({
            recId: this.folderId
        })
            .then(result => {
                console.log('Result ==> ', result);
                this.folderWrap = result;
                this.folderDetails = result.publicFolder;
                let fileDetails = result.fileWrapperList;

                let fileWrapperList = [];
                let fileWrapper = {};
                for (let i = 0; i < fileDetails.length; i++) {
                    fileWrapper = {};
                    fileWrapper.fileName = fileDetails[i].publicFile.buildertek__File_Name__c;
                    fileWrapper.fileId = fileDetails[i].publicFile.Id;
                    fileWrapper.fileType = fileDetails[i].cv.FileType;
                    // fileWrapper.fileSize = Math.round(fileDetails[i].cv.ContentSize/1024) + ' KB';
                    if (fileDetails[i].cv.ContentSize < 1024) {
                        fileWrapper.fileSize = fileDetails[i].cv.ContentSize + ' B';
                    } else if (fileDetails[i].cv.ContentSize >= 1024 && fileDetails[i].cv.ContentSize < 1048576) {
                        fileWrapper.fileSize = Math.round(fileDetails[i].cv.ContentSize / 1024) + ' KB';
                    } else if (fileDetails[i].cv.ContentSize >= 1048576 && fileDetails[i].cv.ContentSize < 1073741824) {
                        fileWrapper.fileSize = Math.round(fileDetails[i].cv.ContentSize / 1048576) + ' MB';
                    } else if (fileDetails[i].cv.ContentSize >= 1073741824) {
                        fileWrapper.fileSize = Math.round(fileDetails[i].cv.ContentSize / 1073741824) + ' GB';
                    }
                    fileWrapper.fileCreatedDate = fileDetails[i].publicFile.CreatedDate.slice(0, 10);
                    fileWrapper.publicURL = fileDetails[i].publicFile.buildertek__Public_URL__c;
                    fileWrapperList.push(fileWrapper);
                }

                // console.log('fileWrapperList ==> ',fileWrapperList);

                this.listFiles = fileWrapperList;
                console.log('this.listFiles ==> ', JSON.stringify(this.listFiles));


                if (result.publicFolder.buildertek__File_Count__c == 0) {
                    this.noFiles = true;
                }

                this.showspinner = false;
            })
            .catch(error => {
                console.error('Error => ', error);
                this.showspinner = false;
                alert('Something Went Wrong.');
            });
    }

    renderedCallback() {
        if (this.InitialLoad) {
            const body = document.querySelector('body');
            if (body) {
                body.style = `overflow-y : hidden !important`
                this.InitialLoad = false;
            }
        }
    }

}