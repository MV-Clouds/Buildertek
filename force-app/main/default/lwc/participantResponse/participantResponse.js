import { LightningElement,track, wire, api} from 'lwc';
//import updateParticipant from '@salesforce/apex/ParticipantResponseController.updateParticipant';

export default class ParticipantResponse extends LightningElement {

    @api YesNoOptions=[{label:'Yes',value:'Yes'},
    {label:'No',value:'No'}];

    @track recordId='';
    @track response='';

    connectedCallback(){
        let params = (new URL(document.location)).searchParams;
        let recId = params.get('Id'); 
        this.recordId = recId;
        alert(this.recordId);
    }
    
}