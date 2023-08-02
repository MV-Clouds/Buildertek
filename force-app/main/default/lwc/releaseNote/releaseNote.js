import { LightningElement } from 'lwc';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import PDF_Resource from '@salesforce/resourceUrl/Releasenote';

export default class ReleaseNote extends LightningElement {
    pdfUrl;

    connectedCallback() {
        this.pdfUrl = PDF_Resource;
    }
}