import { LightningElement, track, wire, api } from 'lwc';
import getFolderList from "@salesforce/apex/PublicFileShareController.getFolderList";
import createPublicFolder from "@salesforce/apex/PublicFileShareController.createPublicFolder";
import ConfirmationPageSiteURL from "@salesforce/apex/PublicFileShareController.ConfirmationPageSiteUR";
import deleteFolder from "@salesforce/apex/PublicFileShareController.deleteFolder";
import {NavigationMixin} from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateFolder from "@salesforce/apex/PublicFileShareController.updateFolder";

export default class PublicFileShareLWC extends NavigationMixin(LightningElement) {

    @api recordId; // Passed record ID
    @track spinnerDataTable = true;
    @track folderData = [];
    @track selectedFolder = '';
    @track showManageFolder = false;
    @track showFolderTable = false;

    @track folderforEdit = {
        Id : '',
        Name : '',
        Description : ''}
    @track showdeleteFolderPopup = false;
    @track showEditFolderPopup = false;
    @track showNewFolderPopup = false;
    @track newFolderName = '';
    @track newFolderDescription = '';
    @track FileSiteURL = '';
    @track deleteFolderId = '';
    connectedCallback() {
        try {
            this.getFolderDataFromApex();
            this.getConfirmationPageSiteURLfromAPEX();            
        } catch (error) {
            console.error(error);
        }
    }

    getFolderDataFromApex(){
        getFolderList({ currentId : this.recordId })
            .then((response) =>{
                console.log("FolderData:- ",response);
                this.folderData = response;
                if(this.folderData.length > 0){
                    this.showFolderTable = true;
                } else {
                    this.showFolderTable = false;
                }
                this.spinnerDataTable = false
            });
    }

    getConfirmationPageSiteURLfromAPEX(){
        ConfirmationPageSiteURL()
        .then(result => {
            if(result != null){
                this.FileSiteURL = result;
            }
        })
    }
    handleNewFolder(event){
        this.showNewFolderPopup = true;
    }

    handleNameChange(event) {
        this.newFolderName = event.target.value;
        this.folderforEdit.Name = event.target.value;
    }

    handleDescriptionChange(event) {
        this.newFolderDescription = event.target.value;
        this.folderforEdit.Description = event.target.value;
    }

    createFolder(){
        console.log('newFolderName :- ',this.newFolderName);
        this.newFolderName = this.newFolderName.replace(/^\s+/g, '');
            if(this.newFolderName == null || this.newFolderName == ' ' || this.newFolderName == ''){
                // this.template.querySelector('c-toast-component').showToast('error', 'Name is Required, Please Fill the Name', 3000);
                this.showToast('error', 'Name is Required, Please Fill the Name', 'Uh oh, something went wrong');
            }
            else{
                this.spinnerDataTable = true
                this.showNewFolderPopup = false
                createPublicFolder({ Fname : this.newFolderName, Fdesc : this.newFolderDescription, currentId : this.recordId })
                .then((response) =>{
                    console.log('Response for create folder :- ',response);
                    this.newFolderName = null;
                    this.newFolderDescription = null;
                    this.getFolderDataFromApex()
                    // this.template.querySelector('c-toast-component').showToast('success', 'New Folder Created Successfully', 3000);
                    this.showToast('success', 'New Folder Created Successfully', 'Success!');
                    this.spinnerDataTable = false
                })
            }
    }

    manageFolder(event){
        let folderId = event.currentTarget.dataset.id;
        this.selectedFolder = folderId;
        this.showManageFolder = true;
    }

    closeManageFolder(){
        this.showManageFolder = false;
    }

    closeCreateFolder(){
        this.showNewFolderPopup = false;
    }

    copySiteURL(event){
        try {

            var copy_to_clipboad = this.FileSiteURL + 'apex/buildertek__DisplayPublicFolderPage?Id='+ event.currentTarget.dataset.link;

            const textarea = document.createElement('textarea');
            textarea.value = copy_to_clipboad;
            document.body.appendChild(textarea);                
            textarea.select();
            textarea.setSelectionRange(0,99999); // for mobile devices;
            document.execCommand('copy');
            document.body.removeChild(textarea);   

            // Display Copied Info Popup
            const copyInfoPopup = this.template.querySelector(`[data-id="${event.currentTarget.dataset.link}"]`);
            copyInfoPopup.style = 'display : block';
            copyInfoPopup.classList.add('showPopup');
            setTimeout(() => {
                copyInfoPopup.classList.remove('showPopup')
                copyInfoPopup.style = '';
            }, 1000);

        } catch (error) {
            console.log('error in copySiteURL :> ', error.stack);
            
        }
    }

    showToast(Variant , Message, Title) {
        const event = new ShowToastEvent({
            title: Title,
            message: Message,
            variant: Variant
        });
        this.dispatchEvent(event);
    }

    Handle_DeleteFolder(event){
        this.showdeleteFolderPopup = true;
        console.log('record to delete:- ',event.currentTarget.dataset.key);
        this.deleteFolderId = event.currentTarget.dataset.key;
    }
    
    deletefolder(){
        this.spinnerDataTable = true
        this.showdeleteFolderPopup = false;
        deleteFolder({publicFolderId : this.deleteFolderId})
        .then((response) =>{
            console.log("FolderData:- ",response);
            if(response == 'Success'){
                this.getFolderDataFromApex()
                this.showToast('success', 'Folder has been Deleted Successfully', 'Success!');
            } else {
                this.showToast('error', 'Folder has not been Deleted', 'Something Went Wrong!');
            }
            this.spinnerDataTable = false
        });
        
    }

    closedeleteModal(){
        this.showdeleteFolderPopup = false;
    }

    editFolder(event){
        console.log('record to edit:- ',event.currentTarget.dataset.key);
        this.showEditFolderPopup = true;
        this.folderData.forEach(element => {
            if(element.Id == event.currentTarget.dataset.key){
                console.log('element :- ',element);
                this.folderforEdit.Id = element.Id;
                this.folderforEdit.Name = element.Name;
                this.folderforEdit.Description = element.buildertek__Description__c;
            }
            console.log('folderforEdit :- ',this.folderforEdit);
        });
    }

    saveFolderChanges(event){
        console.log('test saveFolderChanges');
        this.spinnerDataTable = true
        updateFolder({publicFolderId : this.folderforEdit.Id, folderName : this.folderforEdit.Name, folderDesc : this.folderforEdit.Description})
        .then((response) =>{
            console.log("FolderData:- ",response);
            if(response == 'Success'){
                //iterate in folderdata and update the name and description
                this.folderData.forEach(element => {
                    if(element.Id == this.folderforEdit.Id){
                        element.Name = this.folderforEdit.Name;
                        element.buildertek__Description__c = this.folderforEdit.Description;
                    }
                });
                console.log('folderData :- ',this.folderData);
                this.showToast('success', 'Folder has been Updated Successfully', 'Success!');
            } else {
                this.showToast('error', 'Folder has not been Updated', 'Something Went Wrong!');
            }
            this.spinnerDataTable = false
        });
        
        this.showEditFolderPopup = false;
    }

    closeEditFolder(){
        this.showEditFolderPopup = false;
    }

}