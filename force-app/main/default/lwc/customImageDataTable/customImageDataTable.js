import LightningDataTable from 'lightning/datatable';
import customImage from './customImage.html';


export default class CustomImageDataTable extends LightningDataTable {
    static customTypes = {
        customImage: {
            template: customImage,
            typeAttributes: ['title']
        }
    }
}